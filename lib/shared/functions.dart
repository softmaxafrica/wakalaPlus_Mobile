import 'dart:math';

class Functions{
  static String generateRequestId() {
    // Generate a random number with 4 digits
    int randomNumber = Random().nextInt(10000);
    String requestId = 'REQ' + randomNumber.toString().padLeft(4, '0');
    return requestId;
  }
}