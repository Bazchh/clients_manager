import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clients_manager/src/features/weather/domain/models/weather_model.dart';

class WeatherRepository {
  final String apiKey;
  final String apibaseUrl;

  WeatherRepository({
    required this.apiKey,
    this.apibaseUrl = 'https://api.openweathermap.org/data/2.5/weather',
  });

  Future<CurrentWeather> fetchCurrentWeather({
    required double latitude,
    required double longitude,
    String units = 'metric',
    String lang = 'en',
  }) async {
    final url = Uri.parse(
      '$apibaseUrl?lat=$latitude&lon=$longitude&units=$units&lang=$lang&appid=$apiKey',
    );

    // Log da URL gerada
    print('Requisição para: $url');

    try {
      // Realiza a requisição HTTP
      final response = await http.get(url);

      // Log do status code da resposta
      print('Status Code: ${response.statusCode}');

      // Verifica se a resposta foi bem-sucedida (status code 200)
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return CurrentWeather.fromJson(data);
      } else {
        throw Exception('${response.reasonPhrase}');
      }
    } catch (error) {
      print('Erro capturado: $error');
      throw Exception('$error');
    }
  }
}