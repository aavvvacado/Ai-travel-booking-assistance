import 'package:equatable/equatable.dart';

class Flight extends Equatable {
  final String id;
  final String airline;
  final String airlineLogo; // Asset or icon tag
  final String flightNumber;
  final String origin;
  final String originCode;
  final String destination;
  final String destinationCode;
  final String departureTime; // "08:30"
  final String arrivalTime;   // "11:45"
  final String duration;       // "3h 15m"
  final double price;          // USD amount
  final int stops;             // 0 for direct, 1 for connecting
  final String? layoverCity;
  final String? layoverDuration;
  final String cabinClass;     // "Economy", "Business", "First"
  final int availableSeats;
  final List<String> amenities; // ["Wi-Fi", "Meal", "USB Power"]
  final String baggageInfo;

  const Flight({
    required this.id,
    required this.airline,
    required this.airlineLogo,
    required this.flightNumber,
    required this.origin,
    required this.originCode,
    required this.destination,
    required this.destinationCode,
    required this.departureTime,
    required this.arrivalTime,
    required this.duration,
    required this.price,
    required this.stops,
    this.layoverCity,
    this.layoverDuration,
    required this.cabinClass,
    required this.availableSeats,
    required this.amenities,
    required this.baggageInfo,
  });

  bool get isDirect => stops == 0;

  @override
  List<Object?> get props => [
        id,
        airline,
        flightNumber,
        origin,
        originCode,
        destination,
        destinationCode,
        departureTime,
        arrivalTime,
        duration,
        price,
        stops,
        layoverCity,
        layoverDuration,
        cabinClass,
        availableSeats,
        amenities,
        baggageInfo,
      ];
}
