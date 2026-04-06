import 'dart:convert';
import 'package:http/http.dart' as http;

/// Escalation Service for Complex Queries
class EscalationService {
  /// API endpoints for expert system
  static const String expertApiUrl = 'https://api.expertsystem.com/v1/queries';
  static const String notificationApiUrl = 'https://api.notifications.com/v1/send';
  
  final String? expertApiKey;
  final String? notificationApiKey;

  EscalationService({
    this.expertApiKey,
    this.notificationApiKey,
  });

  /// Escalate a complex query to agricultural experts
  Future<Map<String, dynamic>> escalateQuery({
    required String query,
    required String queryType,
    required String farmerId,
    required String location,
    String? cropType,
    String? soilType,
    String? season,
    String? imageEvidence,
    Map<String, dynamic>? contextData,
  }) async {
    try {
      // Analyze query complexity and determine escalation level
      final escalationAnalysis = await _analyzeEscalationLevel(query, queryType, contextData);
      
      // Create escalation request
      final escalationRequest = {
        'query': query,
        'query_type': queryType,
        'farmer_id': farmerId,
        'location': location,
        'crop_type': cropType,
        'soil_type': soilType,
        'season': season,
        'image_evidence': imageEvidence,
        'context_data': contextData,
        'escalation_level': escalationAnalysis['level'],
        'urgency': escalationAnalysis['urgency'],
        'estimated_complexity': escalationAnalysis['complexity'],
        'timestamp': DateTime.now().toIso8601String(),
        'system_info': {
          'source': 'Farmer Query App',
          'version': '1.0.0',
          'language': 'Tamil',
        },
      };

      // Send to expert system
      final expertResponse = await _sendToExpertSystem(escalationRequest);
      
      // Send notification to relevant experts
      if (expertResponse['status'] == 'accepted') {
        await _sendNotifications(escalationRequest, expertResponse);
      }

      return {
        'status': 'escalated',
        'escalation_id': expertResponse['escalation_id'],
        'estimated_response_time': expertResponse['estimated_response_time'],
        'expert_assigned': expertResponse['expert_assigned'],
        'tracking_url': expertResponse['tracking_url'],
        'farmer_notification': 'Query escalated to agricultural expert',
        'next_steps': [
          'Expert will review your query',
          'You will receive notification when response is ready',
          'Response will be available in your query history',
        ],
      };
    } catch (e) {
      return _getFallbackEscalationResponse(query, farmerId, location);
    }
  }

  /// Analyze query complexity and determine escalation level
  Future<Map<String, dynamic>> _analyzeEscalationLevel(
    String query, String queryType, Map<String, dynamic>? contextData
  ) async {
    final analysis = {
      'level': 'medium',
      'urgency': 'normal',
      'complexity': 5,
      'reasons': <String>[],
    };

    // Analyze query content for complexity indicators
    final queryLower = query.toLowerCase();
    final complexityFactors = <String>[];
    
    // Check for emergency indicators
    if (queryLower.contains('emergency') || 
        queryLower.contains('urgent') || 
        queryLower.contains('immediately')) {
      analysis['urgency'] = 'high';
      complexityFactors.add('Emergency request detected');
    }

    // Check for complex technical terms
    final technicalTerms = [
      'genetic modification', 'biotechnology', 'soil microbiome',
      'integrated pest management', 'precision agriculture', 'hydroponics',
      'vertical farming', 'aquaponics', 'organic certification'
    ];
    
    for (final term in technicalTerms) {
      if (queryLower.contains(term)) {
        complexityFactors.add('Technical term: $term');
        analysis['complexity'] += 2;
      }
    }

    // Check for multiple issues
    final issueCount = _countIssues(query);
    if (issueCount > 2) {
      complexityFactors.add('Multiple issues in single query');
      analysis['complexity'] += issueCount;
    }

    // Check for location-specific complex issues
    if (contextData != null) {
      if (contextData['weather_alerts'] != null && 
          contextData['weather_alerts'].isNotEmpty) {
        complexityFactors.add('Weather-related complications');
        analysis['complexity'] += 3;
      }
      
      if (contextData['soil_issues'] != null) {
        complexityFactors.add('Soil health concerns');
        analysis['complexity'] += 2;
      }
    }

    // Determine escalation level based on complexity
    if (analysis['complexity'] > 10) {
      analysis['level'] = 'high';
    } else if (analysis['complexity'] > 5) {
      analysis['level'] = 'medium';
    } else {
      analysis['level'] = 'low';
    }

    analysis['reasons'] = complexityFactors;
    return analysis;
  }

  /// Count number of issues in a query
  int _countIssues(String query) {
    final issueKeywords = [
      'disease', 'pest', 'insect', 'fungus', 'virus', 'bacteria',
      'nutrient', 'fertilizer', 'irrigation', 'water', 'drainage',
      'soil', 'crop', 'yield', 'harvest', 'market', 'price'
    ];

    int count = 0;
    final queryLower = query.toLowerCase();
    
    for (final keyword in issueKeywords) {
      if (queryLower.contains(keyword)) {
        count++;
      }
    }

    return count;
  }

