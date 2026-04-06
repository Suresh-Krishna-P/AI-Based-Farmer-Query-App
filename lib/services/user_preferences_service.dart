import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ai_based_farmer_query_app/models/query_model.dart';
import 'package:ai_based_farmer_query_app/models/advisory_model.dart';

/// User Preferences and History Service
class UserPreferencesService {
  static const String _prefsKey = 'user_preferences';
  static const String _queriesKey = 'user_queries';
  static const String _advisoriesKey = 'user_advisories';
  static const String _feedbacksKey = 'user_feedbacks';

  /// User profile information
  static final Map<String, dynamic> defaultUserProfile = {
    'user_id': '',
    'name': '',
    'location': '',
    'village': '',
    'district': '',
    'state': 'Tamil Nadu',
    'phone': '',
    'email': '',
    'language_preference': 'ta', // Tamil
    'experience_level': 'beginner',
    'farm_size': 1.0, // hectares
    'primary_crops': [],
    'secondary_crops': [],
    'soil_type': 'unknown',
    'irrigation_source': 'unknown',
    'registration_date': '',
    'last_active': '',
  };

  /// User preferences for app behavior
  static final Map<String, dynamic> defaultPreferences = {
    'notifications_enabled': true,
    'weather_alerts': true,
    'market_updates': true,
    'language': 'ta',
    'theme': 'light',
    'auto_sync': true,
    'data_usage': 'balanced',
    'offline_mode': false,
    'backup_enabled': false,
  };

  /// Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString('user_profile');
    
