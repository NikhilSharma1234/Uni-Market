import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'user_navbar.dart';

class PostingForm extends StatefulWidget {
  const PostingForm({Key? key}) : super(key: key);

  @override
  State<PostingForm> createState() => _PostingFormState();
}

class _PostingFormState extends State<PostingForm> {
  final GlobalKey<FormBuilderState> _fbKey = GlobalKey<FormBuilderState>();
  final double maxPrice = 10000.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UserNavBar(), // Custom app bar here
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: FormBuilder(
                key: _fbKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'title',
                      style: const TextStyle(fontSize: 13),
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: FormBuilderValidators.required(context),
                      maxLines: 1,
                      maxLength: 30, // Set a maximum character limit
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'description',
                      maxLines: 3,
                      decoration: const InputDecoration(labelText: 'Description'),
                      validator: FormBuilderValidators.required(context),
                      maxLength: 150, // Set a maximum character limit
                    ),
                    const SizedBox(height: 16),
                    FormBuilderTextField(
                      name: 'price',
                      decoration: const InputDecoration(
                        labelText: 'Price',
                      ),
                      validator: FormBuilderValidators.compose([
                        FormBuilderValidators.required(context),
                        (value) {
                          // Custom validator for price format
                          if (value != null && !isValidPrice(value)) {
                            return 'Invalid price format';
                          }
                          if (value != null && double.parse(value) > maxPrice) {
                            return 'Price cannot exceed \$${maxPrice.toStringAsFixed(2)}';
                          }
                          return null;
                        },
                      ]),
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    FormBuilderDropdown(
                      name: 'condition',
                      hint: const Text('Select Condition'),
                      items: ['USED', 'NEW', 'WORN']
                          .map((condition) => DropdownMenuItem(
                                value: condition,
                                child: Text(condition),
                              ))
                          .toList(),
                      validator: FormBuilderValidators.required(context),
                    ),
                    const SizedBox(height: 50),
                    MaterialButton(
                      color: Colors.white,
                      child: const Text("Upload Image",
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 12,
                          )),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 25),
                    MaterialButton(
                      color: Colors.white,
                      child: const Text("Take Photo",
                          style: TextStyle(
                            color: Colors.blueGrey,
                            fontSize: 12,
                          )),
                      onPressed: () {},
                    ),
                    const SizedBox(height: 35),
                    ElevatedButton(
                      onPressed: () {
                        if (_fbKey.currentState!.saveAndValidate()) {
                          // Form is valid, submit your data
                          Map<String, dynamic> formData =
                              _fbKey.currentState!.value;
                          // TODO: Submit data to Firebase
                          print(formData);
                        }
                      },
                      child: const Text('Submit'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Future _pickImageFromGallery() async {
//   final returnedImage =
//       await ImagePicker().pickImage(source: ImageSource.gallery);
// }

bool isValidPrice(String? value) {
  if (value == null) {
    return false;
  }

  // Regular expression to match a valid price format (e.g., 123.45)
  final RegExp priceRegex = RegExp(r'^\d+(\.\d{1,2})?$');
  return priceRegex.hasMatch(value);
}
