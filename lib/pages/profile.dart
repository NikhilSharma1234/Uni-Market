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
import 'package:uni_market/helpers/profile_pic_shuffler.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late GlobalKey<_ProfilePageState> profilePageKey =
      GlobalKey<_ProfilePageState>();
  late bool _switchValue;
  String? profilerPic = const ProfilePicShuffler().reveal();

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
              return CircularProgressIndicator(); // or any loading indicator
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              // Successful DB data snapshot, store in map / filter duplicate strings
              Map<String, dynamic> userProfileData = snapshot.data!;
              List<String> schoolsInMarketplace =
                  List<String>.from(userProfileData["schoolsInMarketplace"]);
              schoolsInMarketplace.remove(userProfileData["institution"]);

              return SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SizedBox(
                  width: screenWidth * 0.85,
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight * 0.0195,
                      ),
                      //
                      // USER PROFILE PIC VIEW
                      AdvancedAvatar(
                        size: screenHeight * .11,
                        image: AssetImage('../assets/portraits/cameron.webp'),
                      ),
                      SizedBox(
                        height: screenHeight * 0.015,
                      ),
                      //
                      // USER NAME VIEW
                      SizedBox(
                        height: screenHeight * 0.025,
                        child: Text(
                          "Name: ${userProfileData["name"]}",
                          textAlign: TextAlign.center,
                        ),
                      ),
                      //
                      // USER EMAIL VIEW
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
                      // Dark Mode Toggle View
                      SizedBox(
                        height: screenHeight * 0.029,
                        width: screenWidth * 0.95,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text("Dark Mode:"),
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
                        height: screenHeight * 0.04,
                      ),
                      //
                      // UPDATE PROFILE
                      OutlinedButton(
                          onPressed: () {}, child: Text("APPLY CHANGES")),
                      //
                      SizedBox(
                        height: screenWidth * 0.055,
                        width: screenWidth * 0.65,
                      ),
                      // ITEMS BOUGHT BUTTON
                      ElevatedButton(
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
                      SizedBox(
                        height: screenHeight * 0.005,
                      ),
                      //
                      // ITEMS SOLD BUTTON
                      ElevatedButton(
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
                      SizedBox(
                        height: screenHeight * 0.005,
                      ),
                      //
                      // SIGN OUT BUTTON
                      ElevatedButton(
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
                      SizedBox(
                        height: screenHeight * 0.065,
                      ),
                      //
                      // Delete Account Button, NO LOGIC
                      TextButton(
                        onPressed: () {},
                        child: Text("Delete Account"),
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
    "profile_pic_url": null
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
      userProfile["profile_pic_path"] = documentSnapshot.get("profile_pic");
    });

    // Get Image Download URL for Profile Page Display
    String? profilePicUrl = await FirebaseStorage.instance
        .ref()
        .child("profile_pics/astronaut.png")
        .getDownloadURL();

    print(profilePicUrl);

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
