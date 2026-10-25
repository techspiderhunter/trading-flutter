import 'package:techspiderhunter/modules/Dashboard/views/widgets/ActiveMessagesFeed.dart';
import 'package:techspiderhunter/modules/Notification/models/NotificationModels.dart';
import 'package:techspiderhunter/helper/Widgets/SelectSingleForm.dart';
import 'package:techspiderhunter/modules/Kyc/views/widgets/KycDocumentViewerModal.dart';
import 'package:techspiderhunter/modules/Dashboard/views/widgets/MessageAttachmentViewerModal.dart';
import 'package:techspiderhunter/modules/Auth/routes/AuthRoutes.dart';
import 'package:techspiderhunter/models/ClientMessageModel.dart';
import 'package:techspiderhunter/modules/Login/controllers/LoginController.dart';
import 'package:techspiderhunter/modules/Login/controllers/OtpController.dart';
import 'package:techspiderhunter/modules/Login/views/LoginIndex.dart';
import 'package:techspiderhunter/modules/Login/views/OtpPage.dart';
import 'package:techspiderhunter/controller/user_controller.dart';
import 'package:techspiderhunter/screens/user_screen.dart';
// Test fixtures intentionally bypass controller startup I/O.
// ignore_for_file: must_call_super

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:techspiderhunter/includes/Storage.dart';
import 'package:techspiderhunter/themes/LightTheme.dart';
import 'package:techspiderhunter/themes/colors.dart';
import 'package:techspiderhunter/widgets/DeskUi.dart';
import 'package:techspiderhunter/models/KycModel.dart';
import 'package:techspiderhunter/models/MitcModel.dart';
import 'package:techspiderhunter/models/InvoiceModel.dart';
import 'package:techspiderhunter/modules/Auth/controllers/AuthController.dart';
import 'package:techspiderhunter/modules/Auth/views/LoginView.dart';
import 'package:techspiderhunter/modules/Auth/views/RegisterView.dart';
import 'package:techspiderhunter/modules/Auth/views/OtpView.dart';
import 'package:techspiderhunter/modules/Auth/views/ForgotPasswordView.dart';
import 'package:techspiderhunter/modules/Dashboard/controllers/DashboardController.dart';
import 'package:techspiderhunter/modules/Dashboard/views/DashboardView.dart';
import 'package:techspiderhunter/modules/MainNav/controllers/MainNavController.dart';
import 'package:techspiderhunter/modules/MainNav/views/MainNavigationView.dart';
import 'package:techspiderhunter/modules/Profile/controllers/ProfileController.dart';
import 'package:techspiderhunter/modules/Profile/views/ProfileView.dart';
import 'package:techspiderhunter/modules/Setting/views/SettingView.dart';
import 'package:techspiderhunter/modules/Setting/routes/SettingRoutes.dart';
import 'package:techspiderhunter/modules/Kyc/controllers/KycController.dart';
import 'package:techspiderhunter/modules/Kyc/views/KycView.dart';
import 'package:techspiderhunter/modules/Mitc/controllers/MitcController.dart';
import 'package:techspiderhunter/modules/Mitc/views/MitcView.dart';
import 'package:techspiderhunter/modules/Invoice/controllers/InvoiceController.dart';
import 'package:techspiderhunter/modules/Invoice/views/InvoiceIndexView.dart';
import 'package:techspiderhunter/modules/Invoice/views/widgets/InvoiceDetailModal.dart';
import 'package:techspiderhunter/modules/Notification/controllers/NotificationController.dart';
import 'package:techspiderhunter/modules/Dashboard/views/widgets/NotificationsBottomSheet.dart';
import 'package:techspiderhunter/modules/Notification/views/NotificationView.dart';

// Disable only startup I/O in fixtures. Production callbacks and form state are unchanged.
class _Dashboard extends DashboardController {
  @override
  void onInit() {}
}

class _Nav extends MainNavController {
  @override
  void onInit() {}
}

class _Profile extends ProfileController {
  @override
  void onInit() {}
}

