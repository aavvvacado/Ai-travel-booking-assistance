import 'package:equatable/equatable.dart';
import 'flight.dart';

enum BookingStatus { confirmed, cancelled }

class Booking extends Equatable {
  final String bookingId;
  final String pnrCode;
  final Flight flight;
  final String passengerName;
  final String passengerEmail;
  final String passportOrId;
  final String seatNumber;
  final DateTime bookingDate;
  final BookingStatus status;

  const Booking({
    required this.bookingId,
    required this.pnrCode,
    required this.flight,
    required this.passengerName,
    required this.passengerEmail,
    required this.passportOrId,
    required this.seatNumber,
    required this.bookingDate,
    this.status = BookingStatus.confirmed,
  });

  Booking copyWith({
    BookingStatus? status,
  }) {
    return Booking(
      bookingId: bookingId,
      pnrCode: pnrCode,
      flight: flight,
      passengerName: passengerName,
      passengerEmail: passengerEmail,
      passportOrId: passportOrId,
      seatNumber: seatNumber,
      bookingDate: bookingDate,
      status: status ?? this.status,
    );
  }

  @override
  List<Object?> get props => [
        bookingId,
        pnrCode,
        flight,
        passengerName,
        passengerEmail,
        passportOrId,
        seatNumber,
        bookingDate,
        status,
      ];
}
