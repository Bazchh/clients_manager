import 'package:flutter/material.dart';
import 'package:clients_manager/src/features/weather/ui/controllers/weather_controller.dart';
import 'package:clients_manager/src/features/weather/domain/models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherController controller;

  const WeatherCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: controller.isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return ValueListenableBuilder<String?>(
          valueListenable: controller.errorMessage,
          builder: (context, error, _) {
            if (error != null) {
              return Center(
                child: Text(
                  error,
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            return ValueListenableBuilder<List<CurrentWeather>?>(
              valueListenable: controller.weatherListNotifier,
              builder: (context, weatherList, _) {
                if (weatherList == null || weatherList.isEmpty) {
                  return const Center(
                    child: Text("Nenhum dado meteorológico disponível."),
                  );
                }
                final weather = weatherList.first;

                return Card(
                  margin: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${weather.date.day}/${weather.date.month}/${weather.date.year}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.0,
                              ),
                            ),
                            Image.network(
                              'https://openweathermap.org/img/wn/${weather.weatherIcon}@2x.png',
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8.0),
                        Text(
                          weather.weatherDescription.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.blueAccent,
                          ),
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                                'Min: ${weather.tempMin.toStringAsFixed(1)}°C'),
                            Text(
                                'Max: ${weather.tempMax.toStringAsFixed(1)}°C'),
                          ],
                        ),
                        const Divider(),
                        Text(
                          'Humidity: ${weather.humidity}%',
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
