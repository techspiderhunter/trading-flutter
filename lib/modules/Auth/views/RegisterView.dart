import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/DeskUi.dart';
import '../../../themes/colors.dart';
import '../../../global/Validator/Validators.dart';
import '../controllers/AuthController.dart';
import '../routes/AuthRoutes.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'widgets/TermsWebViewModal.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());

    return Scaffold(
      appBar: DeskAppBar(
        group: 'Authentication',
        onBack: () => Get.toNamed(AuthRoutes.login),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: DeskBody(
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 4, bottom: 16),
                child: Image.asset(
                  'assets/system/logo.png',
                  height: 56,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const DeskHero(
              title: 'Open Your Client Account',
              subtitle:
                  'Paperless 2-minute onboarding compliant with SEBI regulations.',
            ),
            const SizedBox(height: 20),

            // Card 1: Identity & Contact Details
            DeskCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DeskCardHeader(
                    title: '1. Personal Information',
                    subtitle: 'Legal details as per PAN / Aadhaar records',
                    icon: Icons.person_outline_rounded,
                    iconColor: AppColors.primary,
                    iconBgColor: AppColors.primaryLight,
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 18),

                  const DeskLabel('Legal full name *'),
                  TextFormField(
                    controller: controller.nameController,
                    textCapitalization: TextCapitalization.words,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: Validators.name,
                    style: deskText,
                    decoration: deskInputDecoration(
                      hintText: 'Full name as per PAN card',
                      prefixIcon: const Icon(Icons.badge_outlined,
                          size: 20, color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 16),

                  const DeskLabel('Email address *'),
                  TextFormField(
                    controller: controller.emailController,
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

                  const DeskLabel('Mobile number *'),
                  TextFormField(
                    controller: controller.phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.telephoneNumber],
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    validator: Validators.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    style: deskText,
                    decoration: deskInputDecoration(
                      hintText: '10-digit mobile number',
                      prefixIcon: const Icon(Icons.phone_outlined,
                          size: 20, color: AppColors.textSecondary),
                    ).copyWith(prefixText: '🇮🇳 +91 '),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Card 2: Security & Password Setup
            DeskCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const DeskCardHeader(
                    title: '2. Security Credentials',
                    subtitle: 'Create a password for your account',
                    icon: Icons.shield_outlined,
                    iconColor: AppColors.primary,
                    iconBgColor: AppColors.primaryLight,
                  ),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: AppColors.borderLight),
                  const SizedBox(height: 18),

                  const DeskLabel('Create password *'),
                  Obx(() => TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.isPasswordHidden.value,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [AutofillHints.newPassword],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: Validators.password,
                        style: deskText,
                        decoration: deskInputDecoration(
                          hintText: 'Minimum 6 characters',
                          prefixIcon: const Icon(Icons.lock_outline_rounded,
                              size: 20, color: AppColors.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isPasswordHidden.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            onPressed: () {
                              controller.isPasswordHidden.toggle();
                            },
                          ),
                        ),
                      )),
                  const SizedBox(height: 16),

                  const DeskLabel('Confirm password *'),
                  Obx(() => TextFormField(
                        controller: controller.confirmPasswordController,
                        obscureText: controller.isConfirmPasswordHidden.value,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.newPassword],
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (v) => Validators.confirmPassword(
                            v, controller.passwordController.text),
                        style: deskText,
                        decoration: deskInputDecoration(
                          hintText: 'Repeat password to verify',
                          prefixIcon: const Icon(Icons.lock_reset_rounded,
                              size: 20, color: AppColors.textSecondary),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.isConfirmPasswordHidden.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            onPressed: () {
                              controller.isConfirmPasswordHidden.toggle();
                            },
                          ),
                        ),
                      )),

                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(Icons.check_circle_outline_rounded,
                          size: 14, color: Color(0xFF10B981)),
                      const SizedBox(width: 6),
                      Text(
                        'Keep password private and confidential',
                        style: deskText.copyWith(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Card 3: Regulatory Agreement & Action
            DeskCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFD),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.borderLight),
                    ),
                    child: Obx(() => Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: controller.agreeToTerms.value,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              onChanged: (val) {
                                controller.agreeToTerms.value = val ?? true;
                              },
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontFamily: 'DeskSans',
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                      height: 1.45,
                                    ),
                                    children: [
                                      const TextSpan(text: 'I agree to the '),
                                      TextSpan(
                                        text: 'FinWise Terms & Conditions',
                                        style: const TextStyle(
                                          fontFamily: 'DeskSans',
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w600,
                                          decoration:
                                              TextDecoration.underline,
                                        ),
                                        recognizer: TapGestureRecognizer()
                                          ..onTap = () {
                                            TermsWebViewModal.show(context);
                                          },
                                      ),
                                      const TextSpan(
                                        text:
                                            ' and accept SEBI regulatory compliance guidelines.',
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        )),
                  ),
                  const SizedBox(height: 18),

                  Obx(() => DeskButton(
                        label: 'Complete Free Registration',
                        loading: controller.isRegisterLoading.value,
                        onPressed: controller.isRegisterLoading.value
                            ? null
                            : controller.register,
                      )),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // Sign In Action Card
            DeskCard(
              padding: EdgeInsets.zero,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(22),
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: () => Get.toNamed(AuthRoutes.login),
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
                            Icons.login_rounded,
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
                                'Already have an account?',
                                style: deskText.copyWith(
                                  fontSize: 12,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Sign In to Desk',
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
                                'Sign In',
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
                  const Icon(Icons.verified_user_outlined,
                      size: 14, color: AppColors.textMuted),
                  const SizedBox(width: 6),
                  Text(
                    'KYC & AML Compliant · Bank Grade 256-bit Encryption',
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
}
