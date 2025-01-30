import 'package:flutter/material.dart';
import 'package:clients_manager/src/features/weather/ui/controllers/weather_controller.dart';
import 'package:clients_manager/src/features/weather/data/services/weather_service.dart';
import 'package:clients_manager/src/features/weather/data/repositories/weather_repository.dart';
import 'package:clients_manager/src/features/weather/ui/widgets/weather_card_widget.dart';

class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage>
    with AutomaticKeepAliveClientMixin {
  late final WeatherController _weatherController;

  @override
  bool get wantKeepAlive => true; // Preserva o estado da página

  @override
  void initState() {
    super.initState();

    // Inicializa o controlador e busca os dados do clima
    _weatherController = WeatherController(
      service: WeatherService(
        repository: WeatherRepository(apiKey: '67241a63d0acb68d90993bd49c549327'),
      ),
    );

    // Busca os dados do clima para Faro
    _weatherController.fetchWeather(
      37.0154,
       -7.9352,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Importante quando usando AutomaticKeepAliveClientMixin
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