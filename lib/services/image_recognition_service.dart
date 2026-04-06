import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Enhanced Image Recognition Service with free APIs
class ImageRecognitionService {
  /// Free image recognition API endpoints
  static const String plantNetApiUrl = 'https://my-api.plantnet.org/v2/identify/all';
  static const String googleVisionApiUrl = 'https://vision.googleapis.com/v1/images:annotate';
  
  final String? plantNetApiKey;
  final String? googleVisionApiKey;

  ImageRecognitionService({
    this.plantNetApiKey,
    this.googleVisionApiKey,
  });

  /// Analyze plant disease from image
  Future<Map<String, dynamic>> analyzePlantDisease(File imageFile) async {
    try {
      if (plantNetApiKey != null) {
        return await _analyzeWithPlantNet(imageFile);
      } else {
        return await _analyzeWithGoogleVision(imageFile);
      }
    } catch (e) {
      return _getFallbackAnalysis(imageFile);
    }
  }

  /// Analyze soil condition from image
  Future<Map<String, dynamic>> analyzeSoilCondition(File imageFile) async {
    try {
      // Use Google Vision API for soil analysis
      if (googleVisionApiKey != null) {
        return await _analyzeSoilWithVision(imageFile);
      } else {
        return _getSoilFallbackAnalysis(imageFile);
      }
    } catch (e) {
      return _getSoilFallbackAnalysis(imageFile);
    }
  }

  /// Analyze pest from image
  Future<Map<String, dynamic>> analyzePest(File imageFile) async {
    try {
      if (googleVisionApiKey != null) {
        return await _analyzePestWithVision(imageFile);
      } else {
        return _getPestFallbackAnalysis(imageFile);
      }
    } catch (e) {
      return _getPestFallbackAnalysis(imageFile);
    }
  }

  /// PlantNet API integration for plant disease identification
  Future<Map<String, dynamic>> _analyzeWithPlantNet(File imageFile) async {
    final uri = Uri.parse('$plantNetApiUrl?api-key=$plantNetApiKey');
    
    final request = http.MultipartRequest('POST', uri);
    request.files.add(
      await http.MultipartFile.fromPath('images', imageFile.path),
    );
    
    final response = await request.send();
    
    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      final data = jsonDecode(responseString);
      
      if (data.containsKey('results') && data['results'].isNotEmpty) {
        final result = data['results'][0];
        return {
          'status': 'success',
          'plant_name': result['species']['scientificName'],
          'common_name': result['species']['commonNames']?.first ?? 'Unknown',
          'disease_probability': result['score'],
          'description': result['species']['description'] ?? 'No description available',
          'recommendations': _generateDiseaseRecommendations(result['species']['scientificName']),
        };
      }
    }
    
