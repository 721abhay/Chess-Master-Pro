import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/online_engine.dart';
import '../models/chess_models.dart';
import '../utils/constants.dart';
import 'online_game_screen.dart';

class OnlineSetupScreen extends StatefulWidget {
  const OnlineSetupScreen({Key? key}) : super(key: key);

  @override
  State<OnlineSetupScreen> createState() => _OnlineSetupScreenState();
}

class _OnlineSetupScreenState extends State<OnlineSetupScreen> {
  final TextEditingController _roomController = TextEditingController();
  PieceColor _selectedColor = PieceColor.white;
  bool _isCreating = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Play with Friends')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.public, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Online Multiplayer',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Create a room and share the ID with your friend',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 32),
            
            // Tab-like selector
            Container(
              decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTab('Create Room', _isCreating, () => setState(() => _isCreating = true)),
                  ),
                  Expanded(
                    child: _buildTab('Join Room', !_isCreating, () => setState(() => _isCreating = false)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            TextField(
              controller: _roomController,
              decoration: InputDecoration(
                labelText: 'Room ID',
                hintText: _isCreating ? 'Enter any ID (e.g. 1234)' : 'Enter shared ID',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.meeting_room),
              ),
            ),
            const SizedBox(height: 24),

            if (_isCreating) ...[
              const Text('Play as:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildColorOption(PieceColor.white, 'White'),
                  const SizedBox(width: 24),
                  _buildColorOption(PieceColor.black, 'Black'),
                ],
              ),
            ],
            
            const SizedBox(height: 48),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startOnlineGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  _isCreating ? 'CREATE & START' : 'JOIN GAME',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: active ? Colors.white : Colors.white60,
          ),
        ),
      ),
    );
  }

  Widget _buildColorOption(PieceColor color, String label) {
    final active = _selectedColor == color;
    return GestureDetector(
      onTap: () => setState(() => _selectedColor = color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.blue.withOpacity(0.2) : Colors.white10,
          border: Border.all(color: active ? Colors.blue : Colors.transparent, width: 2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.person,
              color: color == PieceColor.white ? Colors.white : Colors.grey[800],
              size: 40,
            ),
            const SizedBox(height: 8),
            Text(label),
          ],
        ),
      ),
    );
  }

  void _startOnlineGame() {
    final roomId = _roomController.text.trim();
    if (roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a Room ID')),
      );
      return;
    }

    // Initialize Online Engine
    final engine = OnlineChessEngine(serverUrl: ApiConfig.baseUrl);
    
    // Join room
    // If joining, we don't know the color yet, but typically 2nd person is opposite of first.
    // For now, let's assume the user picks their color for simplicity, or we auto-assign.
    // Let's just use the selected color.
    engine.joinRoom(roomId, _selectedColor);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<OnlineChessEngine>.value(
          value: engine,
          child: const OnlineGameScreen(),
        ),
      ),
    );
  }
}
