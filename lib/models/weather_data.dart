/// Modelo de dados do Clima
class CurrentWeather {
  final int temp;
  final String condition;
  final int humidity;
  final int wind;
  final int uvIndex;
  final String seaCondition;
  final int feelsLike;

  CurrentWeather({
    required this.temp,
    required this.condition,
    required this.humidity,
    required this.wind,
    required this.uvIndex,
    required this.seaCondition,
    required this.feelsLike,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temp: json['temp'] ?? 0,
      condition: json['condition'] ?? '',
      humidity: json['humidity'] ?? 0,
      wind: json['wind'] ?? 0,
      uvIndex: json['uvIndex'] ?? 0,
      seaCondition: json['seaCondition'] ?? '',
      feelsLike: json['feelsLike'] ?? 0,
    );
  }
}

class HourlyWeather {
  final String time;
  final String temp;
  final WeatherIcon icon;
  final String rain;

  HourlyWeather({
    required this.time,
    required this.temp,
    required this.icon,
    required this.rain,
  });

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    return HourlyWeather(
      time: json['time'] ?? '',
      temp: json['temp'] ?? '',
      icon: WeatherIcon.values.firstWhere(
        (e) => e.name == json['icon'],
        orElse: () => WeatherIcon.sun,
      ),
      rain: json['rain'] ?? '0%',
    );
  }
}

class DailyForecast {
  final String day;
  final String temp;
  final WeatherIcon icon;
  final String rain;

  DailyForecast({
    required this.day,
    required this.temp,
    required this.icon,
    required this.rain,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    return DailyForecast(
      day: json['day'] ?? '',
      temp: json['temp'] ?? '',
      icon: WeatherIcon.values.firstWhere(
        (e) => e.name == json['icon'],
        orElse: () => WeatherIcon.sun,
      ),
      rain: json['rain'] ?? '0%',
    );
  }
}

enum WeatherIcon { sun, cloud, rain }







