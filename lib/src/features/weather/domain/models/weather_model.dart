class CurrentWeather {
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final String weatherDescription;
  final String weatherIcon;
  final int humidity;

  CurrentWeather({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.weatherDescription,
    required this.weatherIcon,
    required this.humidity,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      date: DateTime.fromMillisecondsSinceEpoch(json['dt'] * 1000),
      tempMin: json['main']['temp_min'].toDouble(),
      tempMax: json['main']['temp_max'].toDouble(),
      weatherDescription: json['weather'][0]['description'],
      weatherIcon: json['weather'][0]['icon'],
      humidity: json['main']['humidity'],
    );
  }
}