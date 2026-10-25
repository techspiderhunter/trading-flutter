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
        appBar: const DeskAppBar(group: 'Authentication'),
        body: DeskBody(children: [
          const DeskHero(
              title: 'Your research desk.',
              subtitle: 'Sign in to access your market communications.'),
          const SizedBox(height: 25),
          const DeskNote(
              title: 'Welcome back',
              description: 'A clearer view of every advisory.'),
          const SizedBox(height: 18),
          const DeskLabel('Email address'),
          TextFormField(
              controller: controller.loginEmailController,
              keyboardType: TextInputType.emailAddress,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validators.email,
              style: deskText,
              decoration: deskInputDecoration(hintText: 'name@example.com')),
          const SizedBox(height: 16),
          const DeskLabel('Password'),
          Obx(() => TextFormField(
              controller: controller.loginPasswordController,
              obscureText: controller.isLoginPasswordHidden.value,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: Validators.password,
              style: deskText,
              decoration: deskInputDecoration(
                  hintText: 'Enter your password',
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
                  )))),
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
                      minimumSize: const Size(0, 44),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap),
                  child: const Text('Forgot password?'))),
          Obx(() => DeskButton(
              label: 'Sign In',
              loading: controller.isLoginLoading.value,
              onPressed: controller.isLoginLoading.value
                  ? null
                  : controller.submitLogin)),
          const SizedBox(height: 20),
          DeskRow(
              title: 'New to the desk?',
              subtitle: 'Create Free Account',
              onTap: () => Get.toNamed(AuthRoutes.register)),
        ]));
  }
}
