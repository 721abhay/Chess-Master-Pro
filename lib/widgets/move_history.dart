// Move History Widget

import 'package:flutter/material.dart';
import '../models/chess_models.dart';

class MoveHistoryWidget extends StatelessWidget {
  final List<Move> moves;

  const MoveHistoryWidget({Key? key, required this.moves}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (moves.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Move History',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Container(
            constraints: const BoxConstraints(maxHeight: 150),
            child: SingleChildScrollView(
              child: Wrap(
                spacing: 16,
                runSpacing: 8,
                children: List.generate((moves.length + 1) ~/ 2, (index) {
                  final whiteMove = moves[index * 2];
                  final blackMove = index * 2 + 1 < moves.length ? moves[index * 2 + 1] : null;

                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${index + 1}. ',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text(whiteMove.toAlgebraic()),
                      if (blackMove != null) ...[
                        const SizedBox(width: 8),
                        Text(blackMove.toAlgebraic()),
                      ],
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
