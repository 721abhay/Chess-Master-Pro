import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/auth_engine.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthEngine>(context);
    final user = auth.currentUser;

    if (user == null) {
      return const Scaffold(backgroundColor: Color(0xFF0F0F13), body: Center(child: Text('Unauthorized access')));
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: Stack(
        children: [
          // Background accents
          _buildBackgroundAccents(),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(context, auth),
                  const SizedBox(height: 40),
                  _buildProfileCard(user),
                  const SizedBox(height: 32),
                  const _SectionHeader(title: 'BATTLES STATS'),
                  const SizedBox(height: 16),
                  _buildStatsGrid(user),
                  const SizedBox(height: 32),
                  const _SectionHeader(title: 'PERFORMANCE'),
                  const SizedBox(height: 16),
                  _buildPerformanceCard(user),
                  const SizedBox(height: 32),
                  const _SectionHeader(title: 'NEXUS ACHIEVEMENTS'),
                  const SizedBox(height: 16),
                  _buildAchievementsSection(),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundAccents() {
    return Positioned(
      top: -100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.purple.withOpacity(0.08)),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: const SizedBox()),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AuthEngine auth) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white70),
          ),
        ),
        const Text('PLAYER PROFILE', style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900, color: Colors.white54, fontSize: 12)),
        GestureDetector(
          onTap: () {
            auth.logout();
            Navigator.pop(context);
          },
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.red.withOpacity(0.2)),
            ),
            child: const Icon(Icons.logout, size: 20, color: Colors.redAccent),
          ),
        ),
      ],
    );
  }

  Widget _buildProfileCard(UserProfile user) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.blue, width: 3)),
            child: CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white12,
              child: SvgPicture.string(_generateAvatarPlaceholder(user.username), width: 50),
            ),
          ),
          const SizedBox(height: 16),
          Text(user.username, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(user.email, style: const TextStyle(color: Colors.white38, fontSize: 13)),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(30)),
            child: Text('${user.rating} ELO', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(UserProfile user) {
    return Row(
      children: [
        Expanded(child: _buildStatItem('Wins', '${user.gamesWon}', Icons.emoji_events, Colors.orange)),
        const SizedBox(width: 16),
        Expanded(child: _buildStatItem('Battles', '${user.gamesPlayed}', Icons.bolt, Colors.blue)),
      ],
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 12),
          Text(value, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: Colors.white38, fontSize: 12, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildPerformanceCard(UserProfile user) {
    final winRatio = user.gamesPlayed > 0 ? (user.gamesWon / user.gamesPlayed) : 0.0;
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(24), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Overall Win Ratio', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold)),
              Text('${(winRatio * 100).toStringAsFixed(1)}%', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 18)),
            ],
          ),
          const SizedBox(height: 20),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: winRatio,
              minHeight: 12,
              backgroundColor: Colors.white.withOpacity(0.05),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Top 15% of all time players', style: TextStyle(color: Colors.white24, fontSize: 11, fontStyle: FontStyle.italic)),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildAchievementBadge(Icons.auto_awesome, 'Tactician', Colors.purple),
          _buildAchievementBadge(Icons.shield, 'Shield', Colors.green),
          _buildAchievementBadge(Icons.local_fire_department, 'On Fire', Colors.orange),
          _buildAchievementBadge(Icons.trending_up, 'Prodigy', Colors.blue),
        ],
      ),
    );
  }

  Widget _buildAchievementBadge(IconData icon, String label, Color color) {
    return Container(
      width: 100,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.1), border: Border.all(color: color.withOpacity(0.3))),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white60)),
        ],
      ),
    );
  }

  String _generateAvatarPlaceholder(String seed) {
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><rect width="100" height="100" fill="#2c3e50"/><text x="50" y="65" font-size="50" text-anchor="middle" fill="#ecf0f1">${seed[0].toUpperCase()}</text></svg>';
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 16, decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5, color: Colors.white38)),
      ],
    );
  }
}
