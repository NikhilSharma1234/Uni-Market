import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';

class Moderator {
  const Moderator({Key? key});

  Future<bool> checkForProfanity(String userInput) async {
    try {
      final response = await FirebaseFunctions.instance
        .httpsCallable("llm_moderation")
        .call({"input": userInput});
      return response.data;
    } catch (e) {
      if (kDebugMode) {
        print("Failed to acquire LLM Moderation Results: $e");
      }
      return false;
    }
  }
}
