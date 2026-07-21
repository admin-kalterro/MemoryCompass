import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memory_compass/core/theme/app_colors.dart';
import 'package:memory_compass/features/memories/domain/entities/memory_pin.dart';

/// A photo pinned to the map, shaped like the app's mark: a teardrop with
/// the photo standing in for the compass face.
class MemoryMarker extends StatelessWidget {
  const MemoryMarker({super.key, required this.pin, required this.onTap});

  final MemoryPin pin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: PhysicalShape(
        clipper: const _PinClipper(),
        color: AppColors.brass,
        elevation: 3,
        shadowColor: Colors.black54,
        child: Padding(
          padding: const EdgeInsets.all(3),
          child: ClipPath(
            clipper: const _PinClipper(),
            child: Image.file(File(pin.photoPath), fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }
}

/// The same teardrop outline as [CompassMark], in 0-100 space, scaled to
/// whatever size the marker is given.
class _PinClipper extends CustomClipper<Path> {
  const _PinClipper();

  @override
  Path getClip(Size size) {
    final sx = size.width / 100;
    final sy = size.height / 100;
    return Path()
      ..moveTo(50 * sx, 93 * sy)
      ..cubicTo(33 * sx, 68 * sy, 15 * sx, 53 * sy, 15 * sx, 39 * sy)
      ..arcToPoint(
        Offset(85 * sx, 39 * sy),
        radius: Radius.elliptical(35 * sx, 35 * sy),
        largeArc: true,
      )
      ..cubicTo(85 * sx, 53 * sy, 67 * sx, 68 * sy, 50 * sx, 93 * sy)
      ..close();
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
