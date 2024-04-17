import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uni_market/components/user_bottom_nav_bar.dart';
import 'package:uni_market/data_models/current_user.dart';
import 'package:uni_market/helpers/functions.dart';
import 'package:uni_market/helpers/is_mobile.dart';
import 'dart:convert';
import 'dart:async';
import 'package:uni_market/helpers/theme_provider.dart';
import 'package:uni_market/pages/item_view.dart';
import 'package:uni_market/data_store.dart' as data_store;

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late GlobalKey<_ProfilePageState> key = GlobalKey<_ProfilePageState>();
  XFile? newProfilePic;
  bool loading = false;
  bool venmoIdLoading = false;
  bool editingVenmoId = false;
  CurrentUser user = data_store.user;

  Set<int> themeMode = {data_store.user.darkMode};

  void flipVenmoEditingState() {
    setState(() {
      editingVenmoId = !editingVenmoId;
    });
  }

  @override
  Widget build(BuildContext context) {
    List<dynamic> schoolsInMarketplace = user.schoolsInMarketplace;
    schoolsInMarketplace.remove(user.schoolId);

    // Get available profile pic (starting or assignable)
    String profilePic;

    if (user.assignable_profile_pic_url == null) {
      // Starting Pic Exists, New User / User Has not set an assignable profile
      profilePic = user.starting_profile_pic_url;
    } else {
      // Assignable Pic Exists, User has changed profile pics
      profilePic = user.assignable_profile_pic_url!;
    }

    if (loading) {
      return Scaffold(
          resizeToAvoidBottomInset: false,
          bottomNavigationBar: isMobile(context)
              ? const UserBottomNavBar(activeIndex: 2)
              : null, // Custom app bar here
          body: const Center(child: CircularProgressIndicator()));
    }

    Future updateVenmoId(String venmoId) async {
      try {
        if (data_store.user.email != "") {
          setState(() {
            venmoIdLoading = true;
          });
          await FirebaseFirestore.instance
              .collection("users")
              .doc(data_store.user.email)
              .update({"venmoId": venmoId == "" ? null : venmoId});
          await loadCurrentUser(data_store.user.email);
          setState(() {
            venmoIdLoading = false;
          });
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error: $e");
        }
      }
    }

    Future getImageFromCamera() async {
      XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);

      if (image != null) {
        return image;
      }
    }

    Future showOptions(BuildContext context) async {
      showCupertinoModalPopup(
        context: context,
        builder: (context) => CupertinoActionSheet(
          actions: [
            CupertinoActionSheetAction(
              child: const Text('Photo Gallery'),
              onPressed: () async {
                Navigator.of(context).pop();
                // get image from gallery
                var newProfilePic = await singleImagePicker(context);
                if (newProfilePic != null) {
                  setState(() {
                    loading = true;
                  });
                  await _updateProfilePicture(newProfilePic)
                      .then((success) async {
                    if (success != null) {
                      await loadCurrentUser(data_store.user.email);
                    }
                  });
                  setState(() {
                    loading = false;
                  });
                }
              },
            ),
            CupertinoActionSheetAction(
              child: const Text('Camera'),
              onPressed: () async {
                Navigator.of(context).pop();
                // get image from gallery
                var newProfilePic = await getImageFromCamera();
                if (newProfilePic != null) {
                  setState(() {
                    loading = true;
                  });
                  await _updateProfilePicture(newProfilePic)
                      .then((success) async {
                    if (success != null) {
                      await loadCurrentUser(data_store.user.email);
                    }
                  });
                  setState(() {
                    loading = false;
                  });
                }
              },
            ),
          ],
        ),
      );
    }

    var child = SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Scrollbar(
        trackVisibility: true,
        child: Padding(
          padding: const EdgeInsets.only(
              top: kIsWeb ? 8 : 64, bottom: 8, left: 16, right: 16),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('P R O F I L E',
                    textAlign: TextAlign.start, style: TextStyle(fontSize: 24)),
                Padding(
                  padding: const EdgeInsets.only(top: 12, bottom: 12),
                  child: Center(
                    child: InkWell(
                      onTap: () async {
                        if (!kIsWeb) {
                          showOptions(context);
                          return;
                        }
                        newProfilePic = await singleImagePicker(context);
                        if (newProfilePic != null) {
                          setState(() {
                            loading = true;
                          });
                          _updateProfilePicture(newProfilePic).then((success) {
                            if (success != null) {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: const Text(
                                          "Profile Settings Changed!"),
                                      content:
                                          const Text("Profile Image Updated"),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                          },
                                          child: const Text("Continue"),
                                        )
                                      ],
                                    );
                                  });
                            }
                          });
                          await loadCurrentUser(data_store.user.email);
                        }
                      },
                      child: Stack(children: [
                        AdvancedAvatar(
                          size: 160,
                          image: NetworkImage(profilePic),
                        ),
                        const Positioned(
                          bottom: 0,
                          right: 0,
                          child: Icon(
                            Icons.edit,
                            size: 20,
                          ),
                        )
                      ]),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Name",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(user.name, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Email",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(user.email, style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text("Dark Mode",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      SizedBox(
                        width: 175,
                        child: SegmentedButton(
                          segments: const [
                            ButtonSegment(value: 0, icon: Icon(Icons.computer)),
                            ButtonSegment(
                                value: 1, icon: Icon(Icons.dark_mode)),
                            ButtonSegment(
                                value: 2, icon: Icon(Icons.light_mode)),
                          ],
                          selected: themeMode,
                          onSelectionChanged: (Set<int> selection) async {
                            int darkModeSelection = selection.elementAt(0);
                            setState(() {
                              themeMode = {darkModeSelection};
                            });
                            switch (darkModeSelection) {
                              case 0:
                                Provider.of<ThemeProvider>(context,
                                        listen: false)
                                    .setThemeMode(ThemeMode.system);
                              case 1:
                                Provider.of<ThemeProvider>(context,
                                        listen: false)
                                    .setThemeMode(ThemeMode.dark);
                                break;
                              case 2:
                                Provider.of<ThemeProvider>(context,
                                        listen: false)
                                    .setThemeMode(ThemeMode.light);
                                break;
                            }
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.email)
                                .update({'darkMode': selection.elementAt(0)});
                            await loadCurrentUser(data_store.user.email);
                          },
                          showSelectedIcon: false,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Institution",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(user.institutionFullName,
                            style: const TextStyle(fontSize: 12)),
                      ]),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Other Schools in Marketplace",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),
                      Text(schoolsInMarketplace.join(', '),
                          style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
                Padding(
                    padding: const EdgeInsets.only(top: 4.0, bottom: 4.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Builder(builder: (context) {
                          if (editingVenmoId) {
                            TextEditingController editingController =
                                TextEditingController();
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Enter Venmo ID"),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        autofocus: true,
                                        controller: editingController,
                                        textAlign: TextAlign.start,
                                        maxLength: 30,
                                        onFieldSubmitted: (value) async {
                                          updateVenmoId(value);
                                          flipVenmoEditingState();
                                        },
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        updateVenmoId(
                                            editingController.text.toString());
                                        flipVenmoEditingState();
                                      },
                                      child: const Text("Confirm"),
                                    ),
                                    TextButton(
                                      style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.red)),
                                      onPressed: () {
                                        flipVenmoEditingState();
                                      },
                                      child: const Text(
                                        "Cancel",
                                      ),
                                    )
                                  ],
                                )
                              ],
                            );
                          } else if (!venmoIdLoading) {
                            return ListTile(
                              hoverColor: data_store.user.darkMode == 1
                                  ? Colors.white24
                                  : Colors.black12,
                              contentPadding: const EdgeInsets.only(left: 2.0),
                              leading: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Venmo ID",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16)),
                                  Text(data_store.user.venmoId ?? "")
                                ],
                              ),
                              trailing: const Icon(Icons.edit),
                              onTap: () {
                                flipVenmoEditingState();
                              },
                            );
                          } else {
                            return AnimatedTextKit(
                              repeatForever: true,
                              animatedTexts: [
                                TyperAnimatedText(
                                    ". . . . . . . . . . . . . . ."),
                                TyperAnimatedText(
                                    ". . . . . . . . . . . . . . .  "),
                                TyperAnimatedText(
                                    ". . . . . . . . . . . . . . .  "),
                                TyperAnimatedText(
                                    ". . . . . . . . . . . . . . .  "),
                                TyperAnimatedText(
                                    "Damn this load is long af sorry"),
                                TyperAnimatedText(
                                    ". . . . . . . . . . . . . . .  "),
                                TyperAnimatedText(
                                    ". . . . . . . . . . . . . . .  "),
                                TyperAnimatedText(
                                    ". . . . . . . . . . . . . . .  "),
                              ],
                            );
                          }
                        }),
                      ],
                    )),
                Padding(
                  padding: const EdgeInsets.only(
                      top: 32.0, right: 8.0, bottom: 8.0, left: 8.0),
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(200, 36),
                        backgroundColor: Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.blue.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) =>
                                ItemView(sellerID: data_store.user.email),
                          ),
                        );
                      },
                      child: const Text("Items you've listed"),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(200, 36),
                        backgroundColor: Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.blue.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("Items Bought"),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(200, 36),
                        backgroundColor: Colors.grey.shade400,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.blue.shade900,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      onPressed: () {},
                      child: const Text("Items Sold"),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        fixedSize: const Size(200, 36),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        shadowColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.0),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(context);
                        data_store.user.delete();
                        data_store.itemBoxes = [];
                        await FirebaseAuth.instance.signOut();
                        // ignore: use_build_context_synchronously
                        Provider.of<ThemeProvider>(context, listen: false)
                            .setThemeMode(ThemeMode.dark);
                      },
                      child: const Text('LOG OUT'),
                    ),
                  ),
                ),
                // Delete Account Button, NO LOGIC
                Center(
                  child: TextButton(
                    onPressed: () {},
                    child: const Text("Delete Account",
                        style: TextStyle(color: Colors.red)),
                  ),
                ),
              ]),
        ),
      ),
    );
    if (!isMobile(context)) return child;
    return Scaffold(
        resizeToAvoidBottomInset: false,
        bottomNavigationBar: isMobile(context)
            ? const UserBottomNavBar(activeIndex: 2)
            : null, // Custom app bar here
        body: child);
  }

