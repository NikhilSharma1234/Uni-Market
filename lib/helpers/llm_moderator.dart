import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';

class Moderator {
  const Moderator({Key? key});

  Future<bool> checkForProfanity(String userInput) async {
    OpenAI.apiKey = "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";
    try {
      OpenAIModerationModel moderation =
          await OpenAI.instance.moderation.create(input: userInput);

      return moderation.results.first.flagged;
    } catch (e) {
      print("Failed to acquire LLM Moderation Results: $e");
      return false;
    }
  }
}
