import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/DeskUi.dart';
import '../../../themes/colors.dart';
import '../controllers/AuthController.dart';
import 'package:flutter/services.dart';

class OtpView extends StatefulWidget {
  const OtpView({super.key});

  @override
  State<OtpView> createState() => _OtpViewState();
}

class _OtpViewState extends State<OtpView> {
  late final AuthController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    // Auto-fill OTP from LocalStorage/fallback and start 3s auto-verification
    controller.fillSavedOtp();
    controller.startAutoVerificationTimer(reset: true);
  }

  @override
  void dispose() {
    controller.cancelAutoVerificationTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final emailText = controller.loginEmailController.text.trim().isEmpty
        ? 'your registered email'
        : controller.loginEmailController.text.trim();
    return Scaffold(
        appBar: DeskAppBar(group: 'Authentication', onBack: () => Get.back()),
        body: DeskBody(children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 20),
              child: Image.asset(
                'assets/system/logo.png',
                height: 64,
                fit: BoxFit.contain,
              ),
            ),
          ),
          DeskHero(
              title: 'Check your inbox.',
              subtitle: 'Enter the 4-digit code sent to $emailText.'),
          const SizedBox(height: 60),
          Row(children: [
            _buildOtpBox(
                context: context,
                controller: controller.otpDigit1,
                authController: controller,
                autoFocus: true),
            _buildOtpBox(
                context: context,
                controller: controller.otpDigit2,
                authController: controller),
            _buildOtpBox(
                context: context,
                controller: controller.otpDigit3,
                authController: controller),
            _buildOtpBox(
                context: context,
                controller: controller.otpDigit4,
                authController: controller,
                isLast: true),
          ]),
          const SizedBox(height: 40),
          Obx(() {
            final isVerifying = controller.isVerifyingOtp.value;
            final isAuto = controller.isAutoVerifying.value;
            final seconds = controller.autoVerifySeconds.value;

            String label = 'Verify & Continue';
            if (isVerifying) {
              label = 'Verifying...';
            } else if (isAuto) {
              label = 'Auto-verifying in ${seconds}s...';
            }

            return DeskButton(
              label: label,
              loading: isVerifying,
              onPressed: isVerifying
                  ? null
                  : () {
                      controller.cancelAutoVerificationTimer();
                      controller.verifyOtpAndGoToDashboard();
                    },
            );
          }),
          const SizedBox(height: 24),
          Obx(() => controller.otpTimerSeconds.value > 0
              ? Text(
                  'Resend code in 00:${controller.otpTimerSeconds.value.toString().padLeft(2, '0')}',
                  style: deskText.copyWith(
                      fontSize: 13, color: AppColors.textSecondary))
              : DeskButton(
                  label: 'Resend Code',
                  secondary: true,
                  loading: controller.isResendingOtp.value,
                  onPressed: controller.isResendingOtp.value
                      ? null
                      : controller.resendOtpCode)),
        ]));
  }

  Widget _buildOtpBox({
    required BuildContext context,
    required TextEditingController controller,
    required AuthController authController,
    bool autoFocus = false,
    bool isLast = false,
  }) {
    return Expanded(
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: SizedBox(
              width: 60,
              height: 70,
              child: TextField(
                controller: controller,
                autofocus: autoFocus,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                maxLength: 1,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                  fontFamily: 'DeskSans',
                  fontSize: 25,
                  fontWeight: FontWeight.w400,
                  color: AppColors.textHeading,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  filled: true,
                  fillColor: AppColors.inputBg,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide:
                        const BorderSide(color: AppColors.primary, width: 2.0),
                  ),
                ),
                onChanged: (value) {
                  authController.saveCurrentEnteredOtp();
                  if (value.isNotEmpty && !isLast) {
                    FocusScope.of(context).nextFocus();
                  } else if (value.isEmpty) {
                    FocusScope.of(context).previousFocus();
                  }
                },
              ),
            )));
  }
}
