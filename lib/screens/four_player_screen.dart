// 4-Player Chess Game Screen

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
        backgroundColor: const Color(0xFF1E1E1E),
        appBar: AppBar(
          title: const Text('4-Player Chess'),
          backgroundColor: const Color(0xFF2C2C2C),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Reset Game?'),
                    content: const Text('Are you sure you want to start a new game?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          setState(() {
                            _engine.reset(mode: _mode);
                          });
                        },
                        child: const Text('Reset'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<FourPlayerChessEngine>(
          builder: (context, engine, _) {
            final state = engine.state;

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    // Mode selector
                    _buildModeSelector(),
                    const SizedBox(height: 12),

                    // Turn indicator
                    _buildTurnIndicator(state),
                    const SizedBox(height: 12),

                    // Chess board
                    const FourPlayerChessBoardWidget(),
                    const SizedBox(height: 12),

                    // Game status
                    _buildGameStatus(state),
                    const SizedBox(height: 12),

                    // Active players
                    _buildActivePlayers(state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Mode: ',
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(width: 12),
          ChoiceChip(
            label: const Text('Free-for-All'),
            selected: _mode == FourPlayerMode.freeForAll,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _mode = FourPlayerMode.freeForAll;
                  _engine.reset(mode: _mode);
                });
              }
            },
          ),
          const SizedBox(width: 8),
          ChoiceChip(
            label: const Text('Teams (2v2)'),
            selected: _mode == FourPlayerMode.teams,
            onSelected: (selected) {
              if (selected) {
                setState(() {
                  _mode = FourPlayerMode.teams;
                  _engine.reset(mode: _mode);
                });
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTurnIndicator(FourPlayerGameState state) {
    if (state.isGameOver) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green),
        ),
        child: Text(
          _getWinnerText(state),
          style: const TextStyle(
            color: Colors.green,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: _getPlayerColor(state.currentTurn).withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: _getPlayerColor(state.currentTurn).withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              color: _getPlayerColor(state.currentTurn),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: _getPlayerColor(state.currentTurn).withOpacity(0.5), blurRadius: 4),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '${_getPlayerName(state.currentTurn).toUpperCase()}\'S TURN',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          if (state.inCheck[state.currentTurn] == true) ...[
            const SizedBox(width: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'CHECK',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGameStatus(FourPlayerGameState state) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'Mode: ${state.mode == FourPlayerMode.freeForAll ? "Free-for-All" : "Teams (2v2)"}',
            style: const TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 4),
          Text(
            'Moves: ${state.moveHistory.length}',
            style: const TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildActivePlayers(FourPlayerGameState state) {
    final players = FourPlayerColor.values;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: players.map((color) {
        final isTurn = state.currentTurn == color;
        final isEliminated = state.eliminated.contains(color);
        final pColor = _getPlayerColor(color);

        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isEliminated 
                ? Colors.transparent 
                : (isTurn ? pColor.withOpacity(0.25) : pColor.withOpacity(0.1)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isEliminated ? Colors.grey : (isTurn ? pColor : pColor.withOpacity(0.4)),
              width: isTurn ? 2 : 1.5,
            ),
            boxShadow: isTurn 
                ? [BoxShadow(color: pColor.withOpacity(0.2), blurRadius: 8)] 
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: isEliminated ? Colors.grey : pColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    if (!isEliminated) BoxShadow(color: pColor.withOpacity(0.5), blurRadius: 4),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _getPlayerName(color).toUpperCase(),
                style: TextStyle(
                  color: isEliminated ? Colors.grey : Colors.white,
                  fontSize: 12,
                  fontWeight: isTurn ? FontWeight.w900 : FontWeight.w600,
                  letterSpacing: 1.1,
                  decoration: isEliminated ? TextDecoration.lineThrough : null,
                ),
              ),
              if (isEliminated) ...[
                const SizedBox(width: 6),
                const Icon(Icons.close, size: 14, color: Colors.red),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }

  String _getPlayerName(FourPlayerColor color) {
    switch (color) {
      case FourPlayerColor.white:
        return 'White';
      case FourPlayerColor.black:
        return 'Black';
      case FourPlayerColor.red:
        return 'Red';
      case FourPlayerColor.blue:
        return 'Blue';
    }
  }

  Color _getPlayerColor(FourPlayerColor color) {
    switch (color) {
      case FourPlayerColor.white:
        return Colors.white;
      case FourPlayerColor.black:
        return Colors.black;
      case FourPlayerColor.red:
        return const Color(0xFFFF0000);
      case FourPlayerColor.blue:
        return const Color(0xFF0066FF);
    }
  }

  String _getWinnerText(FourPlayerGameState state) {
    if (state.mode == FourPlayerMode.freeForAll) {
      final winner = FourPlayerColor.values.firstWhere(
        (c) => !state.eliminated.contains(c),
      );
      return '${_getPlayerName(winner)} WINS!';
    } else {
      // Team mode
      final team1Alive = !state.eliminated.contains(FourPlayerColor.white) ||
                         !state.eliminated.contains(FourPlayerColor.black);
      if (team1Alive) {
        return 'White/Black Team WINS!';
      } else {
        return 'Red/Blue Team WINS!';
      }
    }
  }
}
