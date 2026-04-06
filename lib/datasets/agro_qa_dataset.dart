import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import '../models/agricultural_data_models.dart';
import '../services/database_service.dart';

import 'package:flutter/foundation.dart' show kIsWeb;

class AgroQADataset {
  final DatabaseService _dbService = DatabaseService();
  List<AgroQAData> _agroQAData = [];

  Future<void> initialize() async {
    try {
      if (kIsWeb) {
        print('Web detected: Initializing AgroQA in-memory...');
        await _loadInMemory();
        return;
      }
      
      final count = await _dbService.getAgroQACount();
      if (count == 0) {
        print('Initializing AgroQA database from CSV...');
        await _loadAndInsertCSV();
      } else {
        print('AgroQA database already contains $count entries.');
      }
    } catch (e) {
      print('Error initializing AgroQA dataset: $e');
    }
  }

  Future<void> _loadInMemory() async {
    try {
      final rawData = await rootBundle.loadString('assets/data/agro_qa.csv');
      List<List<dynamic>> rows = const CsvToListConverter(shouldParseNumbers: true).convert(rawData);
      
      if (rows.isNotEmpty) {
        rows = rows.sublist(1);
      }

      _agroQAData = rows.map((row) => AgroQAData(
        crop: row[0].toString(),
        question: row[1].toString(),
        answer: row[2].toString(),
      )).toList();
      print('Successfully loaded ${_agroQAData.length} AgroQA entries into memory.');
    } catch (e) {
      print('Error loading AgroQA CSV into memory: $e');
    }
  }

  Future<void> _loadAndInsertCSV() async {
    try {
      final rawData = await rootBundle.loadString('assets/data/agro_qa.csv');
      List<List<dynamic>> rows = const CsvToListConverter(shouldParseNumbers: true).convert(rawData);
      
      // Skip header row
      if (rows.isNotEmpty) {
        rows = rows.sublist(1);
      }

      List<AgroQAData> dataList = [];
      for (var row in rows) {
        if (row.length >= 3) {
          dataList.add(AgroQAData(
            crop: row[0].toString(),
            question: row[1].toString(),
            answer: row[2].toString(),
          ));
        }

        // Batch insert every 500 rows to avoid memory issues
        if (dataList.length >= 500) {
          await _dbService.insertAgroQA(dataList);
          dataList.clear();
        }
      }

      if (dataList.isNotEmpty) {
        await _dbService.insertAgroQA(dataList);
      }
      
      print('Successfully loaded AgroQA dataset into database.');
    } catch (e) {
      print('Error loading AgroQA CSV: $e');
    }
  }

  Future<List<AgroQAData>> search(String query) async {
    if (kIsWeb) {
      final qLower = query.toLowerCase();
      return _agroQAData.where((qa) => 
        qa.question.toLowerCase().contains(qLower) || 
        qa.answer.toLowerCase().contains(qLower) || 
        qa.crop.toLowerCase().contains(qLower)
      ).toList();
    }
    return await _dbService.searchAgroQA(query);
  }
}
