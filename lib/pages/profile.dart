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

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late GlobalKey<_ProfilePageState> profilePageKey =
      GlobalKey<_ProfilePageState>();
  late bool _switchValue;
  bool _profileSettingsChanged = false;
  XFile? newProfilePic;

  @override
  void initState() {
    super.initState();
    // Set the initial switch value based on the theme
    _switchValue = Provider.of<ThemeProvider>(context, listen: false)
        .setThemeToggleSwitch();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Provider.of<ThemeProvider>(context)
          .currentTheme
          .scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      bottomNavigationBar: !kIsWeb
          ? const UserNavBarMobile(activeIndex: 2)
          : null, // Custom app bar here
      body: Center(
        child: FutureBuilder<Map<String, dynamic>>(
          future: getUserProfileData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator(); // or any loading indicator
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              // Successful DB data snapshot
              Map<String, dynamic> userProfileData = snapshot.data!;

              List<String> schoolsInMarketplace =
                  List<String>.from(userProfileData["schoolsInMarketplace"]);
              schoolsInMarketplace.remove(userProfileData["institution"]);

              // Get available profile pic (starting or assignable)
              var profilePic;

              if (userProfileData["assignable_profile_pic_path"] == null) {
                profilePic = userProfileData["starting_profile_pic_url"];
              } else {
                profilePic = userProfileData["assignable_profile_pic_url"];
              }

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: screenWidth * 0.85,
                  child: Column(
                    children: [
                      // Spacer box sized through trial and error to fit mobile / desktop
                      SizedBox(
                        height: screenHeight * 0.0195,
                      ),
                      //
                      // MODIFIABLE USER PROFILE PIC
                      InkWell(
                        borderRadius:
                            BorderRadius.circular(screenHeight * 0.025),
                        onTap: () async {
                          newProfilePic = await singleImagePicker(context);
                          if (newProfilePic != null) {
                            setState(() {
                              _profileSettingsChanged = true;
                            });
                          }
                        },
                        child: Stack(children: [
                          AdvancedAvatar(
                            size: screenHeight * .11,
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
                      //
                      // Spacer box sized through trial and error to fit mobile / desktop
                      SizedBox(
                        height: screenHeight * 0.015,
                      ),
                      //
                      // USER NAME BOX
                      SizedBox(
                        height: screenHeight * 0.025,
                        child: Text(
                          "Name: ${userProfileData["name"]}",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      //
                      // USER EMAIL BOX
                      SizedBox(
                        height: screenHeight * 0.025,
                        child: Text(
                          "Email: ${userProfileData["email"]}",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.019,
                      ),
                      //
                      // DARK MODE TOGGLE BOX (Text and Stateful Switch)
                      SizedBox(
                        height: screenHeight * 0.029,
                        width: screenWidth * 0.95,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Dark Mode:"),
                            SizedBox(
                              width: screenWidth * 0.005,
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
                      ),
                      //
                      // Spacer box sized through trial and error to fit mobile / desktop
                      SizedBox(
                        height: screenHeight * 0.03,
                      ),
                      //
                      // USER INSTITUTION BOX
                      SizedBox(
                        height: screenHeight * 0.025,
                        width: screenWidth * 0.65,
                        child: Text(
                          "Institution: ${userProfileData["institution"]}",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      //
                      // SCHOOLS IN MARKETPLACE BOX
                      SizedBox(
                        height: screenHeight * 0.025,
                        width: screenWidth * 0.65,
                        child: Text(
                          "Other Schools in Marketplace: $schoolsInMarketplace",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      SizedBox(
                        height: screenHeight * 0.019,
                      ),
                      //
                      // UPDATE PROFILE
                      SizedBox(
                        height: screenHeight * 0.034,
                        width: screenWidth * 0.38,
                        child: OutlinedButton(
                          onPressed: () {
                            if (_profileSettingsChanged == true) {
                              _updateProfilePicture(newProfilePic)
                                  .then((success) {
                                if (success != null) {
                                  showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                              "Profile Settings Changed!"),
                                          content: const Text(
                                              "Profile Settings Updated"),
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
                            } else {
                              // "Don't invoke print in production code" - This linter can put a sock in it
                              print("No changes to apply!!");
                            }
                          },
                          style: _profileSettingsChanged
                              ? ElevatedButton.styleFrom(
                                  backgroundColor: Colors.greenAccent[400])
                              : null,
                          child: const Text("APPLY CHANGES"),
                        ),
                      ),
                      //
                      // Spacer box sized through trial and error to fit mobile / desktop
                      SizedBox(
                        height: screenHeight * 0.0125,
                        width: screenWidth * 0.65,
                      ),
                      // ITEMS BOUGHT BUTTON, UNDEFINED ON PRESSED LOGIC
                      SizedBox(
                        height: screenHeight * 0.034,
                        width: screenWidth * 0.38,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
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
                        onPressed: () {},
                        child: const Text("Items Sold"),
                      ),
                      SizedBox(
                        height: screenHeight * 0.005,
                      ),
                      //
                      // ITEMS SOLD BUTTON, UNDEFINED ON PRESSED LOGIC
                      SizedBox(
                        height: screenHeight * 0.034,
                        width: screenWidth * 0.38,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
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
                        onPressed: () async {
                          await FirebaseAuth.instance.signOut();
                        },
                        child: const Text('LOG OUT'),
                      ),
                      SizedBox(
                        height: screenHeight * 0.005,
                      ),
                      //
                      // SIGN OUT BUTTON
                      SizedBox(
                        height: screenHeight * 0.034,
                        width: screenWidth * 0.38,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
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
                      SizedBox(
                        height: screenHeight * 0.065,
                      ),
                      //
                      // Delete Account Button, NO LOGIC
                      TextButton(
                        onPressed: () {},
                        child: const Text("Delete Account"),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
        ),
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
      userProfile["assignable_profile_pic_path"] =
          documentSnapshot.get("assignable_profile_pic");
      userProfile["starting_profile_pic_path"] =
          documentSnapshot.get("starting_profile_pic");
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
          print("Error: $e");
        }
        Completer<List<String>> completer = Completer<List<String>>();
        completer.complete(imageNames);
        return true;
      } else {
        // Data URL is null
        return false;
      }
    } catch (e) {
      print("Error updating profile picture: $e");
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
