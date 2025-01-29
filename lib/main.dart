import 'package:flutter/material.dart';
import 'package:clients_manager/src/features/weather/ui/controllers/weather_controller.dart';
import 'package:clients_manager/src/features/weather/data/services/weather_service.dart';
import 'package:clients_manager/src/features/weather/ui/widgets/weather_card_widget.dart';
import 'package:clients_manager/src/features/weather/data/repositories/weather_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  await Supabase.initialize(
    url: 'https://ttxorfpxadojffxpgbub.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InR0eG9yZnB4YWRvamZmeHBnYnViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3Mzc4NTIwOTYsImV4cCI6MjA1MzQyODA5Nn0.bHp-RY0eu_8dbX5iCvWk-_9ylucaJVPN9PzmuN2_Avk',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const WeatherHomePage(),
    );
  }
}

class WeatherHomePage extends StatefulWidget {
  const WeatherHomePage({Key? key}) : super(key: key);

  @override
  State<WeatherHomePage> createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  late final WeatherController _weatherController;

  @override
  void initState() {
    super.initState();
    _weatherController = WeatherController(
      weatherService: WeatherService(repository: WeatherRepository(apiKey: '67241a63d0acb68d90993bd49c549327')),
    );
    
    _weatherController.fetchDailyWeather(
      latitude: 37.0154,
      longitude: -7.9352,
      lang: 'en',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weather"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              "Weather situation for Faro today",
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 16.0),
            WeatherCard(controller: _weatherController),
          ],
        ),
      ),
    );
  }
}
