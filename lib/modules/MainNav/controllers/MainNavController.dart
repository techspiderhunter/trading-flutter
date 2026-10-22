import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../includes/Storage.dart';
import '../../Profile/requests/ProfileRequest.dart';
import '../../Kyc/requests/KycRequest.dart';
import '../../../models/UserModel.dart';
import '../../../models/KycModel.dart';

class NotificationItem {
  final String id;
  final String title;
  final String message;
  final String time;
  final String tag;
  final IconData icon;
  final Color tagColor;
  final Color iconBgColor;
  final bool isUnread;

  NotificationItem({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    required this.tag,
    required this.icon,
    required this.tagColor,
    required this.iconBgColor,
    this.isUnread = false,
  });
}

class SmsItem {
  final String id;
  final String sender;
  final String message;
  final String time;
  final String status;

  SmsItem({
    required this.id,
    required this.sender,
    required this.message,
    required this.time,
    required this.status,
  });
}

class MainNavController extends GetxController {
  static const String kycSubmittedStorageKey = 'kyc_submitted_status';
  final ProfileRequest _profileRequest = ProfileRequest();
  final KycRequest _kycRequest = KycRequest();

  // Tab index: 0 = Dashboard, 1 = Profile
  final currentIndex = 0.obs;

  // Active User & KYC State
  final currentUser = Rx<UserModel?>(null);
  final kycProfile = Rx<KycModel?>(null);
  final kycStatus = 'not_submitted'.obs; // not_submitted, pending, verified, rejected
  final isKycSubmitted = false.obs;

  // Static Notifications List (as instructed by user)
  final notifications = <NotificationItem>[].obs;

