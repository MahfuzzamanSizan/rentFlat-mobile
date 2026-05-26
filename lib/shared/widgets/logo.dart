import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class RentEaseLogo extends StatelessWidget {
  final double size;
  final bool showShadow;

  const RentEaseLogo({super.key, this.size = 80, this.showShadow = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.45),
                  blurRadius: size * 0.4,
                  spreadRadius: size * 0.04,
                  offset: Offset(0, size * 0.12),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: size * 0.2,
                  offset: Offset(0, size * 0.06),
                ),
              ]
            : null,
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // House body
          CustomPaint(
            size: Size(size * 0.58, size * 0.58),
            painter: _HouseLogoPainter(),
          ),
          // Verified badge
          Positioned(
            bottom: size * 0.13,
            right: size * 0.13,
            child: Container(
              width: size * 0.26,
              height: size * 0.26,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.primaryGradient.colors.last,
                  width: size * 0.025,
                ),
              ),
              child: Icon(
                Icons.check_rounded,
                size: size * 0.15,
                color: AppColors.secondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HouseLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Roof (triangle)
    final roofPath = Path()
      ..moveTo(w * 0.5, 0)
      ..lineTo(w, h * 0.42)
      ..lineTo(0, h * 0.42)
      ..close();
    canvas.drawPath(roofPath, paint);

    // Main body
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.1, h * 0.38, w * 0.8, h * 0.62),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(bodyRect, paint);

    // Door (contrasting color)
    final doorPaint = Paint()
      ..color = AppColors.secondary.withOpacity(0.7)
      ..style = PaintingStyle.fill;
    final doorRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.36, h * 0.62, w * 0.28, h * 0.38),
      Radius.circular(w * 0.04),
    );
    canvas.drawRRect(doorRect, doorPaint);
  }

  @override
  bool shouldRepaint(_) => false;
}

// Inline logo (logo mark + wordmark side by side)
class RentEaseLogoHorizontal extends StatelessWidget {
  final double logoSize;
  final Color textColor;

  const RentEaseLogoHorizontal({
    super.key,
    this.logoSize = 38,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        RentEaseLogo(size: logoSize, showShadow: false),
        const SizedBox(width: 10),
        Text(
          'RentEase',
          style: TextStyle(
            color: textColor,
            fontSize: logoSize * 0.58,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.3,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
