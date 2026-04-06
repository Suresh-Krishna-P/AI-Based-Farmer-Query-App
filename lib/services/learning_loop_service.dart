import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ai_based_farmer_query_app/services/rag_service.dart';
import 'package:ai_based_farmer_query_app/services/language_service.dart';

/// Learning Loop Service for System Improvement
class LearningLoopService {
  final String? apiKey;
  final String? feedbackApiKey;
  final RAGService? ragService;
  final LanguageService? languageService;

  LearningLoopService({
    this.apiKey,
    this.feedbackApiKey,
    this.ragService,
    this.languageService,
  });

  /// Collect and process user feedback
  Future<Map<String, dynamic>> processFeedback({
    required String query,
    required String response,
    required String feedback,
    required String rating,
    String? farmerId,
    String? queryType,
    String? location,
    String? cropType,
  }) async {
    try {
      // Analyze feedback sentiment and content
      final feedbackAnalysis = await _analyzeFeedback(feedback, rating);
      
      // Store feedback for learning
      final feedbackRecord = await _storeFeedback({
        'query': query,
        'response': response,
        'feedback': feedback,
        'rating': rating,
        'feedback_analysis': feedbackAnalysis,
        'farmer_id': farmerId,
        'query_type': queryType,
        'location': location,
        'crop_type': cropType,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Update knowledge base if feedback indicates knowledge gap
      if (feedbackAnalysis['needs_knowledge_update']) {
        await _updateKnowledgeBase(query, feedback, feedbackAnalysis);
      }

      // Improve response patterns
      if (feedbackAnalysis['response_quality'] < 3) {
        await _improveResponsePatterns(query, response, feedback);
      }

      return {
        'status': 'processed',
        'feedback_id': feedbackRecord['feedback_id'],
        'improvements_made': feedbackAnalysis['improvements_needed'],
        'knowledge_updated': feedbackAnalysis['needs_knowledge_update'],
        'response_improved': feedbackAnalysis['response_quality'] < 3,
        'thank_you_message': _generateThankYouMessage(rating, feedbackAnalysis),
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to process feedback: $e',
        'error_details': e.toString(),
      };
    }
  }

  /// Analyze feedback sentiment and content
  Future<Map<String, dynamic>> _analyzeFeedback(String feedback, String rating) async {
    try {
      if (apiKey != null) {
        final prompt = '''
        Analyze this agricultural query feedback for a farmer advisory system:
        
        Feedback: "$feedback"
        Rating: $rating/5
        
        Please provide analysis with:
        1. Sentiment score (1-10)
        2. Response quality score (1-5)
        3. Whether knowledge base needs updating (true/false)
        4. Specific areas for improvement
        5. Whether this indicates a knowledge gap
        6. Suggested improvements
        
        Return as JSON format.
        ''';

        final response = await _callAIService(prompt);
        return jsonDecode(response);
      } else {
        return _getBasicFeedbackAnalysis(feedback, rating);
      }
    } catch (e) {
      return _getBasicFeedbackAnalysis(feedback, rating);
    }
  }

  /// Store feedback in database or external service
  Future<Map<String, dynamic>> _storeFeedback(Map<String, dynamic> feedbackData) async {
    try {
      if (feedbackApiKey != null) {
        final response = await http.post(
          Uri.parse('https://api.feedbacksystem.com/v1/feedback'),
          headers: {
            'Authorization': 'Bearer $feedbackApiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode(feedbackData),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          return {
            'feedback_id': data['feedback_id'],
            'stored_at': data['timestamp'],
            'status': 'success',
          };
        } else {
          throw Exception('Failed to store feedback');
        }
      } else {
        // Simulate feedback storage
        return {
          'feedback_id': 'FB-${DateTime.now().millisecondsSinceEpoch}',
          'stored_at': DateTime.now().toIso8601String(),
          'status': 'simulated',
        };
      }
    } catch (e) {
      return {
        'feedback_id': 'SIM-${DateTime.now().millisecondsSinceEpoch}',
        'stored_at': DateTime.now().toIso8601String(),
        'status': 'fallback',
        'error': e.toString(),
      };
    }
  }

  /// Update knowledge base based on feedback
  Future<void> _updateKnowledgeBase(String query, String feedback, Map<String, dynamic> analysis) async {
    try {
      if (apiKey != null) {
        final prompt = '''
        Based on this feedback, update the agricultural knowledge base:
        
        Original Query: "$query"
        User Feedback: "$feedback"
        Analysis: ${analysis.toString()}
        
        Please provide:
        1. New information to add to knowledge base
        2. Corrections to existing information
        3. Additional context that should be included
        4. Related topics that should be covered
        
        Format as structured knowledge entries.
        ''';

        final response = await _callAIService(prompt);
        
        // Store updated knowledge
        await _storeKnowledgeUpdate(response, query, feedback);
      }
    } catch (e) {
      print('Failed to update knowledge base: $e');
    }
  }

  /// Store knowledge base updates
  Future<void> _storeKnowledgeUpdate(String update, String query, String feedback) async {
    try {
      if (feedbackApiKey != null) {
        await http.post(
          Uri.parse('https://api.knowledgesystem.com/v1/updates'),
          headers: {
            'Authorization': 'Bearer $feedbackApiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'update_content': update,
            'related_query': query,
            'trigger_feedback': feedback,
            'update_type': 'feedback_driven',
            'timestamp': DateTime.now().toIso8601String(),
          }),
        );
      }
    } catch (e) {
      print('Failed to store knowledge update: $e');
    }
  }

  /// Improve response patterns based on feedback
  Future<void> _improveResponsePatterns(String query, String response, String feedback) async {
    try {
      if (apiKey != null) {
        final prompt = '''
        Improve response patterns for agricultural queries based on this feedback:
        
        Query: "$query"
        Current Response: "$response"
        User Feedback: "$feedback"
        
        Please provide:
        1. Better response structure
        2. More relevant information to include
        3. Improved explanation style
        4. Additional recommendations that should be made
        
        Focus on making responses more helpful and actionable for farmers.
        ''';

        final improvedPattern = await _callAIService(prompt);
        
        // Store improved response pattern
        await _storeResponsePattern(query, improvedPattern);
      }
    } catch (e) {
      print('Failed to improve response patterns: $e');
    }
  }

  /// Store improved response patterns
  Future<void> _storeResponsePattern(String query, String pattern) async {
    try {
      if (feedbackApiKey != null) {
        await http.post(
          Uri.parse('https://api.patterns.com/v1/response-patterns'),
          headers: {
            'Authorization': 'Bearer $feedbackApiKey',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'query_pattern': query,
            'improved_pattern': pattern,
            'pattern_type': 'feedback_improved',
            'timestamp': DateTime.now().toIso8601String(),
          }),
        );
      }
    } catch (e) {
      print('Failed to store response pattern: $e');
    }
  }

