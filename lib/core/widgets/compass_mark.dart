import 'package:flutter/material.dart';
import 'package:memory_compass/core/theme/app_colors.dart';

/// The MemoryCompass mark: a map pin standing in for a compass needle.
/// Brass tip north, ink tip south, same two-tone convention regardless of
/// context — only the outline adapts to sit on light or dark surfaces.
class CompassMark extends StatelessWidget {
  const CompassMark({super.key, this.size = 24, this.color});

  final double size;

  /// Outline/ring color. Defaults to the ambient icon color, falling back
  /// to onSurface.
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final outline =
        color ??
        IconTheme.of(context).color ??
        Theme.of(context).colorScheme.onSurface;
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _CompassMarkPainter(outline)),
    );
  }
}

class _CompassMarkPainter extends CustomPainter {
  _CompassMarkPainter(this.outlineColor);

  final Color outlineColor;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 100, size.height / 100);

    final pin = Path()
      ..moveTo(50, 93)
      ..cubicTo(33, 68, 15, 53, 15, 39)
      ..arcToPoint(
        const Offset(85, 39),
        radius: const Radius.circular(35),
        largeArc: true,
      )
      ..cubicTo(85, 53, 67, 68, 50, 93)
      ..close();
    canvas.drawPath(
      pin,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = outlineColor,
    );

    canvas.drawCircle(
      const Offset(50, 39),
      18,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = outlineColor.withValues(alpha: outlineColor.a * 0.9),
    );

    final north = Path()
      ..moveTo(50, 23)
      ..lineTo(61, 39)
      ..lineTo(39, 39)
      ..close();
    canvas.drawPath(north, Paint()..color = AppColors.brass);

    final south = Path()
      ..moveTo(50, 55)
      ..lineTo(61, 39)
      ..lineTo(39, 39)
      ..close();
    canvas.drawPath(south, Paint()..color = AppColors.ink);

    canvas.drawCircle(const Offset(50, 39), 2.6, Paint()..color = AppColors.paper);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _CompassMarkPainter oldDelegate) =>
      oldDelegate.outlineColor != outlineColor;
}
