import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:uni_market/services/upload_service.dart';
import 'package:uni_market/services/mock_upload_service.dart';

Step AboutYou(int index) {
  return Step(
    title: const Text('About You'),
    content: Container(
      alignment: Alignment.centerLeft,
      child: const AboutYouContent(),
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

  UploadService uploadService = MockUploadService(); // Using mock service for now, just replace with firebase upload service like: UploadService uploadService = FireBaseloadService(); name FireBaseloadService() as appropriate. Create firebase upload service with function: "Future<String?> uploadFile(Object file, String fileName); // Return the name of the file"

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSchoolDropdown(),
        const SizedBox(height: 16),
        _buildFileUpload(
            title: 'File 1',
            onUpload: (url) {
              setState(() {
                firstFileName = url;
              });
            }),
        const SizedBox(height: 16),
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

  // Function for school dropdown
  Widget _buildSchoolDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'School*',
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButton<String>(
          value: selectedSchool,
          hint: const Text('Select your school'),
          onChanged: (String? newValue) {
            setState(() {
              selectedSchool = newValue;
            });
          },
          items: <String>['University of Nevada, Reno', 'Test School']
              .map<DropdownMenuItem<String>>((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Function for file uploads
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
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
      Padding(   
        padding: const EdgeInsets.only(top: 8.0),  
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
      ),
    ],
  );
}
}