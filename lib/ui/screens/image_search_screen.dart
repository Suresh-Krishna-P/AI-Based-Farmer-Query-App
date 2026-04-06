import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:ai_based_farmer_query_app/services/image_search_service.dart';
import 'package:ai_based_farmer_query_app/services/rag_service.dart';
import 'package:ai_based_farmer_query_app/ui/widgets/search_result_item.dart';
import 'package:ai_based_farmer_query_app/ui/widgets/loading_indicator.dart';
import 'package:ai_based_farmer_query_app/theme/app_colors.dart';
import 'package:provider/provider.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;

class ImageSearchScreen extends StatefulWidget {
  const ImageSearchScreen({super.key});

  @override
  State<ImageSearchScreen> createState() => _ImageSearchScreenState();
}

class _ImageSearchScreenState extends State<ImageSearchScreen> with SingleTickerProviderStateMixin {
  XFile? _selectedImage;
  bool _isAnalyzing = false;
  List<dynamic> _searchResults = [];
  String _errorMessage = '';
  String _analysisResult = '';
  int _fileSize = 0;
  String? _simulatedLabel;
  late AnimationController _animationController;

  final List<String> _simulatedDiseases = [
    'Apple : Scab',
    'Tomato : Late Blight',
    'Corn : Common Rust',
    'Grape : Black Rot',
    'Orange : Haunglongbing',
    'Potato : Early Blight',
  ];

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    if (!kIsWeb) {
      PermissionStatus status;
      if (source == ImageSource.camera) {
        status = await Permission.camera.request();
      } else {
        status = await Permission.photos.request();
        if (status.isDenied) {
          status = await Permission.storage.request(); 
        }
      }
      
      if (status != PermissionStatus.granted) {
        setState(() {
          _errorMessage = 'Permission is required to access your ${source == ImageSource.camera ? "camera" : "gallery"}.';
        });
        return;
      }
    }

    final XFile? pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (!mounted) return;
    if (pickedFile != null) {
      int size = 0;
      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        size = bytes.length;
      } else {
        size = File(pickedFile.path).lengthSync();
      }

      setState(() {
        _selectedImage = pickedFile;
        _fileSize = size;
        _searchResults = [];
        _errorMessage = '';
        _analysisResult = '';
      });

