import 'package:clients_manager/src/features/weather/data/repositories/weather_repository.dart';
import 'package:clients_manager/src/features/weather/domain/models/weather_model.dart';

class WeatherService {
  final WeatherRepository repository;

  WeatherService({required this.repository});

  Future<List<DailyWeather>> getFormattedDailyWeather({
    required double latitude,
    required double longitude,
    String lang = 'en',
  }) async {
    try {
      final dailyWeatherList = await repository.fetchDailyWeather(
        latitude: latitude,
        longitude: longitude,
        lang: lang,
      );

      return dailyWeatherList;
    } catch (e) {
      throw Exception('Erro ao processar os dados do clima: $e');
    }
  }
}
