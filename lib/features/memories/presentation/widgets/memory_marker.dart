import 'dart:io';

import 'package:flutter/material.dart';
import 'package:memory_compass/features/memories/domain/entities/memory_pin.dart';

class MemoryMarker extends StatelessWidget {
  const MemoryMarker({super.key, required this.pin, required this.onTap});

  final MemoryPin pin;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
          image: DecorationImage(
            image: FileImage(File(pin.photoPath)),
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
