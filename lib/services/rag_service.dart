import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_based_farmer_query_app/datasets/crop_diseases_dataset.dart';
import 'package:ai_based_farmer_query_app/datasets/pest_management_dataset.dart';
import 'package:ai_based_farmer_query_app/datasets/soil_management_dataset.dart';
import 'package:ai_based_farmer_query_app/datasets/external_datasets.dart';
import 'package:ai_based_farmer_query_app/datasets/agro_qa_dataset.dart';
import 'package:ai_based_farmer_query_app/datasets/recommendation_datasets.dart';
import 'package:ai_based_farmer_query_app/services/language_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';

class RAGService {
  final String? apiKey;
  final String apiUrl;
  final String modelName;
  final ExternalDatasets? externalDatasets;
  final AgroQADataset agroQADataset = AgroQADataset();
  final RecommendationDatasets recommendationDatasets = RecommendationDatasets();

  RAGService({
    this.apiKey, 
    this.apiUrl = 'https://api.openai.com/v1/chat/completions', 
    this.modelName = 'gpt-3.5-turbo',
    this.externalDatasets
  });

  Future<List<Map<String, dynamic>>> search(String query) async {
    try {
      // First, get relevant documents from our datasets
      final relevantDocs = await _retrieveRelevantDocuments(query);
      
      if (relevantDocs.isEmpty) {
        return [
          {
            'title': 'No Results Found',
            'content': 'No relevant information found for your query. Please try with different keywords.',
            'category': 'General',
            'score': 0.0,
          }
        ];
      }

      // If we have an API key, use AI to generate response
      if (apiKey != null && apiKey!.isNotEmpty) {
        final response = await _generateAIResponse(query, relevantDocs);
        return response;
      } else {
        // Fallback to dataset-based responses
        return _generateDatasetResponse(query, relevantDocs);
      }
    } catch (e) {
      return [
        {
          'title': 'Error',
          'content': 'An error occurred while processing your query: $e',
          'category': 'Error',
          'score': 0.0,
        }
      ];
    }
  }