// Helper function for selecting new profile picture
  Future<XFile?> singleImagePicker(BuildContext context) async {
    XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (image != null) {
      return image;
    } else {
      if (kDebugMode) {
        print("Error: No image selected");
      }
    }
    return null;
  }

  Future<bool?> _updateProfilePicture(XFile? profilePic) async {
    if (profilePic != null) {
      Future<String?> imageDataUrl = convertImageToDataUrl(profilePic);
      try {
        String? dataUrl = await imageDataUrl;
        if (dataUrl != null) {
          List<String> imageNames = [];
          Uint8List imageBytes = base64Decode(dataUrl.split(',').last);
          String fileName = DateTime.now().millisecondsSinceEpoch.toString();
          final imageRef = FirebaseStorage.instance
              .ref()
              .child("profile_pics/$fileName.jpg");
          try {
            await imageRef.putData(imageBytes);
            imageNames.add("profile_pics/$fileName.jpg");
          } on FirebaseException catch (e) {
            // Handle Firebase exception
            if (kDebugMode) {
              print(e);
            }
            return false;
          }

          try {
            if (data_store.user.email != "") {
              await FirebaseFirestore.instance
                  .collection("users")
                  .doc(data_store.user.email)
                  .update({"assignable_profile_pic": imageNames[0]});
              await loadCurrentUser(data_store.user.email);
            }
          } catch (e) {
            if (kDebugMode) {
              print("Error: $e");
            }
          }
          Completer<List<String>> completer = Completer<List<String>>();
          completer.complete(imageNames);
          return true;
        } else {
          // Data URL is null
          return false;
        }
      } catch (e) {
        if (kDebugMode) {
          print("Error updating profile picture: $e");
        }
        return false;
      }
    }
    return null;
  }

  Future<String?> convertImageToDataUrl(XFile? imageFile) async {
    if (imageFile != null) {
      List<int> imageBytes = await imageFile.readAsBytes();
      String? dataUrl =
          'data:image/${imageFile.name.split('.').last};base64,${base64Encode(Uint8List.fromList(imageBytes))}';
      return dataUrl;
    }
    return null;
  }
}
