import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../widgets/DeskUi.dart';
import '../../../Kyc/routes/KycRoutes.dart';

class KycInitialLockCard extends StatelessWidget {
  const KycInitialLockCard({super.key});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const DeskNote(
            title: 'KYC Required',
            description:
                'Complete identity verification to access advisory messages.'),
        const SizedBox(height: 18),
        DeskButton(
            label: 'Start KYC',
            onPressed: () => Get.toNamed(KycRoutes.kycIndex)),
        const SizedBox(height: 18),
        const DeskSection('Your workspace'),
        const SizedBox(height: 8),
        const DeskNote(
            title: 'A secure research workspace',
            description:
                'Your advisory access follows your existing verification status.'),
      ]);
}