  Future<List<Map<String, dynamic>>> _retrieveRelevantDocuments(String query) async {
    final queryLower = query.toLowerCase();
    final results = <Map<String, dynamic>>[];
    
    // Tokenize query and remove common stop words for better keyword matching
    final stopWords = {'i', 'want', 'to', 'know', 'how', 'do', 'a', 'the', 'is', 'in', 'on', 'at', 'about', 'tell', 'me', 'please', 'for', 'my'};
    final tokens = queryLower.split(RegExp(r'[\s,.\?!\-]+')).where((t) => t.length > 2 && !stopWords.contains(t)).toList();
    
    if (tokens.isEmpty && queryLower.isNotEmpty) {
      tokens.add(queryLower); // Fallback for very short queries
    }

    // Intent detection (simple)
    bool isPestRelated = tokens.any((t) => ['pest', 'insect', 'bug', 'worm', 'aphid', 'treatment', 'kill', 'remove'].contains(t));
    bool isDiseaseRelated = tokens.any((t) => ['disease', 'blight', 'rust', 'wilt', 'mildew', 'spot', 'rot', 'sick'].contains(t));
    bool isSoilRelated = tokens.any((t) => ['soil', 'dirt', 'land', 'ph', 'nutrient', 'fertilizer', 'manure', 'compost'].contains(t));

    // 1. Scan AgroQA Dataset (from CSV) - Use tokens for better coverage
    try {
      final qas = await agroQADataset.search(query);
      for (var qa in qas.take(3)) {
        results.add({
          'title': 'Related Q&A (${qa.crop})',
          'content': 'Q: ${qa.question}\nA: ${qa.answer}',
          'category': 'Question & Answer',
          'source': 'AgroQA Dataset',
          'priority': 1,
        });
      }
    } catch (e) {
      print('Error searching AgroQA: $e');
    }

    // 2. Scan Recommendation Datasets (Suitability/Fertilizer)
    for (var token in tokens) {
      final suitability = recommendationDatasets.getCropSuitability(token);
      if (suitability.isNotEmpty) {
        results.add({
          'title': 'Crop Suitability Advice',
          'content': suitability.join('\n'),
          'category': 'Recommendation',
          'source': 'Suitability Dataset',
          'priority': 2,
        });
      }

      final pestAdvice = recommendationDatasets.getPestAdvice(token);
      for (var advice in pestAdvice) {
        results.add({
          'title': 'Pest & Disease Advisory',
          'content': advice,
          'category': 'Management',
          'source': 'Pest Dataset',
          'priority': 0, // High priority if keyword matches exactly
        });
      }
    }

    // 3. Scan Crop Database
    for (var crop in ComprehensiveDatasets.extensiveCropData) {
      final cropName = crop['crop_name'].toString().toLowerCase();
      if (queryLower.contains(cropName) || tokens.any((t) => cropName.contains(t))) {
        results.add({
          'title': '${crop['crop_name']} Cultivation Guide',
          'content': _formatDynamicCropData(crop),
          'category': 'Crop Information',
          'source': 'Comprehensive Crop Dataset',
          'priority': isPestRelated || isDiseaseRelated ? 3 : 1, 
        });
      }
    }

    // 4. Scan Pest Database
    for (var pest in ComprehensiveDatasets.extensivePestData) {
      final pestName = pest['pest_name'].toString().toLowerCase();
      if (queryLower.contains(pestName) || tokens.any((t) => pestName.contains(t))) {
        results.add({
          'title': 'Pest Alert: ${pest['pest_name']}',
          'content': _formatDynamicPestData(pest),
          'category': 'Pest Management',
          'source': 'Comprehensive Pest Dataset',
          'priority': 0,
        });
      }
    }

    // 5. Scan Disease Database
    for (var disease in ComprehensiveDatasets.extensiveDiseaseData) {
      final diseaseName = disease['disease_name'].toString().toLowerCase();
      final pathogen = disease['pathogen']?.toString().toLowerCase() ?? '';
      if (queryLower.contains(diseaseName) || tokens.any((t) => diseaseName.contains(t) || (pathogen.isNotEmpty && pathogen.contains(t)))) {
        results.add({
          'title': 'Disease Advisory: ${disease['disease_name']}',
          'content': _formatDynamicDiseaseData(disease),
          'category': 'Crop Disease',
          'source': 'Comprehensive Disease Dataset',
          'priority': 0,
        });
      }
    }

    // 6. Scan Soil Database
    for (var soil in ComprehensiveDatasets.extensiveSoilData) {
      final soilType = soil['soil_type'].toString().toLowerCase();
      if (queryLower.contains(soilType) || isSoilRelated) {
        results.add({
          'title': '${soil['soil_type']} Management',
          'content': _formatDynamicSoilData(soil),
          'category': 'Soil Management',
          'source': 'Comprehensive Soil Dataset',
          'priority': isSoilRelated ? 0 : 4,
        });
        if (isSoilRelated) break;
      }
    }

    // Sort results by priority (0 is highest)
    results.sort((a, b) => (a['priority'] ?? 5).compareTo(b['priority'] ?? 5));

    // If still empty or no strong matches, return broad terms
    if (results.where((r) => r['priority'] != null && r['priority'] < 3).isEmpty) {
      if (isDiseaseRelated) {
        results.add({
          'title': 'General Disease Guidance',
          'content': 'We detected you are asking about crop diseases. Common identified treatments involve applying copper-based fungicides or maintaining better field sanitation. Please specify the crop (e.g., Tomato) for precise records.',
          'category': 'Crop Disease',
          'source': 'Heuristic Engine',
          'priority': 0,
        });
      } else if (isPestRelated) {
        results.add({
          'title': 'General Pest Guidance',
          'content': 'We detected a pest management query. Standard organic controls include Neem Oil sprays, while chemical options often include Imidacloprid. Please specify the crop and insect for better advice.',
          'category': 'Pest Management',
          'source': 'Heuristic Engine',
          'priority': 0,
        });
      }
    }

    if (results.isEmpty) {
      results.add({
        'title': 'Agricultural Assistant',
        'content': 'I heard your query about "$query". To help you better, please try specifying a crop (like Rice, Wheat, or Tomato) and the specific problem you are facing.',
        'category': 'General',
        'source': 'Fallback System',
      });
    }

    return results.take(10).toList();
  }

