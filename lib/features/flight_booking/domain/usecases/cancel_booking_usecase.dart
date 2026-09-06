import '../../../../core/errors/result.dart';
import '../entities/booking.dart';
import '../repositories/booking_repository.dart';

class CancelBookingUseCase {
  final BookingRepository repository;

  CancelBookingUseCase(this.repository);

  Future<Result<Booking>> call(String bookingId) {
    return repository.cancelBooking(bookingId);
  }
}
