import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/booking.dart';
import '../../domain/usecases/confirm_booking_usecase.dart';
import '../../domain/usecases/cancel_booking_usecase.dart';
import '../../domain/repositories/booking_repository.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final ConfirmBookingUseCase confirmBookingUseCase;
  final CancelBookingUseCase cancelBookingUseCase;
  final BookingRepository bookingRepository;

  BookingBloc({
    required this.confirmBookingUseCase,
    required this.cancelBookingUseCase,
    required this.bookingRepository,
  }) : super(const BookingState()) {
    on<LoadUserBookingsEvent>(_onLoadUserBookings);
    on<CreateBookingEvent>(_onCreateBooking);
    on<CancelBookingEvent>(_onCancelBooking);
  }

  void _onLoadUserBookings(LoadUserBookingsEvent event, Emitter<BookingState> emit) async {
    emit(state.copyWith(status: BookingStateStatus.loading));
    final result = await bookingRepository.getBookings();
    result.fold(
      (list) => emit(state.copyWith(status: BookingStateStatus.initial, bookings: list)),
      (failure) => emit(state.copyWith(status: BookingStateStatus.error, errorMessage: failure.message)),
    );
  }

  void _onCreateBooking(CreateBookingEvent event, Emitter<BookingState> emit) async {
    emit(state.copyWith(status: BookingStateStatus.loading));
    final result = await confirmBookingUseCase(
      flight: event.flight,
      passengerName: event.passengerName,
      passengerEmail: event.passengerEmail,
      passportOrId: event.passportOrId,
      seatNumber: event.seatNumber,
    );

    result.fold(
      (booking) async {
        final currentList = List<Booking>.from(state.bookings)..insert(0, booking);
        emit(state.copyWith(
          status: BookingStateStatus.success,
          bookings: currentList,
          latestConfirmedBooking: booking,
        ));
      },
      (failure) {
        emit(state.copyWith(
          status: BookingStateStatus.error,
          errorMessage: failure.message,
        ));
      },
    );
  }

  void _onCancelBooking(CancelBookingEvent event, Emitter<BookingState> emit) async {
    emit(state.copyWith(status: BookingStateStatus.loading));
    final result = await cancelBookingUseCase(event.bookingId);
    result.fold(
      (cancelledBooking) async {
        final updatedList = state.bookings.map((b) {
          return b.bookingId == cancelledBooking.bookingId ? cancelledBooking : b;
        }).toList();

        emit(state.copyWith(
          status: BookingStateStatus.initial,
          bookings: updatedList,
        ));
      },
      (failure) {
        emit(state.copyWith(
          status: BookingStateStatus.error,
          errorMessage: failure.message,
        ));
      },
    );
  }
}
