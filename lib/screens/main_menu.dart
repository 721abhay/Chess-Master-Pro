import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/auth_engine.dart';
import 'game_screen.dart';
import 'four_player_screen.dart';
import 'online_setup_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MainMenuScreen extends StatelessWidget {
  const MainMenuScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthEngine>(context);
    final user = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Master Pro'),
        centerTitle: true,
        actions: [
          _buildUserAvatar(context, auth),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const SizedBox(height: 20),
            const Icon(Icons.casino, size: 100, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Welcome to Chess Master',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choose your game mode and compete globally',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white60),
            ),
            const SizedBox(height: 40),

            // Ranking & Profile Quick Actions
            Row(
              children: [
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    title: 'Rankings',
                    icon: Icons.leaderboard,
                    color: Colors.orange,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildQuickActionButton(
                    context,
                    title: 'My Stats',
                    icon: Icons.analytics,
                    color: Colors.blue,
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
            ),
            
            const SizedBox(height: 32),

            // Local Chess
            _buildModeButton(
              context,
              title: 'Classic Local',
              subtitle: 'Play against AI or a local friend',
              icon: Icons.person,
              color: Colors.blue,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GameScreen())),
            ),
            const SizedBox(height: 16),

            // Online
            _buildModeButton(
              context,
              title: 'Online Match',
              subtitle: 'Compete with friends via Room ID',
              icon: Icons.public,
              color: Colors.green,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const OnlineSetupScreen())),
            ),
            const SizedBox(height: 16),

            // 4-Player
            _buildModeButton(
              context,
              title: '4-Player Battle',
              subtitle: 'Chaotic 4-player team or FFA combat',
              icon: Icons.groups,
              color: Colors.purple,
              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FourPlayerGameScreen())),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserAvatar(BuildContext context, AuthEngine auth) {
    if (!auth.isAuthenticated) {
      return TextButton.icon(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
        icon: const Icon(Icons.login, color: Colors.blue),
        label: const Text('LOGIN', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
      );
    }

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
      child: Padding(
        padding: const EdgeInsets.only(right: 16.0),
        child: CircleAvatar(
          backgroundColor: Colors.white12,
          child: SvgPicture.string(
            _generateAvatarPlaceholder(auth.currentUser!.username),
            width: 32,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionButton(BuildContext context, {required String title, required IconData icon, required Color color, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildModeButton(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color, width: 2),
        ),
        child: Row(
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  Text(subtitle, style: const TextStyle(fontSize: 13, color: Colors.white60)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color, size: 20),
          ],
        ),
      ),
    );
  }

  String _generateAvatarPlaceholder(String seed) {
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><rect width="100" height="100" fill="#2c3e50"/><text x="50" y="65" font-size="50" text-anchor="middle" fill="#ecf0f1">${seed[0].toUpperCase()}</text></svg>';
  }
}
