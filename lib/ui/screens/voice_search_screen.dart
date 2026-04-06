import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
import 'package:ai_based_farmer_query_app/services/rag_service.dart';
import 'package:ai_based_farmer_query_app/services/voice_search_service.dart';
import 'package:ai_based_farmer_query_app/ui/widgets/search_result_item.dart';
import 'package:ai_based_farmer_query_app/ui/widgets/loading_indicator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:ai_based_farmer_query_app/services/language_service.dart';
import 'package:ai_based_farmer_query_app/theme/app_colors.dart';

class VoiceSearchScreen extends StatefulWidget {
  const VoiceSearchScreen({super.key});

  @override
  State<VoiceSearchScreen> createState() => _VoiceSearchScreenState();
}

class _VoiceSearchScreenState extends State<VoiceSearchScreen>
    with SingleTickerProviderStateMixin {
  final stt.SpeechToText _speechToText = stt.SpeechToText();
  bool _hasSpeech = false;
  bool _isListening = false;
  String _spokenText = '';
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';
  String _lastQuery = '';
  String _selectedLocale = 'en_IN'; // Default to Indian English
  late AnimationController _animationController;
  final LanguageService _languageService = LanguageService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _initSpeech();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _speechToText.stop();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    try {
      if (!kIsWeb) {
        final status = await Permission.microphone.request();
        if (status != PermissionStatus.granted) {
          setState(() {
            _errorMessage = 'Microphone permission is required for voice search.';
          });
          return;
        }
      }
      
      bool available = await _speechToText.initialize(
        onStatus: (status) {
          print('Speech status: $status');
          if (!mounted) return;
          if (status == 'listening') {
            setState(() => _isListening = true);
          } else if (status == 'notListening') {
            setState(() => _isListening = false);
          }
        },
        onError: (error) {
          print('Speech error: $error');
          if (!mounted) return;
          setState(() {
            _errorMessage = 'Speech Error: ${error.errorMsg}';
            _isListening = false;
          });
        },
      );
      
      if (!mounted) return;
      setState(() {
        _hasSpeech = available;
        if (!available) {
          _errorMessage = 'Speech recognition is not available on this browser/device.';
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error initializing speech recognition: $e';
        _hasSpeech = false;
      });
    }
  }

  Future<void> _startListening() async {
    if (!_speechToText.isAvailable || _isListening) return;

    setState(() {
      _isListening = true;
      _spokenText = 'Listening...';
      _searchResults = [];
      _errorMessage = '';
    });

    try {
      await _speechToText.listen(
        onResult: (result) {
          String text = result.recognizedWords;
          // Apply fast heuristic translation for real-time UI feedback
          if (_selectedLocale.startsWith('ta')) {
            text = _languageService.translateTamilTerms(text);
          }
          
          if (!mounted) return;
          setState(() {
            _spokenText = text;
          });

          if (result.finalResult) {
            _stopListening();
            _performSearch(result.recognizedWords); // Perform full search with original recognition for best accuracy
          }
        },
        listenMode: stt.ListenMode.dictation,
        localeId: _selectedLocale,
        listenFor: const Duration(seconds: 20),
        pauseFor: const Duration(seconds: 5),
        partialResults: true,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isListening = false;
        _errorMessage = 'Error starting to listen: $e';
      });
    }
  }

  Future<void> _stopListening() async {
    await _speechToText.stop();
    if (!mounted) return;
    setState(() {
      _isListening = false;
    });
    
    // Only search if we actually got some text that isn't the placeholder
    if (_spokenText.isNotEmpty && _spokenText != 'Listening...') {
      _performSearch(_spokenText);
    } else {
      // If still "Listening...", it means no speech was recognized
      _spokenText = ''; // Clear the placeholder
    }
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No speech recognized. Please try again.')),
      );
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _searchResults = [];
      _errorMessage = '';
      _lastQuery = query;
    });

    try {
      final ragService = Provider.of<RAGService>(context, listen: false);
      
      final results = await ragService.searchWithLanguageSupport(
        query,
        preferredLanguage: _selectedLocale.startsWith('ta') ? 'ta' : 'en',
      );
      
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isLoading = false;
        if (results.isEmpty) {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No specific information found for "$query".')),
          );
        }
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error performing search: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverToBoxAdapter(
                child: Column(
                  children: [
                    // Language Toggle
                    _buildLanguageToggle(),
                    
                    const SizedBox(height: 10),

                    // Voice Input Section
                    _buildVoiceInputSection(),
                    
                    const SizedBox(height: 20),
                    
                    // Instructions
                    _buildInstructions(),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            
            // Results Section
            _buildResultsSliver(),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSliver() {
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: LoadingIndicator()),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Center(
            child: Text(
              _errorMessage,
              style: const TextStyle(color: Colors.red),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    if (_searchResults.isEmpty) {
      if (_lastQuery.isNotEmpty) {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.search_off,
                  size: 64,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No results found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Query: "$_lastQuery"',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        );
      } else {
        return SliverFillRemaining(
          hasScrollBody: false,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.mic,
                  size: 80,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Ready to Listen',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tap the microphone to start your voice query',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.black38,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }

    return SliverPadding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            if (index == 0) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(
                  'Results for: "$_lastQuery"',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              );
            }
            final result = _searchResults[index - 1];
            return SearchResultItem(
              title: result['title'] ?? 'Query Result',
              description: result['content'] ?? result['description'] ?? '',
              category: result['category'] ?? 'General',
              onTap: () {
                _showResultDetails(result);
              },
            );
          },
          childCount: _searchResults.length + 1,
        ),
      ),
    );
  }

  Widget _buildVoiceInputSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Microphone Icon and Status
            _buildMicrophoneStatus(),
            
            const SizedBox(height: 20),
            
            // Voice Input Text
            _buildVoiceInputText(),
            
            const SizedBox(height: 20),
            
            // Action Buttons
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildMicrophoneStatus() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing rings for resonance effect
        if (_isListening) ...[
          _buildPulseRing(1.2, 0.6),
          _buildPulseRing(1.5, 0.3),
        ],
        
        // Main Mic Button
        GestureDetector(
          onTap: _isListening ? _stopListening : _startListening,
          child: Hero(
            tag: 'mic_button',
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: _isListening
                      ? [const Color(0xFFFF5252), const Color(0xFFD32F2F)]
                      : [const Color(0xFF43A047), const Color(0xFF2E7D32)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening ? Colors.red : Colors.green).withOpacity(0.4),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.stop_rounded : Icons.mic_rounded,
                size: 45,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPulseRing(double scaleFactor, double opacity) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_animationController.value * scaleFactor),
          child: Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: (_isListening ? Colors.red : Colors.green).withOpacity(opacity * (1.0 - _animationController.value)),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVoiceInputText() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.black.withOpacity(0.05)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            _isListening ? 'LISTENING' : 'TAP TO SPEAK',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
              color: _isListening ? Colors.red : Colors.grey,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _spokenText.isNotEmpty
                ? _spokenText
                : 'Your query will appear here...',
            style: TextStyle(
              fontSize: _spokenText.isNotEmpty ? 18 : 14,
              fontWeight: _spokenText.isNotEmpty ? FontWeight.w600 : FontWeight.normal,
              color: _spokenText.isNotEmpty ? AppColors.primaryBlue : Colors.black26,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Start Listening Button
        ElevatedButton(
          onPressed: _hasSpeech && !_isListening ? _startListening : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4CAF50),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.mic, size: 20),
              SizedBox(width: 8),
              Text('Start Listening'),
            ],
          ),
        ),
        
        // Stop Listening Button
        ElevatedButton(
          onPressed: _isListening ? _stopListening : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFF5252),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Icon(Icons.stop, size: 20),
              SizedBox(width: 8),
              Text('Stop'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Voice Search Tips',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          _buildInstructionItem('Speak clearly and naturally'),
          _buildInstructionItem('Use specific farming terms'),
          _buildInstructionItem('Try queries like: "How to treat crop disease?"'),
          _buildInstructionItem('Choose Tamil for local language support'),
          _buildInstructionItem('You can speak in English or Tamil'),
        ],
      ),
    );
  }

  Widget _buildInstructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 16, color: Color(0xFF4CAF50)),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Voice Language:',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: [
              _buildLocaleButton('English', 'en_IN'),
              const SizedBox(width: 8),
              _buildLocaleButton('தமிழ்', 'ta_IN'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocaleButton(String label, String locale) {
    bool isSelected = _selectedLocale == locale;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected && !_isListening) {
          setState(() {
            _selectedLocale = locale;
            _errorMessage = '';
          });
        }
      },
      selectedColor: const Color(0xFF4CAF50),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  void _showResultDetails(Map<String, dynamic> result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(result['title'] ?? 'Query Result'),
        content: SingleChildScrollView(
          child: Text(result['content'] ?? result['description'] ?? ''),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}