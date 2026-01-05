import 'dart:ui';
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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAndMakeAIMove();
    });
  }

  void _checkAndMakeAIMove() {
    if (!mounted) return;
    final engine = Provider.of<ChessEngine>(context, listen: false);
    final state = engine.state;
    if (isAIMode && state.turn == PieceColor.black && !state.isCheckmate && !state.isStalemate && !state.isDraw && !isAIThinking) {
      setState(() => isAIThinking = true);
      final thinkTime = aiDifficulty == 'easy' ? 400 : aiDifficulty == 'medium' ? 800 : 1500;
      Future.delayed(Duration(milliseconds: thinkTime), () {
        if (!mounted) return;
        final move = SimpleAI.getAIMove(engine, aiDifficulty);
        if (move != null) engine.makeMove(move);
        if (mounted) setState(() => isAIThinking = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<ChessEngine>(context);
    final state = engine.state;

    return Scaffold(
      backgroundColor: const Color(0xFF0F0F13),
      body: Stack(
        children: [
          // Background accents
          _buildBackgroundAccents(),
          
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context, engine),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildModeSelector(),
                        const SizedBox(height: 16),
                        if (isAIMode) _buildDifficultySelector(),
                        const SizedBox(height: 24),
                        
                        // Board Container with shadow
                        _buildBoardContainer(),
                        
                        const SizedBox(height: 24),
                        _buildStatusIndicator(state),
                        const SizedBox(height: 24),
                        _buildControls(engine, state),
                        const SizedBox(height: 24),
                        if (state.moveHistory.isNotEmpty) MoveHistoryWidget(moves: state.moveHistory),
                        const SizedBox(height: 40),
                      ],
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

  Widget _buildBackgroundAccents() {
    return Positioned(
      bottom: -100,
      left: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.blue.withOpacity(0.05)),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: const SizedBox()),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ChessEngine engine) {
    return Container(
      padding: const EdgeInsets.all(20),
      color: Colors.white.withOpacity(0.02),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          const Column(
            children: [
              Text('NEXUS CHESS', style: TextStyle(fontSize: 10, letterSpacing: 4, fontWeight: FontWeight.w900, color: Colors.blue)),
              Text('Tactical Duel', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => engine.reset(),
          ),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          _buildModeTab('🤖 VS AI', isAIMode, () => setState(() => isAIMode = true)),
          _buildModeTab('👥 2 PLAYER', !isAIMode, () => setState(() => isAIMode = false)),
        ],
      ),
    );
  }

  Widget _buildModeTab(String label, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? Colors.blue.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? Colors.blue.withOpacity(0.5) : Colors.transparent),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: active ? Colors.white : Colors.white38)),
        ),
      ),
    );
  }

  Widget _buildDifficultySelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: ['easy', 'medium', 'hard'].map((diff) {
          final active = aiDifficulty == diff;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: ChoiceChip(
              label: Text(diff.toUpperCase()),
              selected: active,
              onSelected: (val) => setState(() => aiDifficulty = diff),
              selectedColor: Colors.blue.withOpacity(0.3),
              backgroundColor: Colors.white.withOpacity(0.05),
              labelStyle: TextStyle(color: active ? Colors.blue : Colors.white38, fontWeight: FontWeight.bold, fontSize: 11),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBoardContainer() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.3), blurRadius: 30, spreadRadius: 5)],
      ),
      child: ChessBoardWidget(flipped: isBoardFlipped),
    );
  }

  Widget _buildStatusIndicator(GameState state) {
    final message = _getStatusMessage(state);
    final color = state.isCheckmate ? Colors.redAccent : state.isCheck ? Colors.orange : Colors.blue;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isAIThinking) const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.blue)),
          if (isAIThinking) const SizedBox(width: 12),
          Text(message.toUpperCase(), style: TextStyle(color: color, fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 1.2)),
        ],
      ),
    );
  }

  Widget _buildControls(ChessEngine engine, GameState state) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white10)),
      child: GameControlsWidget(
        onNewGame: () => engine.reset(),
        onUndo: () {
          if (state.moveHistory.isNotEmpty) {
            engine.reset();
            final moves = List<Move>.from(state.moveHistory);
            moves.removeLast();
            if (isAIMode && moves.isNotEmpty) moves.removeLast();
            for (final move in moves) engine.makeMove(move);
          }
        },
        onFlipBoard: () => setState(() => isBoardFlipped = !isBoardFlipped),
        canUndo: state.moveHistory.isNotEmpty,
      ),
    );
  }

  String _getStatusMessage(GameState state) {
    if (isAIThinking) return 'AI Thinking...';
    if (state.isCheckmate) {
      final winner = state.turn == PieceColor.white ? 'Black' : 'White';
      return '$winner Wins by Checkmate!';
    }
    if (state.isStalemate) return 'Stalemate - Draw';
    if (state.isDraw) return 'Game Drawn';
    if (state.isCheck) return 'Warning: Check!';
    final turn = state.turn == PieceColor.white ? 'White' : 'Black';
    return "$turn's Turn";
  }
}
