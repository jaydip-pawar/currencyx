import 'package:currencyx/common/colors.dart';
import 'package:flutter/material.dart';

class LabelIcon extends StatelessWidget {
  const LabelIcon({
    required this.icon,
    required this.label,
    this.showBullet = true,
    super.key,
  });

  final IconData icon;
  final String label;
  final bool showBullet;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 1.67),
        child: Icon(icon, color: AppColors.primaryColor, size: 11.67),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          height: 15 / 10,
          color: AppColors.labelTextColor,
        ),
      ),
      if (showBullet) ...[
        const SizedBox(width: 16),
        Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            color: AppColors.bulletColor,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 16),
      ],
    ],
  );
}
