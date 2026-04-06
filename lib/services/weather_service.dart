import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Weather Service for Agricultural Applications
class WeatherService {
  /// Free weather API endpoints
  static const String openMeteoUrl = 'https://api.open-meteo.com/v1/forecast';
  static const String weatherApiUrl = 'https://api.weatherapi.com/v1/current.json';
  static const String proxyBaseUrl = 'http://localhost:3001/proxy?url=';
  
  final String? weatherApiKey;

  WeatherService({this.weatherApiKey});

  /// Helper to handle proxying on Web
  Future<http.Response> _get(String url) async {
    String finalUrl = url;
    if (kIsWeb) {
      finalUrl = '$proxyBaseUrl${Uri.encodeComponent(url)}';
    }
    return await http.get(Uri.parse(finalUrl)).timeout(const Duration(seconds: 15));
  }

  /// Get current weather data for a location
  Future<Map<String, dynamic>> getWeatherData(String location) async {
    try {
      // Try to get coordinates first (simplified for demo)
      final coordinates = await _getCoordinates(location);
      
      if (weatherApiKey != null) {
        return await _getWeatherFromWeatherApi(coordinates['lat'], coordinates['lon']);
      } else {
        return await _getWeatherFromOpenMeteo(coordinates['lat'], coordinates['lon']);
      }
    } catch (e) {
      return _getFallbackWeatherData(location);
    }
  }

  /// Get weather forecast for agricultural planning
  Future<Map<String, dynamic>> getWeatherForecast(String location, int days) async {
    try {
      final coordinates = await _getCoordinates(location);
      
      if (weatherApiKey != null) {
        return await _getForecastFromWeatherApi(coordinates['lat'], coordinates['lon'], days);
      } else {
        return await _getForecastFromOpenMeteo(coordinates['lat'], coordinates['lon'], days);
      }
    } catch (e) {
      return _getFallbackForecast(days);
    }
  }

  /// Get agricultural weather alerts
  Future<Map<String, dynamic>> getWeatherAlerts(String location) async {
    try {
      final coordinates = await _getCoordinates(location);
      
      if (weatherApiKey != null) {
        return await _getAlertsFromWeatherApi(coordinates['lat'], coordinates['lon']);
      } else {
        return await _getAlertsFromOpenMeteo(coordinates['lat'], coordinates['lon']);
      }
    } catch (e) {
      return _getFallbackAlerts();
    }
  }

  /// Get coordinates for a location (simplified implementation)
  Future<Map<String, double>> _getCoordinates(String location) async {
    // In a real implementation, this would use a geocoding API
    // For demo purposes, using hardcoded coordinates for major cities
    final locationMap = {
      'Chennai': {'lat': 13.0827, 'lon': 80.2707},
      'Coimbatore': {'lat': 11.0168, 'lon': 76.9558},
      'Madurai': {'lat': 9.9252, 'lon': 78.1198},
      'Trichy': {'lat': 10.7905, 'lon': 78.7047},
      'Salem': {'lat': 11.6643, 'lon': 78.1460},
      'Tirunelveli': {'lat': 8.7139, 'lon': 77.7567},
      'Thanjavur': {'lat': 10.7905, 'lon': 79.1334},
      'Vellore': {'lat': 12.9165, 'lon': 79.1325},
      'Erode': {'lat': 11.3410, 'lon': 77.7172},
      'Tiruppur': {'lat': 11.1085, 'lon': 77.3411},
    };

    final locationLower = location.toLowerCase();
    for (final entry in locationMap.entries) {
      if (locationLower.contains(entry.key.toLowerCase())) {
        return {'lat': entry.value['lat']!, 'lon': entry.value['lon']!};
      }
    }

    // Default to Chennai coordinates if location not found
    return {'lat': 13.0827, 'lon': 80.2707};
  }

