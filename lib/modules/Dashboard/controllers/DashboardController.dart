import 'package:get/get.dart';
import '../../MainNav/controllers/MainNavController.dart';
import '../../../models/UserModel.dart';
import '../../../models/KycModel.dart';
import '../../../models/ClientMessageModel.dart';
import '../../../includes/Storage.dart';
import '../../../database/db_helper.dart';
import '../requests/DashboardRequest.dart';

/// MVC Controller for Dashboard Module
/// Connects DashboardView with DashboardRequest and synchronizes state with MainNavController.
class DashboardController extends GetxController {
  final DashboardRequest _dashboardRequest = DashboardRequest();

  final isLoading = false.obs;
  final clientName = 'Client'.obs;
  final clientAccountId = '# MV-CLIENT'.obs;
  final kycStatus = 'not_submitted'.obs;
  final isKycSubmitted = false.obs;
  final rejectionReason = Rx<String?>(null);
  final referenceId = Rx<String?>(null);
  final kycProfile = Rx<KycModel?>(null);

  // Dynamic Communications & Notifications
  final messages = <ClientMessageModel>[].obs;
  final isMessagesLoading = false.obs;
  final unreadNotificationsCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadCachedMessagesImmediately();
    _readCachedData();
    _bindWithMainNav();
    syncDashboard();
  }

  /// Instant Offline Load from SQLite
  Future<void> _loadCachedMessagesImmediately() async {
    try {
      final cached = await DBHelper().getMessages(limit: 20);
      if (cached.isNotEmpty) {
        messages.assignAll(cached);
      }
    } catch (_) {}
  }

  void _bindWithMainNav() {
    if (Get.isRegistered<MainNavController>()) {
      final mainNav = Get.find<MainNavController>();
      if (mainNav.isKycSubmitted.value) {
        isKycSubmitted.value = true;
        kycStatus.value = mainNav.kycStatus.value;
      }
      if (mainNav.kycProfile.value != null) {
        kycProfile.value = mainNav.kycProfile.value;
        referenceId.value = mainNav.kycProfile.value!.referenceId;
        rejectionReason.value = mainNav.kycProfile.value!.rejectionReason;
      }

      ever(mainNav.isKycSubmitted, (bool submitted) {
        isKycSubmitted.value = submitted;
      });
      ever(mainNav.kycStatus, (String status) {
        kycStatus.value = status;
      });
      ever(mainNav.kycProfile, (KycModel? profile) {
        kycProfile.value = profile;
        if (profile != null) {
          referenceId.value = profile.referenceId;
          rejectionReason.value = profile.rejectionReason;
        }
      });
    }
  }

  Future<void> syncDashboard() async {
    isLoading.value = true;

    // 1. Read cached state immediately
    _readCachedData();

    // 2. Fetch fresh profile & KYC from backend
    if (LocalStorage.hasToken()) {
      final profileRes = await _dashboardRequest.getProfile();
      if (profileRes.success && profileRes.data != null) {
        final user = profileRes.data!;
        clientName.value = user.name.isNotEmpty ? user.name : 'Client';
        clientAccountId.value = user.formattedAccountId;

        if (Get.isRegistered<MainNavController>()) {
          Get.find<MainNavController>().currentUser.value = user;
        }
      }

      final kycRes = await _dashboardRequest.getKyc();
      if (kycRes.success && kycRes.data != null) {
        final kyc = kycRes.data!;
        kycProfile.value = kyc;
        kycStatus.value = kyc.isVerified ? 'verified' : kyc.verificationStatus;
        rejectionReason.value = kyc.rejectionReason;
        referenceId.value = kyc.referenceId;
        isKycSubmitted.value = kyc.isPending || kyc.isVerified;

        // Persist fresh backend data
        await LocalStorage.write(LocalStorage.kycDataKey, kyc.toJsonString());
        await LocalStorage.write(
          MainNavController.kycSubmittedStorageKey,
          isKycSubmitted.value ? 'true' : 'false',
        );

        if (Get.isRegistered<MainNavController>()) {
          final mainNav = Get.find<MainNavController>();
          mainNav.kycProfile.value = kyc;
          mainNav.kycStatus.value = kyc.isVerified ? 'verified' : kyc.verificationStatus;
          mainNav.isKycSubmitted.value = isKycSubmitted.value;
        }
      }

      // 3. Fetch dynamic communications / messages (Quiet background sync if SQLite has data)
      if (messages.isEmpty) {
        isMessagesLoading.value = true;
      }
      final msgRes = await _dashboardRequest.getClientMessages();
      isMessagesLoading.value = false;
      if (msgRes.success && msgRes.data != null) {
        messages.assignAll(msgRes.data!);
        await DBHelper().saveMessages(msgRes.data!);
      }

      // 4. Fetch notifications & update unread count badge
      final notifRes = await _dashboardRequest.getNotifications();
      if (notifRes.success && notifRes.data != null) {
        final data = notifRes.data!;
        final unread = data['unread_count'];
        if (unread is num) {
          unreadNotificationsCount.value = unread.toInt();
        } else if (data['notifications'] is List) {
          final list = data['notifications'] as List;
          unreadNotificationsCount.value = list.where((n) {
            if (n is Map) {
              return n['is_read'] != true && n['read_at'] == null;
            }
            return false;
          }).length;
        }
      }
    }

    isLoading.value = false;
  }

  void _readCachedData() {
    final cachedUserJson = LocalStorage.read(LocalStorage.userProfileKey);
    if (cachedUserJson != null && cachedUserJson.isNotEmpty) {
      try {
        final user = UserModel.fromJsonString(cachedUserJson);
        clientName.value = user.name.isNotEmpty ? user.name : 'Client';
        clientAccountId.value = user.formattedAccountId;
      } catch (_) {}
    }

    final cachedKycJson = LocalStorage.read(LocalStorage.kycDataKey);
    if (cachedKycJson != null && cachedKycJson.isNotEmpty) {
      try {
        final kyc = KycModel.fromJsonString(cachedKycJson);
        kycProfile.value = kyc;
        kycStatus.value = kyc.isVerified ? 'verified' : kyc.verificationStatus;
        rejectionReason.value = kyc.rejectionReason;
        referenceId.value = kyc.referenceId;
        isKycSubmitted.value = kyc.isPending || kyc.isVerified;
      } catch (_) {}
    } else {
      kycProfile.value = null;
      kycStatus.value = 'not_submitted';
      isKycSubmitted.value = false;
      referenceId.value = null;
      rejectionReason.value = null;
    }

    // Check submission status flag for instant reflection
    final submittedFlag = LocalStorage.read(MainNavController.kycSubmittedStorageKey);
    if (submittedFlag == 'true') {
      isKycSubmitted.value = true;
      if (kycStatus.value == 'not_submitted') {
        kycStatus.value = 'pending';
      }
    } else if (submittedFlag == 'false') {
      isKycSubmitted.value = false;
    }

    // Read cached messages from local SQLite immediately
    DBHelper().getMessages(limit: 20).then((cachedMsgs) {
      if (cachedMsgs.isNotEmpty && messages.isEmpty) {
        messages.assignAll(cachedMsgs);
      }
    });
  }
}
