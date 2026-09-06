import '../../../../core/errors/result.dart';
import '../entities/flight.dart';
import '../entities/search_criteria.dart';

abstract class FlightRepository {
  Future<Result<List<Flight>>> getAllFlights();
  Future<Result<List<Flight>>> searchFlights(SearchCriteria criteria);
  Future<Result<Flight>> getFlightById(String flightId);
}
