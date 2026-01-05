import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../engine/auth_engine.dart';
import 'game_screen.dart';
import 'four_player_screen.dart';
import 'online_setup_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';
import 'puzzle_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainMenuScreen extends StatefulWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  State<MainMenuScreen> createState() => _MainMenuScreenState();
}

class _MainMenuScreenState extends State<MainMenuScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthEngine>(context);
    
    return Scaffold(
      body: Stack(
        children: [
          // Animated Nebula Background
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return CustomPaint(
                  painter: NebulaPainter(_controller.value),
                );
              },
            ),
          ),

          // Main Content with Slivers
          CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context, auth),
              
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildHeroParallax(),
                      const SizedBox(height: 32),
                      _buildQuickActionGrid(context, auth),
                      const SizedBox(height: 40),
                      _buildSectionTitle('BATTLE ARENAS'),
                      const SizedBox(height: 20),
                      _buildGameModeList(context),
                      const SizedBox(height: 100), // Bottom padding for content
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Floating Decorative Accent
          Positioned(
            bottom: -50,
            right: -50,
            child: Icon(
              Icons.grid_4x4,
              size: 200,
              color: Colors.white.withOpacity( 0.02),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, AuthEngine auth) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(color: Colors.transparent),
        titlePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        centerTitle: false,
        title: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _scrollOffset > 50 ? 1.0 : 0.0,
          child: Text(
            'CHESS MASTER PRO',
            style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900,
              fontSize: 18,
              letterSpacing: 2,
              color: Colors.white,
            ),
          ),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.settings_outlined, color: Colors.white70),
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
        ),
        _buildUserAction(context, auth),
        const SizedBox(width: 12),
      ],
    );
  }

  Widget _buildUserAction(BuildContext context, AuthEngine auth) {
    if (!auth.isAuthenticated) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: ElevatedButton(
          onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6366F1).withOpacity( 0.1),
            foregroundColor: const Color(0xFF6366F1),
            side: const BorderSide(color: Color(0xFF6366F1), width: 1),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            elevation: 0,
          ),
          child: const Text('JOIN NOW', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
        ),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFFEC4899)]),
        ),
        child: CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFF0A0A0E),
          child: SvgPicture.string(
            _generateAvatarPlaceholder(auth.currentUser!.username),
            width: 22,
          ),
        ),
      ),
    );
  }

  Widget _buildHeroParallax() {
    return Container(
      height: 240,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity( 0.3),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Stack(
          children: [
            // Parallax image
            Positioned(
              top: -(_scrollOffset * 0.2),
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/chess_hero.png',
                height: 350,
                fit: BoxFit.cover,
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    const Color(0xFF0F172A).withOpacity( 0.95),
                    const Color(0xFF1E293B).withOpacity( 0.4),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'SEASON 1 LIVE',
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'DOMINATE THE\nNEXUS GRID',
                    style: GoogleFonts.outfit(
                      fontSize: 32,
                      height: 1.1,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionGrid(BuildContext context, AuthEngine auth) {
    return Row(
      children: [
        Expanded(
          child: _buildStateCard(
            title: 'Rankings',
            subtitle: 'Global ELO',
            icon: Icons.auto_graph,
            color: const Color(0xFFF59E0B),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildStateCard(
            title: 'Intelligence',
            subtitle: 'Your Stats',
            icon: Icons.analytics_outlined,
            color: const Color(0xFF3B82F6),
            onTap: () {
              if (auth.isAuthenticated) {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              } else {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              }
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStateCard({required String title, required String subtitle, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity( 0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity( 0.08)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity( 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 20),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(subtitle, style: const TextStyle(color: Colors.white38, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildGameModeList(BuildContext context) {
    return Column(
      children: [
        _buildModeTile(
          context,
          'Duel of Minds',
          'Classical 1v1 Battle',
          Icons.shield_outlined,
          const Color(0xFF6366F1),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen())),
        ),
        const SizedBox(height: 16),
        _buildModeTile(
          context,
          'Quantum Arena',
          'Global Online Match',
          Icons.blur_on,
          const Color(0xFF10B981),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineSetupScreen())),
        ),
        const SizedBox(height: 16),
        _buildModeTile(
          context,
          'Dynasty Warfare',
          'Four Player Conflict',
          Icons.webhook,
          const Color(0xFFEC4899),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FourPlayerGameScreen())),
        ),
        const SizedBox(height: 16),
        _buildModeTile(
          context,
          'Tactical Breach',
          'Daily Puzzle Challenge',
          Icons.extension,
          const Color(0xFFF59E0B),
          () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PuzzleScreen())),
        ),
      ],
    );
  }

  Widget _buildModeTile(BuildContext context, String title, String subtitle, IconData icon, Color accent, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity( 0.04),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: Colors.white.withOpacity( 0.08)),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background accent glow
              Positioned(
                right: -20,
                bottom: -20,
                child: Icon(icon, size: 100, color: accent.withOpacity( 0.05)),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Container(
                      height: 54,
                      width: 54,
                      decoration: BoxDecoration(
                        color: accent.withOpacity( 0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accent.withOpacity( 0.2)),
                      ),
                      child: Icon(icon, color: accent, size: 28),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            subtitle,
                            style: const TextStyle(fontSize: 12, color: Colors.white38),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.white12),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 3,
            color: const Color(0xFF6366F1),
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(child: Divider(color: Colors.white10)),
      ],
    );
  }

  String _generateAvatarPlaceholder(String seed) {
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><rect width="100" height="100" fill="#2c3e50"/><text x="50" y="65" font-size="50" text-anchor="middle" fill="#ecf0f1">${seed[0].toUpperCase()}</text></svg>';
  }
}

class NebulaPainter extends CustomPainter {
  final double animationValue;
  NebulaPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 100);

    // Deep blue nebula
    paint.color = const Color(0xFF6366F1).withOpacity( 0.08);
    canvas.drawCircle(
      Offset(
        size.width * (0.5 + 0.3 * math.sin(animationValue * 2 * math.pi)),
        size.height * (0.3 + 0.2 * math.cos(animationValue * 2 * math.pi)),
      ),
      size.width * 0.6,
      paint,
    );

    // Purple nebula
    paint.color = const Color(0xFFEC4899).withOpacity( 0.05);
    canvas.drawCircle(
      Offset(
        size.width * (0.2 + 0.4 * math.cos(animationValue * 2 * math.pi)),
        size.height * (0.7 + 0.3 * math.sin(animationValue * 2 * math.pi)),
      ),
      size.width * 0.5,
      paint,
    );
  }

  @override
  bool shouldRepaint(NebulaPainter oldDelegate) => true;
}
