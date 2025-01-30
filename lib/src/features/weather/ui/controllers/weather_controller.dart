import 'package:flutter/material.dart';
import 'package:clients_manager/src/features/weather/data/services/weather_service.dart';
import 'package:clients_manager/src/features/weather/domain/models/weather_model.dart';

class WeatherController {
  final WeatherService service;
  final ValueNotifier<bool> isLoading = ValueNotifier(false);
  final ValueNotifier<String?> errorMessage = ValueNotifier(null);
  final ValueNotifier<List<CurrentWeather>?> weatherListNotifier = ValueNotifier(null);

  WeatherController({required this.service});

  Future<void> fetchWeather(double latitude, double longitude) async {
    isLoading.value = true;
    errorMessage.value = null;
    weatherListNotifier.value = null;

    try {
      // Usa o serviço para buscar os dados formatados
      final weatherList = await service.getFormattedDailyWeather(
        latitude: latitude,
        longitude: longitude,
      );

      // Atualiza o notificador com a lista de dados
      weatherListNotifier.value = weatherList;
    } catch (e) {
      errorMessage.value = 'Erro ao buscar clima: $e';
    } finally {
      isLoading.value = false;
    }
  }
}