import 'package:flutter/material.dart';
import 'package:ai_based_farmer_query_app/services/rag_service.dart';
import 'package:ai_based_farmer_query_app/models/advisory_model.dart';
import 'package:ai_based_farmer_query_app/ui/widgets/advisory_card.dart';
import 'package:ai_based_farmer_query_app/theme/app_colors.dart';
import 'package:ai_based_farmer_query_app/ui/widgets/loading_indicator.dart';
import 'package:provider/provider.dart';

class AdvisoryScreen extends StatefulWidget {
  const AdvisoryScreen({super.key});

  @override
  State<AdvisoryScreen> createState() => _AdvisoryScreenState();
}

class _AdvisoryScreenState extends State<AdvisoryScreen> {
  List<AdvisoryModel> _advisories = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _currentCrop = 'All Crops';
  String _currentSeason = 'All Seasons';

  final List<String> _crops = [
    'All Crops', 'Wheat', 'Rice', 'Corn', 'Soybean', 'Cotton', 'Sugarcane', 'Vegetables', 'Fruits',
  ];

  final List<String> _seasons = [
    'All Seasons', 'Kharif', 'Rabi', 'Zaid',
  ];

  @override
  void initState() {
    super.initState();
    _loadAdvisories();
  }

  Future<void> _loadAdvisories() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final sampleAdvisories = await _generateSampleAdvisories();
      
      if (!mounted) return;
      setState(() {
        _advisories = sampleAdvisories;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error loading advisories: $e';
        _isLoading = false;
      });
    }
  }

  Future<List<AdvisoryModel>> _generateSampleAdvisories() async {
    final ragService = Provider.of<RAGService>(context, listen: false);
    final recData = ragService.recommendationDatasets;
    
    final cropSamples = recData.cropRecommendations;
    final pestSamples = recData.pestTreatments;
    final seedSamples = recData.seedVarieties;
    final fertilizerSamples = recData.fertilizerRecommendations;

    List<AdvisoryModel> loadedAdvisories = [];
    int idCounter = 1;

    String getSeasonForCrop(String crop) {
      final kharif = ['rice', 'maize', 'corn', 'cotton', 'soybean', 'sugarcane', 'groundnut', 'turmeric', 'jowar', 'bajra'];
      final rabi = ['wheat', 'mustard', 'barley', 'gram', 'peas', 'potato', 'oats'];
      final zaid = ['watermelon', 'muskmelon', 'cucumber', 'vegetables', 'pumpkin'];
      
      final lowerCrop = crop.toLowerCase();
      if (kharif.any((c) => lowerCrop.contains(c))) return 'Kharif';
      if (rabi.any((c) => lowerCrop.contains(c))) return 'Rabi';
      if (zaid.any((c) => lowerCrop.contains(c))) return 'Zaid';
      return 'Annual';
    }

    // 1. Guides
    for (var crop in cropSamples) {
      final season = getSeasonForCrop(crop.label);
      loadedAdvisories.add(AdvisoryModel(
        advisoryId: 'crop_${idCounter++}',
        farmerId: 'f1',
        title: '${crop.label.toUpperCase()} Guide',
        description: 'Nutrients: N:${crop.nitrogen}, P:${crop.phosphorus}, K:${crop.potassium}. PH: ${crop.ph}.',
        recommendations: ['Maintain N at ${crop.nitrogen}', 'Optimal PH: ${crop.ph}'],
        cropType: crop.label,
        soilType: 'Varies',
        weatherCondition: season,
        timestamp: DateTime.now(),
      ));
      if (idCounter > 40) break;
    }

    // 2. Pests
    for (var pest in pestSamples.take(40)) {
      final season = getSeasonForCrop(pest.crop);
      loadedAdvisories.add(AdvisoryModel(
        advisoryId: 'pest_${idCounter++}',
        farmerId: 'f1',
        title: 'Pest: ${pest.pestOrDisease}',
        description: 'Target: ${pest.crop}. Symptoms: ${pest.symptoms}',
        recommendations: [pest.treatment, pest.organicControl],
        cropType: pest.crop,
        soilType: 'Any',
        weatherCondition: season,
        timestamp: DateTime.now(),
      ));
    }

    return loadedAdvisories;
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _advisories.where((a) {
      final cMatch = _currentCrop == 'All Crops' || a.cropType.toLowerCase().contains(_currentCrop.toLowerCase());
      final sMatch = _currentSeason == 'All Seasons' || a.weatherCondition.toLowerCase().contains(_currentSeason.toLowerCase());
      return cMatch && sMatch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.secondaryGray,
      appBar: AppBar(title: const Text('Advisory Support'), centerTitle: true),
      body: _isLoading 
        ? const LoadingIndicator()
        : CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildFilters(),
                      const SizedBox(height: 16),
                      _buildStats(filtered.length),
                    ],
                  ),
                ),
              ),
              filtered.isEmpty
                ? const SliverFillRemaining(child: Center(child: Text('No data found')))
                : SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => AdvisoryCard(
                        advisory: filtered[index],
                        onTap: () => _showDetails(filtered[index]),
                      ),
                      childCount: filtered.length,
                    ),
                  ),
            ],
          ),
    );
  }

  Widget _buildFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Expanded(child: _drop('Crop', _currentCrop, _crops, (v) => setState(() => _currentCrop = v!))),
          const SizedBox(width: 12),
          Expanded(child: _drop('Season', _currentSeason, _seasons, (v) => setState(() => _currentSeason = v!))),
        ],
      ),
    );
  }

  Widget _drop(String lab, String val, List<String> items, ValueChanged<String?> onC) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(lab, style: const TextStyle(fontSize: 10, color: Colors.grey)),
        DropdownButton<String>(
          value: val,
          isExpanded: true,
          onChanged: onC,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
        ),
      ],
    );
  }

  Widget _buildStats(int count) {
    return Row(
      children: [
        _stat('Total', '${_advisories.length}'),
        _stat('Found', '$count'),
      ],
    );
  }

  Widget _stat(String lab, String val) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              Text(val, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
              Text(lab, style: const TextStyle(fontSize: 10)),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetails(AdvisoryModel a) {
    showModalBottomSheet(
      context: context,
      builder: (c) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(a.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(a.description),
            const Divider(),
            ...a.recommendations.map((r) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text('• $r'),
            )),
          ],
        ),
      ),
    );
  }
}