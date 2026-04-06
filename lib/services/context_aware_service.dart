import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_based_farmer_query_app/services/weather_service.dart';
import 'package:ai_based_farmer_query_app/services/language_service.dart';

/// Context-Aware Advisory System
class ContextAwareService {
  final WeatherService? weatherService;
  final LanguageService? languageService;
  final String? apiKey;

  ContextAwareService({
    this.weatherService,
    this.languageService,
    this.apiKey,
  });

  /// Generate personalized agricultural advisory
  Future<Map<String, dynamic>> generateAdvisory({
    required String cropType,
    required String soilType,
    required String season,
    required String location,
    String? farmerExperience = 'beginner',
    String? previousCrops = '',
    double? fieldSize = 1.0,
    String? preferredLanguage = 'en',
  }) async {
    try {
      // Get weather data for the location
      final weatherData = await _getWeatherData(location, season);
      
      // Get crop-specific recommendations
      final cropRecommendations = await _getCropRecommendations(
        cropType, season, weatherData, soilType
      );
      
      // Get seasonal advice
      final seasonalAdvice = await _getSeasonalAdvice(season, weatherData);
      
      // Get location-specific advice
      final locationAdvice = await _getLocationAdvice(location, cropType);
      
      // Generate integrated advisory
      final advisory = await _generateIntegratedAdvisory(
        cropType: cropType,
        soilType: soilType,
        season: season,
        location: location,
        weatherData: weatherData,
        cropRecommendations: cropRecommendations,
        seasonalAdvice: seasonalAdvice,
        locationAdvice: locationAdvice,
        farmerExperience: farmerExperience,
        fieldSize: fieldSize,
      );

      // Translate to preferred language if needed
      if (preferredLanguage == 'ta' && languageService != null) {
        return await _translateAdvisory(advisory, languageService!);
      }

      return advisory;
    } catch (e) {
      return _getFallbackAdvisory(cropType, season, location);
    }
  }

  /// Get weather data for location and season
  Future<Map<String, dynamic>> _getWeatherData(String location, String season) async {
    try {
      if (weatherService != null) {
        return await weatherService!.getWeatherData(location);
      } else {
        return _getFallbackWeatherData(location, season);
      }
    } catch (e) {
      return _getFallbackWeatherData(location, season);
    }
  }

  /// Get crop-specific recommendations
  Future<Map<String, dynamic>> _getCropRecommendations(
    String cropType, String season, Map<String, dynamic> weatherData, String soilType
  ) async {
    try {
      // Use AI service for crop recommendations
      if (apiKey != null) {
        final prompt = '''
        Provide detailed agricultural recommendations for growing $cropType in $season season.
        Weather conditions: ${weatherData['temperature']}°C, ${weatherData['humidity']}% humidity, ${weatherData['precipitation']}mm precipitation.
        Soil type: $soilType.
        
        Please provide:
        1. Planting schedule and timing
        2. Fertilization requirements
        3. Irrigation needs
        4. Pest and disease management
        5. Harvest timing
        6. Yield expectations
        ''';

        final response = await _callAIService(prompt);
        return {
          'planting_schedule': 'Based on seasonal analysis',
          'fertilization': 'Tailored to crop and soil needs',
          'irrigation': 'Based on weather patterns',
          'pest_management': 'Seasonal pest control measures',
          'harvest_timing': 'Optimal harvest period',
          'yield_expectations': 'Expected yield per hectare',
          'ai_recommendations': response,
        };
      } else {
        return _getBasicCropRecommendations(cropType, season, soilType);
      }
    } catch (e) {
      return _getBasicCropRecommendations(cropType, season, soilType);
    }
  }