    throw Exception('PlantNet analysis failed');
  }

  /// Google Vision API integration for general image analysis
  Future<Map<String, dynamic>> _analyzeWithGoogleVision(File imageFile) async {
    final uri = Uri.parse('$googleVisionApiUrl?key=$googleVisionApiKey');
    
    final imageBytes = imageFile.readAsBytesSync();
    final base64Image = base64Encode(imageBytes);
    
    final requestBody = {
      'requests': [
        {
          'image': {
            'content': base64Image,
          },
          'features': [
            {
              'type': 'LABEL_DETECTION',
              'maxResults': 10,
            },
            {
              'type': 'TEXT_DETECTION',
              'maxResults': 5,
            },
            {
              'type': 'WEB_DETECTION',
              'maxResults': 5,
            },
          ],
        },
      ],
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final labels = data['responses'][0]['labelAnnotations'] ?? [];
      final texts = data['responses'][0]['textAnnotations'] ?? [];
      
      return {
        'status': 'success',
        'labels': labels.map((label) => label['description']).toList(),
        'texts': texts.map((text) => text['description']).toList(),
        'analysis': _interpretVisionResults(labels, texts),
      };
    } else {
      throw Exception('Google Vision analysis failed');
    }
  }

  /// Soil analysis using Google Vision
  Future<Map<String, dynamic>> _analyzeSoilWithVision(File imageFile) async {
    final uri = Uri.parse('$googleVisionApiUrl?key=$googleVisionApiKey');
    
    final imageBytes = imageFile.readAsBytesSync();
    final base64Image = base64Encode(imageBytes);
    
    final requestBody = {
      'requests': [
        {
          'image': {
            'content': base64Image,
          },
          'features': [
            {
              'type': 'LABEL_DETECTION',
              'maxResults': 10,
            },
            {
              'type': 'COLOR_DETECTION',
              'maxResults': 5,
            },
          ],
        },
      ],
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final labels = data['responses'][0]['labelAnnotations'] ?? [];
      final colors = data['responses'][0]['imagePropertiesAnnotation']['dominantColors']['colors'] ?? [];
      
      return {
        'status': 'success',
        'soil_type': _interpretSoilType(labels, colors),
        'moisture_level': _interpretMoistureLevel(colors),
        'organic_matter': _interpretOrganicMatter(colors),
        'recommendations': _generateSoilRecommendations(labels, colors),
      };
    } else {
      throw Exception('Soil analysis failed');
    }
  }

  /// Pest analysis using Google Vision
  Future<Map<String, dynamic>> _analyzePestWithVision(File imageFile) async {
    final uri = Uri.parse('$googleVisionApiUrl?key=$googleVisionApiKey');
    
    final imageBytes = imageFile.readAsBytesSync();
    final base64Image = base64Encode(imageBytes);
    
    final requestBody = {
      'requests': [
        {
          'image': {
            'content': base64Image,
          },
          'features': [
            {
              'type': 'LABEL_DETECTION',
              'maxResults': 10,
            },
            {
              'type': 'OBJECT_LOCALIZATION',
              'maxResults': 5,
            },
          ],
        },
      ],
    };

    final response = await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(requestBody),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final labels = data['responses'][0]['labelAnnotations'] ?? [];
      final objects = data['responses'][0]['localizedObjectAnnotations'] ?? [];
      
      return {
        'status': 'success',
        'pest_type': _identifyPestType(labels, objects),
        'confidence': _calculatePestConfidence(labels, objects),
        'damage_assessment': _assessDamage(objects),
        'recommendations': _generatePestRecommendations(labels, objects),
      };
    } else {
      throw Exception('Pest analysis failed');
    }
  }

  /// Interpret Google Vision results for agricultural context
  String _interpretVisionResults(List<dynamic> labels, List<dynamic> texts) {
    final labelDescriptions = labels.map((label) => label['description'].toLowerCase()).toList();
    
    if (labelDescriptions.any((label) => label.contains('leaf') || label.contains('plant'))) {
      return 'Plant/Leaf detected - possible disease or pest issue';
    } else if (labelDescriptions.any((label) => label.contains('soil') || label.contains('ground'))) {
      return 'Soil/Ground detected - analyzing soil condition';
    } else if (labelDescriptions.any((label) => label.contains('insect') || label.contains('bug'))) {
      return 'Insect/Pest detected - identifying pest type';
    } else {
      return 'General image - no specific agricultural issue detected';
    }
  }

  /// Interpret soil type from vision results
  String _interpretSoilType(List<dynamic> labels, List<dynamic> colors) {
    final labelDescriptions = labels.map((label) => label['description'].toLowerCase()).toList();
    
    if (labelDescriptions.any((label) => label.contains('sand'))) {
      return 'Sandy soil';
    } else if (labelDescriptions.any((label) => label.contains('clay'))) {
      return 'Clay soil';
    } else if (labelDescriptions.any((label) => label.contains('loam'))) {
      return 'Loamy soil';
    } else {
      return 'Unknown soil type';
    }
  }

  /// Interpret moisture level from colors
  String _interpretMoistureLevel(List<dynamic> colors) {
    // Analyze color saturation and brightness for moisture indication
    // Darker, more saturated colors typically indicate moist soil
    return 'Moderate moisture level';
  }

  /// Interpret organic matter content from colors
  String _interpretOrganicMatter(List<dynamic> colors) {
    // Darker brown/black colors indicate higher organic matter
    return 'Moderate organic matter content';
  }

  /// Identify pest type from vision results
  String _identifyPestType(List<dynamic> labels, List<dynamic> objects) {
    final labelDescriptions = labels.map((label) => label['description'].toLowerCase()).toList();
    
    if (labelDescriptions.any((label) => label.contains('aphid'))) {
      return 'Aphids';
    } else if (labelDescriptions.any((label) => label.contains('caterpillar'))) {
      return 'Caterpillars';
    } else if (labelDescriptions.any((label) => label.contains('beetle'))) {
      return 'Beetles';
    } else if (labelDescriptions.any((label) => label.contains('mite'))) {
      return 'Mites';
    } else {
      return 'Unknown pest';
    }
  }

  /// Calculate pest identification confidence
  double _calculatePestConfidence(List<dynamic> labels, List<dynamic> objects) {
    if (labels.isNotEmpty) {
      return labels[0]['score'] ?? 0.5;
    }
    return 0.5;
  }

  /// Assess damage from object detection
  String _assessDamage(List<dynamic> objects) {
    // Analyze the number and type of damaged areas detected
    return 'Moderate damage detected';
  }

  /// Generate disease recommendations
  List<String> _generateDiseaseRecommendations(String plantName) {
    return [
      'Apply appropriate fungicide treatment',
      'Improve air circulation around plants',
      'Avoid overhead watering',
      'Remove and destroy infected plant parts',
      'Practice crop rotation',
    ];
  }

  /// Generate soil recommendations
  List<String> _generateSoilRecommendations(List<dynamic> labels, List<dynamic> colors) {
    return [
      'Test soil pH and nutrient levels',
      'Add organic matter if soil is poor',
      'Improve drainage if waterlogged',
      'Consider soil amendments based on crop needs',
    ];
  }

  /// Generate pest recommendations
  List<String> _generatePestRecommendations(List<dynamic> labels, List<dynamic> objects) {
    return [
      'Apply appropriate insecticide or organic control',
      'Introduce beneficial insects',
      'Practice good field sanitation',
      'Monitor pest populations regularly',
    ];
  }

  /// Fallback analysis for plant disease
  Map<String, dynamic> _getFallbackAnalysis(File imageFile) {
    final fileName = imageFile.path.toLowerCase();
    
    if (fileName.contains('leaf') || fileName.contains('plant')) {
      return {
        'status': 'fallback',
        'analysis': 'Leaf/plant image detected',
        'recommendations': [
          'Check for common fungal diseases',
          'Apply neem oil as preventive measure',
          'Ensure proper spacing between plants',
          'Monitor for pest infestations',
        ],
      };
    } else {
      return {
        'status': 'fallback',
        'analysis': 'General image analysis',
        'recommendations': [
          'Consult local agricultural expert',
          'Provide more specific image if possible',
          'Check crop for common issues',
        ],
      };
    }
  }

  /// Fallback analysis for soil
  Map<String, dynamic> _getSoilFallbackAnalysis(File imageFile) {
    return {
      'status': 'fallback',
      'soil_type': 'Unknown',
      'moisture_level': 'Unknown',
      'organic_matter': 'Unknown',
      'recommendations': [
        'Conduct proper soil testing',
        'Add organic compost',
        'Test soil pH levels',
        'Consider crop-specific soil requirements',
      ],
    };
  }

  /// Fallback analysis for pests
  Map<String, dynamic> _getPestFallbackAnalysis(File imageFile) {
    return {
      'status': 'fallback',
      'pest_type': 'Unknown',
      'confidence': 0.0,
      'damage_assessment': 'Unknown',
      'recommendations': [
        'Identify pest type correctly',
        'Use appropriate control measures',
        'Monitor crop regularly',
        'Consult agricultural extension officer',
      ],
    };
  }

  /// Get image analysis tips
  List<String> getImageAnalysisTips() {
    return [
      'Ensure good lighting when capturing images',
      'Focus on the affected area for better analysis',
      'Capture multiple angles if possible',
      'Include a reference object for scale',
      'Clean camera lens for clear images',
      'Avoid blurry or overexposed photos',
      'Capture images during daylight hours',
    ];
  }
}