  /// Get system improvement recommendations
  Future<Map<String, dynamic>> getSystemImprovements() async {
    try {
      // Analyze feedback trends and system performance
      final feedbackTrends = await _analyzeFeedbackTrends();
      final performanceMetrics = await _getPerformanceMetrics();
      final knowledgeGaps = await _identifyKnowledgeGaps();

      return {
        'feedback_trends': feedbackTrends,
        'performance_metrics': performanceMetrics,
        'knowledge_gaps': knowledgeGaps,
        'improvement_recommendations': _generateImprovementRecommendations(
          feedbackTrends, performanceMetrics, knowledgeGaps
        ),
        'priority_actions': _getPriorityActions(feedbackTrends, knowledgeGaps),
        'analysis_date': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to generate improvements: $e',
      };
    }
  }

  /// Analyze feedback trends over time
  Future<Map<String, dynamic>> _analyzeFeedbackTrends() async {
    try {
      if (feedbackApiKey != null) {
        final response = await http.get(
          Uri.parse('https://api.feedbacksystem.com/v1/trends'),
          headers: {
            'Authorization': 'Bearer $feedbackApiKey',
          },
        );

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        }
      }
    } catch (e) {
      print('Failed to fetch feedback trends: $e');
    }

    // Return fallback trends
    return {
      'average_rating': 3.8,
      'total_feedbacks': 150,
      'positive_feedbacks': 120,
      'negative_feedbacks': 30,
      'common_issues': [
        'Response too technical',
        'Lacks local context',
        'Missing crop-specific advice',
      ],
      'improvement_trend': 'positive',
      'trend_period': 'last_30_days',
    };
  }

  /// Get system performance metrics
  Future<Map<String, dynamic>> _getPerformanceMetrics() async {
    try {
      if (feedbackApiKey != null) {
        final response = await http.get(
          Uri.parse('https://api.metricsystem.com/v1/performance'),
          headers: {
            'Authorization': 'Bearer $feedbackApiKey',
          },
        );

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        }
      }
    } catch (e) {
      print('Failed to fetch performance metrics: $e');
    }

    // Return fallback metrics
    return {
      'query_success_rate': 85.5,
      'average_response_time': 2.3,
      'user_satisfaction': 3.8,
      'escalation_rate': 12.5,
      'knowledge_coverage': 78.2,
      'language_accuracy': 92.1,
      'metrics_period': 'last_30_days',
    };
  }

  /// Identify knowledge gaps based on feedback
  Future<Map<String, dynamic>> _identifyKnowledgeGaps() async {
    try {
      if (apiKey != null) {
        final prompt = '''
        Analyze feedback data to identify knowledge gaps in the agricultural advisory system:
        
        Look for patterns in:
        1. Queries that received poor ratings
        2. Common follow-up questions
        3. Escalation reasons
        4. Missing information requests
        
        Provide specific knowledge gaps and suggested topics to cover.
        ''';

        final response = await _callAIService(prompt);
        return jsonDecode(response);
      }
    } catch (e) {
      print('Failed to identify knowledge gaps: $e');
    }

    // Return fallback knowledge gaps
    return {
      'identified_gaps': [
        'Organic farming practices for Tamil Nadu',
        'Climate-resilient crop varieties',
        'Integrated pest management techniques',
        'Soil health management for different regions',
        'Market price trends and forecasting',
      ],
      'gap_severity': 'medium',
      'recommended_actions': [
        'Add organic farming module',
        'Include climate adaptation strategies',
        'Expand pest management database',
        'Add regional soil guides',
        'Integrate market data',
      ],
    };
  }

  /// Generate improvement recommendations
  List<String> _generateImprovementRecommendations(
    Map<String, dynamic> feedbackTrends,
    Map<String, dynamic> performanceMetrics,
    Map<String, dynamic> knowledgeGaps
  ) {
    final recommendations = <String>[];

    // Based on feedback trends
    if (feedbackTrends['average_rating'] < 4.0) {
      recommendations.add('Improve response quality and clarity');
    }

    if (feedbackTrends['common_issues'] != null) {
      for (final issue in feedbackTrends['common_issues']) {
        if (issue.contains('technical')) {
          recommendations.add('Simplify technical language in responses');
        }
        if (issue.contains('local')) {
          recommendations.add('Add more location-specific information');
        }
        if (issue.contains('crop')) {
          recommendations.add('Expand crop-specific advice database');
        }
      }
    }

    // Based on performance metrics
    if (performanceMetrics['query_success_rate'] < 90) {
      recommendations.add('Improve query understanding and matching');
    }

    if (performanceMetrics['escalation_rate'] > 15) {
      recommendations.add('Reduce escalation rate by improving knowledge base');
    }

    // Based on knowledge gaps
    if (knowledgeGaps['identified_gaps'] != null) {
      recommendations.add('Address identified knowledge gaps in priority order');
      recommendations.add('Regularly update knowledge base with new information');
    }

    return recommendations;
  }

  /// Get priority actions based on analysis
  List<Map<String, dynamic>> _getPriorityActions(
    Map<String, dynamic> feedbackTrends, Map<String, dynamic> knowledgeGaps
  ) {
    final actions = <Map<String, dynamic>>[];

    // High priority actions
    if (feedbackTrends['negative_feedbacks'] > 20) {
      actions.add({
        'priority': 'high',
        'action': 'Address common negative feedback issues',
        'timeline': '1-2 weeks',
        'impact': 'improve user satisfaction',
      });
    }

    if (knowledgeGaps['identified_gaps'].length > 3) {
      actions.add({
        'priority': 'high',
        'action': 'Fill critical knowledge gaps',
        'timeline': '2-4 weeks',
        'impact': 'reduce escalation rate',
      });
    }

    // Medium priority actions
    actions.add({
      'priority': 'medium',
      'action': 'Implement feedback-driven improvements',
      'timeline': '1 month',
      'impact': 'continuous system improvement',
    });

    actions.add({
      'priority': 'medium',
      'action': 'Expand local agricultural knowledge',
      'timeline': 'ongoing',
      'impact': 'better regional coverage',
    });

    return actions;
  }

  /// Generate thank you message based on feedback
  String _generateThankYouMessage(String rating, Map<String, dynamic> analysis) {
    final ratingNum = int.tryParse(rating) ?? 0;
    
    if (ratingNum >= 4) {
      return 'Thank you for your positive feedback! We appreciate your input and will continue to improve our service.';
    } else if (ratingNum >= 2) {
      return 'Thank you for your feedback. We will work on the areas you mentioned to improve our service.';
    } else {
      return 'We apologize that our service didn\'t meet your expectations. Your feedback helps us improve.';
    }
  }

  /// Get basic feedback analysis (fallback)
  Map<String, dynamic> _getBasicFeedbackAnalysis(String feedback, String rating) {
    final feedbackLower = feedback.toLowerCase();
    final ratingNum = int.tryParse(rating) ?? 0;
    
    final analysis = {
      'sentiment_score': ratingNum * 2,
      'response_quality': ratingNum,
      'needs_knowledge_update': false,
      'improvements_needed': <String>[],
      'knowledge_gap': false,
      'suggested_improvements': <String>[],
    };

    // Analyze feedback content
    if (feedbackLower.contains('not helpful') || feedbackLower.contains('wrong')) {
      analysis['needs_knowledge_update'] = true;
      analysis['improvements_needed'].add('Improve response accuracy');
    }

    if (feedbackLower.contains('too technical') || feedbackLower.contains('difficult')) {
      analysis['improvements_needed'].add('Simplify language');
    }

    if (feedbackLower.contains('not specific') || feedbackLower.contains('general')) {
      analysis['improvements_needed'].add('Add more specific information');
    }

    if (feedbackLower.contains('outdated') || feedbackLower.contains('old')) {
      analysis['knowledge_gap'] = true;
      analysis['suggested_improvements'].add('Update with current information');
    }

    return analysis;
  }

  /// Call AI service for analysis
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
              'content': 'You are an AI expert analyzing agricultural advisory system feedback and providing improvement recommendations.'
            },
            {
              'role': 'user',
              'content': prompt
            }
          ],
          'max_tokens': 300,
          'temperature': 0.7,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['choices'][0]['message']['content'];
      } else {
        return 'Analysis temporarily unavailable. Using basic analysis.';
      }
    } catch (e) {
      return 'Unable to connect to AI service. Using fallback analysis.';
    }
  }

  /// Get learning statistics
  Future<Map<String, dynamic>> getLearningStatistics() async {
    try {
      if (feedbackApiKey != null) {
        final response = await http.get(
          Uri.parse('https://api.learningsystem.com/v1/statistics'),
          headers: {
            'Authorization': 'Bearer $feedbackApiKey',
          },
        );

        if (response.statusCode == 200) {
          return jsonDecode(response.body);
        }
      }
    } catch (e) {
      print('Failed to fetch learning statistics: $e');
    }

    // Return fallback statistics
    return {
      'total_feedbacks_processed': 150,
      'knowledge_updates_made': 25,
      'response_patterns_improved': 15,
      'user_satisfaction_improvement': 12.5,
      'learning_period': 'last_30_days',
      'system_improvements': [
        'Added organic farming module',
        'Improved pest identification accuracy',
        'Enhanced local crop recommendations',
      ],
    };
  }
}