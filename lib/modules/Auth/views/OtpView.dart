import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/DeskUi.dart';
import '../../../themes/colors.dart';
import '../controllers/AuthController.dart';
import 'package:flutter/services.dart';

class OtpView extends StatelessWidget {
  const OtpView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    final emailText = controller.loginEmailController.text.trim().isEmpty
        ? 'your registered email'
        : controller.loginEmailController.text.trim();
    return Scaffold(
        appBar: DeskAppBar(group: 'Authentication', onBack: () => Get.back()),
        body: DeskBody(children: [
          DeskHero(
              title: 'Check your inbox.',
              subtitle: 'Enter the 4-digit code sent to $emailText.'),
          const SizedBox(height: 60),
          Row(children: [
            _buildOtpBox(
                context: context,
                controller: controller.otpDigit1,
                autoFocus: true),
            _buildOtpBox(context: context, controller: controller.otpDigit2),
            _buildOtpBox(context: context, controller: controller.otpDigit3),
            _buildOtpBox(
                context: context,
                controller: controller.otpDigit4,
                isLast: true),
          ]),
          const SizedBox(height: 40),
          Obx(() => DeskButton(
              label: 'Verify & Continue',
              loading: controller.isVerifyingOtp.value,
              onPressed: controller.isVerifyingOtp.value
                  ? null
                  : controller.verifyOtpAndGoToDashboard)),
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
