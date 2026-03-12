import 'package:currencyx/common/constants/colors.dart';
import 'package:flutter/material.dart';

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({required this.icon, required this.label, super.key});
  
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, size: 14, color: AppColors.labelTextColor),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.labelTextColor,
        ),
      ),
    ],
  );
}