      await _analyzeImage(_selectedImage!);
    }
  }

  Future<void> _analyzeImage(XFile imageFile) async {
    setState(() {
      _isAnalyzing = true;
      _errorMessage = '';
    });

    try {
      final imageSearchService = Provider.of<ImageSearchService>(context, listen: false);
      final ragService = Provider.of<RAGService>(context, listen: false);
      
      // Use simulated label if selected, otherwise try filename matching
      AnalysisResult analysis;
      if (_simulatedLabel != null) {
        analysis = await imageSearchService.analyzeWithLabel(imageFile, _simulatedLabel!);
      } else {
        analysis = await imageSearchService.analyzeImage(imageFile);
      }
      
      setState(() {
        _analysisResult = analysis.report;
      });

      // Search using specific keywords for higher accuracy
      final results = await ragService.search(analysis.searchKeywords);
      
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isAnalyzing = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Error analyzing image: $e';
        _isAnalyzing = false;
      });
    }
  }

  Future<void> _captureImage() async {
    _pickImage(ImageSource.camera);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Search'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16.0),
            sliver: SliverToBoxAdapter(
              child: Column(
                children: [
                  // Image Selection Section
                  _buildImageSelectionSection(),
                  
                  if (_selectedImage != null) ...[
                    const SizedBox(height: 24),
                    _buildImagePreview(),
                  ],
                  
                  if (_isAnalyzing || _analysisResult.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    _buildAnalysisResultPresentation(),
                  ],
                  
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
          
          // Results Section
          _buildResultsSliver(),
        ],
      ),
    );
  }

  Widget _buildResultsSliver() {
    if (_isAnalyzing) {
      return const SliverToBoxAdapter(child: LoadingIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return SliverToBoxAdapter(
        child: Center(
          child: Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (_searchResults.isEmpty && _selectedImage != null) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image_search, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text('No results found', style: TextStyle(fontSize: 18, color: Colors.black54)),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isNotEmpty) {
      return SliverPadding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        sliver: SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              if (index == 0) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    'Results based on image analysis',
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

    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_search, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('No Image Selected', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black54)),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSelectionSection() {
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
            const Text(
              'Select or Capture an Image',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Upload a photo of your crops, soil, or any farming issue to get AI-powered analysis and recommendations.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Gallery Button
                _buildSelectionButton(
                  icon: Icons.photo_library,
                  label: 'From Gallery',
                  onPressed: () => _pickImage(ImageSource.gallery),
                ),
                
                // Camera Button
                _buildSelectionButton(
                  icon: Icons.camera_alt,
                  label: 'Take Photo',
                  onPressed: _captureImage,
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Simulation Dropdown
            const Divider(),
            const SizedBox(height: 10),
            const Text(
              'Or Simulate Detection (for Testing)',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                hint: const Text('Select a disease to simulate'),
                value: _simulatedLabel,
                isExpanded: true,
                underline: Container(),
                items: _simulatedDiseases.map((String disease) {
                  return DropdownMenuItem<String>(
                    value: disease,
                    child: Text(disease, style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _simulatedLabel = value;
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4CAF50), Color(0xFF81C784)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(icon, size: 32, color: Colors.white),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.black54,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (_selectedImage != null)
              kIsWeb 
                ? Image.network(_selectedImage!.path, width: double.infinity, height: double.infinity, fit: BoxFit.cover)
                : Image.file(File(_selectedImage!.path), width: double.infinity, height: double.infinity, fit: BoxFit.cover)
            else
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.add_a_photo_outlined, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('Capture or Upload Crop Image', style: TextStyle(color: Colors.grey)),
                ],
              ),
            
            // AI SCANNING ANIMATION
            if (_isAnalyzing)
              _buildScanningOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildScanningOverlay() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Stack(
          children: [
            // Scanning Line
            Positioned(
              top: _animationController.value * 300,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.greenAccent.withOpacity(0.8),
                      blurRadius: 15,
                      spreadRadius: 2,
                    ),
                  ],
                  gradient: LinearGradient(
                    colors: [
                      Colors.greenAccent.withOpacity(0),
                      Colors.greenAccent,
                      Colors.greenAccent.withOpacity(0),
                    ],
                  ),
                ),
              ),
            ),
            // Translucent overlay
            Container(color: Colors.black12),
          ],
        );
      },
    );
  }

  Widget _buildAnalysisResultPresentation() {
    if (_isAnalyzing) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
            ),
            const SizedBox(width: 16),
            const Text(
              'Artificial Intelligence Analyzing...',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primaryBlue),
            ),
          ],
        ),
      );
    }

    if (_analysisResult.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.analytics_outlined, color: Colors.white, size: 24),
              const SizedBox(width: 12),
              const Text(
                'AI ANALYSIS REPORT',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1.5, fontSize: 12),
              ),
              const Spacer(),
              _buildHealthyBadge(_analysisResult.toLowerCase().contains('healthy')),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _analysisResult,
            style: const TextStyle(color: Colors.white, fontSize: 13, height: 1.6),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthyBadge(bool isHealthy) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: isHealthy ? Colors.greenAccent.withOpacity(0.2) : Colors.redAccent.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: isHealthy ? Colors.greenAccent : Colors.redAccent, width: 1),
      ),
      child: Text(
        isHealthy ? 'HEALTHY' : 'DISEASE DETECTED',
        style: TextStyle(
          color: isHealthy ? Colors.greenAccent : Colors.redAccent,
          fontSize: 9,
          fontWeight: FontWeight.bold,
        ),
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