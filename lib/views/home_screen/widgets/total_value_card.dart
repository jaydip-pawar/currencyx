import 'package:currencyx/common/constants/colors.dart';
import 'package:flutter/material.dart';

class TotalValueCard extends StatelessWidget {
  const TotalValueCard({
    required this.totalValue,
    required this.baseCurrency,
    required this.baseCurrencyLabel,
    super.key,
  });

  final String totalValue;
  final String baseCurrency;
  final String baseCurrencyLabel;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: AppColors.primaryColor,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryColor.withValues(alpha: .3),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Total Value ($baseCurrency)',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.white.withValues(alpha: .8),
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              totalValue,
              style: const TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              baseCurrency,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.white.withValues(alpha: .8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.white.withValues(alpha: .15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.info_outline,
                size: 14,
                color: AppColors.white.withValues(alpha: .9),
              ),
              const SizedBox(width: 6),
              Text(
                'Base currency: $baseCurrencyLabel',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.white.withValues(alpha: .9),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
