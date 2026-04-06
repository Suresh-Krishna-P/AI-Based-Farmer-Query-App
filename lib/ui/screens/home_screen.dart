import 'package:flutter/material.dart';
import 'package:ai_based_farmer_query_app/ui/screens/text_search_screen.dart';
import 'package:ai_based_farmer_query_app/ui/screens/voice_search_screen.dart';
import 'package:ai_based_farmer_query_app/ui/screens/image_search_screen.dart';
import 'package:ai_based_farmer_query_app/ui/screens/advisory_screen.dart';
import 'package:ai_based_farmer_query_app/theme/app_colors.dart';
import 'package:ai_based_farmer_query_app/ui/widgets/search_option_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: AppColors.secondaryGray,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // 1. STUNNING SLIVER APP BAR
            SliverAppBar(
              expandedHeight: 220,
              floating: false,
              pinned: true,
              stretch: true,
              backgroundColor: AppColors.primaryBlue,
              flexibleSpace: FlexibleSpaceBar(
                stretchModes: const [
                  StretchMode.zoomBackground,
                  StretchMode.blurBackground,
                  StretchMode.fadeTitle,
                ],
                title: const Text(
                  'Farmer Support',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                ),
                background: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Professional background pattern or image can go here
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF004D40),
                            AppColors.primaryBlue,
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Icon(
                        Icons.agriculture,
                        size: 200,
                        color: Colors.white.withOpacity(0.05),
                      ),
                    ),
                    _buildHeroHeader(),
                  ],
                ),
              ),
            ),

            // 2. MAIN DASHBOARD CONTENT
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionHeader('Smart Search Options'),
                          const SizedBox(height: 16),
                          
                          // Grid of Action Cards
                          _buildSearchGrid(context),
                          
                          const SizedBox(height: 32),
                          
                          _buildSectionHeader('Today\'s Overview'),
                          const SizedBox(height: 16),
                          
                          _buildInfoHighlight(),
                          
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroHeader() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Hero(
                tag: 'gov_logo',
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 10)],
                  ),
                  child: const Icon(Icons.account_balance, size: 32, color: AppColors.primaryBlue),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI-Powered Agricultural Assistant',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Ready to Assist',
                      style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 40), // Spacing for title overlap
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryBlue,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildSearchGrid(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.95,
      children: [
        _animatedCard(
          0,
          SearchOptionCard(
            title: 'Text Search',
            description: 'Database & RAG lookup',
            icon: Icons.search_rounded,
            color: const Color(0xFF43A047),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const TextSearchScreen())),
          ),
        ),
        _animatedCard(
          1,
          SearchOptionCard(
            title: 'Voice Query',
            description: 'Speech-to-Text AI',
            icon: Icons.mic_external_on,
            color: const Color(0xFF1E88E5),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const VoiceSearchScreen())),
          ),
        ),
        _animatedCard(
          2,
          SearchOptionCard(
            title: 'Vision Scan',
            description: 'Disease Detection AI',
            icon: Icons.document_scanner_outlined,
            color: const Color(0xFFFB8C00),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const ImageSearchScreen())),
          ),
        ),
        _animatedCard(
          3,
          SearchOptionCard(
            title: 'Advisory',
            description: 'Personalized Expert advice',
            icon: Icons.auto_awesome,
            color: const Color(0xFF8E24AA),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const AdvisoryScreen())),
          ),
        ),
      ],
    );
  }

  Widget _animatedCard(int index, Widget child) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final delay = index * 0.1;
        final animValue = Curves.elasticOut.transform(
          ((_controller.value - delay).clamp(0.0, 1.0) / (1.0 - delay)).clamp(0.0, 1.0)
        );
        return Transform.scale(
          scale: 0.8 + (0.2 * animValue),
          child: Opacity(opacity: animValue, child: child),
        );
      },
      child: child,
    );
  }

  Widget _buildInfoHighlight() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryBlue, Color(0xFF0D47A1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.info_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'AI Engine Active',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'The RAG system is utilizing comprehensive local datasets for optimal offline-first performance.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _buildModernChip('AgroQA CSV', Colors.white24),
              _buildModernChip('External API', Colors.white24),
              _buildModernChip('Localized', Colors.white24),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernChip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}