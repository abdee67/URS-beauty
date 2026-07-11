import 'package:flutter/material.dart';

class StylistAvatar extends StatelessWidget {
  const StylistAvatar({super.key, required this.imageUrl});

  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;
    return CircleAvatar(
      radius: 28,
      backgroundColor: const Color(0xFFF8F1EA),
      backgroundImage: hasImage
          ? NetworkImage(imageUrl!)
          : const AssetImage('assets/images/stylist.png'),
    );
  }
}
