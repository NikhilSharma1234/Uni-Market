import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uni_market/posting_form.dart';
import 'package:uni_market/services/FirebaseUploadService.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'helpers/stepper_states.dart';

Step AboutYou(int index) {
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
  _AboutYouContentState createState() => _AboutYouContentState();
}

class _AboutYouContentState extends State<AboutYouContent> {
  String? selectedSchool;
  String? firstFileName;
  String? secondFileName;
  FilePickerResult? fileResult1;
  FilePickerResult? fileResult2;
  ValueNotifier<bool> isSubmitting = ValueNotifier(false);

  FirebaseUploadService uploadService = FirebaseUploadService();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSchoolDropdown(),
        const SizedBox(height: 32),
        _buildFileUpload(
            title: 'File 1*',
            fileNumber: 1, // Added fileNumber argument
            onUpload: (url) {
              setState(() {
                firstFileName = url;
              });
            }),
        const SizedBox(height: 32),
        _buildFileUpload(
            title: 'File 2*',
            fileNumber: 2, // Added fileNumber argument
            onUpload: (url) {
              setState(() {
                secondFileName = url;
              });
            }),
        Padding(
          padding: const EdgeInsets.only(top: 48), // Add more padding
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

  Widget _buildSchoolDropdown() {
    List<String> list = [
      'University of Nevada, Reno',
      'Test School',
      "Test School 2",
      "Test School 3"
    ];
    String? dropdownValue =
        selectedSchool; // Ensure dropdown reflects the current state

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'School*',
          style: TextStyle(
            color: Colors.white,
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
            fillColor: Color.fromARGB(71, 11, 26, 103),
            hintText: "Select your school",
            hintStyle: TextStyle(fontSize: 16, color: Colors.white),
          ),
          items: list.map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(
                value,
                style: const TextStyle(fontSize: 16, color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              selectedSchool =
                  newValue; // Update the selectedSchool state variable
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
            color: Colors.white,
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
          // Upload logic for the selected school
          await uploadService.uploadSelectedSchool(selectedSchool!);

          // Additional actions after successful upload
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Upload successful!')),
          );
          isSubmitting.value = false;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const PostingForm(),
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
