import 'package:clients_manager/src/features/weather/data/repositories/weather_repository.dart';
import 'package:clients_manager/src/features/weather/domain/models/weather_model.dart';

class WeatherService {
  final WeatherRepository repository;

  WeatherService({required this.repository});

  Future<List<CurrentWeather>> getFormattedDailyWeather({
    required double latitude,
    required double longitude,
    String lang = 'en',
  }) async {
    try {
      // Busca os dados atuais do clima
      final currentWeather = await repository.fetchCurrentWeather(
        latitude: latitude,
        longitude: longitude,
        lang: lang,
      );

      // Retorna os dados formatados como uma lista (para compatibilidade futura)
      return [currentWeather];
    } catch (e) {
      throw Exception('Erro ao processar os dados do clima: $e');
    }
  }
}