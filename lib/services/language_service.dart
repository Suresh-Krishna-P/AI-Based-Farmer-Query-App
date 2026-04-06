import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart' show kIsWeb;

/// Tamil Language Support Service (Free APIs only)
class LanguageService {
  /// Free translation API endpoints
  static const String libreTranslateUrl = 'https://libretranslate.de/translate';
  static const String myMemoryUrl = 'https://api.mymemory.translated.net/get';

  /// Detect language of input text using heuristic approach
  Future<String> detectLanguage(String text) async {
    try {
      // Simple heuristic-based detection for Tamil
      return _detectLanguageHeuristic(text);
    } catch (e) {
      return 'en'; // Default to English
    }
  }

  /// Translate text to English for processing using free APIs
  Future<String> translateToEnglish(String text, String sourceLanguage) async {
    try {
      if (sourceLanguage == 'ta') {
        return await _translateToEnglishFree(text);
      } else {
        return text; // Already in English or other language
      }
    } catch (e) {
      return text;
    }
  }

  /// Translate response back to Tamil using free APIs
  Future<String> translateToTamil(String text) async {
    try {
      return await _translateToTamilFree(text);
    } catch (e) {
      return text;
    }
  }

  /// Helper to handle proxying on Web
  String _getProxyUrl(String url) {
    if (kIsWeb) {
      return 'http://localhost:3001/proxy?url=${Uri.encodeComponent(url)}';
    }
    return url;
  }

