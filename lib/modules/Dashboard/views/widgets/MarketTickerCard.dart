import 'package:flutter/material.dart';
import '../../../../themes/AppColors.dart';

class MarketTickerCard extends StatelessWidget {
  const MarketTickerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Market Watchlist',
              style: TextStyle(
                fontFamily: 'DeskSans',
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Row(
              children: [
                Icon(Icons.fiber_manual_record,
                    color: AppColors.primary, size: 10),
                const SizedBox(width: 4),
                Text(
                  'Market Open',
                  style: TextStyle(
                    fontFamily: 'DeskSans',
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
            children: [
              _buildIndexItem(
                name: 'NIFTY 50',
                value: '25,014.30',
                change: '+178.40 (+0.72%)',
                isPositive: true,
              ),
              const SizedBox(width: 12),
              _buildIndexItem(
                name: 'BANK NIFTY',
                value: '51,320.15',
                change: '+432.80 (+0.85%)',
                isPositive: true,
              ),
              const SizedBox(width: 12),
              _buildIndexItem(
                name: 'SENSEX',
                value: '81,890.20',
                change: '+550.10 (+0.68%)',
                isPositive: true,
              ),
              const SizedBox(width: 12),
              _buildIndexItem(
                name: 'FIN NIFTY',
                value: '23,640.80',
                change: '+192.40 (+0.82%)',
                isPositive: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIndexItem({
    required String name,
    required String value,
    required String change,
    required bool isPositive,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: const TextStyle(
              fontFamily: 'DeskSans',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'DeskSans',
              fontSize: 17,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: isPositive ? AppColors.successBg : AppColors.errorBg,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isPositive
                      ? Icons.arrow_drop_up_rounded
                      : Icons.arrow_drop_down_rounded,
                  size: 16,
                  color: isPositive ? AppColors.primary : AppColors.error,
                ),
                Text(
                  change,
                  style: TextStyle(
                    fontFamily: 'DeskSans',
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: isPositive ? AppColors.primaryDark : AppColors.error,
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
