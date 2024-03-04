import 'package:flutter/material.dart';
import 'dart:convert';

class SelectedImagesThumbnail extends StatelessWidget {
  final List<String> imageDataUrls;

  const SelectedImagesThumbnail({super.key, required this.imageDataUrls});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: imageDataUrls.map((imageUrl) {
        return Container(
          width: 50.0,
          height: 50.0,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.0),
            image: DecorationImage(
              image: MemoryImage(base64Decode(imageUrl.split(',')[1])),
              fit: BoxFit.cover,
            ),
          ),
        );
      }).toList(),
    );
  }
}
