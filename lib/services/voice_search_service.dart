import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:ai_based_farmer_query_app/services/rag_service.dart';

class VoiceSearchService {
  late stt.SpeechToText _speechToText;
  bool _isListening = false;
  String _recognizedText = '';
  final RAGService ragService;

  VoiceSearchService({required this.ragService}) {
    _speechToText = stt.SpeechToText();
  }

  Future<bool> initializeSpeechToText() async {
    try {
      bool available = await _speechToText.initialize(
        onError: (error) => print('Error: $error'),
        onStatus: (status) => print('Status: $status'),
      );
      return available;
    } catch (e) {
      print('Error initializing speech to text: $e');
      return false;
    }
  }

  Future<void> startListening(
      {Function(String)? onRecognitionResult}) async {
    if (!_isListening) {
      try {
        bool available = await _speechToText.initialize();
        if (available) {
          _isListening = true;
          _speechToText.listen(
            onResult: (result) {
              _recognizedText = result.recognizedWords;
              if (onRecognitionResult != null) {
                onRecognitionResult(_recognizedText);
              }
            },
            localeId: 'en_IN', // Indian English
            listenFor: const Duration(seconds: 15),
            pauseFor: const Duration(seconds: 3),
          );
        }
      } catch (e) {
        print('Error starting to listen: $e');
      }
    }
  }

  void stopListening() {
    if (_isListening) {
      _speechToText.stop();
      _isListening = false;
    }
  }

  String getRecognizedText() {
    return _recognizedText;
  }

  bool isListening() {
    return _isListening;
  }

  void clearRecognizedText() {
    _recognizedText = '';
  }

  Future<List<Map<String, dynamic>>> searchByVoice(String query) async {
    try {
      return await ragService.search(query);
    } catch (e) {
      return [
        {
          'title': 'Voice Search Error',
          'content': 'Unable to process voice search: $e',
          'category': 'Error',
          'score': 0.0,
        }
      ];
    }
  }

  List<String> getVoiceCommands() {
    return [
      'How to weed maize?',
      'When to harvest beans?',
      'How to dry cassava?',
      'How to control cassava mosaic?',
      'How to control bean weevils?',
      'How to avoid red color on bean leaves?',
    ];
  }
}