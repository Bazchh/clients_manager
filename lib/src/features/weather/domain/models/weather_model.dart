class DailyWeather {
  final DateTime date;
  final double minTemp;
  final double maxTemp;
  final double dayTemp;
  final double nightTemp;
  final String weatherDescription;
  final String weatherIcon;
  final int humidity;
  final double windSpeed;
  final int windDirection;
  final double uvi;
  final double precipitationProbability;

  DailyWeather({
    required this.date,
    required this.minTemp,
    required this.maxTemp,
    required this.dayTemp,
    required this.nightTemp,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.humidity,
    required this.windSpeed,
    required this.windDirection,
    required this.uvi,
    required this.precipitationProbability,
  });

  // Método para converter um JSON em um objeto DailyWeather
  factory DailyWeather.fromJson(Map<String, dynamic> json) {
    return DailyWeather(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      minTemp: json['temp']['min'].toDouble(),
      maxTemp: json['temp']['max'].toDouble(),
      dayTemp: json['temp']['day'].toDouble(),
      nightTemp: json['temp']['night'].toDouble(),
      weatherDescription: json['weather'][0]['description'],
      weatherIcon: json['weather'][0]['icon'],
      humidity: json['humidity'],
      windSpeed: json['wind_speed'].toDouble(),
      windDirection: json['wind_deg'],
      uvi: json['uvi'].toDouble(),
      precipitationProbability: (json['pop'] * 100), // Convertendo para porcentagem
    );
  }
}
