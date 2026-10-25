import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../widgets/DeskUi.dart';
import '../../../themes/colors.dart';
import '../../../global/Validator/Validators.dart';
import '../controllers/AuthController.dart';
import '../routes/AuthRoutes.dart';

class ForgotPasswordView extends StatelessWidget {
  const ForgotPasswordView({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<AuthController>()
        ? Get.find<AuthController>()
        : Get.put(AuthController());
    return Scaffold(
        appBar: DeskAppBar(
            group: 'Authentication',
            onBack: () {
              controller.resetForgotState();
              Get.back();
            }),
        body: Obx(() => DeskBody(
            children: controller.forgotEmailSent.value
                ? [
                    const DeskHero(title: 'Check your email.'),
                    const SizedBox(height: 25),
                    DeskNote(
                        title: 'Reset link dispatched',
                        color: AppColors.success,
                        icon: Icons.check_rounded,
                        description:
                            'If this email is registered, follow the link in your inbox to configure a new password.\n${controller.lastForgotEmail.value}'),
                    const SizedBox(height: 18),
                    DeskButton(
                        label: 'Back to Sign In',
                        onPressed: () {
                          controller.resetForgotState();
                          Get.offAllNamed(AuthRoutes.login);
                        }),
                    const SizedBox(height: 20),
                    DeskButton(
                        label: 'Resend link',
                        secondary: true,
                        loading: controller.isForgotLoading.value,
                        onPressed: controller.isForgotLoading.value
                            ? null
                            : controller.sendForgotPassword),
                  ]
                : [
                    const DeskHero(
                        title: 'Let’s get you back.',
                        subtitle:
                            'Enter your registered email to receive a reset link.'),
                    const SizedBox(height: 25),
                    const DeskLabel('Registered email'),
                    TextFormField(
                        controller: controller.forgotEmailController,
                        keyboardType: TextInputType.emailAddress,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: Validators.email,
                        style: deskText,
                        decoration:
                            deskInputDecoration(hintText: 'name@example.com')),
                    const SizedBox(height: 16),
                    DeskButton(
                        label: 'Send Reset Link',
                        loading: controller.isForgotLoading.value,
                        onPressed: controller.isForgotLoading.value
                            ? null
                            : controller.sendForgotPassword),
                    const SizedBox(height: 20),
                    DeskRow(
                        title: 'Remember your password?',
                        subtitle: 'Sign In',
                        onTap: () {
                          controller.resetForgotState();
                          Get.back();
                        }),
                  ])));
  }
}
