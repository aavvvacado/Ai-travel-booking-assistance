import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/services/service_locator.dart';
import 'features/flight_booking/presentation/bloc/voice_chat_bloc.dart';
import 'features/flight_booking/presentation/bloc/booking_bloc.dart';
import 'features/flight_booking/presentation/pages/travel_assistant_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ServiceLocator.instance.init();

  runApp(const AiTravelApp());
}

class AiTravelApp extends StatelessWidget {
  const AiTravelApp({super.key});

  @override
  Widget build(BuildContext context) {
    final sl = ServiceLocator.instance;

    return MultiBlocProvider(
      providers: [
        BlocProvider<VoiceChatBloc>(
          create: (context) => VoiceChatBloc(
            sttService: sl.sttService,
            ttsService: sl.ttsService,
            parseUserIntentUseCase: sl.parseUserIntentUseCase,
            searchFlightsUseCase: sl.searchFlightsUseCase,
          ),
        ),
        BlocProvider<BookingBloc>(
          create: (context) => BookingBloc(
            confirmBookingUseCase: sl.confirmBookingUseCase,
            cancelBookingUseCase: sl.cancelBookingUseCase,
            bookingRepository: sl.bookingRepository,
          ),
        ),
      ],
      child: MaterialApp(
        title: 'AI Travel Assistant',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const TravelAssistantPage(),
      ),
    );
  }
}
