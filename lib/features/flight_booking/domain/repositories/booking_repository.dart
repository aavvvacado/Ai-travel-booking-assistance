import '../../../../core/errors/result.dart';
import '../entities/booking.dart';
import '../entities/flight.dart';

abstract class BookingRepository {
  Future<Result<Booking>> createBooking({
    required Flight flight,
    required String passengerName,
    required String passengerEmail,
    required String passportOrId,
    required String seatNumber,
  });

  Future<Result<List<Booking>>> getBookings();
  Future<Result<Booking>> cancelBooking(String bookingId);
}