  String _formatDynamicCropData(Map<String, dynamic> crop) {
    final buffer = StringBuffer();
    buffer.writeln('${crop['crop_name']} (${crop['scientific_name']})');
    buffer.writeln('- Family: ${crop['family']}');
    buffer.writeln('- Seasons: ${crop['growing_season']?.join(', ')}');
    buffer.writeln('- Water Requirement: ${crop['water_requirement']}');
    buffer.writeln('- Optimal Temp: ${crop['optimal_temperature']?[0]}-${crop['optimal_temperature']?[1]}°C');
    buffer.writeln('- Yield Expectancy: ${crop['yield_per_hectare']} t/ha');
    buffer.writeln('- Harvest: ${crop['harvest_time']}');
    return buffer.toString();
  }

  String _formatDynamicPestData(Map<String, dynamic> pest) {
    final buffer = StringBuffer();
    buffer.writeln('${pest['pest_name']} (${pest['type']})');
    buffer.writeln('- Risks to Crops: ${pest['affected_crops']?.join(', ')}');
    buffer.writeln('- Symptoms Checklist: ${pest['damage_symptoms']?.join(', ')}');
    buffer.writeln('- Lifecycle: ${pest['life_cycle']}');
    buffer.writeln('- Organic Solutions: ${pest['organic_control']?.join(', ')}');
    buffer.writeln('- Primary Predators: ${pest['natural_predators']?.join(', ')}');
    return buffer.toString();
  }

  String _formatDynamicDiseaseData(Map<String, dynamic> disease) {
    final buffer = StringBuffer();
    buffer.writeln('${disease['disease_name']}');
    buffer.writeln('- Pathogen Source: ${disease['pathogen']}');
    buffer.writeln('- At-Risk Crops: ${disease['affected_crops']?.join(', ')}');
    buffer.writeln('- Visual Symptoms: ${disease['symptoms']?.join(', ')}');
    buffer.writeln('- Favorable Triggers: ${disease['favorable_conditions']?.join(', ')}');
    buffer.writeln('- Mitigation Protocols: ${disease['preventive_measures']?.join(', ')}');
    buffer.writeln('- Treatment: ${disease['organic_control']?.join(', ')}');
    return buffer.toString();
  }

  String _formatDynamicSoilData(Map<String, dynamic> soil) {
    final buffer = StringBuffer();
    buffer.writeln('${soil['soil_type']}');
    buffer.writeln('- Physical Profile: ${soil['texture']} texture with ${soil['drainage']} drainage.');
    buffer.writeln('- Target pH: ${soil['ph_range']?[0]} - ${soil['ph_range']?[1]}');
    buffer.writeln('- Best Utilizing Crops: ${soil['suitable_crops']?.join(', ')}');
    
    if (soil['challenges'] != null) {
      buffer.writeln('- Common Challenges: ${soil['challenges']?.join(', ')}');
    }
    
    final interventions = soil['improvement_methods'] ?? soil['maintenance_methods'];
    if (interventions != null) {
      buffer.writeln('- Action Plan: ${interventions?.join(', ')}');
    }
    return buffer.toString();
  }

