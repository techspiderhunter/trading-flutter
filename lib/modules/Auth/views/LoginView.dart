import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/DeskUi.dart';
import '../../../themes/colors.dart';
import '../../../global/Validator/Validators.dart';
import '../controllers/AuthController.dart';
import '../routes/AuthRoutes.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    return Scaffold(
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: DeskBody(
          children: [
            // Top Compliance Badge
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 8, bottom: 16),
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFE2D9F8)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: Color(0xFF10B981),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'SEBI REGISTERED RESEARCH DESK',
                      style: TextStyle(
                        fontFamily: 'DeskSans',
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Center(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Image.asset(
                  'assets/system/logo.png',
                  height: 64,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            const DeskHero(
              title: 'Welcome to Research Desk',
              subtitle:
                  'Sign in to access real-time market communications & insights.',
            ),
            const SizedBox(height: 20),

            // Primary Credentials Card
            DeskCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DeskCardHeader(
                    title: 'Account Sign In',
                    subtitle: 'Enter your registered credentials below',
                    icon: Icons.lock_outline_rounded,
                    iconColor: AppColors.primary,
                    iconBgColor: AppColors.primaryLight,
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 18),

                  const DeskLabel('Email address'),
                  TextFormField(
                    controller: controller.loginEmailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: Validators.email,
                    style: deskText,
                    decoration: deskInputDecoration(
                      hintText: 'name@example.com',
                      prefixIcon: const Icon(Icons.mail_outline_rounded,
                          size: 20, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const DeskLabel('Password'),
                  Obx(() => TextFormField(
                        controller: controller.loginPasswordController,
                        obscureText: controller.isLoginPasswordHidden.value,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: Validators.password,
                        onFieldSubmitted: (_) {
                          if (!controller.isLoginLoading.value) {
                            controller.submitLogin();
                          }
                        },
                        style: deskText,
                        decoration: deskInputDecoration(
                          hintText: 'Enter your password',
                          prefixIcon: const Icon(Icons.key_outlined,
                              size: 20, color: AppColors.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isLoginPasswordHidden.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textSecondary,
                              size: 19,
                            ),
                            onPressed: () {
                              controller.isLoginPasswordHidden.toggle();
                            },
                          ),
                        ),
                      )),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        if (controller.loginEmailController.text
                            .trim()
                            .isNotEmpty) {
                          controller.forgotEmailController.text =
                              controller.loginEmailController.text.trim();
                        }
                        controller.forgotEmailSent.value = false;
                        Get.toNamed(AuthRoutes.forgotPassword);
                      },
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        minimumSize: const Size(0, 42),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          fontFamily: 'DeskSans',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  Obx(() => DeskButton(
                        label: 'Sign In to Desk',
                        loading: controller.isLoginLoading.value,
                        onPressed: controller.isLoginLoading.value
                            ? null
                            : controller.submitLogin,
                      )),

                  const SizedBox(height: 16),

                  // Micro Trust Strip inside Card
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 9),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildMicroTrust(
                            Icons.lock_rounded, '256-Bit SSL'),
                        Container(
                            width: 1,
                            height: 14,
                            color: AppColors.borderLight),
                        _buildMicroTrust(
                            Icons.shield_outlined, 'SEBI Regulated'),
                        Container(
                            width: 1,
                            height: 14,
                            color: AppColors.borderLight),
                        _buildMicroTrust(
                            Icons.bolt_rounded, 'Instant Desk'),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Register Action Card
            DeskCard(
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => Get.toNamed(AuthRoutes.register),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18, vertical: 16),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: AppColors.cardBlue,
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: const Icon(
                            Icons.person_add_outlined,
                            color: AppColors.primary,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'New to NM Research Partner?',
                                style: deskText.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Create Free Client Account',
                                style: deskText.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 7),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(9),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Register',
                                style: deskText.copyWith(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                size: 13,
                                color: AppColors.primary,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shield_outlined,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    'SEBI Reg. Research Analyst · Safe & Encrypted',
                    style: deskText.copyWith(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildMicroTrust(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: AppColors.primary),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'DeskSans',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
