import 'dart:io';

import 'package:flutter/material.dart';

class FullScreenPhotoView extends StatelessWidget {
  const FullScreenPhotoView({
    super.key,
    required this.photoPath,
    required this.heroTag,
  });

  final String photoPath;
  final Object heroTag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      extendBodyBehindAppBar: true,
      body: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Center(
          child: Hero(
            tag: heroTag,
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 4,
              child: Image.file(File(photoPath)),
            ),
          ),
        ),
      ),
    );
  }
}
