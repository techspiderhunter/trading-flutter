import 'package:flutter/material.dart';

/// Exact reproduction of User Image 2:
/// "Your Document Verification is Under Review" card with lock icon and remark,
/// strictly WITHOUT any button inside the card.
class KycUnderReviewCard extends StatelessWidget {
  final String? referenceId;

  const KycUnderReviewCard({super.key, this.referenceId});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFFDE68A), // Light amber border from Image 2
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF59E0B).withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Circular Amber Badge with Lock Icon (Image 2)
          Container(
            width: 76,
            height: 76,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF7ED),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Container(
                width: 60,
                height: 60,
                decoration: const BoxDecoration(
                  color: Color(0xFFFEF3C7), // Amber circle
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Color(0xFFD97706), // Amber lock
                  size: 32,
                ),
              ),
            ),
          ),
          const SizedBox(height: 22),

          // Title / Remark from Image 2
          const Text(
            'Your Document Verification is Under Review',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 19,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
              letterSpacing: -0.3,
              height: 1.25,
            ),
          ),
          if (referenceId != null && referenceId!.isNotEmpty) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Text(
                'Reference: $referenceId',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFFB45309),
                ),
              ),
            ),
          ],
          const SizedBox(height: 12),

          // Subtitle / Remark from Image 2
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 6),
            child: Text(
              'Advisory bulletins, market recommendations, and direct communication feeds are locked while your identity documents are undergoing compliance review.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: Color(0xFF64748B),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