class _Kyc extends KycController {
  @override
  void onInit() {}
}

class _Mitc extends MitcController {
  @override
  void onInit() {}
}

class _Invoices extends InvoiceController {
  @override
  void onInit() {}
}

class _Notifications extends NotificationController {
  int? markedTab;
  @override
  Future<void> markAllAsRead() async {
    markedTab = selectedTab.value;
  }

  @override
  void onInit() {}
}

class _LegacyOtp extends OtpController {
  @override
  void onInit() {
    phone = '9999999999';
  }
}

class _Users extends UserController {
  @override
  void onInit() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await (FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
        .load();
    await (FontLoader('DeskSans')
          ..addFont(rootBundle.load('assets/fonts/DeskSans-Regular.ttf'))
          ..addFont(rootBundle.load('assets/fonts/DeskSans-Medium.ttf'))
          ..addFont(rootBundle.load('assets/fonts/DeskSans-Semibold.ttf'))
          ..addFont(rootBundle.load('assets/fonts/DeskSans-Bold.ttf')))
        .load();
  });
  setUp(() async {
    Get.testMode = true;
    SharedPreferences.setMockInitialValues({});
    await LocalStorage.init();
    Get.put<MainNavController>(_Nav());
    Get.put<DashboardController>(
        _Dashboard()..clientName.value = 'Aarav Sharma');
    Get.put<ProfileController>(_Profile()
      ..clientName.value = 'Aarav Sharma'
      ..clientEmail.value = 'aarav@example.com'
      ..nameEditController.text = 'Aarav Sharma');
    Get.put<KycController>(_Kyc());
    Get.put<MitcController>(_Mitc());
    Get.put<InvoiceController>(_Invoices());
    Get.put<NotificationController>(_Notifications());
    Get.put<AuthController>(AuthController());
    Get.put<LoginController>(LoginController());
    Get.put<OtpController>(_LegacyOtp());
    Get.put<UserController>(_Users());
  });
  tearDown(() => Get.reset());

  Future<void> render(WidgetTester tester, Widget page, String name,
      {double width = 390, double scale = 1}) async {
    tester.view.physicalSize = Size(width, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final key = GlobalKey();
    await tester.pumpWidget(GetMaterialApp(
      theme: lightTheme(),
      getPages: [...SettingRoutes.routes, ...AuthRoutes.routes],
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
            padding: const EdgeInsets.only(top: 36, bottom: 20),
            textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: RepaintBoundary(key: key, child: page),
    ));
    await tester.pump(const Duration(milliseconds: 300));
    expect(tester.takeException(), isNull, reason: '$name at $width / $scale');
    final output = Platform.environment['UI_CAPTURE_DIR'];
    if (output != null && width == 390 && scale == 1) {
      await tester.runAsync(() async {
        final boundary =
            key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
        final image = await boundary.toImage();
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        Directory(output).createSync(recursive: true);
        File('$output/$name.png').writeAsBytesSync(bytes!.buffer.asUint8List());
        image.dispose();
      });
    }
  }

  for (final width in [320.0, 390.0, 900.0]) {
    for (final entry in <String, Widget>{
      'kyc-document-error': const Scaffold(
          body: KycDocumentViewerModal(title: 'PAN card · Front')),
      'message-attachment-error':
          const Scaffold(body: MessageAttachmentViewerModal(imageUrl: '')),
      'legacy-login': const LoginIndex(),
      'legacy-otp': const OtpPage(),
      'local-users': const UserScreen(),
      'login': const LoginView(),
      'register': const RegisterView(),
      'otp': const OtpView(),
      'forgot-password': const ForgotPasswordView(),
      'dashboard': const DashboardView(),
      'setting': const SettingView(),
      'profile': const ProfileView(),
      'mitc-form': const MitcView(),
      'invoices-empty': const InvoiceIndexView(),
      'notifications-empty': const Scaffold(body: NotificationsBottomSheet()),
    }.entries) {
      testWidgets('${entry.key} fits $width', (tester) async {
        await render(tester, entry.value, entry.key, width: width);
      });
    }
    for (var step = 0; step < 4; step++) {
      testWidgets('KYC step $step fits $width', (tester) async {
        Get.find<KycController>().currentStep.value = step;
        await render(tester, const KycView(), 'kyc-step-$step', width: width);
      });
    }
    for (final status in ['pending', 'verified', 'rejected']) {
      testWidgets('KYC $status fits $width', (tester) async {
        final c = Get.find<KycController>();
        c.currentKycStatus.value = status;
        c.currentKyc.value = KycModel(
            id: 1,
            fullName: 'Aarav Sharma',
            verificationStatus: status,
            referenceId: 'TEST-001',
            rejectionReason: 'Please upload a clear identity document.');
        await render(tester, const KycView(), 'kyc-$status', width: width);
      });
      testWidgets('MITC $status fits $width', (tester) async {
        final c = Get.find<MitcController>();
        c.currentStatus.value = status;
        c.mitcProfile.value = MitcModel(
            id: 1,
            fullName: 'Aarav Sharma',
            mobile: '9XXXXXXXXX',
            email: 'aarav@example.com',
            verificationStatus: status,
            rejectionReason: 'Please provide a clear signature.');
        await render(tester, const MitcView(), 'mitc-$status', width: width);
      });
      testWidgets('Dashboard $status fits $width', (tester) async {
        Get.find<DashboardController>().kycStatus.value = status;
        await render(tester, const DashboardView(), 'dashboard-$status',
            width: width);
      });
    }
    testWidgets('Invoice list and cancelled detail fit $width', (tester) async {
      final invoice = InvoiceModel(
          invoiceNumber: 'TEST-001',
          status: 'cancelled',
          formattedStatus: 'Cancelled',
          cancellationReason: 'Sample cancellation reason');
      Get.find<InvoiceController>().invoices.add(invoice);
      await render(tester, const InvoiceIndexView(), 'invoices-list',
          width: width);
      await render(
          tester,
          Scaffold(
              body: SingleChildScrollView(
                  child: InvoiceDetailModal(
                      invoice: invoice, onPreview: () {}, onDownload: () {}))),
          'invoice-detail',
          width: width);
    });
  }

  for (final page in <String, Widget>{
    'login': const LoginView(),
    'register': const RegisterView(),
    'setting': const SettingView(),
    'profile': const ProfileView(),
  }.entries) {
    testWidgets('${page.key} at large text', (tester) async {
      await render(tester, page.value, '${page.key}-large-text',
          width: 390, scale: 1.3);
    });
  }

  testWidgets('Forgot password preserves email prefill and resets sent state',
      (tester) async {
    await render(tester, const LoginView(), 'login-recovery');
    final c = Get.find<AuthController>();
    c.loginEmailController.text = 'client@example.com';
    c.forgotEmailSent.value = true;
    await tester.tap(find.text('Forgot password?'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, AuthRoutes.forgotPassword);
    expect(c.forgotEmailController.text, 'client@example.com');
    expect(c.forgotEmailSent.value, isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Sign out cancel does not execute logout', (tester) async {
    await render(tester, const ProfileView(), 'profile-dialog');
    Get.find<ProfileController>().logout();
    await tester.pumpAndSettle();
    expect(find.byType(DeskSheetContent), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(Get.isDialogOpen, isFalse);
    expect(tester.takeException(), isNull);
  });
  testWidgets('Document source sheet keeps camera and gallery choices',
      (tester) async {
    await render(tester, const KycView(), 'kyc-source');
    await Get.find<KycController>().pickPanDocument();
    await tester.pumpAndSettle();
    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Choose from Gallery'), findsOneWidget);
    Get.back();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });
  testWidgets('Full message dialog retains body and close action',
      (tester) async {
    await render(tester, const Scaffold(body: Text('Message fixture')),
        'message-dialog');
    Get.find<NotificationController>().handleMessageTap(
        tester.element(find.text('Message fixture')),
        ClientMessageModel(
            id: 1,
            sender: 'Research Desk',
            subject: 'Desk communication',
            message: 'Complete original message body.',
            date: 'Today'));
    await tester.pumpAndSettle();
    expect(find.text('Complete original message body.'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0, 900.0]) {
    for (final attached in [false, true]) {
      testWidgets('attachment action visibility $attached fits $width',
          (tester) async {
        Get.find<DashboardController>().messages.add(ClientMessageModel(
            id: 1,
            sender: 'Research Desk',
            subject: 'Message subject',
            message: 'Original message content.',
            date: 'Today',
            attachmentUrl:
                attached ? 'https://example.com/attachment.png' : null));
        await render(
            tester,
            const Scaffold(
                body: SingleChildScrollView(
                    padding: EdgeInsets.all(24), child: ActiveMessagesFeed())),
            'attachment-action-$attached',
            width: width);
        expect(find.text('View attachment'),
            attached ? findsOneWidget : findsNothing);
        expect(find.byIcon(Icons.attach_file_rounded),
            attached ? findsOneWidget : findsNothing);
        expect(find.byIcon(Icons.arrow_forward_rounded),
            attached ? findsOneWidget : findsNothing);
        expect(find.byIcon(Icons.chevron_right_rounded), findsNothing);
        expect(find.byIcon(Icons.north_east_rounded), findsNothing);
        if (attached) {
          final action = tester
              .widget<DeskAttachmentAction>(find.byType(DeskAttachmentAction));
          expect(action.onPressed, isNotNull);
          final card = find.byType(DeskMessageCard);
          final button =
              find.descendant(of: card, matching: find.byType(TextButton));
          expect(button, findsOneWidget);
          final cardRect = tester.getRect(card);
          final buttonRect = tester.getRect(button);
          expect(cardRect.contains(buttonRect.topLeft), isTrue);
          expect(cardRect.contains(buttonRect.bottomRight), isTrue);
        }
      });
    }
  }

  testWidgets('Shared selection sheet retains search and selection callbacks',
      (tester) async {
    String? chosen;
    await render(
        tester,
        Scaffold(
            body: Padding(
                padding: const EdgeInsets.all(24),
                child: SelectSingleForm(
                    label: 'Risk selection',
                    hint: 'Choose an option',
                    items: const [
                      {'value': 'one', 'label': 'First'},
                      {'value': 'two', 'label': 'Second'}
                    ],
                    onChanged: (value) => chosen = value))),
        'selection-sheet');
    await tester.tap(find.text('Choose an option'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Second');
    await tester.pump();
    expect(find.text('First'), findsNothing);
    await tester.tap(find.descendant(
        of: find.byType(DeskRow), matching: find.text('Second')));
    await tester.pumpAndSettle();
    expect(chosen, 'two');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'notification sheet renders only Alerts even with a stale messages tab',
      (tester) async {
    final c = Get.find<NotificationController>() as _Notifications;
    c.selectedTab.value = 1;
    c.messages.add(ClientMessageModel(
        id: 1,
        sender: 'Desk',
        subject: 'Hidden advisory message',
        message: 'Hidden message body',
        date: 'Today'));
    c.notifications.add(NotificationModel.fromJson({
      'id': '1',
      'title': 'KYC alert',
      'message': 'Identity review update',
      'type': 'kyc'
    }));
    await render(tester, const Scaffold(body: NotificationsBottomSheet()),
        'notifications-alerts-only');
    expect(find.byType(NotificationsBottomSheet), findsOneWidget);
    expect(find.text('Messages'), findsNothing);
    expect(find.text('Hidden advisory message'), findsNothing);
    expect(find.text('KYC alert'), findsOneWidget);
    await tester.tap(find.text('Mark all read'));
    await tester.pump();
    expect(c.markedTab, 0);
    expect(c.messages.single.subject, 'Hidden advisory message');
    expect(tester.takeException(), isNull);
  });

  for (final width in [320.0, 390.0, 900.0]) {
    testWidgets('notification page keeps each update in one card at $width',
        (tester) async {
      final c = Get.find<NotificationController>() as _Notifications;
      c.selectedTab.value = 1;
      c.notifications.add(NotificationModel.fromJson({
        'id': 'welcome',
        'title': 'Welcome to Moneyara Research!',
        'message':
            'Your trading account has been registered successfully. Please submit your KYC to activate advisory channels.',
        'type': 'welcome',
        'time_ago': '17 hours ago',
      }));
      await render(tester, const NotificationView(), 'notification-page',
          width: width, scale: width == 320 ? 1.3 : 1);
      final card = find.byType(NotificationCard);
      expect(card, findsOneWidget);
      expect(
          find.descendant(
              of: card, matching: find.text('Welcome to Moneyara Research!')),
          findsOneWidget);
      expect(
          find.descendant(
              of: card, matching: find.text(c.notifications.single.message)),
          findsOneWidget);
      expect(find.descendant(of: card, matching: find.text('17 hours ago')),
          findsOneWidget);
      await tester.tap(find.text('Mark all read'));
      await tester.pump();
      expect(c.markedTab, 0);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Page heading stays compact and unboxed with large text',
      (tester) async {
    await render(
        tester,
        const Scaffold(
            body: SingleChildScrollView(
                child: Padding(
                    padding: EdgeInsets.all(24),
                    child: DeskHero(
                      title:
                          'Welcome back, a client with a very long legal name.',
                      subtitle: 'Your market research & regulatory portal.',
                      trailing: Text('Under Review'),
                    )))),
        'large-text',
        width: 320,
        scale: 1.6);
    final heading = find.byType(DeskHero);
    expect(find.descendant(of: heading, matching: find.byType(DecoratedBox)),
        findsNothing);
    expect(find.descendant(of: heading, matching: find.byType(CustomPaint)),
        findsNothing);
    expect(find.text('TRADING / RESEARCH DESK'), findsNothing);
    expect(find.text('Welcome back, a client with a very long legal name.'),
        findsOneWidget);
  });

  testWidgets('Dashboard has gear beside bell and no bottom tabs',
      (tester) async {
    await render(tester, const MainNavigationView(), 'main-navigation');
    expect(find.byTooltip('Setting'), findsOneWidget);
    expect(find.byTooltip('Notifications & Alerts'), findsOneWidget);
    expect(find.byType(BottomNavigationBar), findsNothing);
    final bell = tester.getCenter(find.byTooltip('Notifications & Alerts'));
    final gear = tester.getCenter(find.byTooltip('Setting'));
    expect(gear.dx, greaterThan(bell.dx));
    expect((gear.dy - bell.dy).abs(), lessThan(8));
    await tester.tap(find.byTooltip('Setting'));
    await tester.pumpAndSettle();
    expect(Get.currentRoute, SettingRoutes.setting);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Login retains email/password editing and visibility toggle',
      (tester) async {
    await render(tester, const LoginView(), 'login-fields');
    final c = Get.find<AuthController>();
    final inputs = find.byType(TextFormField);
    expect(inputs, findsNWidgets(2));
    await tester.enterText(inputs.first, 'client@example.com');
    await tester.enterText(inputs.last, 'unchanged-password');
    expect(c.loginEmailController.text, 'client@example.com');
    expect(c.loginPasswordController.text, 'unchanged-password');
    final wasHidden = c.isLoginPasswordHidden.value;
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pump();
    expect(c.isLoginPasswordHidden.value, !wasHidden);
  });

  testWidgets(
      'Destructive button remains red and disabled callbacks stay disabled',
      (tester) async {
    var calls = 0;
    await render(
        tester,
        Scaffold(
            body: Column(children: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
              onPressed: () => calls++,
              child: const Text('Sign Out')),
          const ElevatedButton(onPressed: null, child: Text('Disabled')),
        ])),
        'buttons');
    final inks = tester.widgetList<Ink>(find.byType(Ink));
    expect(
        inks.where((ink) =>
            ink.decoration is BoxDecoration &&
            (ink.decoration! as BoxDecoration).gradient != null),
        isEmpty);
    await tester.tap(find.text('Disabled'));
    expect(calls, 0);
  });
}
