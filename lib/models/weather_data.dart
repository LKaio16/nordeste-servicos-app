/// Modelo de dados do Clima
/// Mapeia o WeatherResponse da API
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

  /// Cria um CurrentWeather a partir do JSON da API
  factory CurrentWeather.fromApiJson(Map<String, dynamic> json) {
    final temperature = json['temperature']?.toDouble() ?? 0.0;
    final humidity = json['humidity']?.toDouble() ?? 0.0;
    final windSpeed = json['windSpeed']?.toDouble() ?? 0.0;
    final uvIndex = json['uvIndex']?.toDouble() ?? 0.0;
    final weatherDescription = json['weatherDescription']?.toString() ?? 'Indisponível';
    final seaCondition = json['seaCondition']?.toString() ?? 'Indisponível';
    
    return CurrentWeather(
      temp: temperature.round(),
      condition: weatherDescription,
      humidity: humidity.round(),
      wind: windSpeed.round(),
      uvIndex: uvIndex.round(),
      seaCondition: seaCondition,
      feelsLike: temperature.round(), // API não retorna feelsLike, usa temperatura
    );
  }

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    // Se tem campos da API, usa fromApiJson
    if (json.containsKey('temperature') || json.containsKey('weatherDescription')) {
      return CurrentWeather.fromApiJson(json);
    }
    
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
  final int humidity;

  HourlyWeather({
    required this.time,
    required this.temp,
    required this.icon,
    required this.rain,
    required this.humidity,
  });

  /// Cria um HourlyWeather a partir do JSON da API
  factory HourlyWeather.fromApiJson(Map<String, dynamic> json) {
    final timeStr = json['time']?.toString() ?? '';
    final temperature = json['temperature']?.toDouble() ?? 0.0;
    final uvIndex = json['uvIndex']?.toDouble() ?? 0.0;
    final humidity = json['humidity']?.toDouble() ?? 0.0;
    
    // Formata o horário (pega apenas a hora do formato ISO)
    String formattedTime = timeStr;
    if (timeStr.contains('T')) {
      final parts = timeStr.split('T');
      if (parts.length > 1) {
        final timePart = parts[1].split(':');
        if (timePart.length >= 2) {
          formattedTime = '${timePart[0]}:${timePart[1]}';
        }
      }
    }
    
    // Determina o ícone baseado no UV index e condições
    WeatherIcon icon = WeatherIcon.sun;
    if (uvIndex < 1) {
      icon = WeatherIcon.cloud; // Noite ou nublado
    } else if (uvIndex > 7) {
      icon = WeatherIcon.sun; // Sol forte
    } else {
      icon = WeatherIcon.cloud; // Parcialmente nublado
    }
    
    return HourlyWeather(
      time: formattedTime,
      temp: '${temperature.round()}°',
      icon: icon,
      rain: '0%', // Mantido para compatibilidade
      humidity: humidity.round(),
    );
  }

  factory HourlyWeather.fromJson(Map<String, dynamic> json) {
    // Se tem campos da API, usa fromApiJson
    if (json.containsKey('temperature') || json.containsKey('uvIndex')) {
      return HourlyWeather.fromApiJson(json);
    }
    
    return HourlyWeather(
      time: json['time'] ?? '',
      temp: json['temp'] ?? '',
      icon: WeatherIcon.values.firstWhere(
        (e) => e.name == json['icon'],
        orElse: () => WeatherIcon.sun,
      ),
      rain: json['rain'] ?? '0%',
      humidity: json['humidity'] ?? 0,
    );
  }
}

class DailyForecast {
  final String day;
  final String temp;
  final WeatherIcon icon;
  final String rain;
  final int? humidity;

  DailyForecast({
    required this.day,
    required this.temp,
    required this.icon,
    required this.rain,
    this.humidity,
  });

  /// Cria um DailyForecast a partir do JSON da API
  factory DailyForecast.fromApiJson(Map<String, dynamic> json) {
    final dateStr = json['date']?.toString() ?? '';
    final tempMax = json['temperatureMax']?.toDouble() ?? 0.0;
    final tempMin = json['temperatureMin']?.toDouble() ?? 0.0;
    final uvIndexMax = json['uvIndexMax']?.toDouble() ?? 0.0;
    
    // Formata a data para mostrar o dia da semana
    String dayName = '';
    try {
      final date = DateTime.parse(dateStr);
      final weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];
      dayName = weekdays[date.weekday % 7];
      
      // Se for hoje, mostra "Hoje"
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        dayName = 'Hoje';
      }
    } catch (e) {
      dayName = dateStr;
    }
    
    // Determina o ícone baseado no UV index
    WeatherIcon icon = WeatherIcon.sun;
    if (uvIndexMax < 3) {
      icon = WeatherIcon.cloud;
    } else if (uvIndexMax > 7) {
      icon = WeatherIcon.sun;
    } else {
      icon = WeatherIcon.cloud;
    }
    
    final humidityMax = json['humidityMax']?.toDouble();
    final humidity = humidityMax != null ? humidityMax.round() : null;
    
    return DailyForecast(
      day: dayName,
      temp: '${tempMax.round()}°/${tempMin.round()}°',
      icon: icon,
      rain: '0%', // API não retorna chuva diretamente
      humidity: humidity,
    );
  }

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    // Se tem campos da API, usa fromApiJson
    if (json.containsKey('date') || json.containsKey('temperatureMax')) {
      return DailyForecast.fromApiJson(json);
    }
    
    return DailyForecast(
      day: json['day'] ?? '',
      temp: json['temp'] ?? '',
      icon: WeatherIcon.values.firstWhere(
        (e) => e.name == json['icon'],
        orElse: () => WeatherIcon.sun,
      ),
      rain: json['rain'] ?? '0%',
      humidity: json['humidity'] as int?,
    );
  }
}

enum WeatherIcon { sun, cloud, rain }







