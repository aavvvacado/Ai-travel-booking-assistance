import '../../../../core/errors/result.dart';
import '../entities/booking.dart';
import '../entities/flight.dart';
import '../repositories/booking_repository.dart';

class ConfirmBookingUseCase {
  final BookingRepository repository;

  ConfirmBookingUseCase(this.repository);

  Future<Result<Booking>> call({
    required Flight flight,
    required String passengerName,
    required String passengerEmail,
    required String passportOrId,
    required String seatNumber,
  }) {
    return repository.createBooking(
      flight: flight,
      passengerName: passengerName,
      passengerEmail: passengerEmail,
      passportOrId: passportOrId,
      seatNumber: seatNumber,
    );
  }
}
