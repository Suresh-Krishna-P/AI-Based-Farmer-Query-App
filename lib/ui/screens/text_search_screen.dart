import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ai_based_farmer_query_app/services/text_search_service.dart';
import 'package:ai_based_farmer_query_app/services/rag_service.dart';
import 'package:ai_based_farmer_query_app/ui/widgets/search_result_item.dart';
import 'package:ai_based_farmer_query_app/ui/widgets/loading_indicator.dart';
import 'package:ai_based_farmer_query_app/theme/app_colors.dart';
import 'package:provider/provider.dart';

class TextSearchScreen extends StatefulWidget {
  const TextSearchScreen({super.key});

  @override
  State<TextSearchScreen> createState() => _TextSearchScreenState();
}

class _TextSearchScreenState extends State<TextSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  List<dynamic> _searchResults = [];
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchResults = [];
      _errorMessage = '';
    });

    try {
      final ragService = Provider.of<RAGService>(context, listen: false);
      final results = await ragService.searchWithExternalData(query, cropType: 'Wheat', region: 'India', location: 'Delhi');
      
      if (!mounted) return;
      setState(() {
        _searchResults = results;
        _isLoading = false;
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
      backgroundColor: AppColors.secondaryGray,
      appBar: AppBar(
        title: const Text('Knowledge Finder'),
        centerTitle: true,
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Search Input Section
                  _buildSearchInput(),
                  
                  const SizedBox(height: 24),
                  
                  // Suggestions Section
                  _buildSuggestions(),
                ],
              ),
            ),
          ),
          
          // Results Header
          if (_searchResults.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                child: Row(
                  children: [
                    const Icon(Icons.auto_graph, size: 14, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      'Found ${_searchResults.length} matching records',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 0.5),
                    ),
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
    if (_isLoading) {
      return const SliverFillRemaining(
        child: Center(child: CircularProgressIndicator(color: AppColors.primaryBlue)),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
              const SizedBox(height: 12),
              Text(_errorMessage, style: const TextStyle(color: Colors.redAccent), textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    if (_searchResults.isEmpty && _searchController.text.isNotEmpty) {
      return SliverFillRemaining(
        hasScrollBody: false,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
            const SizedBox(height: 16),
            const Text('No records found', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black26)),
            const Text('Try broader keywords (e.g. Rice)', style: TextStyle(color: Colors.black26)),
          ],
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final result = _searchResults[index];
            return SearchResultItem(
              title: result['title'] ?? 'Query Result',
              description: result['content'] ?? result['description'] ?? '',
              category: result['category'] ?? 'General',
              onTap: () => _showResultDetails(result),
            );
          },
          childCount: _searchResults.length,
        ),
      ),
    );
  }

  Widget _buildSearchInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.primaryBlue),
        decoration: InputDecoration(
          hintText: 'Ask about crops, pests, or soil...',
          hintStyle: const TextStyle(color: Colors.black26, fontWeight: FontWeight.normal),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primaryBlue),
          suffixIcon: _searchController.text.isNotEmpty 
            ? IconButton(
                icon: const Icon(Icons.close_rounded, color: Colors.grey),
                onPressed: () {
                  _searchController.clear();
                  setState(() { _searchResults = []; _errorMessage = ''; });
                },
              )
            : IconButton(
                icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.primaryBlue),
                onPressed: () => _performSearch(_searchController.text),
              ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
        onSubmitted: _performSearch,
      ),
    );
  }

  Widget _buildSuggestions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'SMART SUGGESTIONS',
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _buildSuggestionChip('Treat tomato late blight'),
            _buildSuggestionChip('High yield rice'),
            _buildSuggestionChip('Soil NPK for Mango'),
            _buildSuggestionChip('Cotton pests'),
            _buildSuggestionChip('HD-2967 Wheat'),
          ],
        ),
      ],
    );
  }

  Widget _buildSuggestionChip(String suggestion) {
    return InkWell(
      onTap: () {
        _searchController.text = suggestion;
        _performSearch(suggestion);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black.withOpacity(0.05)),
        ),
        child: Text(
          suggestion,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.primaryBlue),
        ),
      ),
    );
  }

  void _showResultDetails(Map<String, dynamic> result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 24),
            Text(result['title'] ?? 'Record Detail', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: AppColors.primaryBlue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
              child: Text(result['category']?.toUpperCase() ?? 'GENERAL', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.primaryBlue)),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Text(
                  result['content'] ?? result['description'] ?? '',
                  style: const TextStyle(fontSize: 15, height: 1.8, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Got it'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}