  /// Get seasonal advice
  Future<Map<String, dynamic>> _getSeasonalAdvice(String season, Map<String, dynamic> weatherData) async {
    final seasonalTips = <String, dynamic>{};
    
    if (season.toLowerCase().contains('summer')) {
      seasonalTips['key_points'] = [
        'Ensure adequate irrigation during hot days',
        'Use mulching to retain soil moisture',
        'Monitor for heat stress in crops',
        'Apply fertilizers during cooler parts of the day',
      ];
      seasonalTips['challenges'] = ['High temperature', 'Water scarcity', 'Pest infestations'];
      seasonalTips['opportunities'] = ['Fast crop growth', 'Multiple cropping cycles'];
    } else if (season.toLowerCase().contains('winter')) {
      seasonalTips['key_points'] = [
        'Protect crops from frost damage',
        'Use appropriate cold-resistant varieties',
        'Monitor for fungal diseases in cool weather',
        'Plan for spring planting preparation',
      ];
      seasonalTips['challenges'] = ['Low temperature', 'Frost risk', 'Slow growth'];
      seasonalTips['opportunities'] = ['Rabi crops', 'Soil preparation', 'Infrastructure maintenance'];
    } else if (season.toLowerCase().contains('monsoon') || season.toLowerCase().contains('rainy')) {
      seasonalTips['key_points'] = [
        'Ensure proper drainage to prevent waterlogging',
        'Monitor for fungal diseases in humid conditions',
        'Use raised beds if flooding is a concern',
        'Apply fertilizers after heavy rains',
      ];
      seasonalTips['challenges'] = ['Excessive rainfall', 'Waterlogging', 'Disease outbreaks'];
      seasonalTips['opportunities'] = ['Natural irrigation', 'Kharif crops', 'Soil rejuvenation'];
    }

    return seasonalTips;
  }