  // Static SMS Card List (as instructed by user)
  final smsList = <SmsItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    currentIndex.value = 0; // Strictly ensure default index is Dashboard
    _loadCachedState();
    _loadInitialNotifications();
    _loadInitialSms();
    syncUserAndKyc();
  }

  void changeTab(int index) {
    if (index >= 0 && index <= 1) {
      currentIndex.value = index;
    }
  }

  void _loadCachedState() {
    final cachedUserJson = LocalStorage.read(LocalStorage.userProfileKey);
    if (cachedUserJson != null && cachedUserJson.isNotEmpty) {
      try {
        currentUser.value = UserModel.fromJsonString(cachedUserJson);
      } catch (_) {}
    }

    final cachedKycJson = LocalStorage.read(LocalStorage.kycDataKey);
    if (cachedKycJson != null && cachedKycJson.isNotEmpty) {
      try {
        kycProfile.value = KycModel.fromJsonString(cachedKycJson);
        kycStatus.value = kycProfile.value!.isVerified ? 'verified' : kycProfile.value!.verificationStatus;
        isKycSubmitted.value = kycProfile.value!.isPending || kycProfile.value!.isVerified;
      } catch (_) {}
    } else {
      kycProfile.value = null;
      kycStatus.value = 'not_submitted';
      isKycSubmitted.value = false;
    }

    final localStatus = LocalStorage.read(kycSubmittedStorageKey);
    if (localStatus == 'true') {
      isKycSubmitted.value = true;
    } else if (localStatus == 'false') {
      isKycSubmitted.value = false;
    }
  }

  Future<void> syncUserAndKyc() async {
    if (!LocalStorage.hasToken()) return;

    // 1. Fetch user profile
    final profileRes = await _profileRequest.getProfile();
    if (profileRes.success && profileRes.data != null) {
      currentUser.value = profileRes.data;
    }

    // 2. Fetch KYC
    await syncKycStatus();
  }

  Future<void> syncKycStatus() async {
    if (!LocalStorage.hasToken()) return;

    final kycRes = await _kycRequest.getKyc();
    if (kycRes.success && kycRes.data != null) {
      final kyc = kycRes.data!;
      kycProfile.value = kyc;
      kycStatus.value = kyc.isVerified ? 'verified' : kyc.verificationStatus;

      if (kyc.isPending || kyc.isVerified) {
        isKycSubmitted.value = true;
        await LocalStorage.write(kycSubmittedStorageKey, 'true');
      } else {
        isKycSubmitted.value = false;
        await LocalStorage.write(kycSubmittedStorageKey, 'false');
      }
    }
  }

  String get clientDisplayName {
    if (currentUser.value != null && currentUser.value!.name.isNotEmpty) {
      return currentUser.value!.name;
    }
    return 'Client';
  }

  String get clientAccountId {
    if (currentUser.value != null) {
      return currentUser.value!.formattedAccountId;
    }
    return '# MV-CLIENT';
  }

  Future<void> completeKycSubmission() async {
    isKycSubmitted.value = true;
    kycStatus.value = 'pending';
    currentIndex.value = 0; // Return to Dashboard
    await LocalStorage.write(kycSubmittedStorageKey, 'true');

    notifications.insert(
      0,
      NotificationItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: 'Regulatory KYC Submitted Successfully',
        message:
            'Aadhaar, PAN & investor suitability documents received by compliance desk. Verification in progress.',
        time: 'Just now',
        tag: 'Under Review',
        icon: Icons.schedule_rounded,
        tagColor: const Color(0xFFD97706),
        iconBgColor: const Color(0xFFFEF3C7),
        isUnread: true,
      ),
    );

    smsList.insert(
      0,
      SmsItem(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sender: 'VM-MNYARA',
        message:
            'Dear ${clientDisplayName}, your KYC documents have been submitted to Moneyara Research Desk. Tracking ID: #${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
        time: 'Just now',
        status: 'Delivered',
      ),
    );
  }

  // Static notifications as instructed by user
  void _loadInitialNotifications() {
    notifications.assignAll([
      NotificationItem(
        id: '1',
        title: 'KYC Document Verification Under Review',
        message:
            'Advisory bulletins, market recommendations, and direct communication feeds are locked while your identity documents are undergoing compliance review.',
        time: 'Just now',
        tag: 'KYC Review',
        icon: Icons.lock_clock_rounded,
        tagColor: const Color(0xFFD97706),
        iconBgColor: const Color(0xFFFEF3C7),
        isUnread: true,
      ),
      NotificationItem(
        id: '2',
        title: 'Statutory Risk Suitability Profiling Completed',
        message:
            'Your risk appetite has been categorized as Moderate-Aggressive for equity derivatives & cash recommendations.',
        time: '15 mins ago',
        tag: 'Compliance',
        icon: Icons.verified_user_rounded,
        tagColor: const Color(0xFF00B074),
        iconBgColor: const Color(0xFFECFDF5),
        isUnread: true,
      ),
      NotificationItem(
        id: '3',
        title: 'SEBI Mandatory MITC & Charter Recorded',
        message:
            'Client Terms of Service, MITC disclosures, and dispute resolution guidelines acknowledged.',
        time: '1 hour ago',
        tag: 'Regulatory',
        icon: Icons.assignment_turned_in_rounded,
        tagColor: const Color(0xFF3B82F6),
        iconBgColor: const Color(0xFFEFF6FF),
        isUnread: false,
      ),
      NotificationItem(
        id: '4',
        title: 'Nifty 50 Technical Advisory Bulletin',
        message:
            'Key support established at 24,950; resistance levels projected at 25,240 ahead of expiry.',
        time: '3 hours ago',
        tag: 'Market Research',
        icon: Icons.trending_up_rounded,
        tagColor: const Color(0xFF8B5CF6),
        iconBgColor: const Color(0xFFF5F3FF),
        isUnread: false,
      ),
      NotificationItem(
        id: '5',
        title: 'Welcome to Moneyara Research Desk',
        message:
            'Client Account initialized with compliance clearance gateway.',
        time: 'Today',
        tag: 'System',
        icon: Icons.shield_rounded,
        tagColor: const Color(0xFF64748B),
        iconBgColor: const Color(0xFFF1F5F9),
        isUnread: false,
      ),
    ]);
  }

  // Static SMS feed as instructed by user
  void _loadInitialSms() {
    smsList.assignAll([
      SmsItem(
        id: '1',
        sender: 'VM-MNYARA',
        message:
            'Moneyara: Welcome to Moneyara Research Desk. Complete your SEBI regulatory KYC to unlock equity advisory channels.',
        time: '10 mins ago',
        status: 'Delivered',
      ),
      SmsItem(
        id: '2',
        sender: 'VM-MNYARA',
        message:
            'Moneyara: Your one-time verification code is 4829. Valid for 10 minutes. Do not share your OTP with anyone.',
        time: '35 mins ago',
        status: 'Delivered',
      ),
      SmsItem(
        id: '3',
        sender: 'VK-SEBIRD',
        message:
            'SEBI Reg Advisory: Standard disclaimer applies to all research calls. Investments in securities market are subject to market risks.',
        time: 'Yesterday',
        status: 'Delivered',
      ),
    ]);
  }
}
