import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/four_player_engine.dart';
import '../models/four_player_models.dart';
import '../widgets/four_player_board.dart';

class FourPlayerGameScreen extends StatefulWidget {
  const FourPlayerGameScreen({Key? key}) : super(key: key);

  @override
  State<FourPlayerGameScreen> createState() => _FourPlayerGameScreenState();
}

class _FourPlayerGameScreenState extends State<FourPlayerGameScreen> {
  late FourPlayerChessEngine _engine;
  FourPlayerMode _mode = FourPlayerMode.freeForAll;

  @override
  void initState() {
    super.initState();
    _engine = FourPlayerChessEngine(mode: _mode);
  }

  @override
  void dispose() {
    _engine.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _engine,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F13),
        body: Stack(
          children: [
            _buildBackgroundAccents(),
            SafeArea(
              child: Consumer<FourPlayerChessEngine>(
                builder: (context, engine, _) {
                  final state = engine.state;
                  return Column(
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
                              _buildTurnIndicator(state),
                              const SizedBox(height: 32),
                              
                              // Board with deep contrast
                              _buildBoardWrapper(),
                              
                              const SizedBox(height: 32),
                              const Text('ACTIVE CONTENDERS', style: TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900, color: Colors.white24, fontSize: 10)),
                              const SizedBox(height: 16),
                              _buildPlayerStatusGrid(state),
                              const SizedBox(height: 40),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundAccents() {
    return Positioned(
      top: 100,
      right: -100,
      child: Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.red.withOpacity(0.05)),
        child: BackdropFilter(filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100), child: const SizedBox()),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, FourPlayerChessEngine engine) {
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
              Text('NEXUS QUAD', style: TextStyle(fontSize: 10, letterSpacing: 4, fontWeight: FontWeight.w900, color: Colors.purpleAccent)),
              Text('War of Dynasties', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _showResetDialog(context, engine),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, FourPlayerChessEngine engine) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E1E26),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Reset Warzone?'),
        content: const Text('All active progress will be lost. Reset board?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('CANCEL', style: TextStyle(color: Colors.white38))),
          ElevatedButton(
            onPressed: () { Navigator.pop(context); engine.reset(mode: _mode); },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.purpleAccent),
            child: const Text('RE-DEPLOY'),
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
          _buildModeTab('FFA', _mode == FourPlayerMode.freeForAll, () => setState(() { _mode = FourPlayerMode.freeForAll; _engine.reset(mode: _mode); })),
          _buildModeTab('TEAMS 2V2', _mode == FourPlayerMode.teams, () => setState(() { _mode = FourPlayerMode.teams; _engine.reset(mode: _mode); })),
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
            color: active ? Colors.purpleAccent.withOpacity(0.2) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: active ? Colors.purpleAccent.withOpacity(0.5) : Colors.transparent),
          ),
          child: Text(label, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: active ? Colors.white : Colors.white38)),
        ),
      ),
    );
  }

  Widget _buildTurnIndicator(FourPlayerGameState state) {
    if (state.isGameOver) return _buildGameOverPill(state);
    
    final color = _getPlayerColor(state.currentTurn);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.4), width: 2),
        boxShadow: [BoxShadow(color: color.withOpacity(0.15), blurRadius: 15, spreadRadius: 2)],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle, boxShadow: [BoxShadow(color: color, blurRadius: 4)])),
          const SizedBox(width: 16),
          Text('${_getPlayerName(state.currentTurn).toUpperCase()}\'S STRIKE', style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1.5, fontSize: 13)),
          if (state.inCheck[state.currentTurn] == true) ...[
            const SizedBox(width: 12),
            _buildCheckBadge(),
          ],
        ],
      ),
    );
  }

  Widget _buildGameOverPill(FourPlayerGameState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(color: Colors.green.withOpacity(0.2), borderRadius: BorderRadius.circular(30), border: Border.all(color: Colors.green, width: 2)),
      child: Text(_getWinnerText(state).toUpperCase(), style: const TextStyle(color: Colors.green, fontWeight: FontWeight.w900, letterSpacing: 2)),
    );
  }

  Widget _buildCheckBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(6)),
      child: const Text('CHECK', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w900, letterSpacing: 1)),
    );
  }

  Widget _buildBoardWrapper() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.35), blurRadius: 40, spreadRadius: 2)],
      ),
      child: const FourPlayerChessBoardWidget(),
    );
  }

  Widget _buildPlayerStatusGrid(FourPlayerGameState state) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: FourPlayerColor.values.map((color) {
        final active = state.currentTurn == color;
        final dead = state.eliminated.contains(color);
        final pColor = _getPlayerColor(color);
        
        return Container(
          width: 100,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: dead ? Colors.transparent : (active ? pColor.withOpacity(0.15) : Colors.white.withOpacity(0.03)),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: dead ? Colors.white10 : (active ? pColor : Colors.white24), width: active ? 2 : 1),
          ),
          child: Column(
            children: [
              Container(width: 8, height: 8, decoration: BoxDecoration(color: dead ? Colors.white12 : pColor, shape: BoxShape.circle)),
              const SizedBox(height: 8),
              Text(
                _getPlayerName(color).toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w900 : FontWeight.bold,
                  color: dead ? Colors.white24 : (active ? Colors.white : Colors.white54),
                  decoration: dead ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Color _getPlayerColor(FourPlayerColor color) {
    switch (color) {
      case FourPlayerColor.white: return Colors.white;
      case FourPlayerColor.black: return Colors.black;
      case FourPlayerColor.red: return const Color(0xFFFF0055);
      case FourPlayerColor.blue: return const Color(0xFF00AAFF);
    }
  }

  String _getPlayerName(FourPlayerColor color) => color.toString().split('.').last.toUpperCase();

  String _getWinnerText(FourPlayerGameState state) {
    if (state.mode == FourPlayerMode.freeForAll) {
      final winner = FourPlayerColor.values.firstWhere((c) => !state.eliminated.contains(c));
      return '${_getPlayerName(winner)} VICTORIOUS';
    } else {
      final team1Alive = !state.eliminated.contains(FourPlayerColor.white) || !state.eliminated.contains(FourPlayerColor.black);
      return team1Alive ? 'TEAM ALPHA VICTORIOUS' : 'TEAM OMEGA VICTORIOUS';
    }
  }
}
