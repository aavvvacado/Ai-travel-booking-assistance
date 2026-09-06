import '../models/booking_model.dart';
import '../../domain/entities/booking.dart';

abstract class BookingLocalDataSource {
  Future<BookingModel> saveBooking(BookingModel booking);
  Future<List<BookingModel>> getBookings();
  Future<BookingModel> cancelBooking(String bookingId);
}

class BookingLocalDataSourceImpl implements BookingLocalDataSource {
  final List<BookingModel> _bookings = [];

  @override
  Future<BookingModel> saveBooking(BookingModel booking) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _bookings.insert(0, booking);
    return booking;
  }

  @override
  Future<List<BookingModel>> getBookings() async {
    await Future.delayed(const Duration(milliseconds: 50));
    return List.unmodifiable(_bookings);
  }

  @override
  Future<BookingModel> cancelBooking(String bookingId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final index = _bookings.indexWhere((b) => b.bookingId == bookingId);
    if (index != -1) {
      final updated = _bookings[index].copyWith(status: BookingStatus.cancelled) as BookingModel;
      _bookings[index] = updated;
      return updated;
    } else {
      throw Exception('Booking with ID $bookingId not found.');
    }
  }
}
