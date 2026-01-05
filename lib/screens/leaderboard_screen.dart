import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({Key? key}) : super(key: key);

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  List<dynamic> _players = [];
  late AnimationController _listController;

  @override
  void initState() {
    super.initState();
    _listController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fetchLeaderboard();
  }

  @override
  void dispose() {
    _listController.dispose();
    super.dispose();
  }

  Future<void> _fetchLeaderboard() async {
    try {
      final response = await http.get(Uri.parse('${ApiConfig.baseUrl}/api/leaderboard'));
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            _players = jsonDecode(response.body);
            _isLoading = false;
          });
          _listController.forward();
        }
      }
    } catch (e) {
      debugPrint('Error fetching leaderboard: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: Stack(
        children: [
          // Background accents
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.withOpacity(0.1)),
              child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 80, sigmaY: 80), child: const SizedBox()),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator(color: Colors.blue))
                      : _players.isEmpty
                        ? _buildEmptyState()
                        : RefreshIndicator(
                            onRefresh: _fetchLeaderboard,
                            backgroundColor: const Color(0xFF1E1E26),
                            color: Colors.blue,
                            child: ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              itemCount: _players.length,
                              itemBuilder: (context, index) {
                                final player = _players[index];
                                final animation = CurvedAnimation(
                                  parent: _listController,
                                  curve: Interval(index * 0.05 > 1.0 ? 1.0 : index * 0.05, 1.0, curve: Curves.easeOut),
                                );
                                
                                return FadeTransition(
                                  opacity: animation,
                                  child: SlideTransition(
                                    position: Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero).animate(animation),
                                    child: _buildPlayerListItem(player, index + 1),
                                  ),
                                );
                              },
                            ),
                          ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white10),
              ),
              child: const Icon(Icons.arrow_back_ios_new, size: 20, color: Colors.white70),
            ),
          ),
          const SizedBox(width: 20),
          const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'GLOBAL ARENA',
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 3, color: Colors.blue),
              ),
              Text(
                'Top Grandmasters',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const Spacer(),
          const Icon(Icons.emoji_events, color: Colors.orange, size: 30),
        ],
      ),
    );
  }

  Widget _buildPlayerListItem(dynamic player, int rank) {
    final isTop3 = rank <= 3;
    final Color rankColor = rank == 1 ? Colors.amber : rank == 2 ? const Color(0xFFC0C0C0) : rank == 3 ? const Color(0xFFCD7F32) : Colors.transparent;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isTop3 ? Colors.blue.withOpacity(0.12) : Colors.white.withOpacity(0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isTop3 ? Colors.blue.withOpacity(0.3) : Colors.white10,
                width: isTop3 ? 2 : 1,
              ),
              boxShadow: isTop3 ? [
                BoxShadow(color: Colors.blue.withOpacity(0.05), blurRadius: 10, spreadRadius: 0)
              ] : [],
            ),
            child: Row(
              children: [
                _buildRankBadge(rank, rankColor),
                const SizedBox(width: 16),
                _buildAvatar(player['username']),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        player['username'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'W: ${player['gamesWon']} / P: ${player['gamesPlayed']}',
                        style: const TextStyle(color: Colors.white38, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                _buildRating(player['rating']),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRankBadge(int rank, Color color) {
    if (rank <= 3) {
      return Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.2), border: Border.all(color: color, width: 2)),
        alignment: Alignment.center,
        child: Text('$rank', style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 14)),
      );
    }
    return SizedBox(
      width: 32,
      child: Text('#$rank', textAlign: TextAlign.center, style: const TextStyle(color: Colors.white38, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildAvatar(String username) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: Colors.white10)),
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white.withOpacity(0.05),
        child: SvgPicture.string(_generateAvatarPlaceholder(username), width: 24),
      ),
    );
  }

  Widget _buildRating(int rating) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          '$rating',
          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 20, letterSpacing: 1),
        ),
        const Text('ELO', style: TextStyle(color: Colors.white24, fontSize: 10, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 80, color: Colors.white10),
          const SizedBox(height: 16),
          const Text('No contenders yet', style: TextStyle(color: Colors.white38, fontSize: 16)),
        ],
      ),
    );
  }

  String _generateAvatarPlaceholder(String seed) {
    return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100"><rect width="100" height="100" fill="#2c3e50"/><text x="50" y="65" font-size="50" text-anchor="middle" fill="#ecf0f1">${seed[0].toUpperCase()}</text></svg>';
  }
}
