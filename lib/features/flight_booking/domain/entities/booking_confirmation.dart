import 'package:equatable/equatable.dart';
import 'flight.dart';
import 'passenger_details.dart';

enum BookingStatus { confirmed, pending, failed, cancelled }

class BookingConfirmation extends Equatable {
  final String bookingId;
  final Flight flight;
  final PassengerDetails passenger;
  final double totalPrice;
  final BookingStatus status;
  final DateTime createdAt;

  const BookingConfirmation({
    required this.bookingId,
    required this.flight,
    required this.passenger,
    required this.totalPrice,
    this.status = BookingStatus.confirmed,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        bookingId,
        flight,
        passenger,
        totalPrice,
        status,
        createdAt,
      ];
}
