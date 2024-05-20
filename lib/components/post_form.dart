import 'dart:typed_data';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:uni_market/components/image_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:uni_market/helpers/functions.dart';
import 'dart:convert';
import 'dialog.dart';

class PostForm extends StatefulWidget {
  final Function(List<Widget> newItems, bool append, [bool? start])
      setHomeState;
  const PostForm({Key? key, required this.setHomeState}) : super(key: key);

  @override
  State<PostForm> createState() => _PostFormState();
}

class _PostFormState extends State<PostForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  final double _maxPrice = 10000.0;
  bool submitActive = true;

  bool submitting = false;
  bool isFlagged = false;
  List<String> _imageDataUrls = [];
  static int maxTags = 6;
  final List<String?> _tags = [];
  List<String?> _suggestedTags = [
    "desk",
    "chair",
    "lamp",
    "bed",
    "rug",
    "phone",
  ]; // temp tags

  @override
  initState() {
    // searchTags("", maxTags, [])
    //     .then((value) => setState(() => _suggestedTags = value));
    super.initState();
  }

  List<Widget> tagSuggestionsBuilder(String input) {
    // update _suggestedTags with tags from typesense
    // leave selected tags in place as the first couple in _suggestedTags, give an x button for those to de-select them
    List<Widget> selected = List.generate(_tags.length, (int index) {
      final background = Theme.of(context).colorScheme.background;
      return Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
          child: Container(
              decoration: BoxDecoration(
                  color: background,
                  border: Border.all(
                      color: background == Colors.white
                          ? Colors.black
                          : Colors.white),
                  borderRadius: const BorderRadius.all(Radius.circular(15))),
              child: Row(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(_tags[index]!)),
                  IconButton(
                      onPressed: () {
                        setState(() {
                          String? temp = _tags.removeAt(index);
                          _suggestedTags.add(temp);
                        });
                      },
                      icon: const Icon(Icons.close))
                ],
              )),
        ),
      );
    });

    List<Widget> suggested = List.generate(maxTags - _tags.length, (int index) {
      return Padding(
        padding: const EdgeInsets.all(2),
        child: InkWell(
            onTap: () => setState(() {
                  _tags.add(_suggestedTags[index]);
                  _suggestedTags.removeAt(index);
                  _tagsController.clear();
                }),
            child: Container(
              decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.background,
                  borderRadius: const BorderRadius.all(Radius.circular(15))),
              child: Padding(
                  padding: const EdgeInsets.only(
                      top: 5, bottom: 5, left: 10, right: 10),
                  child: Text(_suggestedTags[index]!)),
            )),
      );
    });

    return selected + suggested;
  }

  void _flag(bool flag) {
    setState(() => isFlagged = (isFlagged || flag));
  }

  Timer? _debounce;

  @override
  Widget build(BuildContext context) {
    return submitting
        ? SizedBox(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                ],
              ),
            ),
          )
        : FormBuilder(
            key: _fbKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Create a post!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                // Title box
                const SizedBox(height: 8),
                FormBuilderTextField(
                  name: 'title',
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(
                      labelText: 'Title',
                      suffixIcon: Tooltip(
                        message: 'Search for book by title entered',
                        child:
                            IconButton(onPressed: null, icon: Icon(Icons.book)),
                      )),
                  controller: _titleController,
                  validator: FormBuilderValidators.required(context),
                  maxLines: 1,
                  maxLength: 50, // Set a maximum character limit
                ),
                // Description
                const SizedBox(height: 8),
                FormBuilderTextField(
                  name: 'description',
                  controller: _descriptionController,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                  validator: FormBuilderValidators.required(context),
                  maxLength: 150, // Set a maximum character limit
                ),
                // Price Box
                const SizedBox(height: 8),
                FormBuilderTextField(
                  name: 'price',
                  controller: _priceController,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                  ),
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(context),
                    (value) {
                      // Custom validator for price format
                      if (value != null && !isValidPrice(value)) {
                        return 'Invalid price format';
                      }
                      if (value != null && double.parse(value) > _maxPrice) {
                        return 'Price cannot exceed \$${_maxPrice.toStringAsFixed(2)}';
                      }
                      return null;
                    },
                  ]),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),
                const SizedBox(height: 16),
                // Condition Box
                FormBuilderDropdown(
                  name: 'condition',
                  hint: const Text('Select Condition'),
                  items: ['USED', 'NEW', 'WORN']
                      .map((condition) => DropdownMenuItem(
                            value: condition,
                            child: Text(condition),
                          ))
                      .toList(),
                  validator: FormBuilderValidators.required(context),
                ),
                const SizedBox(height: 38),
                // check if tag is in list of tags (stored in firebase but for now just here)
                FormBuilderTextField(
                  name: 'tags',
                  style: const TextStyle(fontSize: 13),
                  decoration: const InputDecoration(labelText: 'Tags'),
                  controller: _tagsController,
                  maxLines: 1,
                  maxLength: 30,
                  onChanged: (value) {
                    if (_debounce?.isActive ?? false) _debounce?.cancel();
                    _debounce = Timer(const Duration(milliseconds: 350), () {
                      searchTags(value!, maxTags, _tags).then((value) {
                        setState(() => _suggestedTags = value);
                      });
                    });
                  },
                  onSubmitted: (value) {
                    if (_suggestedTags.contains(value)) {
                      setState(() {
                        _tags.add(value);
                        _tagsController.clear();
                      });
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                          content: Text('Tag not found, try again!')));
                      _tagsController.clear();
                    }
                  },
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: tagSuggestionsBuilder(_tagsController.text),
                  ),
                ),
                const SizedBox(height: 38),
                ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        shadowColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.0))),
                    onPressed: null,
                    child: Column(
                      children: [
                        const Text("Upload Image(s)",
                            style: TextStyle(fontSize: 12)),
                        if (_imageDataUrls.isNotEmpty)
                          const Text("✅",
                              style:
                                  TextStyle(fontSize: 20, color: Colors.green)),
                      ],
                    )),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      shadowColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0))),
                  onPressed: null,
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shadowColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0))),
                  onPressed: submitActive ==
                          false // disables button while waiting for response from API
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );
  }

  Future showOptions(BuildContext context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Photo Gallery'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from gallery
              getImageFromGallery();
            },
          ),
          CupertinoActionSheetAction(
            child: const Text('Camera'),
            onPressed: () {
              // close the options modal
              Navigator.of(context).pop();
              // get image from camera
              getImageFromCamera();
            },
          ),
        ],
      ),
    );
  }

  Future getImageFromGallery() async {
    List<XFile> clientImageFiles = await multiImagePicker(context);

    if (clientImageFiles.isNotEmpty) {
      List<String> dataUrls = await convertXFilesToDataUrls(clientImageFiles);

      // Show the pop-up dialog for image confirmation
      if (context.mounted) {
        String confirmSelection = await showDialog(
          context: context,
          builder: (BuildContext context) {
            // Assign the captured context
            return ImageCarouselDialog(imageDataUrls: dataUrls);
          },
        );

        // Check if the user confirmed the selection
        if (confirmSelection == 'yes') {
          setState(() {
            _imageDataUrls = dataUrls;
          });

          if (await moderateSelectedImages(dataUrls) == true) {
            _flag(true);
          }
        }
      }
    }
  }

  Future getImageFromCamera() async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);
    if (image != null) {
      List<String> dataUrls = await convertXFilesToDataUrls([image]);

      // Show the pop-up dialog for image confirmation
      if (context.mounted) {
        String confirmSelection = await showDialog(
          context: context,
          builder: (BuildContext context) {
            // Assign the captured context
            return ImageCarouselDialog(
                imageDataUrls: dataUrls, cameraBasedImage: true);
          },
        );

        // Check if the user confirmed the selection
        if (confirmSelection == 'yes') {
          setState(() {
            _imageDataUrls = dataUrls;
          });
          if (await moderateSelectedImages(dataUrls) == true) {
            _flag(true);
          }
        }
        if (confirmSelection == 'more') {
          XFile? secondImage =
              await ImagePicker().pickImage(source: ImageSource.camera);
          if (secondImage != null) {
            List<String> secondDataUrls =
                await convertXFilesToDataUrls([image, secondImage]);
            // Show the pop-up dialog for image confirmation
            if (context.mounted) {
              String confirmSelection = await showDialog(
                context: context,
                builder: (BuildContext context) {
                  // Assign the captured context
                  return ImageCarouselDialog(
                      imageDataUrls: secondDataUrls, cameraBasedImage: true);
                },
              );
              // Check if the user confirmed the selection
              if (confirmSelection == 'yes') {
                setState(() {
                  _imageDataUrls = secondDataUrls;
                });
                if (isFlagged != true) {
                  List<String> tempUrl = [];
                  tempUrl.add(secondDataUrls[1]);
                  if (await moderateSelectedImages(tempUrl) == true) {
                    _flag(true);
                  }
                }
              }
              if (confirmSelection == 'more') {
                XFile? thirdImage =
                    await ImagePicker().pickImage(source: ImageSource.camera);
                if (thirdImage != null) {
                  List<String> secondDataUrls = await convertXFilesToDataUrls(
                      [image, secondImage, thirdImage]);

                  // Show the pop-up dialog for image confirmation
                  if (context.mounted) {
                    String confirmSelection = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        // Assign the captured context
                        return ImageCarouselDialog(
                            imageDataUrls: secondDataUrls);
                      },
                    );

                    // Check if the user confirmed the selection
                    if (confirmSelection == 'yes') {
                      setState(() {
                        _imageDataUrls = secondDataUrls;
                      });
                      if (isFlagged != true) {
                        List<String> tempUrl = [];
                        tempUrl.add(secondDataUrls[2]);
                        if (await moderateSelectedImages(tempUrl) == true) {
                          _flag(true);
                        }
                      }
                    }
                  }
                }
              }
            }
          }
        }
      }
    }
  }

  // Helper functions for input form to database document

  bool isValidPrice(String? value) {
    if (value == null) {
      return false;
    }

    // Regular expression to match a valid price format (e.g., 123.45)
    final RegExp priceRegex = RegExp(r'^\d+(\.\d{1,2})?$');
    return priceRegex.hasMatch(value);
  }
}