  /// Get weather from Open-Meteo (free API)
  Future<Map<String, dynamic>> _getWeatherFromOpenMeteo(double lat, double lon) async {
    final uri = Uri.parse(
      '$openMeteoUrl?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,precipitation,rain,showers,snowfall,weather_code,wind_speed_10m,wind_direction_10m&timezone=Asia%2FKolkata'
    );

    final response = await _get(uri.toString());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final current = data['current'];
      
      return {
        'temperature': current['temperature_2m'],
        'humidity': current['relative_humidity_2m'],
        'precipitation': current['precipitation'] ?? 0,
        'rain': current['rain'] ?? 0,
        'snowfall': current['snowfall'] ?? 0,
        'weather_code': current['weather_code'],
        'wind_speed': current['wind_speed_10m'],
        'wind_direction': current['wind_direction_10m'],
        'weather_description': _getWeatherDescription(current['weather_code']),
        'location': {'lat': lat, 'lon': lon},
        'source': 'Open-Meteo',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  /// Get weather from WeatherAPI (requires API key)
  Future<Map<String, dynamic>> _getWeatherFromWeatherApi(double lat, double lon) async {
    final uri = Uri.parse(
      '$weatherApiUrl?key=$weatherApiKey&q=$lat,$lon&aqi=no'
    );

    final response = await _get(uri.toString());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final current = data['current'];
      final location = data['location'];
      
      return {
        'temperature': current['temp_c'],
        'humidity': current['humidity'],
        'precipitation': current['precip_mm'] ?? 0,
        'rain': current['precip_mm'] ?? 0,
        'snowfall': 0, // WeatherAPI doesn't provide snowfall in current data
        'weather_code': _getWeatherCode(current['condition']['text']),
        'wind_speed': current['wind_kph'],
        'wind_direction': current['wind_degree'],
        'weather_description': current['condition']['text'],
        'location': {
          'name': location['name'],
          'lat': location['lat'],
          'lon': location['lon'],
        },
        'source': 'WeatherAPI',
        'timestamp': DateTime.now().toIso8601String(),
      };
    } else {
      throw Exception('Failed to fetch weather data');
    }
  }

  /// Get forecast from Open-Meteo
  Future<Map<String, dynamic>> _getForecastFromOpenMeteo(double lat, double lon, int days) async {
    final uri = Uri.parse(
      '$openMeteoUrl?latitude=$lat&longitude=$lon&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum,rain_sum,showers_sum,snowfall_sum,wind_speed_10m_max&timezone=Asia%2FKolkata&forecast_days=$days'
    );

    final response = await _get(uri.toString());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final daily = data['daily'];
      
      return {
        'forecast_days': days,
        'daily_forecast': daily['time'].asMap().map((index, date) => MapEntry(
          date,
          {
            'date': date,
            'weather_code': daily['weather_code'][index],
            'temp_max': daily['temperature_2m_max'][index],
            'temp_min': daily['temperature_2m_min'][index],
            'precipitation': daily['precipitation_sum'][index] ?? 0,
            'rain': daily['rain_sum'][index] ?? 0,
            'showers': daily['showers_sum'][index] ?? 0,
            'snowfall': daily['snowfall_sum'][index] ?? 0,
            'wind_speed_max': daily['wind_speed_10m_max'][index],
            'weather_description': _getWeatherDescription(daily['weather_code'][index]),
          }
        )),
        'location': {'lat': lat, 'lon': lon},
        'source': 'Open-Meteo',
        'generated_at': DateTime.now().toIso8601String(),
      };
    } else {
      throw Exception('Failed to fetch forecast data');
    }
  }