  Future<List<Map<String, dynamic>>> _generateAIResponse(
    String query, 
    List<Map<String, dynamic>> relevantDocs
  ) async {
    try {
      final prompt = _buildPrompt(query, relevantDocs);
      
      final response = await http.post(
        Uri.parse(_getAIUrl(apiUrl)),
        headers: {
          'Authorization': 'Bearer $apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': modelName,
          'messages': [
            {
              'role': 'system',
              'content': 'You are an agricultural expert providing helpful and accurate information to farmers. Use the provided context to answer the query. IMPORTANT: Provide your answer in plain text without any Markdown formatting (no headers like ###, no bolding like **).'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final content = data['choices'][0]['message']['content'];
        
        return [
          {
            'title': 'AI-Generated Response',
            'content': content,
            'category': 'AI Response',
            'score': 1.0,
          }
        ];
      } else {
        throw Exception('API request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      // Fallback to dataset response if AI fails
      return _generateDatasetResponse(query, relevantDocs);
    }
  }

  String _buildPrompt(String query, List<Map<String, dynamic>> relevantDocs) {
    final context = relevantDocs.map((doc) => doc['content']).join('\n\n');
    
    return '''
    Context: $context
    
    Query: $query
    
    Please provide a helpful and accurate response to the farmer's query based on the context provided. 
    Focus on practical advice and actionable recommendations.
    Keep the response concise and easy to understand.
    ''';
  }

  List<Map<String, dynamic>> _generateDatasetResponse(
    String query, 
    List<Map<String, dynamic>> relevantDocs
  ) {
    // Simple keyword-based response generation
    final queryLower = query.toLowerCase();
    final results = <Map<String, dynamic>>[];

    if (queryLower.contains('how to') || queryLower.contains('treat')) {
      results.add({
        'title': 'Treatment Recommendations',
        'content': 'Based on your query, here are some general treatment recommendations:\n\n1. Identify the specific problem first\n2. Use appropriate cultural practices\n3. Apply recommended treatments\n4. Monitor results and adjust as needed',
        'category': 'Treatment',
        'score': 0.8,
      });
    } else if (queryLower.contains('prevent') || queryLower.contains('avoid')) {
      results.add({
        'title': 'Prevention Strategies',
        'content': 'Prevention is key in agriculture. Consider these strategies:\n\n1. Use disease-resistant varieties\n2. Practice proper crop rotation\n3. Maintain field sanitation\n4. Monitor for early signs of problems',
        'category': 'Prevention',
        'score': 0.8,
      });
    } else {
      results.add({
        'title': 'General Information',
        'content': 'Here is some general information related to your query based on our agricultural datasets.',
        'category': 'General',
        'score': 0.6,
      });
    }

    return results;
  }

  /// Enhanced search with external datasets integration
  Future<List<Map<String, dynamic>>> searchWithExternalData(
    String query, {
    String? cropType,
    String? region,
    String? location,
  }) async {
    try {
      final queryLower = query.toLowerCase();
      
      // Auto-detect crop if not provided
      if (cropType == null) {
        for (var crop in ['wheat', 'rice', 'maize', 'corn', 'soybean', 'cotton', 'tomato', 'potato', 'banana', 'mango']) {
          if (queryLower.contains(crop)) {
            cropType = crop;
            break;
          }
        }
      }
      
      region ??= 'India'; // Default to India for broader knowledge base support
      
      // Get basic dataset results
      final basicResults = await _retrieveRelevantDocuments(query);
      
      // Wikipedia Open-Ended Fallback if local databases fail
      bool isFallbackOnly = basicResults.length == 1 && basicResults[0]['source'] == 'Fallback System';
      String sanitizedQuery = query.toLowerCase().trim();
      
      // Don't search for placeholder or too short queries
      if (isFallbackOnly && sanitizedQuery.isNotEmpty && sanitizedQuery != 'listening...') {
        try {
          // Enhancing search term purely for agricultural context
          final encodedQuery = Uri.encodeComponent("agriculture OR crop OR farming " + sanitizedQuery);
          final rawUrl = 'https://en.wikipedia.org/w/api.php?action=query&list=search&srsearch=$encodedQuery&utf8=&format=json&origin=*';
          final uri = Uri.parse(_getAIUrl(rawUrl));
          final response = await http.get(uri);
          
          if (response.statusCode == 200) {
            final data = jsonDecode(response.body);
            if (data['query'] != null && data['query']['search'] != null && data['query']['search'].isNotEmpty) {
              final searchResults = data['query']['search'] as List;
              final topResult = searchResults[0];
              final title = topResult['title'];
              String snippet = topResult['snippet'] ?? '';
              
              // Clean out the HTML spans returned by Wikipedia
              snippet = snippet.replaceAll(RegExp(r'<[^>]*>'), '');
              snippet = snippet.replaceAll('&quot;', '"').replaceAll('&amp;', '&').replaceAll('&lt;', '<').replaceAll('&gt;', '>');
              
              if (snippet.isNotEmpty) {
                // Remove the offline fallback entirely to present the live knowledge!
                basicResults.clear();
                basicResults.add({
                  'title': 'Global Knowledge: $title',
                  'content': '$snippet...\n\n(Source: Wikipedia API Sandbox)',
                  'category': 'Open-Ended Results',
                  'source': 'Wikipedia',
                });
              }
            }
          }
        } catch (e) {
          print('Wikipedia fallback failed: $e');
        }
      }

      
      // If external datasets are available, fetch additional data
      if (externalDatasets != null && (cropType != null || region != null)) {
        try {
          final externalData = await externalDatasets!.fetchComprehensiveData(
            cropType: cropType ?? 'general',
            region: region ?? 'India',
            location: location,
          );

          // Add external data to results
          if (externalData.containsKey('crop_yield')) {
            basicResults.add({
              'title': 'Crop Yield Information',
              'content': _formatExternalCropData(externalData['crop_yield']),
              'category': 'Crop Information',
              'source': 'USDA/FAO',
            });
          }

          if (externalData.containsKey('pest_disease')) {
            basicResults.add({
              'title': 'Pest and Disease Data',
              'content': _formatExternalPestData(externalData['pest_disease']),
              'category': 'Pest Management',
              'source': 'FAO',
            });
          }

          if (externalData.containsKey('soil_data')) {
            basicResults.add({
              'title': 'Soil Analysis',
              'content': _formatExternalSoilData(externalData['soil_data']),
              'category': 'Soil Management',
              'source': 'SoilGrids',
            });
          }

          if (externalData.containsKey('market_prices')) {
            basicResults.add({
              'title': 'Market Prices',
              'content': _formatExternalMarketData(externalData['market_prices']),
              'category': 'Market Information',
              'source': 'Agmarknet',
            });
          }

          if (externalData.containsKey('weather')) {
            basicResults.add({
              'title': 'Weather Information',
              'content': _formatExternalWeatherData(externalData['weather']),
              'category': 'Weather',
              'source': 'OpenWeather',
            });
          }
        } catch (e) {
          // If external data fails, continue with basic results
          print('External data fetch failed: $e');
        }
      }

      // Generate AI response if API key is available
      if (apiKey != null && apiKey!.isNotEmpty) {
        return await _generateAIResponse(query, basicResults);
      } else {
        return basicResults;
      }
    } catch (e) {
      return [
        {
          'title': 'Search Error',
          'content': 'An error occurred while processing your query: $e',
          'category': 'Error',
          'score': 0.0,
        }
      ];
    }
  }

  String _formatExternalCropData(List<dynamic> cropData) {
    final buffer = StringBuffer();
    buffer.writeln('External Crop Data');
    buffer.writeln('');
    
    for (var crop in cropData.take(3)) {
      buffer.writeln('${crop['crop'] ?? 'Crop Yield'}');
      buffer.writeln('- Yield Per Hectare: ${crop['yield_per_hectare'] ?? 'Unknown'}');
      buffer.writeln('- Season: ${crop['season'] ?? 'Unknown'}');
      buffer.writeln('- Region: ${crop['region'] ?? 'Unknown'}');
      buffer.writeln('- Source: ${crop['source'] ?? 'Unknown'}');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  String _formatExternalPestData(List<dynamic> pestData) {
    final buffer = StringBuffer();
    buffer.writeln('External Pest Data');
    buffer.writeln('');
    
    for (var pest in pestData.take(3)) {
      buffer.writeln('${pest['pest_name'] ?? 'Pest'}');
      buffer.writeln('- Description: ${pest['description'] ?? 'No description available'}');
      var methods = pest['control_methods'];
      String methodsStr = methods is List ? methods.join(', ') : methods.toString();
      buffer.writeln('- Control Methods: ${methodsStr.isEmpty ? 'Not specified' : methodsStr}');
      buffer.writeln('- Source: ${pest['source'] ?? 'Unknown'}');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  String _formatExternalSoilData(List<dynamic> soilData) {
    final buffer = StringBuffer();
    buffer.writeln('External Soil Data');
    buffer.writeln('');
    
    for (var soil in soilData.take(2)) {
      buffer.writeln('${soil['soil_type'] ?? 'Soil Type'}');
      buffer.writeln('- pH Level: ${soil['ph_level'] ?? 'Unknown'}');
      buffer.writeln('- Organic Matter: ${soil['organic_matter'] ?? 'Unknown'}%');
      buffer.writeln('- Source: ${soil['source'] ?? 'Unknown'}');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  String _formatExternalMarketData(List<dynamic> marketData) {
    final buffer = StringBuffer();
    buffer.writeln('External Market Data');
    buffer.writeln('');
    
    for (var price in marketData.take(3)) {
      buffer.writeln('${price['market'] ?? 'Market'}');
      buffer.writeln('- Price: ₹${price['price'] ?? 'N/A'}/quintal');
      buffer.writeln('- Date: ${price['date'] ?? 'Unknown'}');
      buffer.writeln('- Variety: ${price['variety'] ?? 'Unknown'}');
      buffer.writeln('- Source: ${price['source'] ?? 'Unknown'}');
      buffer.writeln('');
    }

    return buffer.toString();
  }

  String _formatExternalWeatherData(Map<String, dynamic> weatherData) {
    final buffer = StringBuffer();
    buffer.writeln('External Weather Data');
    buffer.writeln('');
    
    buffer.writeln('Current Conditions');
    buffer.writeln('- Temperature: ${weatherData['temperature'] ?? 'Unknown'}°C');
    buffer.writeln('- Humidity: ${weatherData['humidity'] ?? 'Unknown'}%');
    buffer.writeln('- Precipitation: ${weatherData['precipitation'] ?? 'Unknown'} mm');
    buffer.writeln('- Wind Speed: ${weatherData['wind_speed'] ?? 'Unknown'} km/h');
    buffer.writeln('- Weather: ${weatherData['weather'] ?? 'Unknown'}');
    buffer.writeln('- Source: ${weatherData['source'] ?? 'Unknown'}');

    return buffer.toString();
  }

  /// Enhanced search with Tamil language support
  Future<List<Map<String, dynamic>>> searchWithLanguageSupport(
    String query, {
    String? preferredLanguage = 'en',
    String? cropType,
    String? region,
    String? location,
  }) async {
    try {
      final languageService = LanguageService();
      
      // Detect language and translate if needed
      String processedQuery = query;
      String detectedLanguage = 'en';
      
      if (languageService.isTamilText(query)) {
        detectedLanguage = 'ta';
        // First apply fast keyword mapping for core agricultural terms
        processedQuery = languageService.translateTamilTerms(query);
        // Then try deep translation for complex sentence structure
        processedQuery = await languageService.translateToEnglish(processedQuery, 'ta');
      }

      // Perform search with processed query
      final results = await searchWithExternalData(
        processedQuery,
        cropType: cropType,
        region: region,
        location: location,
      );

      // Translate results back to Tamil if needed
      if (preferredLanguage == 'ta' && detectedLanguage == 'ta') {
        for (var result in results) {
          if (result['content'] != null) {
            result['content'] = await languageService.translateToTamil(result['content']);
          }
          if (result['title'] != null) {
            result['title'] = await languageService.translateToTamil(result['title']);
          }
        }
      }

      return results;
    } catch (e) {
      return [
        {
          'title': 'Search Error',
          'content': 'An error occurred while processing your query: $e',
          'category': 'Error',
          'score': 0.0,
        }
      ];
    }
  }

  String _getAIUrl(String url) {
    if (kIsWeb) {
      return 'http://localhost:3001/proxy?url=${Uri.encodeComponent(url)}';
    }
    return url;
  }
}