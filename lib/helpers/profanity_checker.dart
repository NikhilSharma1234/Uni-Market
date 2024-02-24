import 'package:profanity_filter/profanity_filter.dart';
import 'package:uni_market/helpers/constants.dart';

bool checkProfanity(String inputString) {
  final filter = ProfanityFilter.filterAdditionally(additionalProfanity);
  return filter.hasProfanity(inputString);
}