  /// Get forecast from WeatherAPI
  Future<Map<String, dynamic>> _getForecastFromWeatherApi(double lat, double lon, int days) async {
    final uri = Uri.parse(
      'https://api.weatherapi.com/v1/forecast.json?key=$weatherApiKey&q=$lat,$lon&days=$days&aqi=no&alerts=yes'
    );

    final response = await _get(uri.toString());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final forecast = data['forecast']['forecastday'];
      
      return {
        'forecast_days': days,
        'daily_forecast': forecast.map((day) => {
          'date': day['date'],
          'weather_code': _getWeatherCode(day['day']['condition']['text']),
          'temp_max': day['day']['maxtemp_c'],
          'temp_min': day['day']['mintemp_c'],
          'precipitation': day['day']['totalprecip_mm'] ?? 0,
          'rain': day['day']['totalprecip_mm'] ?? 0,
          'snowfall': day['day']['totalsnow_cm'] ?? 0,
          'wind_speed_max': day['day']['maxwind_kph'],
          'weather_description': day['day']['condition']['text'],
          'chance_of_rain': day['day']['daily_chance_of_rain'],
          'chance_of_snow': day['day']['daily_chance_of_snow'],
        }).toList(),
        'location': {
          'name': data['location']['name'],
          'lat': data['location']['lat'],
          'lon': data['location']['lon'],
        },
        'source': 'WeatherAPI',
        'generated_at': DateTime.now().toIso8601String(),
      };
    } else {
      throw Exception('Failed to fetch forecast data');
    }
  }

  /// Get alerts from Open-Meteo
  Future<Map<String, dynamic>> _getAlertsFromOpenMeteo(double lat, double lon) async {
    // Open-Meteo doesn't have a direct alerts API, so we'll simulate based on weather conditions
    final currentWeather = await _getWeatherFromOpenMeteo(lat, lon);
    
    final alerts = <Map<String, dynamic>>[];
    
    // Generate alerts based on weather conditions
    if (currentWeather['temperature'] > 40) {
      alerts.add({
        'type': 'Heat Wave',
        'severity': 'High',
        'description': 'Extreme heat conditions detected. Take precautions for crops and livestock.',
        'recommendations': [
          'Provide adequate shade for crops',
          'Increase irrigation frequency',
          'Monitor livestock for heat stress',
        ],
      });
    }

    if (currentWeather['precipitation'] > 50) {
      alerts.add({
        'type': 'Heavy Rainfall',
        'severity': 'Medium',
        'description': 'Heavy rainfall expected. Monitor for waterlogging.',
        'recommendations': [
          'Check drainage systems',
          'Avoid field operations during heavy rain',
          'Monitor crops for fungal diseases',
        ],
      });
    }

    if (currentWeather['wind_speed'] > 30) {
      alerts.add({
        'type': 'Strong Winds',
        'severity': 'Medium',
        'description': 'Strong winds detected. Secure loose items and monitor crops.',
        'recommendations': [
          'Secure farm structures',
          'Monitor for wind damage to crops',
          'Avoid pesticide application during high winds',
        ],
      });
    }

    return {
      'alerts': alerts,
      'location': {'lat': lat, 'lon': lon},
      'source': 'Open-Meteo (Simulated)',
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Get alerts from WeatherAPI
  Future<Map<String, dynamic>> _getAlertsFromWeatherApi(double lat, double lon) async {
    final uri = Uri.parse(
      'https://api.weatherapi.com/v1/forecast.json?key=$weatherApiKey&q=$lat,$lon&days=1&aqi=no&alerts=yes'
    );

    final response = await _get(uri.toString());

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      
      if (data.containsKey('alerts') && data['alerts'].containsKey('alert')) {
        final alerts = data['alerts']['alert'];
        
        return {
          'alerts': alerts.map((alert) => ({
            'type': alert['event'],
            'severity': alert['severity'],
            'description': alert['desc'],
            'effective': alert['effective'],
            'expires': alert['expires'],
            'instruction': alert['instruction'],
          })).toList(),
          'location': {
            'name': data['location']['name'],
            'lat': data['location']['lat'],
            'lon': data['location']['lon'],
          },
          'source': 'WeatherAPI',
          'generated_at': DateTime.now().toIso8601String(),
        };
      } else {
        return {
          'alerts': [],
          'location': {
            'name': data['location']['name'],
            'lat': data['location']['lat'],
            'lon': data['location']['lon'],
          },
          'source': 'WeatherAPI',
          'generated_at': DateTime.now().toIso8601String(),
        };
      }
    } else {
      throw Exception('Failed to fetch alerts data');
    }
  }

  /// Get weather description from weather code
  String _getWeatherDescription(int weatherCode) {
    switch (weatherCode) {
      case 0: return 'Clear sky';
      case 1: return 'Mainly clear';
      case 2: return 'Partly cloudy';
      case 3: return 'Overcast';
      case 45: return 'Fog';
      case 48: return 'Depositing rime fog';
      case 51: return 'Light drizzle';
      case 53: return 'Moderate drizzle';
      case 55: return 'Dense drizzle';
      case 61: return 'Slight rain';
      case 63: return 'Moderate rain';
      case 65: return 'Heavy rain';
      case 71: return 'Slight snow fall';
      case 73: return 'Moderate snow fall';
      case 75: return 'Heavy snow fall';
      case 80: return 'Rain showers';
      case 81: return 'Heavy rain showers';
      case 82: return 'Violent rain showers';
      case 95: return 'Thunderstorm';
      default: return 'Unknown weather condition';
    }
  }

  /// Get weather code from description
  int _getWeatherCode(String description) {
    final descLower = description.toLowerCase();
    
    if (descLower.contains('clear')) return 0;
    if (descLower.contains('cloud')) return 3;
    if (descLower.contains('rain')) return 63;
    if (descLower.contains('snow')) return 73;
    if (descLower.contains('fog')) return 45;
    if (descLower.contains('storm')) return 95;
    
    return 0; // Default to clear
  }

  /// Get fallback weather data
  Map<String, dynamic> _getFallbackWeatherData(String location) {
    return {
      'temperature': 25.0,
      'humidity': 60,
      'precipitation': 0,
      'rain': 0,
      'snowfall': 0,
      'weather_code': 0,
      'wind_speed': 5.0,
      'wind_direction': 180,
      'weather_description': 'Clear sky',
      'location': {'name': location, 'lat': 0, 'lon': 0},
      'source': 'Fallback Data',
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Get fallback forecast
  Map<String, dynamic> _getFallbackForecast(int days) {
    final forecast = <String, dynamic>{};
    final today = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = today.add(Duration(days: i));
      final dateString = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      forecast[dateString] = {
        'date': dateString,
        'weather_code': 0,
        'temp_max': 30.0 + (i * 0.5),
        'temp_min': 22.0 + (i * 0.3),
        'precipitation': 0,
        'rain': 0,
        'snowfall': 0,
        'wind_speed_max': 10.0 + (i * 0.2),
        'weather_description': 'Clear sky',
      };
    }

    return {
      'forecast_days': days,
      'daily_forecast': forecast,
      'location': {'lat': 0, 'lon': 0},
      'source': 'Fallback Data',
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Get fallback alerts
  Map<String, dynamic> _getFallbackAlerts() {
    return {
      'alerts': [],
      'location': {'lat': 0, 'lon': 0},
      'source': 'Fallback Data',
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Get agricultural weather recommendations based on current conditions
  Map<String, dynamic> getAgriculturalRecommendations(Map<String, dynamic> weatherData) {
    final recommendations = <String, dynamic>{};
    final temperature = weatherData['temperature'] ?? 25;
    final humidity = weatherData['humidity'] ?? 60;
    final precipitation = weatherData['precipitation'] ?? 0;
    final windSpeed = weatherData['wind_speed'] ?? 5;

    final agronomicTips = <String>[];
    final cropManagement = <String>[];
    final pestManagement = <String>[];

    // Temperature-based recommendations
    if (temperature > 35) {
      agronomicTips.add('Avoid field operations during peak heat hours (12-3 PM)');
      agronomicTips.add('Provide adequate irrigation to prevent heat stress');
      cropManagement.add('Consider heat-tolerant crop varieties');
      pestManagement.add('Monitor for heat-loving pests like spider mites');
    } else if (temperature < 15) {
      agronomicTips.add('Protect sensitive crops from cold stress');
      agronomicTips.add('Consider using row covers for young plants');
      cropManagement.add('Use cold-tolerant varieties for winter crops');
      pestManagement.add('Monitor for fungal diseases in cool, damp conditions');
    }

    // Humidity-based recommendations
    if (humidity > 80) {
      agronomicTips.add('Ensure good air circulation to prevent fungal diseases');
      agronomicTips.add('Avoid overhead irrigation during high humidity');
      pestManagement.add('Apply preventive fungicide treatments');
      pestManagement.add('Monitor for powdery mildew and rust diseases');
    } else if (humidity < 40) {
      agronomicTips.add('Increase irrigation frequency to prevent water stress');
      agronomicTips.add('Consider mulching to retain soil moisture');
      cropManagement.add('Use drought-tolerant crop varieties');
    }

    // Precipitation-based recommendations
    if (precipitation > 20) {
      agronomicTips.add('Ensure proper drainage to prevent waterlogging');
      agronomicTips.add('Avoid field operations in wet conditions');
      cropManagement.add('Monitor for root rot diseases');
      pestManagement.add('Delay pesticide applications until conditions improve');
    } else if (precipitation < 5) {
      agronomicTips.add('Implement water conservation measures');
      agronomicTips.add('Consider deficit irrigation strategies');
      cropManagement.add('Use drought-resistant crop varieties');
      pestManagement.add('Monitor for drought-stressed crop susceptibility to pests');
    }

    // Wind-based recommendations
    if (windSpeed > 20) {
      agronomicTips.add('Secure loose farm structures and equipment');
      agronomicTips.add('Avoid pesticide application during high winds');
      cropManagement.add('Consider windbreaks for wind-sensitive crops');
      pestManagement.add('Monitor for wind-dispersed pests and diseases');
    }

    recommendations['agronomic_tips'] = agronomicTips;
    recommendations['crop_management'] = cropManagement;
    recommendations['pest_management'] = pestManagement;
    recommendations['weather_summary'] = weatherData;
    recommendations['generated_at'] = DateTime.now().toIso8601String();

    return recommendations;
  }
}