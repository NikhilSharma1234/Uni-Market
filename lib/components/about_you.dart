import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uni_market/pages/posting_page.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
          padding: const EdgeInsets.only(top: 16), // Add more padding
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
    );
  }

  Widget _buildSchoolDropdown(list) {
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
                style: const TextStyle(fontSize: 16),
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
          child: Row(
            children: [
              ElevatedButton(
                onPressed: () async {
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
                },
                child: Text('Upload $title'),
              ),
              const SizedBox(width: 10),
              Text(fileNumber == 1
                  ? (firstFileName ?? '')
                  : (secondFileName ?? '')),
            ],
          ),
        ),
      ],
    );
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

  Future<Map<String, String>> getListOfSchools() async {
    final Map<String, String> list = {};
    await FirebaseFirestore.instance
        .collection('schools')
        .get()
        .then((value) => value.docs.forEach((doc) {
              final name = doc.data()['name'];
              list[name] = doc.id.toString();
            }));
    return list;
  }

  Future<void> checkUpload() async {
    isSubmitting.value = true;
    if (selectedSchool != null && fileResult1 != null && fileResult2 != null) {
      try {
        // Use uploadFile function for both files
        String? uploadedFileName1 =
            await uploadFile(fileResult1!, firstFileName!);
        String? uploadedFileName2 =
            await uploadFile(fileResult2!, secondFileName!);

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
              .doc(FirebaseAuth.instance.currentUser?.email)
              .update(
                  {'schoolId': selectedSchool, 'marketplaceId': marketplaceId});

          // Additional actions after successful upload
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload successful!')),
          );
          isSubmitting.value = false;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => const PostingPage(),
            ),
          );
        } else {
          // Handle the case where file upload failed
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('File upload failed. Please try again.')),
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
