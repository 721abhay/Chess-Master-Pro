import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/online_engine.dart';
import '../models/chess_models.dart';
import '../widgets/chess_board.dart';
import '../widgets/move_history.dart';
import '../widgets/captured_pieces.dart';

class OnlineGameScreen extends StatelessWidget {
  const OnlineGameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<OnlineChessEngine>(context);
    final state = engine.state;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text('Online Match'),
            Text(
              'Room ID: ${engine.roomId ?? "N/A"}',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _showResetDialog(context, engine),
            tooltip: 'Request Reset',
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 16),
          _buildConnectionStatus(engine),
          const SizedBox(height: 16),
          
          // Captured pieces (Opponent)
          CapturedPiecesWidget(
            color: engine.playerColor == PieceColor.white ? PieceColor.white : PieceColor.black,
            pieces: state.getCapturedPieces()[engine.playerColor == PieceColor.white ? PieceColor.white : PieceColor.black] ?? [],
          ),
          
          const Spacer(),
          
          // The Board
          Center(
            child: ChessBoardWidget(
              flipped: engine.playerColor == PieceColor.black,
            ),
          ),
          
          const Spacer(),
          
          // Captured pieces (Player)
          CapturedPiecesWidget(
            color: engine.playerColor == PieceColor.white ? PieceColor.black : PieceColor.white,
            pieces: state.getCapturedPieces()[engine.playerColor == PieceColor.white ? PieceColor.black : PieceColor.white] ?? [],
          ),
          
          const SizedBox(height: 16),
          
          // Status indicator
          _buildStatusPanel(engine),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildConnectionStatus(OnlineChessEngine engine) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: engine.isConnected ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: engine.isConnected ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            engine.isConnected 
                ? (engine.playerCount < 2 ? 'Waiting for opponent...' : 'Connected') 
                : 'Disconnected',
            style: TextStyle(
              color: engine.isConnected ? Colors.green : Colors.red,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusPanel(OnlineChessEngine engine) {
    final isMyTurn = engine.state.turn == engine.playerColor;
    final color = isMyTurn ? Colors.blue : Colors.white24;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color, width: 2),
      ),
      child: Text(
        isMyTurn ? "YOUR TURN" : "WAITING FOR OPPONENT",
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.5,
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, OnlineChessEngine engine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Game?'),
        content: const Text('This will reset the board for both players.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () {
              engine.reset();
              Navigator.pop(context);
            },
            child: const Text('RESET'),
          ),
        ],
      ),
    );
  }
}
