import 'package:equatable/equatable.dart';
import '../../domain/entities/flight.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserBookingsEvent extends BookingEvent {}

class CreateBookingEvent extends BookingEvent {
  final Flight flight;
  final String passengerName;
  final String passengerEmail;
  final String passportOrId;
  final String seatNumber;

  const CreateBookingEvent({
    required this.flight,
    required this.passengerName,
    required this.passengerEmail,
    required this.passportOrId,
    required this.seatNumber,
  });

  @override
  List<Object?> get props => [flight, passengerName, passengerEmail, passportOrId, seatNumber];
}

class CancelBookingEvent extends BookingEvent {
  final String bookingId;
  const CancelBookingEvent(this.bookingId);

  @override
  List<Object?> get props => [bookingId];
}
