import 'package:currencyx/common/colors.dart';
import 'package:flutter/material.dart';

class LoadingProgressBar extends StatefulWidget {
  const LoadingProgressBar({super.key});

  @override
  State<LoadingProgressBar> createState() => _LoadingProgressBarState();
}

class _LoadingProgressBarState extends State<LoadingProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 6,
        width: double.infinity,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, _) => CustomPaint(
            painter: _ProgressBarPainter(
              progress: _controller.value,
              foregroundColor: AppColors.primaryColor,
              backgroundColor: AppColors.primaryColorShadowColor,
            ),
          ),
        ),
      );
}

class _ProgressBarPainter extends CustomPainter {
  _ProgressBarPainter({
    required this.progress,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final double progress;
  final Color foregroundColor;
  final Color backgroundColor;

  static const double _barFraction = 0.40;

  @override
  void paint(Canvas canvas, Size size) {
    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.fill;

    final foregroundPaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.fill;

    final radius = Radius.circular(size.height / 2);

    // Draw full background track
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.width, size.height),
        radius,
      ),
      backgroundPaint,
    );

    final barWidth = size.width * _barFraction;

    // Bar travels from fully off-screen left (-barWidth)
    // to fully off-screen right (size.width).
    // At progress=0 → barLeft = -barWidth (fully hidden left)
    // At progress=1 → barLeft =  size.width (fully hidden right)
    final barLeft = -barWidth + progress * (size.width + barWidth);
    final barRight = barLeft + barWidth;

    // Clip to visible track area before drawing
    final visibleLeft = barLeft.clamp(0.0, size.width);
    final visibleRight = barRight.clamp(0.0, size.width);

    if (visibleRight > visibleLeft) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(visibleLeft, 0, visibleRight, size.height),
          radius,
        ),
        foregroundPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_ProgressBarPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.foregroundColor != foregroundColor ||
      oldDelegate.backgroundColor != backgroundColor;
}
