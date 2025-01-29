import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:clients_manager/src/features/weather/domain/models/weather_model.dart';

class WeatherRepository {
  final String apiKey;
  final String apibaseUrl;

  WeatherRepository({
    required this.apiKey,
    this.apibaseUrl = 'https://api.openweathermap.org/data/3.0/onecall',
  });

  Future<List<DailyWeather>> fetchDailyWeather({
    required double latitude,
    required double longitude,
    String exclude = 'current,minutely,hourly,alerts',
    String units = 'metric',
    String lang = 'en',
  }) async {
    final url = Uri.parse(
      '$apibaseUrl?lat=$latitude&lon=$longitude&exclude=$exclude&units=$units&lang=$lang&appid=$apiKey',
    );

    print('Requisição para: $url');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> dailyJson = data['daily'];

        return dailyJson.map((json) => DailyWeather.fromJson(json)).toList();
      } else {
        throw Exception('${response.reasonPhrase}');
      }
    } catch (error) {
      throw Exception('$error');
    }
  }
}
