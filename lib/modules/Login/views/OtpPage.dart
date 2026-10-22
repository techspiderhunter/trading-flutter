import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../helper/Widgets/Loading.dart';
import '../controllers/OtpController.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  static const Color primaryBlue = Color(0xFF0D63F3);
  static const Color deepNavy = Color(0xFF101828);

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
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final isCompact = size.height < 720;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FBFF),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(22, 14, 22, 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Get.back(),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white,
                                fixedSize: const Size(44, 44),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  side: const BorderSide(
                                    color: Color(0xFFE4ECF7),
                                  ),
                                ),
                              ),
                              icon: const Icon(
                                Icons.arrow_back_rounded,
                                color: deepNavy,
                                size: 21,
                              ),
                            ),
                            Image.asset(
                              'assets/system/logo.png',
                              height: 34,
                              width: 92,
                              fit: BoxFit.contain,
                              alignment: Alignment.centerRight,
                              errorBuilder: (context, error, stackTrace) {
                                return const Text(
                                  'VEX',
                                  style: TextStyle(
                                    color: deepNavy,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w900,
                                    height: 1,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: isCompact ? 28 : 44),
                        Container(
                          width: 98,
                          height: 98,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: primaryBlue.withValues(alpha: 0.12),
                                blurRadius: 28,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.sms_rounded,
                            color: primaryBlue,
                            size: 42,
                          ),
                        ),
                        SizedBox(height: isCompact ? 22 : 32),
                        const Text(
                          'Verify OTP',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: deepNavy,
                            fontSize: 31,
                            fontWeight: FontWeight.w900,
                            height: 1.12,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Enter the 4-digit code sent to your mobile number.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 9,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(999),
                            border: Border.all(
                              color: const Color(0xFFE4ECF7),
                            ),
                          ),
                          child: Text(
                            '+91 ${controller.maskedPhone}',
                            style: const TextStyle(
                              color: deepNavy,
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        SizedBox(height: isCompact ? 28 : 38),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFE4ECF7),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 22,
                                offset: const Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              Obx(() => _otpBoxes(controller.otpValue.value)),
                              const SizedBox(height: 20),
                              Obx(
                                () => controller.canResend.value
                                    ? TextButton.icon(
                                        onPressed: controller.isResending.value
                                            ? null
                                            : controller.resendOtp,
                                        icon: controller.isResending.value
                                            ? const ButtonLoading(
                                                size: 16,
                                                color: primaryBlue,
                                              )
                                            : const Icon(
                                                Icons.refresh_rounded,
                                                size: 18,
                                              ),
                                        label: const Text('Generate OTP Again'),
                                        style: TextButton.styleFrom(
                                          foregroundColor: primaryBlue,
                                          textStyle: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      )
                                    : Text(
                                        'Generate again in 00:${controller.secondsRemaining.value.toString().padLeft(2, '0')}',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF98A2B3),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                              const SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: Obx(
                                  () => ElevatedButton(
                                    onPressed: controller.isVerifying.value
                                        ? null
                                        : controller.verifyOtp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryBlue,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          const Color(0xFFBBD5FF),
                                      elevation: 0,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: controller.isVerifying.value
                                        ? const ButtonLoading()
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Verify & Continue',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Icon(
                                                Icons.verified_rounded,
                                                size: 21,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(height: 22),
                        const Text(
                          'Your OTP keeps your VEX account secure.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF98A2B3),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

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
                        : const Color(0xFFF8FAFC),
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
                      color: deepNavy,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
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
