import 'package:equatable/equatable.dart';
import '../../domain/entities/booking.dart';

enum BookingStateStatus { initial, loading, success, error }

class BookingState extends Equatable {
  final BookingStateStatus status;
  final List<Booking> bookings;
  final Booking? latestConfirmedBooking;
  final String? errorMessage;

  const BookingState({
    this.status = BookingStateStatus.initial,
    this.bookings = const [],
    this.latestConfirmedBooking,
    this.errorMessage,
  });

  BookingState copyWith({
    BookingStateStatus? status,
    List<Booking>? bookings,
    Booking? latestConfirmedBooking,
    String? errorMessage,
  }) {
    return BookingState(
      status: status ?? this.status,
      bookings: bookings ?? this.bookings,
      latestConfirmedBooking: latestConfirmedBooking ?? this.latestConfirmedBooking,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, bookings, latestConfirmedBooking, errorMessage];
}
