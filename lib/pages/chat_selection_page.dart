import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:uni_market/components/register.dart'; // Import where EmailContainer is defined
import 'package:uni_market/components/user_navbar_desktop.dart';
import 'package:uni_market/components/user_navbar_mobile.dart';
import 'package:uni_market/pages/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatSelectionPage extends StatefulWidget {
  @override
  _ChatSelectionPageState createState() => _ChatSelectionPageState();
}

class _ChatSelectionPageState extends State<ChatSelectionPage> {
  final TextEditingController emailController = TextEditingController();
  final ValueNotifier<bool> submitEnabled = ValueNotifier<bool>(true); // Set to true initially
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String?> getUserEmail(String productId) async {
    try {
      DocumentSnapshot productSnapshot =
          await _firestore.collection('items').doc(productId).get();

      if (!productSnapshot.exists) {
        print("Error: No product found with the provided ID: $productId");
        return null;
      }
      return productSnapshot['sellerId'];
    } catch (e) {
      print("Error fetching seller email: $e");
      return null;
    }
  }

  //make another function to extract the product name from given product id from the items collection
  Future<String?> getProductName(String productId) async {
    try {
      DocumentSnapshot productSnapshot =
          await _firestore.collection('items').doc(productId).get();

      if (!productSnapshot.exists) {
        print("Error: No product found with the provided ID: $productId");
        return null;
      }
      return productSnapshot['name'];
    } catch (e) {
      print("Error fetching product name: $e");
      return null;
    }
  }

  //make another function to extract the buyer nmae from given email from the user collection
  Future<String?> getBuyerName(String email) async {
    try {
      DocumentSnapshot userSnapshot =
          await _firestore.collection('users').doc(email).get();

      if (!userSnapshot.exists) {
        print("Error: No user found with the provided email: $email");
        return null;
      }
      return userSnapshot['name'];
    } catch (e) {
      print("Error fetching user name: $e");
      return null;
    }
  }

  
  Future<String?> createChatSession(String productId) async {
  // Ensure the current user is valid
  if (currentUser == null || currentUser!.email == null) {
    print("Error: Current user is null or has no email");
    return null;
  }

  // Retrieve the seller's email based on the product ID
  String? receiverEmail = await getUserEmail(productId);
  if (receiverEmail == null) {
    print("Error: Could not find seller's email for product ID: $productId");
    return null;
  }


  String senderEmail = currentUser!.email!;
  print("Current user email: $senderEmail");

  //retrieve the buyer name
  String? buyerName = await getBuyerName(senderEmail);

  //retrieve the product name
  String? productName = await getProductName(productId);

  // Generate the composite key by sorting and joining the participant IDs
  List<String> participantIds = [senderEmail, receiverEmail];
  participantIds.sort();
  String participantIdsKey = participantIds.join(':');
  print("Composite key generated: $participantIdsKey");

  // Check if a chat session already exists between these two users with the specific product
  final QuerySnapshot existingChatSessionQuery = await _firestore
      .collection('chat_sessions')
      .where('participantIdsKey', isEqualTo: participantIdsKey)
      .where('productId', isEqualTo: productId) // Add productId to the query to check for product-specific chat
      .limit(1)
      .get();

  if (existingChatSessionQuery.docs.isNotEmpty) {
    print("Chat session for the product already exists, returning existing session ID");
    return existingChatSessionQuery.docs.first.id;
  }

  // If no existing chat session is found for this product, create a new chat session
  DocumentReference chatSessionRef = await _firestore.collection('chat_sessions').add({
    'productName': productName, // Include the product name in the chat session document
    'buyerName': buyerName,
    'participantIds': participantIds,
    'productId': productId, // Include the productId in the chat session document
    'participantDetails': {
      senderEmail: {'email': senderEmail},
      receiverEmail: {'email': receiverEmail},
    },
    'createdAt': Timestamp.now(),
    'lastMessage': '',
    'lastMessageAt': Timestamp.now(),
  });

  print("New chat session created with ID: ${chatSessionRef.id} for product ID: $productId");

  // Update the 'chats' field in both the sender's and receiver's user documents with the new session ID
  await _firestore.collection('users').doc(senderEmail).update({
    'chats': FieldValue.arrayUnion([chatSessionRef.id]),
  }).catchError((e) => print("Error updating sender's chat list: $e"));

  await _firestore.collection('users').doc(receiverEmail).update({
    'chats': FieldValue.arrayUnion([chatSessionRef.id]),
  }).catchError((e) => print("Error updating receiver's chat list: $e"));

  return chatSessionRef.id;
}


  @override
  Widget build(BuildContext context) {
    redrawItems(List<Widget> newItems, bool append) {
      return;
    }

    double screenWidth = MediaQuery.of(context).size.width;
    // Initialize submitEnabled as false to indicate no submission is happening initially.
    final ValueNotifier<bool> submitEnabled = ValueNotifier<bool>(false);

    return Scaffold(
     appBar: 
          !kIsWeb ? const UserNavBarMobile(activeIndex: 0) : null,
      body: Center(
        child: Form(
          key: _formKey,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                width:
                    screenWidth < 500 ? screenWidth * 0.95 : screenWidth * 0.45,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: AutoSizeText(
                        'Start a New Chat',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w500,
                        ),
                        minFontSize: 16,
                        maxLines: 2,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(height: 20),
                    TextField(
  controller: emailController, // Use the existing TextEditingController
  decoration: InputDecoration(
    labelText: 'Enter product ID', // Update label as needed
    border: OutlineInputBorder(), // Adds border around the TextField
    hintText: 'Enter product ID', // Adds hint text inside the TextField
  ),
  keyboardType: TextInputType.text, // Set keyboard type to text
  // You can add validation logic inside onChanged or in TextFormField with a validator
),
 // Use the imported EmailContainer
                    SizedBox(height: 20),

                    ValueListenableBuilder<bool>(
                      valueListenable: submitEnabled,
                      builder: (context, isSubmitting, child) {
                        return isSubmitting
                            ? CircularProgressIndicator()
                            : ElevatedButton(
                                onPressed: () async {
                                  if (!_formKey.currentState!.validate())
                                    return;
                                  final String receiverEmail =
                                      emailController.text.trim();
                                  if (receiverEmail.isEmpty)
                                    return; // Ensure non-empty email
                                  submitEnabled.value =
                                      true; // Start submission process

                                  String? sessionId =
                                      await createChatSession(receiverEmail);

                                  if (sessionId != null) {
                                    // Show a modal dialog to indicate success
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                              'Chat Session Created'),
                                          content: Text(
                                              'Chat session with $receiverEmail has been successfully created.'),
                                          actions: <Widget>[
                                            TextButton(
                                              child: const Text('OK'),
                                              onPressed: () {
                                                Navigator.of(context)
                                                    .pop(); // Dismiss the dialog
                                                // Keep the redirection commented out for now.

                                                // Navigate to the ChatPage with the new session ID
                                                Navigator.pushReplacement(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) =>
                                                            ChatPage(
                                                                chatSessionId:
                                                                    sessionId!)));
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    // Handle the case where the chat session could not be created
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              'Failed to start chat with $receiverEmail')),
                                    );
                                  }

                                  submitEnabled.value =
                                      false; // End submission process
                                },
                                child: Text('Start Chat'),
                              );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


