import 'package:flutter/material.dart';
import 'package:uni_market/image_data_store.dart'; // Ensure this path is correct

class AppBarTitleWithImage extends StatelessWidget {
  final String title;
  final String? imagePath; // Make this nullable

  const AppBarTitleWithImage({
    Key? key,
    required this.title,
    this.imagePath, // Now nullable
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If no imagePath is provided, just return the title
    if (imagePath == null) {
      return Text(title);
    }

    // Proceed with fetching the image if imagePath is provided
    return FutureBuilder<String?>(
      future: ImageDataStore().getImageUrl(imagePath!),
      builder: (context, snapshot) {
        Widget leadingWidget = const CircleAvatar(
          backgroundColor: Colors.grey,
          child: Icon(Icons.person, color: Colors.white),
        );

        if (snapshot.connectionState == ConnectionState.waiting) {
          leadingWidget = const CircleAvatar(
            backgroundColor: Colors.grey,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          );
        } else if (snapshot.hasData) {
          leadingWidget = CircleAvatar(
            backgroundImage: NetworkImage(snapshot.data!),
          );
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leadingWidget,
            const SizedBox(width: 8),
            Expanded(child: Text(title, overflow: TextOverflow.ellipsis)),
          ],
        );
      },
    );
  }
}