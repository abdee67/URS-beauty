import 'package:flutter/material.dart';

class StylistAvatar extends StatelessWidget {
  const StylistAvatar({super.key, required this.imageUrl});

  final String imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl.trim().isNotEmpty;
    return CircleAvatar(
      radius: 28,
      backgroundColor: const Color(0xFFF8F1EA),
      backgroundImage: hasImage ? NetworkImage(imageUrl) : null,
      child: hasImage
          ? null
          : const Icon(Icons.face_rounded, color: Color(0xFFC96A3D)),
    );
  }
}