    if (profileJson != null) {
      return jsonDecode(profileJson);
    } else {
      return Map.from(defaultUserProfile);
    }
  }

  /// Save user profile
  Future<void> saveUserProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    profile['last_active'] = DateTime.now().toIso8601String();
    await prefs.setString('user_profile', jsonEncode(profile));
  }

  /// Get user preferences
  Future<Map<String, dynamic>> getUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final prefsJson = prefs.getString('user_preferences');
    
    if (prefsJson != null) {
      return jsonDecode(prefsJson);
    } else {
      return Map.from(defaultPreferences);
    }
  }

  /// Save user preferences
  Future<void> saveUserPreferences(Map<String, dynamic> preferences) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_preferences', jsonEncode(preferences));
  }

  /// Update specific preference
  Future<void> updatePreference(String key, dynamic value) async {
    final prefs = await getUserPreferences();
    prefs[key] = value;
    await saveUserPreferences(prefs);
  }

  /// Get user queries history
  Future<List<QueryModel>> getQueryHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final queriesJson = prefs.getString(_queriesKey);
    
    if (queriesJson != null) {
      final queriesList = jsonDecode(queriesJson) as List<dynamic>;
      return queriesList.map((q) => QueryModel.fromJson(q)).toList();
    } else {
      return [];
    }
  }

  /// Add query to history
  Future<void> addQueryToHistory(QueryModel query) async {
    final queries = await getQueryHistory();
    queries.add(query);
    
    // Keep only last 100 queries
    if (queries.length > 100) {
      queries.removeRange(0, queries.length - 100);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_queriesKey, jsonEncode(queries.map((q) => q.toJson()).toList()));
  }

  /// Get user advisories history
  Future<List<AdvisoryModel>> getAdvisoryHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final advisoriesJson = prefs.getString(_advisoriesKey);
    
    if (advisoriesJson != null) {
      final advisoriesList = jsonDecode(advisoriesJson) as List<dynamic>;
      return advisoriesList.map((a) => AdvisoryModel.fromJson(a)).toList();
    } else {
      return [];
    }
  }

  /// Add advisory to history
  Future<void> addAdvisoryToHistory(AdvisoryModel advisory) async {
    final advisories = await getAdvisoryHistory();
    advisories.add(advisory);
    
    // Keep only last 50 advisories
    if (advisories.length > 50) {
      advisories.removeRange(0, advisories.length - 50);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_advisoriesKey, jsonEncode(advisories.map((a) => a.toJson()).toList()));
  }

  /// Get user feedbacks
  Future<List<Map<String, dynamic>>> getFeedbackHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final feedbacksJson = prefs.getString(_feedbacksKey);
    
    if (feedbacksJson != null) {
      return jsonDecode(feedbacksJson);
    } else {
      return [];
    }
  }

  /// Add feedback
  Future<void> addFeedback(Map<String, dynamic> feedback) async {
    final feedbacks = await getFeedbackHistory();
    feedback['timestamp'] = DateTime.now().toIso8601String();
    feedbacks.add(feedback);
    
    // Keep only last 50 feedbacks
    if (feedbacks.length > 50) {
      feedbacks.removeRange(0, feedbacks.length - 50);
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_feedbacksKey, jsonEncode(feedbacks));
  }

  /// Get user's frequently asked topics
  Future<Map<String, int>> getFrequentTopics() async {
    final queries = await getQueryHistory();
    final topics = <String, int>{};
    
    for (final query in queries) {
      final queryLower = query.queryText.toLowerCase();
      final topic = _extractTopic(queryLower);
      topics[topic] = (topics[topic] ?? 0) + 1;
    }
    
    return topics;
  }

  /// Get user's crop preferences based on query history
  Future<Map<String, int>> getCropPreferences() async {
    final queries = await getQueryHistory();
    final crops = <String, int>{};
    
    for (final query in queries) {
      final queryLower = query.queryText.toLowerCase();
      final crop = _extractCrop(queryLower);
      if (crop.isNotEmpty) {
        crops[crop] = (crops[crop] ?? 0) + 1;
      }
    }
    
    return crops;
  }

  /// Get user's location-based preferences
  Future<Map<String, dynamic>> getLocationPreferences() async {
    final profile = await getUserProfile();
    final location = profile['location'];
    
    if (location.isNotEmpty) {
      return {
        'location': location,
        'village': profile['village'],
        'district': profile['district'],
        'state': profile['state'],
        'region_type': _getRegionType(location),
        'suitable_crops': _getSuitableCropsForRegion(profile['district']),
        'climate_zone': _getClimateZone(profile['district']),
      };
    }
    
    return {};
  }

  /// Get personalized recommendations based on user history
  Future<Map<String, dynamic>> getPersonalizedRecommendations() async {
    final frequentTopics = await getFrequentTopics();
    final cropPreferences = await getCropPreferences();
    final locationPrefs = await getLocationPreferences();
    
    final recommendations = <String, dynamic>{};
    
    // Crop-specific recommendations
    if (cropPreferences.isNotEmpty) {
      final topCrop = cropPreferences.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      recommendations['primary_crop'] = topCrop;
      recommendations['crop_tips'] = _getCropSpecificTips(topCrop);
    }
    
    // Location-based recommendations
    if (locationPrefs.isNotEmpty) {
      recommendations['location_tips'] = _getLocationSpecificTips(locationPrefs['district']);
    }
    
    // Topic-based recommendations
    if (frequentTopics.isNotEmpty) {
      final topTopic = frequentTopics.entries.reduce((a, b) => a.value > b.value ? a : b).key;
      recommendations['topic_tips'] = _getTopicSpecificTips(topTopic);
    }
    
    // Seasonal recommendations based on current date
    recommendations['seasonal_tips'] = _getSeasonalTips();
    
    return recommendations;
  }

  /// Get user statistics
  Future<Map<String, dynamic>> getUserStatistics() async {
    final queries = await getQueryHistory();
    final advisories = await getAdvisoryHistory();
    final feedbacks = await getFeedbackHistory();
    final profile = await getUserProfile();
    
    final stats = <String, dynamic>{};
    
    stats['total_queries'] = queries.length;
    stats['total_advisories'] = advisories.length;
    stats['total_feedbacks'] = feedbacks.length;
    stats['active_days'] = _calculateActiveDays(queries);
    stats['avg_response_time'] = _calculateAverageResponseTime(queries);
    stats['satisfaction_score'] = _calculateSatisfactionScore(feedbacks);
    stats['most_used_feature'] = _getMostUsedFeature(queries);
    stats['query_frequency'] = _getQueryFrequency(queries);
    
    return stats;
  }

  /// Clear user data (for privacy)
  Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_profile');
    await prefs.remove('user_preferences');
    await prefs.remove(_queriesKey);
    await prefs.remove(_advisoriesKey);
    await prefs.remove(_feedbacksKey);
  }

  /// Export user data
  Future<String> exportUserData() async {
    final profile = await getUserProfile();
    final preferences = await getUserPreferences();
    final queries = await getQueryHistory();
    final advisories = await getAdvisoryHistory();
    final feedbacks = await getFeedbackHistory();
    
    final userData = {
      'profile': profile,
      'preferences': preferences,
      'queries': queries.map((q) => q.toJson()).toList(),
      'advisories': advisories.map((a) => a.toJson()).toList(),
      'feedbacks': feedbacks,
      'export_date': DateTime.now().toIso8601String(),
    };
    
    return jsonEncode(userData);
  }

  /// Import user data
  Future<void> importUserData(String data) async {
    final userData = jsonDecode(data);
    
    if (userData.containsKey('profile')) {
      await saveUserProfile(userData['profile']);
    }
    if (userData.containsKey('preferences')) {
      await saveUserPreferences(userData['preferences']);
    }
    if (userData.containsKey('queries')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_queriesKey, jsonEncode(userData['queries']));
    }
    if (userData.containsKey('advisories')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_advisoriesKey, jsonEncode(userData['advisories']));
    }
    if (userData.containsKey('feedbacks')) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_feedbacksKey, jsonEncode(userData['feedbacks']));
    }
  }

  /// Extract topic from query
  String _extractTopic(String query) {
    final topicKeywords = {
      'pest': ['pest', 'insect', 'bug', 'worm'],
      'disease': ['disease', 'fungus', 'virus', 'bacteria', 'rot'],
      'fertilizer': ['fertilizer', 'manure', 'compost', 'nutrient'],
      'irrigation': ['water', 'irrigation', 'drip', 'sprinkler'],
      'market': ['price', 'market', 'sell', 'buy'],
      'weather': ['weather', 'rain', 'temperature', 'climate'],
    };
    
    for (final entry in topicKeywords.entries) {
      for (final keyword in entry.value) {
        if (query.contains(keyword)) {
          return entry.key;
        }
      }
    }
    
    return 'general';
  }

  /// Extract crop from query
  String _extractCrop(String query) {
    final crops = ['rice', 'wheat', 'coconut', 'banana', 'sugarcane', 'cotton', 'turmeric', 'mango', 'vegetable', 'fruit'];
    
    for (final crop in crops) {
      if (query.contains(crop)) {
        return crop;
      }
    }
    
    return '';
  }

  /// Get region type based on location
  String _getRegionType(String location) {
    final coastalDistricts = ['Chennai', 'Cuddalore', 'Nagapattinam', 'Tiruvarur', 'Kanyakumari'];
    final interiorDistricts = ['Coimbatore', 'Erode', 'Salem', 'Tiruppur', 'Karur'];
    final hillDistricts = ['Nilgiris', 'Dharmapuri'];
    final aridDistricts = ['Madurai', 'Theni', 'Ramanathapuram', 'Virudhunagar'];
    
    if (coastalDistricts.contains(location)) return 'coastal';
    if (interiorDistricts.contains(location)) return 'interior';
    if (hillDistricts.contains(location)) return 'hill';
    if (aridDistricts.contains(location)) return 'arid';
    
    return 'unknown';
  }

  /// Get suitable crops for region
  List<String> _getSuitableCropsForRegion(String district) {
    switch (_getRegionType(district)) {
      case 'coastal':
        return ['Rice', 'Coconut', 'Banana', 'Mango', 'Vegetables'];
      case 'interior':
        return ['Cotton', 'Sugarcane', 'Turmeric', 'Millets', 'Pulses'];
      case 'hill':
        return ['Tea', 'Coffee', 'Spices', 'Fruits', 'Flowers'];
      case 'arid':
        return ['Millets', 'Pulses', 'Oilseeds', 'Date palm', 'Arid vegetables'];
      default:
        return ['Rice', 'Vegetables', 'Fruits'];
    }
  }

  /// Get climate zone for district
  String _getClimateZone(String district) {
    return _getRegionType(district);
  }

  /// Get crop-specific tips
  List<String> _getCropSpecificTips(String crop) {
    switch (crop) {
      case 'rice':
        return [
          'Monitor water levels carefully during different growth stages',
          'Use appropriate nitrogen management to prevent lodging',
          'Practice integrated pest management for stem borers',
        ];
      case 'coconut':
        return [
          'Regularly inspect for red palm weevil infestation',
          'Maintain proper spacing for good air circulation',
          'Apply organic manures for better yield',
        ];
      case 'banana':
        return [
          'Use tissue culture plants for better disease resistance',
          'Practice proper bunch management for quality fruits',
          'Monitor for Panama wilt and take preventive measures',
        ];
      default:
        return [
          'Follow recommended crop management practices',
          'Use certified seeds and planting materials',
          'Practice crop rotation for better soil health',
        ];
    }
  }

  /// Get location-specific tips
  List<String> _getLocationSpecificTips(String district) {
    switch (_getRegionType(district)) {
      case 'coastal':
        return [
          'Use salt-tolerant crop varieties',
          'Improve drainage to prevent waterlogging',
          'Plant windbreaks to protect crops from cyclones',
        ];
      case 'interior':
        return [
          'Implement water conservation measures',
          'Use drought-resistant crop varieties',
          'Practice rainwater harvesting',
        ];
      case 'hill':
        return [
          'Practice terrace farming to prevent soil erosion',
          'Use disease-resistant varieties for high humidity',
          'Implement proper drainage systems',
        ];
      case 'arid':
        return [
          'Use micro-irrigation systems',
          'Practice mulching to conserve moisture',
          'Choose short-duration crop varieties',
        ];
      default:
        return [
          'Follow best agricultural practices for your region',
          'Stay updated with local weather forecasts',
          'Consult local agricultural experts regularly',
        ];
    }
  }

  /// Get topic-specific tips
  List<String> _getTopicSpecificTips(String topic) {
    switch (topic) {
      case 'pest':
        return [
          'Monitor crops regularly for pest infestations',
          'Use biological control methods when possible',
          'Apply chemical controls only when necessary',
        ];
      case 'disease':
        return [
          'Use disease-resistant varieties',
          'Practice crop rotation to break disease cycles',
          'Maintain field sanitation',
        ];
      case 'fertilizer':
        return [
          'Test soil before applying fertilizers',
          'Use balanced fertilization based on crop needs',
          'Incorporate organic matter regularly',
        ];
      default:
        return [
          'Follow recommended agricultural practices',
          'Stay updated with latest technologies',
          'Participate in farmer training programs',
        ];
    }
  }

  /// Get seasonal tips based on current date
  List<String> _getSeasonalTips() {
    final month = DateTime.now().month;
    
    if (month >= 6 && month <= 9) {
      return [
        'Ensure proper drainage during monsoon',
        'Monitor for fungal diseases in humid conditions',
        'Use appropriate crop varieties for rainy season',
      ];
    } else if (month >= 10 && month <= 2) {
      return [
        'Prepare fields for rabi crops',
        'Implement water conservation measures',
        'Use cold-resistant crop varieties',
      ];
    } else {
      return [
        'Provide adequate irrigation during summer',
        'Use mulching to conserve soil moisture',
        'Monitor for heat stress in crops',
      ];
    }
  }

  /// Calculate active days from query history
  int _calculateActiveDays(List<QueryModel> queries) {
    final dates = queries.map((q) => q.queryDate).toSet();
    return dates.length;
  }

  /// Calculate average response time
  double _calculateAverageResponseTime(List<QueryModel> queries) {
    // This would need actual response time data
    // For now, returning a placeholder
    return 2.5; // minutes
  }

  /// Calculate satisfaction score from feedbacks
  double _calculateSatisfactionScore(List<Map<String, dynamic>> feedbacks) {
    if (feedbacks.isEmpty) return 0.0;
    
    double totalScore = 0;
    for (final feedback in feedbacks) {
      if (feedback.containsKey('rating')) {
        totalScore += double.tryParse(feedback['rating'].toString()) ?? 0;
      }
    }
    
    return totalScore / feedbacks.length;
  }

  /// Get most used feature based on query patterns
  String _getMostUsedFeature(List<QueryModel> queries) {
    final featureCounts = <String, int>{};
    
    for (final query in queries) {
      final queryLower = query.queryText.toLowerCase();
      if (queryLower.contains('image') || queryLower.contains('photo')) {
        featureCounts['image_search'] = (featureCounts['image_search'] ?? 0) + 1;
      } else if (queryLower.contains('voice') || queryLower.contains('speak')) {
        featureCounts['voice_search'] = (featureCounts['voice_search'] ?? 0) + 1;
      } else {
        featureCounts['text_search'] = (featureCounts['text_search'] ?? 0) + 1;
      }
    }
    
    if (featureCounts.isNotEmpty) {
      final mostUsed = featureCounts.entries.reduce((a, b) => a.value > b.value ? a : b);
      return mostUsed.key;
    }
    
    return 'text_search';
  }

  /// Get query frequency patterns
  Map<String, int> _getQueryFrequency(List<QueryModel> queries) {
    final frequency = <String, int>{};
    
    for (final query in queries) {
      final day = query.queryDate.day;
      final month = query.queryDate.month;
      final key = '$month-$day';
      frequency[key] = (frequency[key] ?? 0) + 1;
    }
    
    return frequency;
  }
}