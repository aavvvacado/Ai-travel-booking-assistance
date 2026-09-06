import 'dart:math';

class ReferenceGenerator {
  ReferenceGenerator._();

  static final Random _random = Random();

  /// Generates a realistic booking reference ID e.g. TRV-7842-X9
  static String generateBookingId() {
    final numPart = _random.nextInt(8999) + 1000;
    final charPart = String.fromCharCode(65 + _random.nextInt(26)) + _random.nextInt(9).toString();
    return 'TRV-$numPart-$charPart';
  }

  /// Generates a 6-character PNR code e.g. WX9K2L
  static String generatePnr() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (index) => chars[_random.nextInt(chars.length)]).join();
  }
}