  /// Translate to English using LibreTranslate (free)
  Future<String> _translateToEnglishFree(String text) async {
    try {
      final url = _getProxyUrl(libreTranslateUrl);
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': text,
          'source': 'ta',
          'target': 'en',
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translatedText'];
      } else {
        throw Exception('Translation failed');
      }
    } catch (e) {
      // Fallback to MyMemory API
      return await _translateToEnglishMyMemory(text);
    }
  }

  /// Translate to Tamil using LibreTranslate (free)
  Future<String> _translateToTamilFree(String text) async {
    try {
      final url = _getProxyUrl(libreTranslateUrl);
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'q': text,
          'source': 'en',
          'target': 'ta',
          'format': 'text',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translatedText'];
      } else {
        throw Exception('Translation failed');
      }
    } catch (e) {
      // Fallback to MyMemory API
      return await _translateToTamilMyMemory(text);
    }
  }

  /// Fallback translation using MyMemory API (free)
  Future<String> _translateToEnglishMyMemory(String text) async {
    final rawUrl = '$myMemoryUrl?q=${Uri.encodeComponent(text)}&langpair=ta|en';
    final url = _getProxyUrl(rawUrl);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['responseData']['translatedText'];
    } else {
      throw Exception('Translation failed');
    }
  }

  /// Fallback translation to Tamil using MyMemory API (free)
  Future<String> _translateToTamilMyMemory(String text) async {
    final rawUrl = '$myMemoryUrl?q=${Uri.encodeComponent(text)}&langpair=en|ta';
    final url = _getProxyUrl(rawUrl);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['responseData']['translatedText'];
    } else {
      throw Exception('Translation failed');
    }
  }

  /// Heuristic-based language detection for Tamil
  Future<String> _detectLanguageHeuristic(String text) async {
    final tamilChars = RegExp(r'[\u0B80-\u0BFF]');
    final hasTamil = tamilChars.hasMatch(text);
    
    if (hasTamil) {
      return 'ta';
    } else {
      return 'en';
    }
  }

  /// Tamil agricultural terminology mapping for basic queries
  static final Map<String, String> tamilTerms = {
    // Common agricultural terms
    'அரிசி': 'rice',
    'கோதுமை': 'wheat', 
    'சோளம்': 'corn',
    'பருப்பு': 'pulse',
    'காய்கறி': 'vegetable',
    'புழு': 'worm',
    'பூச்சி': 'insect',
    'நோய்': 'disease',
    'பூஞ்சை': 'fungus',
    'பயிர்': 'crop',
    'உரம்': 'fertilizer',
    'மண்': 'soil',
    'நீர்': 'water',
    'விதை': 'seed',
    'அறுவடை': 'harvest',
    'பராமரிப்பு': 'maintenance',
    'பாதுகாப்பு': 'protection',
    'பரிசோதனை': 'test',
    'முடிவு': 'solution',
    'ஆலோசனை': 'advice',
    'உதவி': 'help',
    'பயிர்த்தொழில்': 'farming',
    'உழவு': 'cultivation',
    'நிலம்': 'land',
    'வயல்': 'field',
    'தோட்டம்': 'garden',
    'பயிர்ப்பரப்பு': 'farmland',
    'உருளைக்கிழங்கு': 'potato',
    'தக்காளி': 'tomato',
    'மிளகு': 'chili',
    'பூண்டு': 'garlic',
    'வெங்காயம்': 'onion',
    'மஞ்சள்': 'turmeric',
    'இஞ்சி': 'ginger',
    'கரும்பு': 'sugar cane',
    'தேங்காய்': 'coconut',
    'வாழை': 'banana',
    'மாம்பழம்': 'mango',
    'பப்பாளி': 'papaya',
    'பலாப்பழம்': 'jackfruit',
    'முந்திரி': 'cashew',
    'எலுமிச்சை': 'lemon',
    'மிளகு': 'pepper',
    'கற்பூரம்': 'camphor',
    'வேர்க்கடலை': 'groundnut',
    'பயறு': 'bean',
    'பட்டாணி': 'peas',
    'கத்திரிக்காய்': 'brinjal',
    'கீரை': 'greens',
    'பூசணிக்காய்': 'pumpkin',
    'வெண்டைக்காய்': 'okra',
    'கோழி': 'chicken',
    'ஆடு': 'goat',
    'மாடு': 'cow',
    'எருமை': 'buffalo',
    'ஆலை': 'factory',
    'காலாவஸ்தை': 'weather',
    'மழை': 'rain',
    'சூரியன்': 'sun',
    'மேகம்': 'cloud',
    'காற்று': 'wind',
    'குளிர்': 'cold',
    'வெப்பம்': 'heat',
    'சூடு': 'warmth',
    'குளிர்ச்சி': 'cold',
    'குளிர்காலம்': 'winter',
    'கோடைகாலம்': 'summer',
    'மழைக்காலம்': 'rainy season',
    'வறட்சி': 'drought',
    'வெள்ளம்': 'flood',
    'காலநிலை மாற்றம்': 'climate change',
    'இயற்கை': 'nature',
    'சுற்றுச்சூழல்': 'environment',
    'பூமி': 'earth',
    'வானம்': 'sky',
    'நட்சத்திரம்': 'star',
    'சந்திரன்': 'moon',
    'சூரியன்': 'sun',
    'கிரகம்': 'planet',
    'உற்பத்தி': 'production',
    'அறுவடை': 'harvest',
    'கோது': 'reaping',
    'அறுத்தெடுத்தல்': 'cutting',
    'சேகரித்தல்': 'collection',
    'சேமிப்பு': 'storage',
    'பாதுகாப்பு': 'preservation',
    'பராமரிப்பு': 'maintenance',
    'பராமரித்தல்': 'maintaining',
    'பராமரிப்பாளர்': 'caretaker',
    'பராமரிக்க': 'to maintain',
  };

  /// Simple Tamil to English translation for basic terms
  String translateTamilTerms(String text) {
    String translated = text;
    
    tamilTerms.forEach((tamil, english) {
      translated = translated.replaceAll(tamil, english);
    });
    
    return translated;
  }

  /// Check if text contains Tamil characters
  bool isTamilText(String text) {
    final tamilChars = RegExp(r'[\u0B80-\u0BFF]');
    return tamilChars.hasMatch(text);
  }
}