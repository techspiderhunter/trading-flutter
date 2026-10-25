import 'package:flutter/material.dart';
import '../../../../widgets/DeskUi.dart';
import '../../../../themes/colors.dart';

class KycUnderReviewCard extends StatelessWidget {
  final String? referenceId;
  const KycUnderReviewCard({super.key, this.referenceId});
  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        DeskNote(
            title: 'Under Review',
            description:
                'Your submitted identity documents are being reviewed.${referenceId != null && referenceId!.isNotEmpty ? '\nReference: $referenceId' : ''}',
            color: AppColors.warning,
            icon: Icons.schedule_rounded),
        const SizedBox(height: 18),
        const DeskSection('Your workspace'),
        const SizedBox(height: 8),
        const DeskNote(
            title: 'A secure research workspace',
            description:
                'Your advisory access follows your existing verification status.'),
      ]);
}