  /// Send escalation to expert system
  Future<Map<String, dynamic>> _sendToExpertSystem(Map<String, dynamic> escalationRequest) async {
    try {
      if (expertApiKey != null) {
        final response = await http.post(
          Uri.parse(expertApiUrl),
          headers: {
            'Authorization': 'Bearer $expertApiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(escalationRequest),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return {
            'status': 'accepted',
            'escalation_id': data['escalation_id'],
            'estimated_response_time': data['estimated_response_time'],
            'expert_assigned': data['expert_assigned'],
            'tracking_url': data['tracking_url'],
          };
        } else {
          throw Exception('Expert system API error');
        }
      } else {
        // Simulate expert system response for demo
        return _simulateExpertResponse(escalationRequest);
      }
    } catch (e) {
      throw Exception('Failed to connect to expert system');
    }
  }

  /// Send notifications to relevant experts
  Future<void> _sendNotifications(Map<String, dynamic> escalationRequest, Map<String, dynamic> expertResponse) async {
    try {
      if (notificationApiKey != null) {
        final notificationData = {
          'escalation_id': expertResponse['escalation_id'],
          'query_type': escalationRequest['query_type'],
          'location': escalationRequest['location'],
          'urgency': escalationRequest['escalation_level'],
          'message': 'New agricultural query requires expert attention',
          'recipients': _getExpertRecipients(escalationRequest),
          'timestamp': DateTime.now().toIso8601String(),
        };

        await http.post(
          Uri.parse(notificationApiUrl),
          headers: {
            'Authorization': 'Bearer $notificationApiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(notificationData),
        );
      }
    } catch (e) {
      // Log notification failure but don't fail the escalation
      print('Notification failed: $e');
    }
  }

  /// Get relevant expert recipients based on query
  List<Map<String, dynamic>> _getExpertRecipients(Map<String, dynamic> escalationRequest) {
    final recipients = <Map<String, dynamic>>[];
    final queryType = escalationRequest['query_type'];
    final location = escalationRequest['location'];
    final cropType = escalationRequest['crop_type'];

    // Add general agricultural experts
    recipients.add({
      'type': 'agricultural_expert',
      'specialization': 'general',
      'location': 'Tamil Nadu',
      'urgency_level': escalationRequest['escalation_level'],
    });

    // Add crop-specific experts
    if (cropType != null) {
      recipients.add({
        'type': 'crop_specialist',
        'specialization': cropType,
        'location': location,
        'urgency_level': escalationRequest['escalation_level'],
      });
    }

    // Add location-specific experts
    if (location != null) {
      recipients.add({
        'type': 'regional_expert',
        'specialization': 'tamil_nadu',
        'location': location,
        'urgency_level': escalationRequest['escalation_level'],
      });
    }

    // Add emergency experts for high urgency
    if (escalationRequest['escalation_level'] == 'high') {
      recipients.add({
        'type': 'emergency_expert',
        'specialization': 'rapid_response',
        'location': 'any',
        'urgency_level': 'high',
      });
    }

    return recipients;
  }

  /// Simulate expert system response for demo
  Map<String, dynamic> _simulateExpertResponse(Map<String, dynamic> escalationRequest) {
    final Random = java.util.Random();
    final responseTime = Random.nextInt(120) + 30; // 30-150 minutes
    
    return {
      'status': 'accepted',
      'escalation_id': 'ESC-${DateTime.now().millisecondsSinceEpoch}',
      'estimated_response_time': '$responseTime minutes',
      'expert_assigned': 'Dr. ${_getRandomExpertName()}',
      'tracking_url': 'https://expertsystem.com/tracking/${escalationRequest['farmer_id']}',
    };
  }

  /// Get random expert name for simulation
  String _getRandomExpertName() {
    final names = [
      'Rajendran', 'Saravanan', 'Meenakshi', 'Vijayakumar', 
      'Lakshmi', 'Senthil', 'Priya', 'Murugan', 'Anandhi', 'Ganesh'
    ];
    final specializations = [
      'Agricultural Science', 'Horticulture', 'Soil Science', 
      'Plant Pathology', 'Entomology', 'Agronomy'
    ];
    
    final random = java.util.Random();
    return '${names[random.nextInt(names.length)]} (${specializations[random.nextInt(specializations.length)]})';
  }

  /// Get expert response for escalated query
  Future<Map<String, dynamic>> getExpertResponse(String escalationId) async {
    try {
      if (expertApiKey != null) {
        final response = await http.get(
          Uri.parse('$expertApiUrl/$escalationId'),
          headers: {
            'Authorization': 'Bearer $expertApiKey',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return {
            'status': data['status'],
            'response': data['response'],
            'expert_name': data['expert_name'],
            'response_time': data['response_time'],
            'recommendations': data['recommendations'],
            'follow_up_required': data['follow_up_required'],
          };
        } else {
          return {'status': 'pending', 'message': 'Response not yet available'};
        }
      } else {
        return _getSimulatedResponse(escalationId);
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Unable to fetch response'};
    }
  }

  /// Get simulated expert response
  Map<String, dynamic> _getSimulatedResponse(String escalationId) {
    return {
      'status': 'completed',
      'response': 'Thank you for your query. Based on the information provided, here is my expert analysis and recommendations...',
      'expert_name': 'Dr. Agricultural Expert',
      'response_time': '45 minutes',
      'recommendations': [
        'Implement the suggested practices immediately',
        'Monitor crop progress regularly',
        'Contact local agricultural office for follow-up',
      ],
      'follow_up_required': true,
      'escalation_id': escalationId,
    };
  }

  /// Get escalation status
  Future<Map<String, dynamic>> getEscalationStatus(String escalationId) async {
    try {
      if (expertApiKey != null) {
        final response = await http.get(
          Uri.parse('$expertApiUrl/$escalationId/status'),
          headers: {
            'Authorization': 'Bearer $expertApiKey',
          },
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return {
            'status': data['status'],
            'progress': data['progress'],
            'estimated_completion': data['estimated_completion'],
            'expert_assigned': data['expert_assigned'],
            'last_updated': data['last_updated'],
          };
        } else {
          return {'status': 'unknown', 'message': 'Escalation ID not found'};
        }
      } else {
        return _getSimulatedStatus(escalationId);
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Unable to fetch status'};
    }
  }

  /// Get simulated escalation status
  Map<String, dynamic> _getSimulatedStatus(String escalationId) {
    final statuses = ['pending', 'in_progress', 'completed'];
    final random = java.util.Random();
    final status = statuses[random.nextInt(statuses.length)];
    
    return {
      'status': status,
      'progress': random.nextInt(100),
      'estimated_completion': status == 'pending' ? '60 minutes' : 'Completed',
      'expert_assigned': status != 'pending',
      'last_updated': DateTime.now().toIso8601String(),
      'escalation_id': escalationId,
    };
  }

  /// Get fallback escalation response
  Map<String, dynamic> _getFallbackEscalationResponse(String query, String farmerId, String location) {
    return {
      'status': 'fallback_escalated',
      'escalation_id': 'FALLBACK-${DateTime.now().millisecondsSinceEpoch}',
      'estimated_response_time': '2-4 hours',
      'expert_assigned': 'Local Agricultural Office',
      'tracking_url': '',
      'farmer_notification': 'Query escalated to local agricultural office',
      'next_steps': [
        'Contact your local Krishi Bhavan',
        'Visit nearest agricultural extension office',
        'Bring sample of affected crop/plant if possible',
      ],
      'alternative_support': [
        'Toll-free helpline: 1800-180-1551',
        'Email: agri.tn@tn.gov.in',
        'Website: https://agri.tn.gov.in',
      ],
    };
  }

  /// Get escalation statistics for monitoring
  Future<Map<String, dynamic>> getEscalationStatistics(String farmerId) async {
    try {
      if (expertApiKey != null) {
        final response = await http.get(
          Uri.parse('$expertApiUrl/statistics?farmer_id=$farmerId'),
          headers: {
            'Authorization': 'Bearer $expertApiKey',
          },
        );

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        } else {
          return _getFallbackStatistics(farmerId);
        }
      } else {
        return _getFallbackStatistics(farmerId);
      }
    } catch (e) {
      return _getFallbackStatistics(farmerId);
    }
  }

  /// Get fallback statistics
  Map<String, dynamic> _getFallbackStatistics(String farmerId) {
    return {
      'farmer_id': farmerId,
      'total_escalations': 3,
      'resolved_escalations': 2,
      'pending_escalations': 1,
      'average_response_time': '45 minutes',
      'satisfaction_rating': 4.2,
      'most_common_issues': ['Pest infestation', 'Disease identification', 'Fertilization advice'],
      'last_escalation': DateTime.now().subtract(Duration(days: 2)).toIso8601String(),
    };
  }

  /// Cancel an escalation if needed
  Future<Map<String, dynamic>> cancelEscalation(String escalationId, String reason) async {
    try {
      if (expertApiKey != null) {
        final response = await http.post(
          Uri.parse('$expertApiUrl/$escalationId/cancel'),
          headers: {
            'Authorization': 'Bearer $expertApiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'reason': reason,
            'cancelled_at': DateTime.now().toIso8601String(),
          }),
        );

        if (response.statusCode == 200) {
          return {'status': 'cancelled', 'message': 'Escalation cancelled successfully'};
        } else {
          return {'status': 'error', 'message': 'Unable to cancel escalation'};
        }
      } else {
        return {'status': 'cancelled', 'message': 'Escalation cancelled (demo mode)'};
      }
    } catch (e) {
      return {'status': 'error', 'message': 'Failed to cancel escalation'};
    }
  }
}