import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../helper/Widgets/Loading.dart';
import '../controllers/LoginController.dart';

class LoginIndex extends StatelessWidget {
  const LoginIndex({super.key});

  static const Color primaryBlue = Color(0xFF0D63F3);
  static const Color deepNavy = Color(0xFF101828);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
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
                    padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Icon(Icons.account_balance_wallet_rounded),
                        ),
                        SizedBox(height: isCompact ? 30 : 48),
                        Container(
                          width: 96,
                          height: 96,
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
                            Icons.phone_iphone_rounded,
                            color: primaryBlue,
                            size: 42,
                          ),
                        ),
                        SizedBox(height: isCompact ? 24 : 34),
                        const Text(
                          'Welcome to Moneyara Research',
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
                          'Login or register with your mobile number to continue.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFF667085),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            height: 1.45,
                          ),
                        ),
                        SizedBox(height: isCompact ? 28 : 40),
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Mobile Number',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: deepNavy,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                height: 58,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFDCE6F2),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      height: double.infinity,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 15,
                                      ),
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          right: BorderSide(
                                            color: Color(0xFFDCE6F2),
                                          ),
                                        ),
                                      ),
                                      child: const Center(
                                        child: Text(
                                          '+91',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                            color: deepNavy,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        controller: controller.phoneController,
                                        keyboardType: TextInputType.phone,
                                        textInputAction: TextInputAction.done,
                                        autofillHints: const [
                                          AutofillHints.telephoneNumberNational,
                                        ],
                                        inputFormatters: [
                                          FilteringTextInputFormatter
                                              .digitsOnly,
                                          LengthLimitingTextInputFormatter(10),
                                        ],
                                        onSubmitted: (_) =>
                                            controller.sendOtp(),
                                        style: const TextStyle(
                                          color: deepNavy,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w800,
                                        ),
                                        decoration: const InputDecoration(
                                          hintText: '0000000000',
                                          hintStyle: TextStyle(
                                            color: Color(0xFF98A2B3),
                                            fontWeight: FontWeight.w600,
                                          ),
                                          border: InputBorder.none,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 17,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 16),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: Obx(
                                  () => ElevatedButton(
                                    onPressed: controller.isSending.value
                                        ? null
                                        : controller.sendOtp,
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
                                    child: controller.isSending.value
                                        ? const ButtonLoading()
                                        : const Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Text(
                                                'Send OTP',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w800,
                                                ),
                                              ),
                                              SizedBox(width: 10),
                                              Icon(
                                                Icons.arrow_forward_rounded,
                                                size: 22,
                                              ),
                                            ],
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        const Row(
                          children: [
                            Expanded(
                              child: _LoginBenefit(
                                icon: Icons.verified_user_rounded,
                                label: 'Secure login',
                              ),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: _LoginBenefit(
                                icon: Icons.flash_on_rounded,
                                label: 'Fast OTP',
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        const SizedBox(height: 22),
                        const Text(
                          'By continuing, you agree to our Terms & Conditions and Privacy Policy',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF98A2B3),
                            height: 1.35,
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
}

class _LoginBenefit extends StatelessWidget {
  const _LoginBenefit({
    required this.icon,
    required this.label,
  });

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4ECF7),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: LoginIndex.primaryBlue,
            size: 18,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: const TextStyle(
                  color: Color(0xFF344054),
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

          ),
        ],
      ),
    );

  }

}
