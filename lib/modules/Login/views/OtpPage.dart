import '../../../widgets/DeskUi.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/OtpController.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const Color primaryBlue = Color(0xFF6554D9);
  static const Color deepNavy = Color(0xFF192542);

  late final OtpController controller;
  final FocusNode _otpFocus = FocusNode();

  @override
  void initState() {
    super.initState();
    controller = Get.find<OtpController>();
  }

  @override
  void dispose() {
    _otpFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: DeskAppBar(group: 'Authentication', onBack: () => Get.back()),
      body: DeskBody(children: [
        DeskHero(
            title: 'Verify your number.',
            subtitle:
                'Enter the 4-digit code sent to ${controller.maskedPhone}.'),
        const SizedBox(height: 60),
        Obx(() => _otpBoxes(controller.otpValue.value)),
        const SizedBox(height: 40),
        Obx(() => DeskButton(
            label: 'Verify OTP',
            loading: controller.isVerifying.value,
            onPressed:
                controller.isVerifying.value ? null : controller.verifyOtp)),
        const SizedBox(height: 24),
        Obx(() => controller.canResend.value
            ? DeskButton(
                label: 'Generate OTP Again',
                secondary: true,
                loading: controller.isResending.value,
                onPressed:
                    controller.isResending.value ? null : controller.resendOtp)
            : Text(
                'Generate again in 00:${controller.secondsRemaining.value.toString().padLeft(2, '0')}',
                style: deskText)),
      ]));
  Widget _otpBoxes(String otp) {
    return GestureDetector(
      onTap: _otpFocus.requestFocus,
      child: Stack(
        children: [
          Row(
            children: List.generate(4, (index) {
              final digit = index < otp.length ? otp[index] : '';
              final isActive = index == otp.length && otp.length < 4;
              final isFilled = digit.isNotEmpty;

              return Expanded(
                child: Container(
                  height: 64,
                  margin: EdgeInsets.only(right: index == 3 ? 0 : 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isFilled
                        ? primaryBlue.withValues(alpha: 0.06)
                        : const Color(0xFFF1F3FA),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isActive || isFilled
                          ? primaryBlue
                          : const Color(0xFFDCE6F2),
                      width: isActive || isFilled ? 1.4 : 1,
                    ),
                  ),
                  child: Text(
                    digit,
                    style: const TextStyle(
                      fontFamily: 'DeskSans',
                      color: deepNavy,
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              );
            }),
          ),
          Positioned.fill(
            child: Opacity(
              opacity: 0,
              child: TextField(
                controller: controller.otpController,
                focusNode: _otpFocus,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(4),
                ],
                onChanged: controller.updateOtp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
