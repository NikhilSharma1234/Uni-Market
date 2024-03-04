import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uni_market/components/user_navbar_mobile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_advanced_avatar/flutter_advanced_avatar.dart';
import 'package:uni_market/components/custom_switch.dart';
import 'package:uni_market/helpers/theme_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:async';
import 'package:uni_market/helpers/profile_pic_shuffler.dart';
import 'package:uni_market/pages/item_view.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late GlobalKey<_ProfilePageState> key =
      GlobalKey<_ProfilePageState>();
  late bool _switchValue;
  XFile? newProfilePic;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    // Set the initial switch value based on the theme
    _switchValue = Provider.of<ThemeProvider>(context, listen: false)
        .setThemeToggleSwitch();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Provider.of<ThemeProvider>(context)
          .currentTheme
          .scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: !kIsWeb
          ? const UserNavBarMobile(activeIndex: 2)
          : null, // Custom app bar here
      body: FutureBuilder<Map<String, dynamic>>(
        future: getUserProfileData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child:CircularProgressIndicator()); // or any loading indicator
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          } else {
            // Successful DB data snapshot
            Map<String, dynamic> userProfileData = snapshot.data!;
            

      
            List<String> schoolsInMarketplace =
                List<String>.from(userProfileData["schoolsInMarketplace"]);
            schoolsInMarketplace.remove(userProfileData["institution"]);
      
            // Get available profile pic (starting or assignable)
            String profilePic;
      
            if (userProfileData["assignable_profile_pic_path"] == null) {
              // Starting Pic Exists, New User / User Has not set an assignable profile
              profilePic = userProfileData["starting_profile_pic_url"];
            } else {
              // Assignable Pic Exists, User has changed profile pics
              profilePic = userProfileData["assignable_profile_pic_url"];
            }

            if (loading) return const Center(child:CircularProgressIndicator());
      
            return SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Scrollbar(
                trackVisibility: true,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 8, left: 16, right: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profile',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 24
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 12),
                        child: Center(
                          child: InkWell(
                            onTap: () async {
                              newProfilePic = await singleImagePicker(context);
                              if (newProfilePic != null) {
                                setState(() {
                                  loading = true;
                                });
                                _updateProfilePicture(newProfilePic)
                                .then((success) {
                                  if (success != null) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text("Profile Settings Changed!"),
                                          content: const Text("Profile Image Updated"),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text("Continue"),
                                            )
                                          ],
                                        );
                                      }
                                    );
                                  }
                                });
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
                      const Text("Name", style: 
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        )
                      ),
                      Text(userProfileData["name"], style:
                        const TextStyle(
                          fontSize: 12
                        )
                      ),
                      const Text("Email", style: 
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        )
                      ),
                      Text(userProfileData["email"], style:
                        const TextStyle(
                          fontSize: 12
                        )
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Dark Mode", style: 
                            TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                            )
                          ),
                          CustomSwitch(
                            value: _switchValue,
                            onChanged: (bool val) {
                              setState(() {
                                _switchValue = val;
                              });
                              Provider.of<ThemeProvider>(context,
                                      listen: false)
                                  .setThemeMode(
                                      val ? ThemeMode.dark : ThemeMode.light);
                            },
                          ),
                        ],
                      ),
                      const Text("Institution", style: 
                        TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        )
                      ),
                      Text(
                        userProfileData["institutionFullName"],
                        style: const TextStyle(
                          fontSize: 12
                        )
                      ),
                      const Text("Other Schools in Marketplace",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                        )
                      ),
                      Text(
                        schoolsInMarketplace.join(', '),
                        style: const TextStyle(
                          fontSize: 12
                        )
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
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => ItemView(
                                      sellerID: FirebaseAuth
                                          .instance.currentUser?.email),
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
                              await FirebaseAuth.instance.signOut();
                            },
                            child: const Text('LOG OUT'),
                          ),
                        ),
                      ),
                      // Delete Account Button, NO LOGIC
                      Center(
                        child: TextButton(
                          onPressed: () {},
                          child: const Text(
                            "Delete Account",
                            style: TextStyle(
                              color: Colors.red
                            )
                          ),
                        ),
                      ),
                    ]
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}

// Helper function to get db data for profile views
Future<Map<String, dynamic>> getUserProfileData() async {
  final userProfile = <String, dynamic>{
    "name": null,
    "email": null,
    "institution": null,
    "institutionFullName": null,
    "schoolsInMarketplace": null,
    "marketplaceId": null,
    "profile_pic_path": null,
    "profile_pic_url": null,
    "assignable_profile_pic_path": null,
    "assignable_profile_pic_url": null,
  };

  var currentUser = FirebaseAuth.instance.currentUser;

  if (currentUser != null) {
    userProfile["email"] = currentUser.email;
    userProfile["name"] = currentUser.displayName;

    // read User institution / marketplace set from db
    await FirebaseFirestore.instance
        .collection("users")
        .doc(userProfile["email"])
        .get()
        .then((DocumentSnapshot documentSnapshot) {
      userProfile["institution"] = documentSnapshot.get("schoolId");
      userProfile["marketplaceId"] = documentSnapshot.get("marketplaceId");
      try {
        userProfile["assignable_profile_pic_path"] =
            documentSnapshot.get("assignable_profile_pic");
        userProfile["starting_profile_pic_path"] =
            documentSnapshot.get("starting_profile_pic");
      } catch (e) {
        _assignStartingProfilePicSignUp();
      }
    });
    // Get Image Download for Assignable Profile Pic if used
    if (userProfile["assignable_profile_pic_path"] != null) {
      userProfile["assignable_profile_pic_url"] = await FirebaseStorage.instance
          .ref()
          .child(userProfile["assignable_profile_pic_path"])
          .getDownloadURL();
    }

    // Get Image Download URL for starting Profile Pic Display
    userProfile["starting_profile_pic_url"] = await FirebaseStorage.instance
        .ref()
        .child(userProfile["starting_profile_pic_path"])
        .getDownloadURL();

    // read schools in users marketplace Id from db
    await FirebaseFirestore.instance
      .collection("marketplace")
      .doc(userProfile["marketplaceId"])
      .get()
      .then((DocumentSnapshot documentSnapshot) {
              userProfile["schoolsInMarketplace"] = documentSnapshot.get("schoolIds");
      });
    // read school fullname
    await FirebaseFirestore.instance
      .collection("schools")
      .doc(userProfile["institution"])
      .get()
      .then((DocumentSnapshot documentSnapshot) {
        userProfile["institutionFullName"] = documentSnapshot.get("name");
      });
  }

  return userProfile;
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

Future<void> _assignStartingProfilePicSignUp() async {
  var currentUser = FirebaseAuth.instance.currentUser;
  if (currentUser != null) {
    String? userEmail = currentUser.email;
    String? chosenProfilePicPath =
        "profile_pics/${const ProfilePicShuffler().reveal()}";

    CollectionReference users = FirebaseFirestore.instance.collection("users");

    await users.doc(userEmail).update({
      "assignable_profile_pic": null,
      "starting_profile_pic": chosenProfilePicPath
    });
  }
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
        final imageRef =
            FirebaseStorage.instance.ref().child("profile_pics/$fileName.jpg");
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
          var currentUser = FirebaseAuth.instance.currentUser;

          if (currentUser != null) {
            await FirebaseFirestore.instance
                .collection("users")
                .doc(currentUser.email)
                .update({"assignable_profile_pic": imageNames[0]});
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
