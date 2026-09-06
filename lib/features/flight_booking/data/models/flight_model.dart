import '../../domain/entities/flight.dart';

class FlightModel extends Flight {
  const FlightModel({
    required super.id,
    required super.airline,
    required super.airlineLogo,
    required super.flightNumber,
    required super.origin,
    required super.originCode,
    required super.destination,
    required super.destinationCode,
    required super.departureTime,
    required super.arrivalTime,
    required super.duration,
    required super.price,
    required super.stops,
    super.layoverCity,
    super.layoverDuration,
    required super.cabinClass,
    required super.availableSeats,
    required super.amenities,
    required super.baggageInfo,
  });

  factory FlightModel.fromJson(Map<String, dynamic> json) {
    return FlightModel(
      id: json['id'],
      airline: json['airline'],
      airlineLogo: json['airlineLogo'] ?? 'airplane',
      flightNumber: json['flightNumber'],
      origin: json['origin'],
      originCode: json['originCode'],
      destination: json['destination'],
      destinationCode: json['destinationCode'],
      departureTime: json['departureTime'],
      arrivalTime: json['arrivalTime'],
      duration: json['duration'],
      price: (json['price'] as num).toDouble(),
      stops: json['stops'] as int,
      layoverCity: json['layoverCity'],
      layoverDuration: json['layoverDuration'],
      cabinClass: json['cabinClass'] ?? 'Economy',
      availableSeats: json['availableSeats'] ?? 12,
      amenities: List<String>.from(json['amenities'] ?? []),
      baggageInfo: json['baggageInfo'] ?? '7kg Cabin + 23kg Check-in',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'airline': airline,
      'airlineLogo': airlineLogo,
      'flightNumber': flightNumber,
      'origin': origin,
      'originCode': originCode,
      'destination': destination,
      'destinationCode': destinationCode,
      'departureTime': departureTime,
      'arrivalTime': arrivalTime,
      'duration': duration,
      'price': price,
      'stops': stops,
      'layoverCity': layoverCity,
      'layoverDuration': layoverDuration,
      'cabinClass': cabinClass,
      'availableSeats': availableSeats,
      'amenities': amenities,
      'baggageInfo': baggageInfo,
    };
  }
}
