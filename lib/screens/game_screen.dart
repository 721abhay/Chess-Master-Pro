// Game Screen - Main chess gameplay interface

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/chess_engine.dart';
import '../widgets/chess_board.dart';
import '../widgets/game_controls.dart';
import '../widgets/move_history.dart';
import '../models/chess_models.dart';
import '../ai/simple_ai.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool isAIMode = true;
  String aiDifficulty = 'medium';
  bool isBoardFlipped = false;
  bool isAIThinking = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Trigger AI move after build if needed
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndMakeAIMove();
    });
  }

  void _checkAndMakeAIMove() {
    if (!mounted) return;
    
    final engine = Provider.of<ChessEngine>(context, listen: false);
    final state = engine.state;

    // AI moves when it's Black's turn in AI mode
    if (isAIMode && 
        state.turn == PieceColor.black && 
        !state.isCheckmate && 
        !state.isStalemate && 
        !state.isDraw &&
        !isAIThinking) {
      
      setState(() => isAIThinking = true);

      // AI move with difficulty
      final thinkTime = aiDifficulty == 'easy' ? 300 : aiDifficulty == 'medium' ? 600 : 1000;
      
      Future.delayed(Duration(milliseconds: thinkTime), () {
        if (!mounted) return;
        
        final move = SimpleAI.getAIMove(engine, aiDifficulty);
        if (move != null) {
          engine.makeMove(move);
        }
        
        if (mounted) {
          setState(() => isAIThinking = false);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<ChessEngine>(context);
    final state = engine.state;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chess Master', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Game mode selector
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() => isAIMode = true);
                        engine.reset();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isAIMode ? Colors.blue : Colors.grey[800],
                      ),
                      child: const Text('🤖 vs AI'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => isAIMode = false);
                        engine.reset();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: !isAIMode ? Colors.blue : Colors.grey[800],
                      ),
                      child: const Text('👥 2 Player'),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Difficulty selector (AI mode only)
                if (isAIMode)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('AI Difficulty: ', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 8),
                      for (final diff in ['easy', 'medium', 'hard'])
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: ChoiceChip(
                            label: Text(diff.toUpperCase()),
                            selected: aiDifficulty == diff,
                            onSelected: (selected) {
                              if (selected) setState(() => aiDifficulty = diff);
                            },
                          ),
                        ),
                    ],
                  ),

                const SizedBox(height: 24),

                // Chess Board
                ChessBoardWidget(flipped: isBoardFlipped),

                const SizedBox(height: 24),

                // Status message
                Text(
                  _getStatusMessage(state),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Game controls
                GameControlsWidget(
                  onNewGame: () => engine.reset(),
                  onUndo: () {
                    // Simple undo - reset and replay moves except last
                    if (state.moveHistory.isNotEmpty) {
                      engine.reset();
                      final moves = List<Move>.from(state.moveHistory);
                      moves.removeLast();
                      if (isAIMode && moves.isNotEmpty) moves.removeLast(); // Remove AI move too
                      for (final move in moves) {
                        engine.makeMove(move);
                      }
                    }
                  },
                  onFlipBoard: () => setState(() => isBoardFlipped = !isBoardFlipped),
                  canUndo: state.moveHistory.isNotEmpty,
                ),

                const SizedBox(height: 24),

                // Move history
                if (state.moveHistory.isNotEmpty)
                  MoveHistoryWidget(moves: state.moveHistory),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusMessage(GameState state) {
    if (isAIThinking) {
      return '🤔 AI is thinking...';
    }
    if (state.isCheckmate) {
      final winner = state.turn == PieceColor.white ? 'Black' : 'White';
      return '👑 Checkmate! $winner wins!';
    }
    if (state.isStalemate) {
      return '🤝 Stalemate! Game drawn.';
    }
    if (state.isDraw) {
      return '🤝 Draw by insufficient material or 50-move rule.';
    }
    if (state.isCheck) {
      return '⚠️ Check!';
    }
    final turn = state.turn == PieceColor.white ? 'White' : 'Black';
    return '$turn to move';
  }
}
