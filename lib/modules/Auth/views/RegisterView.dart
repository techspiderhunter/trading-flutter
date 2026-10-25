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
            onBack: () => Get.toNamed(AuthRoutes.login)),
        body: DeskBody(children: [
          const DeskHero(
              title: 'Begin with confidence.',
              subtitle: 'Use your legal credentials as per PAN / Aadhaar.'),
          const SizedBox(height: 25),
          const DeskLabel('Full name *'),
          TextFormField(
              controller: controller.nameController,
              textCapitalization: TextCapitalization.words,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validators.name,
              style: deskText,
              decoration: deskInputDecoration(
                  hintText: 'Legal full name (as per PAN)')),
          const SizedBox(height: 16),
          const DeskLabel('Email address *'),
          TextFormField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validators.email,
              style: deskText,
              decoration: deskInputDecoration(hintText: 'name@example.com')),
          const SizedBox(height: 16),
          const DeskLabel('Mobile number *'),
          TextFormField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validators.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              style: deskText,
              decoration:
                  deskInputDecoration(hintText: '10-digit mobile number').copyWith(prefixText: '+91 ')),
          const SizedBox(height: 16),
          const DeskLabel('Create password *'),
          Obx(() => TextFormField(
              controller: controller.passwordController,
              obscureText: controller.isPasswordHidden.value,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validators.password,
              style: deskText,
              decoration: deskInputDecoration(
                  hintText: 'Create a strong password',
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
                  )))),
          const SizedBox(height: 16),
          const DeskLabel('Confirm password *'),
          Obx(() => TextFormField(
              controller: controller.confirmPasswordController,
              obscureText: controller.isConfirmPasswordHidden.value,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (v) => Validators.confirmPassword(
                  v, controller.passwordController.text),
              style: deskText,
              decoration: deskInputDecoration(
                  hintText: 'Confirm your password',
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
                  )))),
          const SizedBox(height: 16),
          Obx(() =>
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Checkbox(
                  value: controller.agreeToTerms.value,
                  activeColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  onChanged: (val) {
                    controller.agreeToTerms.value = val ?? true;
                  },
                ),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'DeskSans',
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(text: 'I agree to the '),
                              TextSpan(
                                text: 'FinWise Terms & Conditions',
                                style: const TextStyle(
                                  fontFamily: 'DeskSans',
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    TermsWebViewModal.show(context);
                                  },
                              ),
                              const TextSpan(
                                text: ' and SEBI regulatory compliance.',
                              ),
                            ],
                          ),
                        )))
              ])),
          const SizedBox(height: 20),
          Obx(() => DeskButton(
              label: 'Create Free Account',
              loading: controller.isRegisterLoading.value,
              onPressed: controller.isRegisterLoading.value
                  ? null
                  : controller.register)),
          const SizedBox(height: 20),
          DeskRow(
              title: 'Already have an account?',
              subtitle: 'Sign In',
              onTap: () => Get.toNamed(AuthRoutes.login)),
        ]));
  }
}
