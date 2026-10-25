import 'package:flutter/material.dart';
import '../../../../themes/AppColors.dart';

class AdvisoryServiceCard extends StatelessWidget {
  const AdvisoryServiceCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Trading & Advisory Desks',
          style: TextStyle(
            fontFamily: 'DeskSans',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),

        // Service 1: Cash Market Research
        _buildServiceCard(
          title: 'Cash Market Research',
          tag: 'Intraday & Swing',
          tagColor: AppColors.primary,
          tagBg: AppColors.primaryLight,
          description:
              'High-conviction equity calls with pre-defined entries, stop-loss & risk:reward targets.',
          icon: Icons.show_chart_rounded,
          iconColor: AppColors.primary,
          iconBg: AppColors.primaryLight,
          accuracy: '86% Accuracy',
          riskLevel: 'Moderate Risk',
        ),
        const SizedBox(height: 12),

        // Service 2: Options & Futures Alpha
        _buildServiceCard(
          title: 'Options & Futures Alpha',
          tag: 'Index & Stock F&O',
          tagColor: const Color(0xFF6366F1),
          tagBg: const Color(0xFFEEF2FF),
          description:
              'Data-backed derivative hedging setups & momentum breakout strategies for Nifty / BankNifty.',
          icon: Icons.bolt_rounded,
          iconColor: const Color(0xFF6366F1),
          iconBg: const Color(0xFFEEF2FF),
          accuracy: '89% Accuracy',
          riskLevel: 'High Velocity',
        ),
        const SizedBox(height: 12),

        // Service 3: Wealth Portfolios
        _buildServiceCard(
          title: 'Long-Term Wealth Portfolios',
          tag: 'Wealth Creation',
          tagColor: const Color(0xFFD97706),
          tagBg: const Color(0xFFFEF3C7),
          description:
              'Curated portfolio of fundamentally solid growth businesses compounders for 2-5 year horizons.',
          icon: Icons.pie_chart_outline_rounded,
          iconColor: const Color(0xFFD97706),
          iconBg: const Color(0xFFFEF3C7),
          accuracy: 'CAGR: 24.5%',
          riskLevel: 'Long Term',
        ),
      ],
    );
  }

  Widget _buildServiceCard({
    required String title,
    required String tag,
    required Color tagColor,
    required Color tagBg,
    required String description,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String accuracy,
    required String riskLevel,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: iconColor, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'DeskSans',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        tag,
                        style: TextStyle(
                          fontFamily: 'DeskSans',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: tagColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14,
                color: AppColors.textMuted,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: const TextStyle(
              fontFamily: 'DeskSans',
              fontSize: 12.5,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _buildBadge(
                  Icons.check_circle_rounded, accuracy, AppColors.primary),
              const SizedBox(width: 10),
              _buildBadge(
                  Icons.shield_outlined, riskLevel, AppColors.textSecondary),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'DeskSans',
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
