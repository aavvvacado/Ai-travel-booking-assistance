import 'package:equatable/equatable.dart';

/// Base class for all domain & data layer failures
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object?> get props => [message];
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'A server error occurred.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Failed to access local storage.']);
}

class VoiceFailure extends Failure {
  const VoiceFailure([super.message = 'Voice recognition error occurred.']);
}

class AiParsingFailure extends Failure {
  const AiParsingFailure([super.message = 'Failed to process prompt with AI.']);
}

class BookingFailure extends Failure {
  const BookingFailure([super.message = 'Failed to complete booking.']);
}
