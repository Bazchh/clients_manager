import 'package:flutter/material.dart';
import 'package:clients_manager/src/features/weather/domain/models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final DailyWeather weather;

  const WeatherCard({
    Key? key,
    required this.weather,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                Text('Min: ${weather.minTemp.toStringAsFixed(1)}°C'),
                Text('Max: ${weather.maxTemp.toStringAsFixed(1)}°C'),
              ],
            ),
            const SizedBox(height: 4.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Day: ${weather.dayTemp.toStringAsFixed(1)}°C'),
                Text('Night: ${weather.nightTemp.toStringAsFixed(1)}°C'),
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
  }
}
