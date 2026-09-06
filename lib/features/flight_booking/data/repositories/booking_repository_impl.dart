import '../../../../core/errors/result.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/reference_generator.dart';
import '../../domain/entities/booking.dart';
import '../../domain/entities/flight.dart';
import '../../domain/repositories/booking_repository.dart';
import '../datasources/booking_local_datasource.dart';
import '../models/booking_model.dart';
import '../models/flight_model.dart';

class BookingRepositoryImpl implements BookingRepository {
  final BookingLocalDataSource localDataSource;

  BookingRepositoryImpl(this.localDataSource);

  @override
  Future<Result<Booking>> createBooking({
    required Flight flight,
    required String passengerName,
    required String passengerEmail,
    required String passportOrId,
    required String seatNumber,
  }) async {
    try {
      final bookingId = ReferenceGenerator.generateBookingId();
      final pnrCode = ReferenceGenerator.generatePnr();

      final flightModel = FlightModel(
        id: flight.id,
        airline: flight.airline,
        airlineLogo: flight.airlineLogo,
        flightNumber: flight.flightNumber,
        origin: flight.origin,
        originCode: flight.originCode,
        destination: flight.destination,
        destinationCode: flight.destinationCode,
        departureTime: flight.departureTime,
        arrivalTime: flight.arrivalTime,
        duration: flight.duration,
        price: flight.price,
        stops: flight.stops,
        layoverCity: flight.layoverCity,
        layoverDuration: flight.layoverDuration,
        cabinClass: flight.cabinClass,
        availableSeats: flight.availableSeats,
        amenities: flight.amenities,
        baggageInfo: flight.baggageInfo,
      );

      final model = BookingModel(
        bookingId: bookingId,
        pnrCode: pnrCode,
        flight: flightModel,
        passengerName: passengerName,
        passengerEmail: passengerEmail,
        passportOrId: passportOrId,
        seatNumber: seatNumber,
        bookingDate: DateTime.now(),
        status: BookingStatus.confirmed,
      );

      final saved = await localDataSource.saveBooking(model);
      return Success(saved);
    } catch (e) {
      return FailureResult(BookingFailure('Failed to complete booking: $e'));
    }
  }

  @override
  Future<Result<List<Booking>>> getBookings() async {
    try {
      final list = await localDataSource.getBookings();
      return Success(list);
    } catch (e) {
      return FailureResult(CacheFailure('Failed to fetch bookings: $e'));
    }
  }

  @override
  Future<Result<Booking>> cancelBooking(String bookingId) async {
    try {
      final updated = await localDataSource.cancelBooking(bookingId);
      return Success(updated);
    } catch (e) {
      return FailureResult(BookingFailure('Failed to cancel booking: $e'));
    }
  }
}
