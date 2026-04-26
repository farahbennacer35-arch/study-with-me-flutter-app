import 'dart:async';
import 'package:flutter/foundation.dart'; // pour debugPrint

class SessionService {
  Future<int> addSessions(FutureOr<int> futureOrInt, int valueToAdd) async {
    int actualValue;

    if (futureOrInt is Future<int>) {
      actualValue = await futureOrInt;
    } else {
      actualValue = futureOrInt; // pas besoin de cast
    }

    return actualValue + valueToAdd;
  }

  void printSum(int sumValue) {
    debugPrint('Le total est : $sumValue'); // plus sûr pour Flutter
  }
}
