// Game Controls Widget

import 'package:flutter/material.dart';

class GameControlsWidget extends StatelessWidget {
  final VoidCallback onNewGame;
  final VoidCallback onUndo;
  final VoidCallback onFlipBoard;
  final bool canUndo;

  const GameControlsWidget({
    Key? key,
    required this.onNewGame,
    required this.onUndo,
    required this.onFlipBoard,
    required this.canUndo,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        ElevatedButton.icon(
          onPressed: onNewGame,
          icon: const Icon(Icons.refresh),
          label: const Text('New Game'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
          ),
        ),
        ElevatedButton.icon(
          onPressed: canUndo ? onUndo : null,
          icon: const Icon(Icons.undo),
          label: const Text('Undo'),
          style: ElevatedButton.styleFrom(
            backgroundColor: canUndo ? Colors.orange : Colors.grey,
          ),
        ),
        ElevatedButton.icon(
          onPressed: onFlipBoard,
          icon: const Icon(Icons.flip),
          label: const Text('Flip Board'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
          ),
        ),
      ],
    );
  }
}
