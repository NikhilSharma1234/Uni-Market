import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';

class ImageCarouselDialog extends StatelessWidget {
  final List<String> imageDataUrls;

  ImageCarouselDialog({required this.imageDataUrls});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Container(
        width: 300, // Set a fixed width
        height: 300, // Set a fixed height
        child: CarouselSlider(
          options: CarouselOptions(
            height: 200.0,
            enlargeCenterPage: true,
            autoPlay: false,
            enableInfiniteScroll: false,
          ),
          items: imageDataUrls.map((imageUrl) {
            return Builder(
              builder: (BuildContext context) {
                return Container(
                  width: MediaQuery.of(context).size.width,
                  margin: EdgeInsets.symmetric(horizontal: 5.0),
                  child: Image.memory(
                    base64Decode(imageUrl.split(',')[1]),
                    fit: BoxFit.cover,
                  ),
                );
              },
            );
          }).toList(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false); // Cancel
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(true); // Confirm
          },
          child: Text('Confirm'),
        ),
      ],
    );
  }
}
