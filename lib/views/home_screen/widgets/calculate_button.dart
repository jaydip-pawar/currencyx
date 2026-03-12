import 'package:currencyx/common/constants/colors.dart';
import 'package:flutter/material.dart';

class CalculateButton extends StatelessWidget {
  const CalculateButton({
    required this.onPressed,
    this.isLoading = false,
    super.key,
  });

  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) => Material(
    color: AppColors.transparent,
    child: InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: onPressed != null
              ? AppColors.primaryColor
              : AppColors.primaryColor.withValues(alpha: .6),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withValues(alpha: .4),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isLoading)
              const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  color: AppColors.white,
                  strokeWidth: 2.5,
                ),
              )
            else
              const Icon(
                Icons.calculate_outlined,
                color: AppColors.white,
                size: 24,
              ),
            const SizedBox(width: 10),
            Text(
              isLoading ? 'Calculating...' : 'Calculate Total',
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
