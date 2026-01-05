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
      return const Scaffold(
        body: Center(child: Text('Please login to view profile')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              auth.logout();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            _buildHeader(user),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                   _buildStatRow(
                    label: 'Current Rating',
                    value: '${user.rating} ELO',
                    icon: Icons.trending_up,
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    label: 'Games Played',
                    value: '${user.gamesPlayed}',
                    icon: Icons.videogame_asset,
                    color: Colors.purple,
                  ),
                  const SizedBox(height: 16),
                  _buildStatRow(
                    label: 'Games Won',
                    value: '${user.gamesWon}',
                    icon: Icons.emoji_events,
                    color: Colors.orange,
                  ),
                  const SizedBox(height: 32),
                  _buildWinRatio(user),
                  const SizedBox(height: 48),
                  
                  // Some badges mock
                  _buildBadgesSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(UserProfile user) {
    return Column(
      children: [
        CircleAvatar(
          radius: 60,
          backgroundColor: Colors.blue.withOpacity(0.1),
          child: SvgPicture.string(
            _generateAvatarPlaceholder(user.username),
            width: 80,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.username,
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        Text(
          user.email,
          style: const TextStyle(color: Colors.white54),
        ),
      ],
    );
  }

  Widget _buildStatRow({required String label, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Text(label, style: const TextStyle(fontSize: 16)),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinRatio(UserProfile user) {
    final ratio = user.gamesPlayed > 0 ? (user.gamesWon / user.gamesPlayed) : 0.0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Win Ratio', style: TextStyle(fontSize: 16)),
            Text('${(ratio * 100).toStringAsFixed(1)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 12,
            backgroundColor: Colors.white10,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Achievements', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBadge(Icons.bolt, 'Fast Learner', Colors.yellow),
            _buildBadge(Icons.shield, 'Defense Pro', Colors.green),
            _buildBadge(Icons.auto_awesome, 'Tactician', Colors.purple),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge(IconData icon, String label, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.white70)),
      ],
    );
  }

  String _generateAvatarPlaceholder(String seed) {
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><rect width="100" height="100" fill="#2c3e50"/><text x="50" y="65" font-size="50" text-anchor="middle" fill="#ecf0f1">${seed[0].toUpperCase()}</text></svg>';
  }
}