// Helper functions Converting XFile to String
Future<String> convertImageToDataUrl(XFile imageFile) async {
  List<int> imageBytes = await imageFile.readAsBytes();
  String dataUrl =
      'data:image/${imageFile.name.split('.').last};base64,${base64Encode(Uint8List.fromList(imageBytes))}';
  return dataUrl;
}

// Function for uploading selected post images to firebase
Future uploadImages(
    List<String> imageDataUrls, Completer<List<String>> completer) async {
  List<String> imageNames = [];
  // Create a firebase storage reference from app
  final storageRef = FirebaseStorage.instance.ref();

  await Future.forEach(imageDataUrls, (String dataUrl) async {
    // Extract image data from data URL
    Uint8List imageBytes = base64Decode(dataUrl.split(',').last);

    // Generate unique image reference in firebase image collection
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final imageRef = storageRef.child("images/$fileName.jpg");
    imageNames.add("images/$fileName.jpg");

    try {
      await imageRef.putData(imageBytes);
    } on FirebaseException catch (e) {
      // Undeveloped catch case for firebase write error
      if (kDebugMode) {
        print(e);
      }
    }
  });
  completer.complete(imageNames);
}

Future<List<XFile>> multiImagePicker(context) async {
  List<XFile>? images = await ImagePicker().pickMultiImage();
  if (images.isNotEmpty && images.length <= 3) {
    return images;
  } else if (images.isNotEmpty && images.length > 3) {
    showDialog<String>(
        context: context,
        builder: (BuildContext context) => appDialog(context, 'Too many images',
            'Please select only three images to upload with your post.', 'Ok'));
  }
  return [];
}

