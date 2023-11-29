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
  List<String> list = ['University of Nevada, Reno', 'Test School', "Test School 2",  "Test School 3"]; // Replace with list of schools from database
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
        value: dropdownValue, // The initial value of the dropdown
        decoration: const InputDecoration(
          // The box decoration of the dropdown
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Color.fromARGB(71, 11, 26, 103),
          hintText: "Select your school", // Added hint text
          hintStyle: TextStyle(fontSize: 16, color: Colors.white),// Style for the hint text
        ),
        items: list.map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(
              value,
              style: const TextStyle(fontSize: 16, color: Colors.white), // Set font size for dropdown items
            ),
          );
        }).toList(),
        onChanged: (String? newValue) {
          // This is called when the user selects an item.
          setState(() {
            dropdownValue = newValue!;
          });
        },
        style: const TextStyle(fontSize: 16), // Set font size for the selected item displayed in the dropdown
      ),
    ],
  );
}





  Widget _buildFileUpload({
  required String title,
  required Function(String? url) onUpload,
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
                FilePickerResult? result = await FilePicker.platform.pickFiles();
                if (result != null)//backend is not
                 {
                  String? uploadedFileName = await uploadService.uploadFile(
                      result.files.single, 
                      result.files.single.name);
                  onUpload(uploadedFileName);
                }
              },
              child: Text('Upload $title'),
            ),
            const SizedBox(width: 10),
            if ((title == 'File 1' && firstFileName != null) ||
                (title == 'File 2' && secondFileName != null))
              Text(title == 'File 1' ? firstFileName! : secondFileName!),
          ],
        ),
      ],
    );
  }
}
