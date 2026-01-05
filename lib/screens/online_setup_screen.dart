import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/online_engine.dart';
import '../engine/online_four_player_engine.dart';
import '../models/chess_models.dart';
import '../models/four_player_models.dart';
import '../utils/constants.dart';
import 'online_game_screen.dart';
import 'online_four_player_screen.dart';

class OnlineSetupScreen extends StatefulWidget {
  const OnlineSetupScreen({Key? key}) : super(key: key);

  @override
  State<OnlineSetupScreen> createState() => _OnlineSetupScreenState();
}

class _OnlineSetupScreenState extends State<OnlineSetupScreen> {
  final TextEditingController _roomController = TextEditingController();
  bool _isCreating = true;
  bool _isFourPlayer = false;
  
  // 2-Player selection
  PieceColor _selectedColor2P = PieceColor.white;
  
  // 4-Player selection
  FourPlayerColor _selectedColor4P = FourPlayerColor.white;

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
            
            const SizedBox(height: 32),
            
            // Mode Selector
            _buildModeSelector(),
            
            const SizedBox(height: 24),

            // Tab-like selector (Create/Join)
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
            const SizedBox(height: 24),

            TextField(
              controller: _roomController,
              decoration: InputDecoration(
                labelText: 'Room ID',
                hintText: 'Enter shared ID',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                prefixIcon: const Icon(Icons.meeting_room),
              ),
            ),
            const SizedBox(height: 24),

            if (_isCreating) ...[
              const Text('Play as:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              if (_isFourPlayer)
                _build4PColorSelector()
              else
                _build2PColorSelector(),
            ],
            
            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _startOnlineGame,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isFourPlayer ? Colors.purple : Colors.blue,
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

  Widget _buildModeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildModeChip('2-Player', !_isFourPlayer, () => setState(() => _isFourPlayer = false)),
        const SizedBox(width: 16),
        _buildModeChip('4-Player', _isFourPlayer, () => setState(() => _isFourPlayer = true)),
      ],
    );
  }

  Widget _buildModeChip(String label, bool active, VoidCallback onTap) {
    return ChoiceChip(
      selected: active,
      label: Text(label),
      onSelected: (_) => onTap(),
      selectedColor: active ? (label.startsWith('2') ? Colors.blue : Colors.purple) : null,
    );
  }

  Widget _buildTab(String title, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: active ? Colors.blue.withOpacity(0.5) : Colors.transparent,
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

  Widget _build2PColorSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildColorCircle(PieceColor.white, Colors.white, _selectedColor2P == PieceColor.white, 
            () => setState(() => _selectedColor2P = PieceColor.white)),
        const SizedBox(width: 32),
        _buildColorCircle(PieceColor.black, Colors.black, _selectedColor2P == PieceColor.black, 
            () => setState(() => _selectedColor2P = PieceColor.black)),
      ],
    );
  }

  Widget _build4PColorSelector() {
    return Wrap(
      spacing: 16,
      runSpacing: 16,
      alignment: WrapAlignment.center,
      children: [
        _buildColorCircle(FourPlayerColor.white, Colors.white, _selectedColor4P == FourPlayerColor.white, 
            () => setState(() => _selectedColor4P = FourPlayerColor.white)),
        _buildColorCircle(FourPlayerColor.black, Colors.black, _selectedColor4P == FourPlayerColor.black, 
            () => setState(() => _selectedColor4P = FourPlayerColor.black)),
        _buildColorCircle(FourPlayerColor.red, Colors.red, _selectedColor4P == FourPlayerColor.red, 
            () => setState(() => _selectedColor4P = FourPlayerColor.red)),
        _buildColorCircle(FourPlayerColor.blue, Colors.blue, _selectedColor4P == FourPlayerColor.blue, 
            () => setState(() => _selectedColor4P = FourPlayerColor.blue)),
      ],
    );
  }

  Widget _buildColorCircle(dynamic value, Color color, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: Border.all(color: active ? Colors.blue : Colors.white24, width: 4),
          boxShadow: active ? [BoxShadow(color: Colors.blue.withOpacity(0.5), blurRadius: 10)] : null,
        ),
        child: active ? const Icon(Icons.check, color: Colors.blue, weight: 10) : null,
      ),
    );
  }

  void _startOnlineGame() {
    final roomId = _roomController.text.trim();
    if (roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a Room ID')));
      return;
    }

    if (_isFourPlayer) {
      final engine = OnlineFourPlayerEngine(serverUrl: ApiConfig.baseUrl);
      engine.joinRoom(roomId, _selectedColor4P);
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<OnlineFourPlayerEngine>.value(
          value: engine,
          child: const OnlineFourPlayerGameScreen(),
        ),
      ));
    } else {
      final engine = OnlineChessEngine(serverUrl: ApiConfig.baseUrl);
      engine.joinRoom(roomId, _selectedColor2P);
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ChangeNotifierProvider<OnlineChessEngine>.value(
          value: engine,
          child: const OnlineGameScreen(),
        ),
      ));
    }
  }
}
