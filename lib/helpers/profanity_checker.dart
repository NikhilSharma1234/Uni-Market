import 'package:profanity_filter/profanity_filter.dart';
import 'package:uni_market/helpers/constants.dart';
import 'package:uni_market/helpers/llm_moderator.dart';

// Worst Case (150!? - can add filter for longest word(50 chars I think) to lower to o(50!) I think, should be very unlikely)
Future<bool> checkProfanity(String userInput,
    {bool checkStrength = true}) async {
  final filter = ProfanityFilter.filterAdditionally(additionalProfanity);
  Moderator llmModerator = const Moderator();

  // If any flagging occurs, return true immeditaly to prevent unneccesary calcs

  // Non-LLM First level of Profanity Checking (Syntactical)
  // Preprocess string into words
  for (String word in userInput.toLowerCase().split(' ')) {
    String preProcessedWord = preprocessWord(word);

    // Simplest profanity check defined profane words
    if (preProcessedWord.isNotEmpty) {
      bool wordHasProfanity = filter.hasProfanity(preProcessedWord);

      if (wordHasProfanity) {
        return true;
      }

      // More Compute, check all pre-processed substrings for defined words
      if (!wordHasProfanity && checkStrength) {
        for (int i = 0; i < preProcessedWord.length; i++) {
          for (int j = i + 1; j <= preProcessedWord.length; j++) {
            String substring = preProcessedWord.substring(i, j);
            if (substring.isNotEmpty) {
              if (filter.hasProfanity(substring)) {
                return true;
              }
            }
          }
        }
      }
    }
  }

  // LLM Second level Semantical Flagging on Title
  final titleProfanity = await llmModerator.checkForProfanity(userInput);
  if (titleProfanity) {
    return true;
  }

  // LLM Second level Semantical Flagging on Description
  final descriptionProfanity = await llmModerator.checkForProfanity(userInput);
  if (descriptionProfanity) {
    return true;
  }

  return false; // Return false if no profanity is found
}

String preprocessWord(String word) {
  // Replace special characters with their English equivalents (subjective)
  word = word
      .replaceAll('@', 'a')
      .replaceAll('6', 'b')
      .replaceAll('1', 'i')
      .replaceAll('4', 'a')
      .replaceAll('3', 'e')
      .replaceAll('!', 'i')
      .replaceAll('9', 'g')
      .replaceAll('0', 'o')
      .replaceAll('2', 'r')
      .replaceAll('5', 's');

  // Remove non-English characters
  word = word.replaceAll(RegExp(r'[^a-zA-Z\s]'), '');

  return word;
}
