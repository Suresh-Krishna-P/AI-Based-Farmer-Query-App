import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ai_based_farmer_query_app/theme/app_theme.dart';
import 'package:ai_based_farmer_query_app/ui/screens/home_screen.dart';
import 'package:ai_based_farmer_query_app/services/database_service.dart';
import 'package:ai_based_farmer_query_app/services/rag_service.dart';
import 'package:ai_based_farmer_query_app/services/language_service.dart';
import 'package:ai_based_farmer_query_app/services/ai_service.dart';
import 'package:ai_based_farmer_query_app/services/image_search_service.dart';
import 'package:ai_based_farmer_query_app/services/voice_search_service.dart';
import 'package:ai_based_farmer_query_app/datasets/external_datasets.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Initialize Database Service (Offline SQLite)
  final dbService = DatabaseService();
  
  // 2. Initialize External Datasets integration
  final externalDatasets = ExternalDatasets(
    dbService: dbService,
    usdaApiKey: 'YOUR_USDA_API_KEY_HERE', // PROVIDE YOUR USDA API KEY HERE
  );
  
  // 3. Initialize RAG (Retrieval Augmented Generation) Service
  final ragService = RAGService(
    // For Groq: Use 'https://api.groq.com/openai/v1/chat/completions' as apiUrl
    // and a Groq model like 'llama-3.1-8b-instant' or 'llama3-70b-8192' as modelName
    apiKey: 'YOUR_GROQ_API_KEY_HERE', // PROVIDE YOUR KEY HERE
    apiUrl: 'https://api.groq.com/openai/v1/chat/completions',
    modelName: 'llama-3.1-8b-instant', 
    externalDatasets: externalDatasets,
  );

  // 4. Initialize AgroQA (CSV base)
  await ragService.agroQADataset.initialize();
  
  // 5. Initialize Recommendation Datasets (Suitability/Fertilizer)
  await ragService.recommendationDatasets.initialize();

  runApp(
    MultiProvider(
      providers: [
        // Make services available throughout the app
        Provider<DatabaseService>.value(value: dbService),
        Provider<ExternalDatasets>.value(value: externalDatasets),
        Provider<RAGService>.value(value: ragService),
        Provider<LanguageService>(create: (_) => LanguageService()),
        Provider<ImageSearchService>(create: (_) => ImageSearchService(ragService: ragService)),
        Provider<VoiceSearchService>(create: (_) => VoiceSearchService(ragService: ragService)),
        Provider<AIService>(create: (_) => AIService()),
      ],
      child: const FarmerQueryApp(),
    ),
  );
}

class FarmerQueryApp extends StatelessWidget {
  const FarmerQueryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Farmer Query Support',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      // The HomeScreen is the main dashboard of the application
      home: const HomeScreen(),
    );
  }
}