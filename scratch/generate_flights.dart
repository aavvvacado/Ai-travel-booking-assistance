import 'dart:io';
import 'dart:math';

void main() {
  final file = File('lib/features/flight_booking/data/datasources/flight_local_datasource.dart');
  final content = file.readAsStringSync();

  final badIndex = content.indexOf("id: 'f_gen_\${i}'");
  if (badIndex == -1) {
    print('No bad flights found.');
    return;
  }

  // Find the start of the broken FlightModel
  final flightModelIndex = content.lastIndexOf('FlightModel(', badIndex);
  
  if (flightModelIndex == -1) {
    print('Could not find FlightModel before bad id');
    return;
  }

  // Slice the valid part
  final validContent = content.substring(0, flightModelIndex);

  // Generate 200 mock flights
  final buffer = StringBuffer();
  buffer.write(validContent);
  
  final random = Random(42);
  
  final cities = [
    {'name': 'Mumbai', 'code': 'BOM'},
    {'name': 'Delhi', 'code': 'DEL'},
    {'name': 'Dubai', 'code': 'DXB'},
    {'name': 'London', 'code': 'LHR'},
    {'name': 'New York', 'code': 'JFK'},
    {'name': 'Singapore', 'code': 'SIN'},
    {'name': 'Tokyo', 'code': 'HND'},
    {'name': 'Paris', 'code': 'CDG'},
    {'name': 'Sydney', 'code': 'SYD'},
    {'name': 'Bangkok', 'code': 'BKK'},
    {'name': 'Chennai', 'code': 'MAA'},
    {'name': 'Bengaluru', 'code': 'BLR'},
  ];

  final airlines = [
    {'name': 'Emirates', 'logo': 'emirates'},
    {'name': 'IndiGo', 'logo': 'indigo'},
    {'name': 'Air India', 'logo': 'airindia'},
    {'name': 'British Airways', 'logo': 'ba'},
    {'name': 'Singapore Airlines', 'logo': 'singapore_air'},
    {'name': 'Vistara', 'logo': 'vistara'},
    {'name': 'Qatar Airways', 'logo': 'qatar'},
    {'name': 'Lufthansa', 'logo': 'lufthansa'},
  ];

  for (int i = 0; i < 200; i++) {
    final origin = cities[random.nextInt(cities.length)];
    var dest = cities[random.nextInt(cities.length)];
    while (dest['code'] == origin['code']) {
      dest = cities[random.nextInt(cities.length)];
    }
    
    final airline = airlines[random.nextInt(airlines.length)];
    final isDirect = random.nextBool();
    
    final depHour = random.nextInt(24);
    final depMin = random.nextInt(60);
    final depTimeStr = '${depHour.toString().padLeft(2, '0')}:${depMin.toString().padLeft(2, '0')}';
    
    final durationHours = random.nextInt(12) + 2;
    final durationMins = random.nextInt(60);
    final durationStr = '${durationHours}h ${durationMins}m';
    
    final arrHour = (depHour + durationHours) % 24;
    final arrMin = (depMin + durationMins) % 60;
    final arrTimeStr = '${arrHour.toString().padLeft(2, '0')}:${arrMin.toString().padLeft(2, '0')}';
    
    final price = 50.0 + random.nextInt(800);
    final cabinClass = price > 400 ? 'Business' : 'Economy';
    final id = 'f_gen_${i}';
    
    buffer.writeln('    FlightModel(');
    buffer.writeln("      id: '${id}',");
    buffer.writeln("      airline: '${airline['name']}',");
    buffer.writeln("      airlineLogo: '${airline['logo']}',");
    buffer.writeln("      flightNumber: '${airline['logo']?.toUpperCase().substring(0,2) ?? 'XX'}-${random.nextInt(8000) + 1000}',");
    buffer.writeln("      origin: '${origin['name']}',");
    buffer.writeln("      originCode: '${origin['code']}',");
    buffer.writeln("      destination: '${dest['name']}',");
    buffer.writeln("      destinationCode: '${dest['code']}',");
    buffer.writeln("      departureTime: '${depTimeStr}',");
    buffer.writeln("      arrivalTime: '${arrTimeStr}',");
    buffer.writeln("      duration: '${durationStr}',");
    buffer.writeln("      price: ${price},");
    
    if (isDirect) {
      buffer.writeln("      stops: 0,");
    } else {
      final layover = cities[random.nextInt(cities.length)];
      buffer.writeln("      stops: 1,");
      buffer.writeln("      layoverCity: '${layover['name']}',");
      buffer.writeln("      layoverDuration: '${random.nextInt(4) + 1}h ${random.nextInt(60)}m',");
    }
    
    buffer.writeln("      cabinClass: '${cabinClass}',");
    buffer.writeln("      availableSeats: ${random.nextInt(40) + 1},");
    buffer.writeln("      amenities: const ['Meals', 'Wi-Fi', 'Entertainment'],");
    buffer.writeln("      baggageInfo: '7kg Cabin + 25kg Check-in',");
    buffer.writeln('    ),');
  }

  // Close the array and class
  buffer.writeln('  ];');
  buffer.writeln();
  buffer.writeln('  @override');
  buffer.writeln('  Future<List<FlightModel>> getFlights() async {');
  buffer.writeln('    await Future.delayed(const Duration(milliseconds: 50));');
  buffer.writeln('    return _mockFlights;');
  buffer.writeln('  }');
  buffer.writeln('}');

  file.writeAsStringSync(buffer.toString());
  print('Successfully fixed flight_local_datasource.dart and generated 200 valid flights.');
}
