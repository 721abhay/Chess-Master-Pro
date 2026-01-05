// 4-Player Extended Chess Board Widget

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/four_player_engine.dart';
import '../models/chess_models.dart';
import '../models/four_player_models.dart';

class FourPlayerChessBoardWidget extends StatefulWidget {
  const FourPlayerChessBoardWidget({Key? key}) : super(key: key);

  @override
  State<FourPlayerChessBoardWidget> createState() => _FourPlayerChessBoardWidgetState();
}

class _FourPlayerChessBoardWidgetState extends State<FourPlayerChessBoardWidget> {
  Square? selectedSquare;
  List<FourPlayerMove> legalMoves = [];

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<FourPlayerChessEngine>(context);
    final state = engine.state;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenWidth - 20; // Smaller padding for 14x14
    final squareSize = boardSize / 14;

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF8B6914),
          width: 3,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 14,
          ),
          itemCount: 196, // 14x14
          itemBuilder: (context, index) {
            final row = 13 - (index ~/ 14); // Flip vertically
            final col = index % 14;
            final square = Square(row, col);
            
            // Check if square is playable (cross shape)
            if (!FourPlayerGameState.isPlayableSquare(row, col)) {
              return Container(color: const Color(0xFF2C2C2C)); // Dark gray for unplayable
            }

            final piece = state.board[row][col];
            final isLight = (row + col) % 2 == 0;

            return GestureDetector(
              onTap: () => _handleSquareTap(engine, square, piece),
              child: _buildSquare(square, piece, isLight, squareSize, state),
            );
          },
        ),
      ),
    );
  }

  void _handleSquareTap(FourPlayerChessEngine engine, Square square, FourPlayerPiece? piece) {
    if (selectedSquare == null) {
      if (piece != null && piece.color == engine.state.currentTurn) {
        setState(() {
          selectedSquare = square;
          legalMoves = engine.getLegalMovesFrom(square);
        });
      }
    } else {
      final moveIndex = legalMoves.indexWhere((m) => m.to == square);
      if (moveIndex != -1) {
        engine.makeMove(legalMoves[moveIndex]);
        setState(() {
          selectedSquare = null;
          legalMoves = [];
        });
      } else if (piece != null && piece.color == engine.state.currentTurn) {
        setState(() {
          selectedSquare = square;
          legalMoves = engine.getLegalMovesFrom(square);
        });
      } else {
        setState(() {
          selectedSquare = null;
          legalMoves = [];
        });
      }
    }
  }

  Widget _buildSquare(
    Square square,
    FourPlayerPiece? piece,
    bool isLight,
    double size,
    FourPlayerGameState state,
  ) {
    final isSelected = selectedSquare == square;
    final isLegalMove = legalMoves.any((m) => m.to == square && m.captured == null);
    final isLegalCapture = legalMoves.any((m) => m.to == square && m.captured != null);

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? const Color(0xBBAAEE55)
            : isLight
                ? const Color(0xFFFFCE9E)
                : const Color(0xFFD18B47),
        border: isLegalCapture
            ? Border.all(color: Colors.red.withOpacity(0.7), width: 2)
            : null,
      ),
      child: Stack(
        children: [
          if (piece != null)
            Center(
              child: Text(
                PieceSymbols.getSymbol(
                  ChessPiece(
                    type: piece.type,
                    // Use White (outlined) symbols for ALL teams.
                    // Outlined symbols are NOT replaced by grey emojis on Android.
                    color: PieceColor.white,
                  ),
                ),
                style: TextStyle(
                  fontSize: size * 0.75,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                  color: _getPieceColor(piece.color),
                  shadows: [
                    // Extra thick black/white border to make the outlined piece look "solid"
                    Shadow(color: _getBorderColor(piece.color), offset: const Offset(-1.5, -1.5)),
                    Shadow(color: _getBorderColor(piece.color), offset: const Offset(1.5, -1.5)),
                    Shadow(color: _getBorderColor(piece.color), offset: const Offset(-1.5, 1.5)),
                    Shadow(color: _getBorderColor(piece.color), offset: const Offset(1.5, 1.5)),
                    // Inner "glow" of the team color to fill the hollow shape
                    Shadow(
                      color: _getPieceColor(piece.color).withOpacity(0.8),
                      blurRadius: 1,
                    ),
                  ],
                ),
              ),
            ),
          if (isLegalMove)
            Center(
              child: Container(
                width: size * 0.3,
                height: size * 0.3,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF587346).withOpacity(0.7),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Color _getPieceColor(FourPlayerColor color) {
    switch (color) {
      case FourPlayerColor.white:
        return Colors.white;
      case FourPlayerColor.black:
        return Colors.black;
      case FourPlayerColor.red:
        return const Color(0xFFFF0000); // Vivid Red
      case FourPlayerColor.blue:
        return const Color(0xFF0066FF); // Vivid Blue
    }
  }

  Color _getBorderColor(FourPlayerColor color) {
    if (color == FourPlayerColor.black) {
      return Colors.white;
    }
    return Colors.black;
  }
}
