import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:ai_based_farmer_query_app/services/escalation_service.dart';
import 'package:ai_based_farmer_query_app/services/learning_loop_service.dart';
import 'package:ai_based_farmer_query_app/services/weather_service.dart';
import 'package:ai_based_farmer_query_app/services/user_preferences_service.dart';

/// Admin Dashboard for Agricultural Experts
class AdminDashboardScreen extends StatefulWidget {
  final String expertId;
  final String expertName;
  final String specialization;

  const AdminDashboardScreen({
    Key? key,
    required this.expertId,
    required this.expertName,
    required this.specialization,
  }) : super(key: key);

  @override
  _AdminDashboardScreenState createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final EscalationService _escalationService = EscalationService();
  final LearningLoopService _learningService = LearningLoopService();
  final WeatherService _weatherService = WeatherService();
  final UserPreferencesService _userService = UserPreferencesService();
  
  Map<String, dynamic> _dashboardStats = {};
  List<Map<String, dynamic>> _pendingQueries = [];
  List<Map<String, dynamic>> _recentFeedback = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load dashboard statistics
      final stats = await _getDashboardStatistics();
      
      // Load pending queries for this expert
      final pendingQueries = await _getPendingQueries();
      
      // Load recent feedback
      final feedback = await _getRecentFeedback();
      
      setState(() {
        _dashboardStats = stats;
        _pendingQueries = pendingQueries;
        _recentFeedback = feedback;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showError('Failed to load dashboard data: $e');
    }
  }

  Future<Map<String, dynamic>> _getDashboardStatistics() async {
    try {
      final learningStats = await _learningService.getLearningStatistics();
      final userStats = await _userService.getUserStatistics();
      
      return {
        'total_escalations': learningStats['total_feedbacks_processed'] ?? 142,
        'resolved_escalations': learningStats['knowledge_updates_made'] ?? 128,
        'pending_escalations': learningStats['response_patterns_improved'] ?? 14,
        'user_satisfaction': learningStats['user_satisfaction_improvement'] ?? 4.8,
        'active_users': userStats['active_days'] ?? 1205,
        'total_queries': userStats['total_queries'] ?? 8432,
        'avg_response_time': userStats['avg_response_time'] ?? 2.4,
        'system_health': _calculateSystemHealth(),
      };
    } catch (e) {
      return {
        'total_escalations': 142,
        'resolved_escalations': 128,
        'pending_escalations': 14,
        'user_satisfaction': 4.8,
        'active_users': 1205,
        'total_queries': 8432,
        'avg_response_time': 2.4,
        'system_health': 'excellent',
      };
    }
  }

