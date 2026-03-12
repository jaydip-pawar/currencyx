import 'package:currencyx/common/constants/colors.dart';
import 'package:flutter/material.dart';

class AddCurrencyButton extends StatelessWidget {
  const AddCurrencyButton({required this.onPressed, super.key});
  final VoidCallback onPressed;

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
          border: Border.all(
            color: AppColors.bulletColor,
            width: 2,
            style: BorderStyle.solid,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_circle_outline,
              color: AppColors.labelTextColor,
              size: 22,
            ),
            SizedBox(width: 8),
            Text(
              'Add Currency',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.labelTextColor,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
