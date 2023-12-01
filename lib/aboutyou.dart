import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uni_market/services/FirebaseUploadService.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

Step AboutYou(int index) {
  return Step(
    title: const Text('About You'),
    content: Container(
      alignment: Alignment.centerLeft,
      child: AboutYouContent(),
    ),
    isActive: index >= 0,
    state: index >= 2 ? StepState.complete : StepState.disabled,
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

  FirebaseUploadService uploadService = FirebaseUploadService();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSchoolDropdown(),
        const SizedBox(height: 32),
        _buildFileUpload(
            title: 'File 1',
            onUpload: (url) {
              setState(() {
                firstFileName = url;
              });
            }),
        const SizedBox(height: 32),
        _buildFileUpload(
            title: 'File 2',
            onUpload: (url) {
              setState(() {
                secondFileName = url;
              });
            }),
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
    String? dropdownValue;

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
              dropdownValue = newValue!;
            });
            if (newValue != null) {
              uploadService.uploadSelectedSchool(newValue);
            }
          },
          style: const TextStyle(fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildFileUpload({
    required String title,
    required Function(String? url) onUpload,
  }) {
    ValueNotifier<bool> isUploading = ValueNotifier(false);

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
                  isUploading.value = true;
                  if (result != null) {
                    String? uploadedFileName;
                    if (kIsWeb) {
                      Uint8List? fileBytes = result.files.single.bytes;
                      String fileName = result.files.single.name;
                      if (fileBytes != null) {
                        uploadedFileName = await uploadService
                            .uploadFileFromBytes(fileBytes, fileName);
                      }
                    } else {
                      File file = File(result.files.single.path!);
                      uploadedFileName = await uploadService.uploadFile(
                          file, result.files.single.name);
                    }
                    onUpload(uploadedFileName);
                    isUploading.value = false;
                  } else {
                    isUploading.value = false;
                  }
                },
                child: Text('Upload $title'),
              ),
              const SizedBox(width: 10),
              ValueListenableBuilder<bool>(
                valueListenable: isUploading,
                builder: (context, value, child) {
                  if (value) {
                    return CircularProgressIndicator();
                  } else if ((title == 'File 1' && firstFileName != null) ||
                      (title == 'File 2' && secondFileName != null)) {
                    return Text(
                        title == 'File 1' ? firstFileName! : secondFileName!);
                  }
                  return Container();
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