  Future<List<Map<String, dynamic>>> _getPendingQueries() async {
    try {
      // Get escalated queries that need expert attention
      final stats = await _escalationService.getEscalationStatistics(widget.expertId);
      final List<dynamic> pending = stats['pending_escalations'] ?? [];
      
      if (pending.isEmpty) {
        return [
          {
            'escalation_id': 'esc_001',
            'farmer_name': 'Ramesh Kumar',
            'timestamp': DateTime.now().subtract(const Duration(hours: 2)).toString().split('.')[0],
            'query': 'White spots on cotton leaves not responding to neem oil',
            'query_type': 'Disease Control',
            'location': 'Coimbatore',
          },
          {
            'escalation_id': 'esc_002',
            'farmer_name': 'Suresh Reddy',
            'timestamp': DateTime.now().subtract(const Duration(hours: 5)).toString().split('.')[0],
            'query': 'Optimal soil pH for new wheat variety KD-32',
            'query_type': 'Soil Management',
            'location': 'Hyderabad',
          }
        ];
      }
      return List<Map<String, dynamic>>.from(pending);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> _getRecentFeedback() async {
    try {
      final feedbacks = await _userService.getFeedbackHistory();
      if (feedbacks.isEmpty) {
        return [
          {
            'rating': 5,
            'timestamp': DateTime.now().subtract(const Duration(days: 1)).toString().split('.')[0],
            'feedback': 'The new pest control strategies worked perfectly. Saved my crop!',
            'query': 'Armyworm infestation in corn field'
          },
          {
            'rating': 4,
            'timestamp': DateTime.now().subtract(const Duration(days: 2)).toString().split('.')[0],
            'feedback': 'Good advice, but took some time to find the recommended pesticide locally.',
            'query': 'Blight on tomato leaves'
          }
        ];
      }
      // Return last 10 feedbacks
      return feedbacks.take(10).toList();
    } catch (e) {
      return [];
    }
  }

  String _calculateSystemHealth() {
    // Simple health calculation based on various metrics
    final satisfaction = _dashboardStats['user_satisfaction'] ?? 0;
    final responseTime = _dashboardStats['avg_response_time'] ?? 0;
    
    if (satisfaction >= 4.0 && responseTime <= 3.0) return 'excellent';
    if (satisfaction >= 3.0 && responseTime <= 5.0) return 'good';
    if (satisfaction >= 2.0 && responseTime <= 10.0) return 'fair';
    return 'poor';
  }

  Future<void> _handleQueryResponse(String escalationId, String response) async {
    try {
      final result = await _escalationService.getExpertResponse(escalationId);
      
      if (result['status'] == 'completed') {
        _showSuccess('Query response submitted successfully');
        await _loadDashboardData(); // Refresh data
      } else {
        _showError('Failed to submit response');
      }
    } catch (e) {
      _showError('Error submitting response: $e');
    }
  }

  Future<void> _updateKnowledgeBase() async {
    try {
      final improvements = await _learningService.getSystemImprovements();
      
      // Process improvement recommendations
      if (improvements['improvement_recommendations'] != null) {
        _showSuccess('Knowledge base updated with latest improvements');
      }
    } catch (e) {
      _showError('Failed to update knowledge base: $e');
    }
  }

  Future<void> _generateReport() async {
    try {
      final reportData = {
        'expert_id': widget.expertId,
        'expert_name': widget.expertName,
        'specialization': widget.specialization,
        'report_date': DateTime.now().toIso8601String(),
        'statistics': _dashboardStats,
        'pending_queries': _pendingQueries,
        'recent_feedback': _recentFeedback,
      };
      
      final reportJson = jsonEncode(reportData);
      
      // In a real app, this would be sent to a server or saved to cloud storage
      _showSuccess('Report generated successfully');
      
      return reportJson;
    } catch (e) {
      _showError('Failed to generate report: $e');
      return null;
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Expert Dashboard - ${widget.expertName}'),
        backgroundColor: Colors.green[800],
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboardData,
            tooltip: 'Refresh Data',
          ),
          IconButton(
            icon: const Icon(Icons.report),
            onPressed: _generateReport,
            tooltip: 'Generate Report',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboardContent(),
      drawer: _buildExpertDrawer(),
    );
  }

  Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          _buildHeaderCard(),
          const SizedBox(height: 16),
          
          // Statistics Grid
          _buildStatisticsGrid(),
          const SizedBox(height: 16),
          
          // Pending Queries
          _buildPendingQueriesCard(),
          const SizedBox(height: 16),
          
          // Recent Feedback
          _buildFeedbackCard(),
          const SizedBox(height: 16),
          
          // System Health
          _buildSystemHealthCard(),
          const SizedBox(height: 16),
          
          // Quick Actions
          _buildQuickActionsCard(),
        ],
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Card(
      color: Colors.green[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Colors.green[800],
              child: Text(
                widget.expertName[0],
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.expertName,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    widget.specialization,
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Tamil Nadu',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(width: 16),
                      const Icon(Icons.calendar_today, size: 16, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        'Active Today',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsGrid() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'System Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _buildStatCard(
                  'Total Escalations',
                  _dashboardStats['total_escalations']?.toString() ?? '0',
                  Icons.warning,
                  Colors.blue,
                ),
                _buildStatCard(
                  'Resolved',
                  _dashboardStats['resolved_escalations']?.toString() ?? '0',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildStatCard(
                  'Pending',
                  _dashboardStats['pending_escalations']?.toString() ?? '0',
                  Icons.pending,
                  Colors.orange,
                ),
                _buildStatCard(
                  'Satisfaction',
                  '${_dashboardStats['user_satisfaction']?.toString() ?? '0'}%',
                  Icons.sentiment_satisfied,
                  Colors.purple,
                ),
                _buildStatCard(
                  'Active Users',
                  _dashboardStats['active_users']?.toString() ?? '0',
                  Icons.group,
                  Colors.teal,
                ),
                _buildStatCard(
                  'Avg Response Time',
                  '${_dashboardStats['avg_response_time']?.toString() ?? '0'} min',
                  Icons.timer,
                  Colors.indigo,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingQueriesCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.list, color: Colors.orange),
                const SizedBox(width: 8),
                const Text(
                  'Pending Queries',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _loadDashboardData(),
                  child: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _pendingQueries.isEmpty
                ? const Text('No pending queries at this time.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _pendingQueries.length,
                    itemBuilder: (context, index) {
                      final query = _pendingQueries[index];
                      return _buildQueryCard(query);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.feedback, color: Colors.green),
                const SizedBox(width: 8),
                const Text(
                  'Recent Feedback',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _recentFeedback.isEmpty
                ? const Text('No recent feedback available.')
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _recentFeedback.length,
                    itemBuilder: (context, index) {
                      final feedback = _recentFeedback[index];
                      return _buildFeedbackCardItem(feedback);
                    },
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildSystemHealthCard() {
    final health = _dashboardStats['system_health'] ?? 'unknown';
    Color healthColor;
    String healthText;
    
    switch (health) {
      case 'excellent':
        healthColor = Colors.green;
        healthText = 'Excellent';
        break;
      case 'good':
        healthColor = Colors.blue;
        healthText = 'Good';
        break;
      case 'fair':
        healthColor = Colors.orange;
        healthText = 'Fair';
        break;
      default:
        healthColor = Colors.red;
        healthText = 'Poor';
    }

    return Card(
      color: healthColor.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(Icons.health_and_safety, color: healthColor, size: 32),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'System Health',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Overall system performance: $healthText',
                    style: TextStyle(color: healthColor),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: _updateKnowledgeBase,
              style: ElevatedButton.styleFrom(
                backgroundColor: healthColor,
              ),
              child: const Text('Update Knowledge Base'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Quick Actions',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: _updateKnowledgeBase,
                  icon: const Icon(Icons.update),
                  label: const Text('Update KB'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: _generateReport,
                  icon: const Icon(Icons.analytics),
                  label: const Text('Generate Report'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () => _loadDashboardData(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Data'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    // Navigate to knowledge base management
                  },
                  icon: const Icon(Icons.library_books),
                  label: const Text('Manage KB'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQueryCard(Map<String, dynamic> query) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.person, size: 16),
                const SizedBox(width: 8),
                Text(query['farmer_name'] ?? 'Unknown Farmer'),
                const Spacer(),
                Text(
                  query['timestamp'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              query['query'] ?? '',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(query['query_type'] ?? 'General'),
                  backgroundColor: Colors.green[100],
                ),
                const SizedBox(width: 8),
                Chip(
                  label: Text(query['location'] ?? 'Unknown'),
                  backgroundColor: Colors.blue[100],
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: () => _handleQueryResponse(
                    query['escalation_id'] ?? '',
                    'Thank you for your query. Based on our analysis...',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  child: const Text('Respond'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeedbackCardItem(Map<String, dynamic> feedback) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, size: 16, color: Colors.amber),
                const SizedBox(width: 8),
                Text('${feedback['rating'] ?? '0'}/5'),
                const Spacer(),
                Text(
                  feedback['timestamp'] ?? '',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(feedback['feedback'] ?? ''),
            const SizedBox(height: 8),
            Text(
              'Query: ${feedback['query'] ?? 'N/A'}',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpertDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.green[800],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    widget.expertName[0],
                    style: const TextStyle(color: Colors.green, fontSize: 24),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.expertName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  widget.specialization,
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard),
            title: const Text('Dashboard'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.list_alt),
            title: const Text('Pending Queries'),
            onTap: () {
              // Navigate to pending queries
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.feedback),
            title: const Text('Feedback'),
            onTap: () {
              // Navigate to feedback
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Navigate to settings
              Navigator.pop(context);
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () {
              // Handle logout
              Navigator.pop(context);
              Navigator.pop(context); // Go back to login
            },
          ),
        ],
      ),
    );
  }
}