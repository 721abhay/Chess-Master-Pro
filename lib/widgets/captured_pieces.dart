// Captured Pieces Widget

import 'package:flutter/material.dart';
import '../models/chess_models.dart';

class CapturedPiecesWidget extends StatelessWidget {
  final List<ChessPiece> pieces;
  final PieceColor color;

  const CapturedPiecesWidget({
    Key? key,
    required this.pieces,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (pieces.isEmpty) {
      return const SizedBox(height: 32);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            color == PieceColor.white ? 'White captured: ' : 'Black captured: ',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
          ...pieces.map((piece) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Text(
                  PieceSymbols.getSymbol(piece),
                  style: const TextStyle(fontSize: 20),
                ),
              )),
        ],
      ),
    );
  }
}
