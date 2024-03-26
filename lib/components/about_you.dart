// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uni_market/components/dialog.dart';
import 'package:uni_market/helpers/functions.dart';
import 'package:uni_market/helpers/theme_provider.dart';
import 'package:uni_market/pages/home.dart';
import 'package:uni_market/services/firebase_upload_service.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:uni_market/helpers/stepper_states.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Step aboutYou(int index) {
  return Step(
    title: const Text('About You'),
    content: Container(
      alignment: Alignment.centerLeft,
      child: const AboutYouContent(),
    ),
    isActive: index == 2,
    state: stepperState(index, 2),
  );
}

class AboutYouContent extends StatefulWidget {
  const AboutYouContent({Key? key}) : super(key: key);

  @override
  State<AboutYouContent> createState() => _AboutYouContentState();
}

class _AboutYouContentState extends State<AboutYouContent> {
  String? selectedSchool;
  String? firstFileName;
  String? secondFileName;
  FilePickerResult? fileResult1;
  FilePickerResult? fileResult2;
  XFile? imageResult1;
  XFile? imageResult2;
  ValueNotifier<bool> isSubmitting = ValueNotifier(false);
  Future<Map<String, String>>? _list;

  FirebaseUploadService uploadService = FirebaseUploadService();
  @override
  void initState() {
    super.initState();
    _list = getListOfSchools();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Please select which school you go to.\nAdditionally, please upload two documents that may help prove that you attend the selected school. Common documents are student id cards and unofficial transcripts.',
            textAlign: TextAlign.center,
          ),
          FutureBuilder(
              future: _list,
              builder: (BuildContext context,
                  AsyncSnapshot<Map<String, String>> snapshot) {
                if (snapshot.hasData) {
                  return _buildSchoolDropdown(snapshot.data);
                }
                return const Text('Loading');
              }),
          const SizedBox(height: 8),
          _buildFileUpload(
              title: 'File 1*',
              fileNumber: 1, // Added fileNumber argument
              onUpload: (url) {
                setState(() {
                  firstFileName = url;
                });
              }),
          const SizedBox(height: 8),
          _buildFileUpload(
              title: 'File 2*',
              fileNumber: 2, // Added fileNumber argument
              onUpload: (url) {
                setState(() {
                  secondFileName = url;
                });
              }),
          Padding(
            padding:
                const EdgeInsets.only(top: 16, bottom: 16), // Add more padding
            child: Center(
              // Center the button
              child: ValueListenableBuilder<bool>(
                valueListenable: isSubmitting,
                builder: (context, isLoading, child) {
                  return isLoading
                      ? const CircularProgressIndicator() // Show loading indicator
                      : ElevatedButton(
                          onPressed: checkUpload,
                          child: const Text('Submit'),
                        );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSchoolDropdown(list) {
    bool darkModeOn =
        Provider.of<ThemeProvider>(context, listen: true).themeMode ==
            ThemeMode.dark;
    String? dropdownValue; // Ensure dropdown reflects the current state

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'School*',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          value: dropdownValue,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            filled: true,
            hintText: "Select your school",
            hintStyle: TextStyle(fontSize: 16),
          ),
          items: list.keys.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: TextStyle(
                    fontSize: 16,
                    color: darkModeOn ? Colors.white : Colors.black),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedSchool =
                  list[newValue]; // Update the selectedSchool state variable
              dropdownValue =
                  newValue; // Update dropdownValue for UI consistency
            });
          },
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildFileUpload({
    required String title,
    required int fileNumber,
    required Function(String) onUpload,
  }) {
    Future getImageFromGallery() async {
      XFile? image = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          if (fileNumber == 1) {
            imageResult1 = image;
            fileResult1 = null;
            firstFileName = image.name;
          } else {
            imageResult2 = image;
            fileResult2 = null;
            secondFileName = image.name;
          }
        });
      }
    }

    Future getImageFromCamera() async {
      XFile? image = await ImagePicker().pickImage(source: ImageSource.camera);

      if (image != null) {
        setState(() {
          if (fileNumber == 1) {
            imageResult1 = image;
            fileResult1 = null;
            firstFileName = image.name;
          } else {
            imageResult2 = image;
            fileResult2 = null;
            secondFileName = image.name;
          }
        });
      }
    }

    showOptions(BuildContext context) {
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
            CupertinoActionSheetAction(
              child: const Text('Select File'),
              onPressed: () async {
                // close the options modal
                Navigator.of(context).pop();
                FilePickerResult? result =
                    await FilePicker.platform.pickFiles();
                if (result != null) {
                  setState(() {
                    if (fileNumber == 1) {
                      fileResult1 = result;
                      imageResult1 = null;
                      firstFileName = result.files.single.name;
                    } else {
                      fileResult2 = result;
                      imageResult2 = null;
                      secondFileName = result.files.single.name;
                    }
                  });
                }
              },
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        if (kIsWeb) {
                          FilePickerResult? result =
                              await FilePicker.platform.pickFiles();
                          if (result != null) {
                            setState(() {
                              if (fileNumber == 1) {
                                fileResult1 = result;
                                firstFileName = result.files.single.name;
                              } else {
                                fileResult2 = result;
                                secondFileName = result.files.single.name;
                              }
                            });
                          }
                        } else {
                          showOptions(context);
                        }
                      },
                      child: Text('Upload $title'),
                    ),
                    const SizedBox(width: 10),
                    Text(fileNumber == 1
                        ? (firstFileName ?? '')
                        : (secondFileName ?? '')),
                  ],
                ))),
      ],
    );
  }

  bool validFileExtension(String fileName) {
    if (fileName.endsWith('.jpeg')) return true;
    if (fileName.endsWith('.jpg')) return true;
    if (fileName.endsWith('.png')) return true;
    if (fileName.endsWith('.pdf')) return true;
    if (fileName.endsWith('.JPG')) return true;
    return false;
  }

  Future<String?> uploadFile(FilePickerResult result, String fileName) async {
    if (kIsWeb) {
      Uint8List? fileBytes = result.files.single.bytes;
      if (fileBytes != null) {
        return await uploadService.uploadFileFromBytes(fileBytes, fileName);
      }
    } else {
      File file = File(result.files.single.path!);
      return await uploadService.uploadFile(file, fileName);
    }
    return null;
  }

  Future<String?> uploadImage(XFile result, String fileName) async {
    return await uploadService.uploadImage(result, fileName);
  }

  Future<Map<String, String>> getListOfSchools() async {
    final Map<String, String> list = {};
    await FirebaseFirestore.instance.collection('schools').get().then((value) {
      for (var doc in value.docs) {
        var name = doc.data()['name'];
        list[name] = doc.id.toString();
      }
    });
    return list;
  }

  Future<void> checkUpload() async {
    isSubmitting.value = true;
    if (selectedSchool != null &&
        (fileResult1 != null || imageResult1 != null) &&
        (fileResult2 != null || imageResult2 != null)) {
      try {
        if (firstFileName == secondFileName) {
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => appDialog(
                  context,
                  'Invalid File',
                  'You have uploaded the same file. Please upload unique verification documents.',
                  'Ok'));
          isSubmitting.value = false;
          return;
        }
        if (!validFileExtension(firstFileName!) ||
            !validFileExtension(secondFileName!)) {
          showDialog<String>(
              context: context,
              builder: (BuildContext context) => appDialog(
                  context,
                  'Invalid File',
                  'One or more of your files is an invalid file extension. Please select a file with extensions .jpeg, .jpg, , .JPG, .png or .pdf.',
                  'Ok'));
          isSubmitting.value = false;
          return;
        }
        // Use uploadFile function for both files
        String? uploadedFileName1 = fileResult1 != null
            ? await uploadFile(fileResult1!, firstFileName!)
            : await uploadImage(imageResult1!, firstFileName!);
        String? uploadedFileName2 = fileResult2 != null
            ? await uploadFile(fileResult2!, secondFileName!)
            : await uploadImage(imageResult2!, secondFileName!);

        if (uploadedFileName1 != null && uploadedFileName2 != null) {
          var marketplaceId = '';
          //  Get marketplace id and save to variable
          await FirebaseFirestore.instance
              .collection('marketplace')
              .where('schoolIds', arrayContains: selectedSchool)
              .get()
              .then((value) => marketplaceId = value.docs[0].id);
          // Update the user with marketplace and school id
          await FirebaseFirestore.instance
              .collection('users')
              .doc(FirebaseAuth.instance.currentUser!.email)
              .update({
            'schoolId': selectedSchool,
            'marketplaceId': marketplaceId,
            'verificationDocsUploaded': true
          });
          await loadCurrentUser(FirebaseAuth.instance.currentUser!.email);
          // Additional actions after successful upload
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Upload successful!')),
          );
          isSubmitting.value = false;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        } else {
          // Handle the case where file upload failed
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('File upload failed. Please try again.')),
          );
          isSubmitting.value = false;
        }
      } catch (e) {
        // Handle errors in file upload
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error during file upload: $e')),
        );
        isSubmitting.value = false;
      }
    } else {
      // Handle the case where not all information is present
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please complete all fields before submitting')),
      );
      isSubmitting.value = false;
    }
  }
}
