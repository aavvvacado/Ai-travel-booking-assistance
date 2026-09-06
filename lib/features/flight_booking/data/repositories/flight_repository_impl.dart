import '../../../../core/errors/result.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/flight.dart';
import '../../domain/entities/search_criteria.dart';
import '../../domain/repositories/flight_repository.dart';
import '../../domain/services/flight_search_service.dart';
import '../datasources/flight_local_datasource.dart';

class FlightRepositoryImpl implements FlightRepository {
  final FlightLocalDataSource localDataSource;
  final FlightSearchService _searchService = const FlightSearchService();

  FlightRepositoryImpl(this.localDataSource);

  @override
  Future<Result<List<Flight>>> getAllFlights() async {
    try {
      final flights = await localDataSource.getFlights();
      return Success(flights);
    } catch (e) {
      return FailureResult(CacheFailure('Failed to load flights: $e'));
    }
  }

  @override
  Future<Result<Flight>> getFlightById(String flightId) async {
    try {
      final flights = await localDataSource.getFlights();
      final flight = flights.firstWhere((f) => f.id == flightId || f.flightNumber == flightId);
      return Success(flight);
    } catch (e) {
      return FailureResult(CacheFailure('Flight with ID $flightId not found.'));
    }
  }

  @override
  Future<Result<List<Flight>>> searchFlights(SearchCriteria criteria) async {
    try {
      final flights = await localDataSource.getFlights();
      final filtered = _searchService.searchFlights(flights: flights, criteria: criteria);
      return Success(filtered);
    } catch (e) {
      return FailureResult(CacheFailure('Error searching flights: $e'));
    }
  }
}
