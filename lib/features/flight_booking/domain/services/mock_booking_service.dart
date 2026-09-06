import 'dart:math';
import '../entities/booking.dart';
import '../entities/flight.dart';
import '../entities/passenger_details.dart';

class MockBookingService {
  const MockBookingService();

  /// Create a deterministic mock booking confirmation with Dart reference code (e.g. TRV-8F42KQ)
  Booking createBooking({
    required Flight flight,
    required PassengerDetails passenger,
    String? seatNumber,
  }) {
    final reference = _generateBookingReference();
    final pnr = _generatePnr();
    final seat = seatNumber ?? _generateRandomSeat();

    return Booking(
      bookingId: reference,
      pnrCode: pnr,
      flight: flight,
      passengerName: passenger.fullName,
      passengerEmail: passenger.email,
      passportOrId: passenger.phone,
      seatNumber: seat,
      bookingDate: DateTime.now(),
      status: BookingStatus.confirmed,
    );
  }

  static String _generateBookingReference() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';
    final rnd = Random();
    final code = List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
    return 'TRV-$code';
  }

  static String _generatePnr() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    final rnd = Random();
    return List.generate(6, (_) => chars[rnd.nextInt(chars.length)]).join();
  }

  static String _generateRandomSeat() {
    final rnd = Random();
    final row = rnd.nextInt(25) + 1;
    final seatLetter = ['A', 'B', 'C', 'D', 'E', 'F'][rnd.nextInt(6)];
    return '$row$seatLetter';
  }
}