Future<List<String>> convertXFilesToDataUrls(List<XFile> xFiles) async {
  List<String> dataUrls = [];

  for (XFile xFile in xFiles) {
    String dataUrl = await convertImageToDataUrl(xFile);
    dataUrls.add(dataUrl);
  }
  return dataUrls;
}

Future<bool> moderateSelectedImages(List<String> imageUrls) async {
  bool containsIllicitContent = false;
  for (var url in imageUrls) {
    try {
      var response = await FirebaseFunctions.instance
          .httpsCallable("image_moderation")
          .call({"imageUrl": url});
      Map<String, dynamic> jsonModerationResponse = jsonDecode(response.data);
      if (jsonModerationResponse["final_decision"] == "KO" &&
          jsonModerationResponse["confidence_score_decision"] > 0.8) {
        containsIllicitContent = true;
        break;
      }
    } catch (e) {
      if (kDebugMode) {
        print("Error, failed http post: $e");
      }
    }
  }
  return containsIllicitContent;
}

makeBookImage(cover, title) {
  return Image.network('https://covers.openlibrary.org/b/ID/$cover-L.jpg',
      height: 500, width: 316, loadingBuilder: (BuildContext context,
          Widget child, ImageChunkEvent? loadingProgress) {
    if (loadingProgress == null) return child;
    return SizedBox(
      height: 500,
      width: 316,
      child: Center(
        child: Column(
          children: [
            Text("book loading: $title"),
            const CircularProgressIndicator(
              color: Colors.indigoAccent,
            ),
          ],
        ),
      ),
    );
  });
}
