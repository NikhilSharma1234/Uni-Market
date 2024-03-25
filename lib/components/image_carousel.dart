import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';

class ImageCarouselDialog extends StatefulWidget {
  final List<String> imageDataUrls;
  final bool? cameraBasedImage;
  const ImageCarouselDialog(
      {Key? key, this.cameraBasedImage, required this.imageDataUrls})
      : super(key: key);

  @override
  State<ImageCarouselDialog> createState() => ImageCarouselDialogState();
}

class ImageCarouselDialogState extends State<ImageCarouselDialog> {
  imagesBuilder(imageDataUrls, cameraBasedImage) {
    List<Widget> images = [];
    for (String imageUrl in imageDataUrls) {
      images.add(Builder(
        builder: (BuildContext context) {
          return Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 5.0),
            child: Image.memory(
              base64Decode(imageUrl.split(',')[1]),
              fit: BoxFit.cover,
            ),
          );
        },
      ));
    }

    Widget plusButton = Builder(
      builder: (BuildContext context) {
        return InkWell(
            onTap: () {
              Navigator.of(context).pop('more');
            },
            child: Container(
                color: Colors.white,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                child: const Icon(
                  Icons.add,
                  color: Colors.black,
                )));
      },
    );
    if (cameraBasedImage != null && cameraBasedImage == true) {
      images.add(plusButton);
    }
    return images.toList();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: SizedBox(
        width: 300, // Set a fixed width
        height: 300, // Set a fixed height
        child: CarouselSlider(
            options: CarouselOptions(
              height: 200.0,
              enlargeCenterPage: true,
              autoPlay: false,
              enableInfiniteScroll: false,
            ),
            items:
                imagesBuilder(widget.imageDataUrls, widget.cameraBasedImage)),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop('no'); // Cancel
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop('yes'); // Confirm
          },
          child: const Text('Confirm'),
        ),
      ],
    );
  }
}
