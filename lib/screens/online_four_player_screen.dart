import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/four_player_engine.dart';
import '../engine/online_four_player_engine.dart';
import '../models/four_player_models.dart';
import '../widgets/four_player_board.dart';

class OnlineFourPlayerGameScreen extends StatelessWidget {
  const OnlineFourPlayerGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<OnlineFourPlayerEngine>(context);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Column(
          children: [
            const Text('4-Player Online', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Room: ${engine.roomId}', style: const TextStyle(fontSize: 10, color: Colors.white54)),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Turn Indicator (Reuse logic from offline screen)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: _buildOnlineTurnIndicator(engine),
          ),

          const Spacer(),

          // Board
          Center(
            child: ChangeNotifierProvider<FourPlayerChessEngine>.value(
              value: engine,
              child: const FourPlayerChessBoardWidget(),
            ),
          ),

          const Spacer(),

          // Connection status
          _buildConnectionBar(engine),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _getColorName(FourPlayerColor color) {
    return color.toString().split('.').last.toUpperCase();
  }

  Color _getColorValue(FourPlayerColor color) {
    switch (color) {
      case FourPlayerColor.white: return Colors.white;
      case FourPlayerColor.black: return Colors.black;
      case FourPlayerColor.red: return Colors.red;
      case FourPlayerColor.blue: return Colors.blue;
    }
  }

  Widget _buildOnlineTurnIndicator(OnlineFourPlayerEngine engine) {
    final isMyTurn = engine.state.currentTurn == engine.playerColor;
    final color = _getColorValue(engine.state.currentTurn);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.2),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            isMyTurn ? "YOUR TURN" : "${_getColorName(engine.state.currentTurn)}'S TURN",
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionBar(OnlineFourPlayerEngine engine) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      margin: const EdgeInsets.symmetric(horizontal: 40),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.circle,
            size: 10,
            color: engine.isConnected ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 10),
          Text(
            engine.isConnected ? 'Connected (${engine.playerCount}/4)' : 'Connecting...',
            style: const TextStyle(fontSize: 12, color: Colors.white60),
          ),
          const Spacer(),
          if (engine.playerColor != null)
            Text(
              'Playing as: ${_getColorName(engine.playerColor!)}',
              style: TextStyle(
                fontSize: 12, 
                fontWeight: FontWeight.bold,
                color: _getColorValue(engine.playerColor!),
              ),
            ),
        ],
      ),
    );
  }
}
