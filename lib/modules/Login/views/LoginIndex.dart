import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../widgets/DeskUi.dart';
import '../controllers/LoginController.dart';

class LoginIndex extends StatelessWidget {
  const LoginIndex({super.key});
  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LoginController>();
    return Scaffold(
        appBar: const DeskAppBar(group: 'Authentication'),
        body: DeskBody(children: [
          const DeskHero(
              title: 'Welcome to your desk.',
              subtitle: 'Secure mobile sign in.'),
          const SizedBox(height: 25),
          const DeskLabel('Mobile number · +91'),
          TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.done,
              autofillHints: const [
                AutofillHints.telephoneNumberNational,
              ],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(10),
              ],
              onSubmitted: (_) => controller.sendOtp(),
              style: deskText,
              decoration:
                  deskInputDecoration(hintText: '10-digit mobile number')),
          const SizedBox(height: 24),
          Obx(() => DeskButton(
              label: 'Send OTP',
              loading: controller.isSending.value,
              onPressed:
                  controller.isSending.value ? null : controller.sendOtp)),
        ]));
  }
}
