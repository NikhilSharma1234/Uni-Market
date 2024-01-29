import 'package:flutter/material.dart';
import 'package:uni_market/components/user_navbar.dart';
import 'package:uni_market/components/post_form.dart';

class PostingPage extends StatefulWidget {
  const PostingPage({Key? key}) : super(key: key);

  @override
  State<PostingPage> createState() => _PostingPageState();
}

class _PostingPageState extends State<PostingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const UserNavBar(), // Custom app bar here
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: const SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: PostForm(),
            ),
          ),
        ),
      ),
    );
  }
}
