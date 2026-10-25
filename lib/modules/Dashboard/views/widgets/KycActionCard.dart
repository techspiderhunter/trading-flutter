import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../themes/AppColors.dart';
import '../../../Kyc/routes/KycRoutes.dart';

class KycActionCard extends StatelessWidget {
  const KycActionCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF192542), Color(0xFF192542)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF192542).withValues(alpha: 0.18),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background decorative glow
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 130,
              height: 130,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primary.withValues(alpha: 0.15),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded,
                              color: Color(0xFFD97706), size: 14),
                          SizedBox(width: 5),
                          Text(
                            'Action Required',
                            style: TextStyle(
                              fontFamily: 'DeskSans',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD97706),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Text(
                      'SEBI Mandate',
                      style: TextStyle(
                        fontFamily: 'DeskSans',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Complete Your Regulatory KYC',
                  style: TextStyle(
                    fontFamily: 'DeskSans',
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'As mandated by SEBI (Research Analysts) Regulations, 2014, complete verification to unlock premium research calls & advisory feeds.',
                  style: TextStyle(
                    fontFamily: 'DeskSans',
                    fontSize: 12.5,
                    color: Color(0xFFCBD5E1),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.toNamed(KycRoutes.kycIndex);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Complete KYC Now',
                          style: TextStyle(
                            fontFamily: 'DeskSans',
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded,
                            size: 16, color: Colors.white),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