  /// Get location-specific advice
  Future<Map<String, dynamic>> _getLocationAdvice(String location, String cropType) async {
    try {
      // Use external API for location-specific data
      final response = await http.get(
        Uri.parse('https://api.agromonitoring.com/api/fields?loc=$location&crop=$cropType&appid=your_api_key'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {
          'soil_analysis': data['soil'] ?? {},
          'crop_suitability': data['suitability'] ?? {},
          'local_recommendations': data['recommendations'] ?? [],
        };
      } else {
        return _getFallbackLocationAdvice(location, cropType);
      }
    } catch (e) {
      return _getFallbackLocationAdvice(location, cropType);
    }
  }

  /// Generate integrated advisory
  Future<Map<String, dynamic>> _generateIntegratedAdvisory({
    required String cropType,
    required String soilType,
    required String season,
    required String location,
    required Map<String, dynamic> weatherData,
    required Map<String, dynamic> cropRecommendations,
    required Map<String, dynamic> seasonalAdvice,
    required Map<String, dynamic> locationAdvice,
    required String farmerExperience,
    required double fieldSize,
  }) async {
    try {
      if (apiKey != null) {
        final prompt = '''
        Generate a comprehensive agricultural advisory for a farmer growing $cropType in $location.
        
        Context:
        - Crop Type: $cropType
        - Soil Type: $soilType
        - Season: $season
        - Location: $location
        - Farmer Experience: $farmerExperience
        - Field Size: ${fieldSize} hectares
        - Weather: ${weatherData['temperature']}°C, ${weatherData['humidity']}% humidity
        
        Crop Recommendations: ${cropRecommendations['ai_recommendations'] ?? ''}
        Seasonal Advice: ${seasonalAdvice['key_points']?.join(', ') ?? ''}
        Location Data: ${locationAdvice['crop_suitability'] ?? ''}
        
        Provide a detailed advisory covering:
        1. Crop management practices
        2. Fertilization schedule
        3. Irrigation management
        4. Pest and disease control
        5. Harvest and post-harvest practices
        6. Risk management strategies
        7. Economic considerations
        ''';

        final aiResponse = await _callAIService(prompt);
        
        return {
          'crop_type': cropType,
          'location': location,
          'season': season,
          'weather_summary': weatherData,
          'crop_recommendations': cropRecommendations,
          'seasonal_advice': seasonalAdvice,
          'location_specific': locationAdvice,
          'integrated_advisory': aiResponse,
          'management_schedule': _generateManagementSchedule(cropType, season),
          'risk_assessment': _assessRisks(weatherData, season, cropType),
          'economic_analysis': _analyzeEconomics(cropType, fieldSize),
          'generated_at': DateTime.now().toIso8601String(),
        };
      } else {
        return _getBasicIntegratedAdvisory(
          cropType, soilType, season, location, weatherData, farmerExperience, fieldSize
        );
      }
    } catch (e) {
      return _getBasicIntegratedAdvisory(
        cropType, soilType, season, location, weatherData, farmerExperience, fieldSize
      );
    }
  }

  /// Generate management schedule
  Map<String, dynamic> _generateManagementSchedule(String cropType, String season) {
    final schedule = <String, dynamic>{};
    
    if (cropType.toLowerCase().contains('rice')) {
      schedule['planting'] = season.toLowerCase().contains('kharif') ? 'June-July' : 'November-December';
      schedule['transplanting'] = '15-25 days after sowing';
      schedule['first_fertilization'] = 'At transplanting';
      schedule['second_fertilization'] = '30 days after transplanting';
      schedule['harvesting'] = season.toLowerCase().contains('kharif') ? 'October-November' : 'March-April';
    } else if (cropType.toLowerCase().contains('wheat')) {
      schedule['planting'] = 'October-November';
      schedule['first_ irrigation'] = 'Immediately after sowing';
      schedule['first_fertilization'] = 'At sowing';
      schedule['second_fertilization'] = 'Crown root initiation stage';
      schedule['harvesting'] = 'March-April';
    } else {
      schedule['planting'] = 'Depends on crop and season';
      schedule['fertilization'] = 'Based on crop requirements';
      schedule['irrigation'] = 'As per crop needs';
      schedule['harvesting'] = 'Based on crop maturity';
    }

    return schedule;
  }

  /// Assess risks based on weather and season
  Map<String, dynamic> _assessRisks(Map<String, dynamic> weatherData, String season, String cropType) {
    final risks = <String, dynamic>{};
    final temperature = weatherData['temperature'] ?? 25;
    final humidity = weatherData['humidity'] ?? 60;
    final precipitation = weatherData['precipitation'] ?? 0;

    final riskFactors = <String>[];
    final mitigationStrategies = <String>[];

    if (temperature > 35) {
      riskFactors.add('High temperature stress');
      mitigationStrategies.add('Provide shade nets or mulching');
    }

    if (humidity > 80) {
      riskFactors.add('Fungal disease outbreak');
      mitigationStrategies.add('Apply fungicides and improve air circulation');
    }

    if (precipitation > 100) {
      riskFactors.add('Waterlogging risk');
      mitigationStrategies.add('Improve drainage and use raised beds');
    }

    if (precipitation < 10) {
      riskFactors.add('Drought conditions');
      mitigationStrategies.add('Implement drip irrigation and water conservation');
    }

    return {
      'identified_risks': riskFactors,
      'mitigation_strategies': mitigationStrategies,
      'weather_risk_level': _calculateRiskLevel(temperature, humidity, precipitation),
      'crop_specific_risks': _getCropSpecificRisks(cropType, season),
    };
  }

  /// Calculate overall risk level
  String _calculateRiskLevel(double temperature, double humidity, double precipitation) {
    int riskScore = 0;
    
    if (temperature > 35) riskScore += 2;
    if (temperature < 15) riskScore += 1;
    if (humidity > 80) riskScore += 2;
    if (precipitation > 100) riskScore += 2;
    if (precipitation < 10) riskScore += 1;

    if (riskScore >= 4) return 'High';
    if (riskScore >= 2) return 'Medium';
    return 'Low';
  }

  /// Get crop-specific risks
  List<String> _getCropSpecificRisks(String cropType, String season) {
    final risks = <String>[];
    
    if (cropType.toLowerCase().contains('rice') && season.toLowerCase().contains('kharif')) {
      risks.addAll([
        'Blast disease in humid conditions',
        'Stem borer infestation',
        'Water management challenges',
      ]);
    } else if (cropType.toLowerCase().contains('wheat') && season.toLowerCase().contains('rabi')) {
      risks.addAll([
        'Rust diseases in cool weather',
        'Aphid infestations',
        'Frost damage in early season',
      ]);
    } else if (cropType.toLowerCase().contains('vegetable')) {
      risks.addAll([
        'Pest infestations',
        'Viral diseases',
        'Market price fluctuations',
      ]);
    }

    return risks;
  }

  /// Analyze economics
  Map<String, dynamic> _analyzeEconomics(String cropType, double fieldSize) {
    final economics = <String, dynamic>{};
    
    // Estimate costs and returns based on crop type
    double estimatedYield = 0;
    double estimatedCost = 0;
    double estimatedRevenue = 0;

    if (cropType.toLowerCase().contains('rice')) {
      estimatedYield = fieldSize * 3.5; // tons per hectare
      estimatedCost = fieldSize * 25000; // INR per hectare
      estimatedRevenue = fieldSize * 35000; // INR per hectare
    } else if (cropType.toLowerCase().contains('wheat')) {
      estimatedYield = fieldSize * 3.0; // tons per hectare
      estimatedCost = fieldSize * 20000; // INR per hectare
      estimatedRevenue = fieldSize * 30000; // INR per hectare
    } else {
      estimatedYield = fieldSize * 2.0; // tons per hectare
      estimatedCost = fieldSize * 15000; // INR per hectare
      estimatedRevenue = fieldSize * 25000; // INR per hectare
    }

    final profit = estimatedRevenue - estimatedCost;
    final roi = profit / estimatedCost * 100;

    economics['estimated_yield'] = estimatedYield;
    economics['estimated_cost'] = estimatedCost;
    economics['estimated_revenue'] = estimatedRevenue;
    economics['estimated_profit'] = profit;
    economics['roi_percentage'] = roi;
    economics['break_even_yield'] = estimatedCost / (estimatedRevenue / estimatedYield);

    return economics;
  }

  /// Call AI service for recommendations
  Future<String> _callAIService(String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'You are an agricultural expert providing detailed farming advice.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 400,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'AI service temporarily unavailable. Please try again later.';
      }
    } catch (e) {
      return 'Unable to connect to AI service. Using basic recommendations.';
    }
  }

  /// Translate advisory to Tamil
  Future<Map<String, dynamic>> _translateAdvisory(Map<String, dynamic> advisory, LanguageService languageService) async {
    try {
      final translatedAdvisory = Map<String, dynamic>.from(advisory);
      
      // Translate key sections
      if (translatedAdvisory.containsKey('integrated_advisory')) {
        translatedAdvisory['integrated_advisory'] = await languageService.translateToTamil(
          translatedAdvisory['integrated_advisory']
        );
      }

      if (translatedAdvisory.containsKey('management_schedule')) {
        final schedule = translatedAdvisory['management_schedule'];
        if (schedule is Map) {
          final translatedSchedule = <String, String>{};
          schedule.forEach((key, value) async {
            translatedSchedule[key] = await languageService.translateToTamil(value.toString());
          });
          translatedAdvisory['management_schedule'] = translatedSchedule;
        }
      }

      return translatedAdvisory;
    } catch (e) {
      return advisory; // Return original if translation fails
    }
  }

  /// Get fallback weather data
  Map<String, dynamic> _getFallbackWeatherData(String location, String season) {
    return {
      'temperature': 25.0,
      'humidity': 60,
      'precipitation': 0,
      'wind_speed': 5.0,
      'weather': 'Clear',
      'location': location,
      'season': season,
    };
  }

  /// Get basic crop recommendations
  Map<String, dynamic> _getBasicCropRecommendations(String cropType, String season, String soilType) {
    return {
      'planting_schedule': 'Consult local agricultural office',
      'fertilization': 'Use balanced NPK fertilizers',
      'irrigation': 'Water as per crop requirements',
      'pest_management': 'Monitor and control pests regularly',
      'harvest_timing': 'Harvest at optimal maturity',
      'yield_expectations': 'Depends on management practices',
    };
  }

  /// Get fallback location advice
  Map<String, dynamic> _getFallbackLocationAdvice(String location, String cropType) {
    return {
      'soil_analysis': {'type': 'Unknown', 'ph': 'Unknown'},
      'crop_suitability': {'suitable': true, 'reason': 'General suitability'},
      'local_recommendations': ['Consult local experts', 'Test soil conditions'],
    };
  }

  /// Get basic integrated advisory
  Map<String, dynamic> _getBasicIntegratedAdvisory(
    String cropType, String soilType, String season, String location,
    Map<String, dynamic> weatherData, String farmerExperience, double fieldSize
  ) {
    return {
      'crop_type': cropType,
      'location': location,
      'season': season,
      'weather_summary': weatherData,
      'crop_recommendations': _getBasicCropRecommendations(cropType, season, soilType),
      'seasonal_advice': _getSeasonalAdvice(season, weatherData),
      'location_specific': _getFallbackLocationAdvice(location, cropType),
      'integrated_advisory': 'Basic advisory generated. For detailed recommendations, please consult local agricultural experts.',
      'management_schedule': _generateManagementSchedule(cropType, season),
      'risk_assessment': _assessRisks(weatherData, season, cropType),
      'economic_analysis': _analyzeEconomics(cropType, fieldSize),
      'generated_at': DateTime.now().toIso8601String(),
    };
  }

  /// Get fallback advisory
  Map<String, dynamic> _getFallbackAdvisory(String cropType, String season, String location) {
    return {
      'crop_type': cropType,
      'location': location,
      'season': season,
      'advisory': 'Unable to generate detailed advisory. Please consult local agricultural experts for crop-specific advice.',
      'recommendations': [
        'Test soil conditions before planting',
        'Choose appropriate crop varieties for your region',
        'Follow recommended planting schedules',
        'Monitor crops regularly for pests and diseases',
        'Practice crop rotation for better yields',
      ],
      'generated_at': DateTime.now().toIso8601String(),
    };
  }
}