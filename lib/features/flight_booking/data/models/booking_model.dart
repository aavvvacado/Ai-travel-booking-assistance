import '../../domain/entities/booking.dart';
import 'flight_model.dart';

class BookingModel extends Booking {
  const BookingModel({
    required super.bookingId,
    required super.pnrCode,
    required super.flight,
    required super.passengerName,
    required super.passengerEmail,
    required super.passportOrId,
    required super.seatNumber,
    required super.bookingDate,
    super.status,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    return BookingModel(
      bookingId: json['bookingId'],
      pnrCode: json['pnrCode'],
      flight: FlightModel.fromJson(json['flight']),
      passengerName: json['passengerName'],
      passengerEmail: json['passengerEmail'],
      passportOrId: json['passportOrId'],
      seatNumber: json['seatNumber'],
      bookingDate: DateTime.parse(json['bookingDate']),
      status: json['status'] == 'cancelled' ? BookingStatus.cancelled : BookingStatus.confirmed,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bookingId': bookingId,
      'pnrCode': pnrCode,
      'flight': (flight as FlightModel).toJson(),
      'passengerName': passengerName,
      'passengerEmail': passengerEmail,
      'passportOrId': passportOrId,
      'seatNumber': seatNumber,
      'bookingDate': bookingDate.toIso8601String(),
      'status': status == BookingStatus.cancelled ? 'cancelled' : 'confirmed',
    };
  }
}
