import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:uni_market/components/ItemGeneration/abstract_item_factory.dart';
import 'package:uni_market/components/ItemGeneration/item.dart';
import 'package:uni_market/components/image_carousel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:uni_market/helpers/functions.dart';
import 'package:uni_market/pages/item_page.dart';
import 'dart:convert';
import 'dialog.dart';
import 'package:uni_market/helpers/profanity_checker.dart';
import 'package:uni_market/data_store.dart' as data_store;
import 'package:http/http.dart' as http;
import 'package:image_network/image_network.dart';

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
    searchTags("", maxTags, [])
        .then((value) => setState(() => _suggestedTags = value));
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
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;

    // shows the books dialog and handles logic
    AlertDialog showBooks(value) {
      return AlertDialog(
          insetPadding: EdgeInsets.all(screenWidth * 0.05),
          title: const Center(
            child: Text(
                'Here are the books we found, please scroll through and select the correct one'),
          ),
          content: SizedBox(
            width: screenWidth * 0.9,
            height: screenHeight * 0.7,
            child: ListView(
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                children: [
                  for (var book in value['docs'])
                    Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            // update form info with book autofill
                            _titleController.text =
                                book['title'] ?? 'Not Found';
                            if (_titleController.text.length > 50) {
                              _titleController.text.substring(0, 50);
                            }
                            if (book['isbn'] != null && book['isbn'] != []) {
                              _descriptionController.text =
                                  "Isbn: ${book['isbn'][0] ?? 'Not Found'}\nAuthor: ${book['author_name'][0] ?? 'Not Found'}";
                            } else {
                              _descriptionController.text =
                                  "Info on book not found";
                            }

                            _tags.add('book');
                            if (_suggestedTags.contains('book')) {
                              _suggestedTags.remove('book');
                            } else {
                              _suggestedTags.removeLast();
                            }
                            // update tags with book related ones
                            searchTags('book', maxTags, _tags).then((value) {
                              setState(() => _suggestedTags = value);
                            });
                          });
                          Navigator.of(context).pop();
                        },
                        child: book['cover_i'] != null
                            ? makeBookImage(book['cover_i'], book['title'])
                            : Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  height: 500,
                                  width: 316,
                                  child: Text(
                                    "No image found for ${book['title']} \n\nAuthor: ${book['author_name'][0]} \n\nISBN: ${book['isbn'] ?? 'Not Found'}",
                                  ),
                                ),
                              ),
                      ),
                    )
                ]),
          ));
    }

    return submitting
        ? const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(child: CircularProgressIndicator()),
              ],
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
                  decoration: InputDecoration(
                      labelText: 'Title',
                      suffixIcon: Tooltip(
                        message: 'Search for book by title entered',
                        child: IconButton(
                            onPressed: () {
                              getBookbyName(_titleController.value.text)
                                  .then((value) {
                                if (value['num_found'] > 0) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return showBooks(value);
                                      });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Book not found, try again!')));
                                }
                              });
                            },
                            icon: const Icon(Icons.book)),
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
                    _debounce = Timer(const Duration(milliseconds: 500), () {
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
                    onPressed: () async {
                      if (kIsWeb) {
                        List<XFile> clientImageFiles =
                            await multiImagePicker(context);

                        if (clientImageFiles.isNotEmpty) {
                          List<String> dataUrls =
                              await convertXFilesToDataUrls(clientImageFiles);

                          // Show the pop-up dialog for image confirmation
                          if (context.mounted) {
                            String confirmSelection = await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                // Assign the captured context
                                return ImageCarouselDialog(
                                    imageDataUrls: dataUrls);
                              },
                            );

                            // Check if the user confirmed selected images
                            if (confirmSelection == 'yes') {
                              setState(() {
                                _imageDataUrls = dataUrls;
                              });

                              if (await moderateSelectedImages(dataUrls) ==
                                  true) {
                                _flag(true);
                              }
                            }
                          }
                        }
                      } else {
                        showOptions(context);
                      }
                    },
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
                  onPressed: () async {
                    // Check form data validitiy
                    if (_fbKey.currentState!.saveAndValidate()) {
                      // Store form data in Map for db upload
                      Map<String, dynamic> formData =
                          Map.from(_fbKey.currentState!.value);
                      String inputText =
                          formData["title"] + " " + formData["description"];

                      if (isFlagged != true) {
                        try {
                          checkProfanity(inputText, checkStrength: false)
                              .then((value) => _flag(value));
                        } catch (e) {
                          if (kDebugMode) {
                            print("Failed to perform profanity checking: $e");
                          }
                        }
                      }

                      _createPost(context, formData, _imageDataUrls);
                    }
                  },
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
                  onPressed: () => Navigator.pop(context),
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
  Future<void> _createPost(
    BuildContext context,
    Map<String, dynamic> formData,
    List<String> imageDataUrls,
  ) async {
    try {
      // Pop Up Post Creation Snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Creating your post')),
      );

      // Update Post Form State
      setState(() => submitting = true);

      // Upload images to firebase storage before generating post document
      try {
        Completer<List<String>> completer = Completer<List<String>>();
        uploadImages(imageDataUrls, completer);
        List<String> downloadUrls = await completer.future;
        formData["images"] = downloadUrls;
      } catch (e) {
        if (kDebugMode) {
          print("Error uploading images: $e");
        }
        return;
      }

      // create userPost map for firebase document data
      final userPost = <String, dynamic>{
        "buyerId": null,
        "condition": formData["condition"],
        "deletedAt": null,
        "createdAt": Timestamp.now(),
        "dateUpdated": Timestamp.now(),
        "description": formData["description"],
        "images": formData["images"],
        "marketplaceId": data_store.user.marketplaceId,
        "name": formData["title"],
        "price": double.parse(formData["price"]),
        "schoolId": data_store.user.schoolId,
        "sellerId": data_store.user.email,
        "isFlagged": isFlagged,
        "tags": FieldValue.arrayUnion(_tags),
        "lastReviewedBy": null
      };

      // POTENTIAL PLACEHOLDER FOR UNACCEPTABLE STRING CHECKING (profanity, racism ...)

      // create post in db

      DocumentReference userItemUploaded =
          await FirebaseFirestore.instance.collection("items").add(userPost);

      userPost['id'] = userItemUploaded.id;
      userPost['tags'] = _tags;
      if (userPost['images'].length == 0) {
        userPost['images'] = [data_store.missingImage];
      } else {
        for (int i = 0; i < userPost['images'].length; i++) {
          userPost['images'][i] = await getURL(userPost['images'][i]);
        }
      }

      // show see post dialog upon successful creation
      if (context.mounted) {
        // create item and add
        AbstractItemFactory factory = AbstractItemFactory();
        widget.setHomeState(
            [factory.buildItemBox(Item.fromFirebase(userPost), context)],
            false,
            true);
        setState(() {
          submitting = false;
        });
        Navigator.of(context).pop();
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Congratulations!'),
              content: const Text('You have successfully created a post.'),
              actions: [
                TextButton(
                  onPressed: () async {
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) {
                            return ItemPage(data: Item.fromFirebase(userPost));
                          },
                        ),
                      );
                    }
                  },
                  child: const Text('Click here to view your post'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Show failure snackbar
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create post')),
        );
      }
      throw ("failed async for create post");
    }
  }

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

  String apiKey = '2Pv9xBw29ZaqthAphAIcM2Ke4Ey1kbbO'; // Your PicPurify API key
  String task = 'porn_moderation,drug_moderation,gore_moderation';
  String apiUrl =
      'https://my-cors-proxy-ed823d7eefa2.herokuapp.com/https://www.picpurify.com/analyse/1.1';

  for (var url in imageUrls) {
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'API_KEY': apiKey,
          'task': task,
          'url_image': url,
        },
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> jsonModerationResponse = jsonDecode(response.body);
        if (jsonModerationResponse["final_decision"] == "KO") {
          containsIllicitContent = true;
          break;
        }
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
