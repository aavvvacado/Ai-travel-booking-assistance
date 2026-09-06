import '../../../../core/errors/result.dart';
import '../entities/flight.dart';
import '../entities/search_criteria.dart';
import '../repositories/flight_repository.dart';

class SearchFlightsUseCase {
  final FlightRepository repository;

  SearchFlightsUseCase(this.repository);

  Future<Result<List<Flight>>> call(SearchCriteria criteria) {
    return repository.searchFlights(criteria);
  }
}
