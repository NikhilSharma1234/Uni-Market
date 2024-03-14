import 'package:uni_market/helpers/constants.dart';

class ProfilePicShuffler {
  const ProfilePicShuffler();

  String? reveal() {
    availableProfilePicsIndices.shuffle();
    return stockProfilePics[availableProfilePicsIndices.last];
  }
}

List<int> availableProfilePicsIndices = [
  //
  // CHANCES FOR RECEIVING ______ profile pic upon account  creation (100 indices)
  // Dr. Folhmer: 1%
  // Astronaught: 9%
  // Bear: 15%
  // Cat: 15%
  // Dog: 15%
  // Gorilla: 15%
  // Llama: 15%
  // Rabbit: 15%
  //
  0, // ASTRONAUGHT
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  0,
  1, // BEAR
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  1,
  2, // RARE FOHLMER (BEARD)
  3, // CAT
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  3,
  4, // DOG
  4,
  4,
  4,
  4,
  4,
  4,
  4,
  4,
  4,
  4,
  4,
  4,
  4,
  4,
  5, // GORILLA
  5,
  5,
  5,
  5,
  5,
  5,
  5,
  5,
  5,
  5,
  5,
  5,
  5,
  5,
  6, // LLAMA
  6,
  6,
  6,
  6,
  6,
  6,
  6,
  6,
  6,
  6,
  6,
  6,
  6,
  6,
  7, // RABBIT
  7,
  7,
  7,
  7,
  7,
  7,
  7,
  7,
  7,
  7,
  7,
  7,
  7,
  7,
];
