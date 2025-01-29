import 'package:flutter/material.dart';
import 'package:clients_manager/src/features/weather/domain/models/weather_model.dart';
import 'package:clients_manager/src/features/weather/data/services/weather_service.dart';

class WeatherController {
  final WeatherService weatherService;
  final ValueNotifier<List<DailyWeather>?> dailyWeatherNotifier = ValueNotifier(null);
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);

  WeatherController({required this.weatherService});

  Future<void> fetchDailyWeather({
    required double latitude,
    required double longitude,
    String lang = 'en',
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = null;

      final dailyWeatherList = await weatherService.getFormattedDailyWeather(
        latitude: latitude,
        longitude: longitude,
        lang: lang,
      );

      dailyWeatherNotifier.value = dailyWeatherList;
    } catch (e) {
      errorMessage.value = 'Erro ao buscar os dados meteorológicos: $e';
    } finally {
      isLoading.value = false;
    }
  }
}
