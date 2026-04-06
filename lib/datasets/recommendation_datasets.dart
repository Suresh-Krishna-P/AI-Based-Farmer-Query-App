import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/agricultural_data_models.dart';

class RecommendationDatasets {
  List<CropRecommendation> _cropRecommendations = [];
  List<FertilizerRecommendation> _fertilizerRecommendations = [];
  List<PestTreatment> _pestTreatments = [];
  List<SeedVariety> _seedVarieties = [];

  List<CropRecommendation> get cropRecommendations => _cropRecommendations;
  List<FertilizerRecommendation> get fertilizerRecommendations => _fertilizerRecommendations;
  List<PestTreatment> get pestTreatments => _pestTreatments;
  List<SeedVariety> get seedVarieties => _seedVarieties;

  Future<void> initialize() async {
    await _loadCropRecommendations();
    await _loadFertilizerRecommendations();
    await _loadPestTreatments();
    await _loadSeedVarieties();
  }

  Future<void> _loadCropRecommendations() async {
    try {
      final rawData = await rootBundle.loadString('assets/data/crop_recommendation.csv');
      List<List<dynamic>> rows = const CsvToListConverter().convert(rawData);
      if (rows.isNotEmpty) rows = rows.sublist(1); // skip header
      _cropRecommendations = rows.map((row) => CropRecommendation.fromCsv(row)).toList();
    } catch (e) {
      print('Error loading Crop Recommendations: $e');
    }
  }

  Future<void> _loadFertilizerRecommendations() async {
    try {
      final rawData = await rootBundle.loadString('assets/data/fertilizer_recommendation.csv');
      List<List<dynamic>> rows = const CsvToListConverter().convert(rawData);
      if (rows.isNotEmpty) rows = rows.sublist(1); // skip header
      _fertilizerRecommendations = rows.map((row) => FertilizerRecommendation.fromCsv(row)).toList();
    } catch (e) {
      print('Error loading Fertilizer Recommendations: $e');
    }
  }

  Future<void> _loadPestTreatments() async {
    try {
      final rawData = await rootBundle.loadString('assets/data/pest_treatment.csv');
      List<List<dynamic>> rows = const CsvToListConverter().convert(rawData);
      if (rows.isNotEmpty) rows = rows.sublist(1);
      _pestTreatments = rows.map((row) => PestTreatment.fromCsv(row)).toList();
    } catch (e) {
      print('Error loading Pest Treatments: $e');
    }
  }

  Future<void> _loadSeedVarieties() async {
    try {
      final rawData = await rootBundle.loadString('assets/data/seed_varieties.csv');
      List<List<dynamic>> rows = const CsvToListConverter().convert(rawData);
      if (rows.isNotEmpty) rows = rows.sublist(1);
      _seedVarieties = rows.map((row) => SeedVariety.fromCsv(row)).toList();
    } catch (e) {
      print('Error loading Seed Varieties: $e');
    }
  }

  List<String> getCropSuitability(String crop) {
    final matches = _cropRecommendations.where((rec) => rec.label.toLowerCase() == crop.toLowerCase()).toList();
    if (matches.isEmpty) return [];
    
    // Average or sample the suitability
    final first = matches.first;
    return [
      'Ideal Conditions for $crop:',
      '- Nitrogen (N): ${first.nitrogen}',
      '- Phosphorus (P): ${first.phosphorus}',
      '- Potassium (K): ${first.potassium}',
      '- Optimal PH: ${first.ph}',
      '- Rainfall: ${first.rainfall} mm',
    ];
  }

  List<String> getFertilizerAdvice({required String crop, required String soil}) {
    final matches = _fertilizerRecommendations.where((rec) => 
      rec.cropType.toLowerCase() == crop.toLowerCase() || 
      rec.soilType.toLowerCase() == soil.toLowerCase()
    ).toList();

    if (matches.isEmpty) return [];

    return matches.map((m) => 
      'For ${m.cropType} in ${m.soilType} soil, use ${m.fertilizerName}. '
      '(Requires N:${m.nitrogen}, P:${m.phosphorus}, K:${m.potassium})'
    ).toList();
  }

  List<String> getPestAdvice(String query) {
    if (query.isEmpty) return [];
    
    final queryLower = query.toLowerCase();
    final queryParts = queryLower.split(RegExp(r'[:\s-]+')).where((p) => p.length > 2).toList();

    final matches = _pestTreatments.where((pest) {
      final cropLower = pest.crop.toLowerCase();
      final pestLower = pest.pestOrDisease.toLowerCase();
      
      // Exact match first
      if (cropLower.contains(queryLower) || pestLower.contains(queryLower)) return true;
      
      // Keyword match (if any keyword matches both crop and pest, or if multiple keywords match)
      if (queryParts.isNotEmpty) {
        bool cropMatch = queryParts.any((part) => cropLower.contains(part));
        bool pestMatch = queryParts.any((part) => pestLower.contains(part));
        return cropMatch && pestMatch; // Best match is when both are present
      }
      
      return false;
    }).toList();

    // If no "both" matches, try any match
    if (matches.isEmpty && queryParts.isNotEmpty) {
      matches.addAll(_pestTreatments.where((pest) {
        final cropLower = pest.crop.toLowerCase();
        final pestLower = pest.pestOrDisease.toLowerCase();
        return queryParts.any((part) => cropLower.contains(part) || pestLower.contains(part));
      }));
    }

    return matches.map((m) => 
      'Pest/Disease: ${m.pestOrDisease} (${m.crop})\n'
      '- Symptoms: ${m.symptoms}\n'
      '- Treatment: ${m.treatment}\n'
      '- Organic: ${m.organicControl}'
    ).toList();
  }

  List<String> getSeedAdvice(String query) {
    final matches = _seedVarieties.where((seed) => 
      seed.crop.toLowerCase().contains(query.toLowerCase()) || 
      seed.variety.toLowerCase().contains(query.toLowerCase())
    ).toList();

    return matches.map((m) => 
      'Variety: ${m.variety} (${m.crop})\n'
      '- Duration: ${m.duration} days\n'
      '- Yield: ${m.estimatedYield} q/ha\n'
      '- Features: ${m.specialFeatures}'
    ).toList();
  }
}
