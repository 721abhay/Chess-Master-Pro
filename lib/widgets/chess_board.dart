// Chess Board Widget - Interactive chess board display

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../engine/chess_engine.dart';
import '../models/chess_models.dart';
import '../utils/constants.dart';

class ChessBoardWidget extends StatefulWidget {
  final bool flipped;

  const ChessBoardWidget({Key? key, this.flipped = false}) : super(key: key);

  @override
  State<ChessBoardWidget> createState() => _ChessBoardWidgetState();
}

class _ChessBoardWidgetState extends State<ChessBoardWidget> {
  Square? selectedSquare;
  List<Move> legalMoves = [];

  @override
  Widget build(BuildContext context) {
    final engine = Provider.of<ChessEngine>(context);
    final state = engine.state;
    final screenWidth = MediaQuery.of(context).size.width;
    final boardSize = screenWidth - 32; // Padding
    final squareSize = boardSize / 8;

    return Container(
      width: boardSize,
      height: boardSize,
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFF8B6914), // Dark golden brown
          width: 5,
        ),
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(2),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 8,
          ),
          itemCount: 64,
          itemBuilder: (context, index) {
            final row = widget.flipped ? index ~/ 8 : 7 - (index ~/ 8);
            final col = widget.flipped ? 7 - (index % 8) : index % 8;
            final square = Square(row, col);
            final piece = state.board[row][col];
            final isLight = (row + col) % 2 == 0;

            return GestureDetector(
              onTap: () => _handleSquareTap(engine, square, piece),
              child: _buildSquare(
                square,
                piece,
                isLight,
                squareSize,
                state,
              ),
            );
          },
        ),
      ),
    );
  }

  void _handleSquareTap(ChessEngine engine, Square square, ChessPiece? piece) {
    if (selectedSquare == null) {
      // Select piece
      if (piece != null && piece.color == engine.state.turn) {
        setState(() {
          selectedSquare = square;
          legalMoves = engine.getLegalMovesFrom(square);
        });
      }
    } else {
      // Try to move
      final move = legalMoves.firstWhere(
        (m) => m.to == square,
        orElse: () => Move(
          piece: const ChessPiece(type: PieceType.pawn, color: PieceColor.white),
          from: selectedSquare!,
          to: square,
        ),
      );

      if (legalMoves.contains(move)) {
        // Check for pawn promotion
        if (move.piece.type == PieceType.pawn &&
            ((move.piece.color == PieceColor.white && square.row == 7) ||
                (move.piece.color == PieceColor.black && square.row == 0))) {
          _showPromotionDialog(engine, move);
        } else {
          engine.makeMove(move);
        }
        setState(() {
          selectedSquare = null;
          legalMoves = [];
        });
      } else if (piece != null && piece.color == engine.state.turn) {
        // Select different piece
        setState(() {
          selectedSquare = square;
          legalMoves = engine.getLegalMovesFrom(square);
        });
      } else {
        // Deselect
        setState(() {
          selectedSquare = null;
          legalMoves = [];
        });
      }
    }
  }

  Widget _buildSquare(
    Square square,
    ChessPiece? piece,
    bool isLight,
    double size,
    GameState state,
  ) {
    final isSelected = selectedSquare == square;
    final isLegalMove = legalMoves.any((m) => m.to == square && m.captured == null);
    final isLegalCapture = legalMoves.any((m) => m.to == square && m.captured != null);
    final isLastMove = state.moveHistory.isNotEmpty &&
        (state.moveHistory.last.from == square || state.moveHistory.last.to == square);
    final isInCheck = state.isCheck &&
        piece?.type == PieceType.king &&
        piece?.color == state.turn;

    return Container(
      decoration: BoxDecoration(
        color: isSelected
            ? Color(BoardColors.selectedSquare)
            : isLastMove
                ? Color(BoardColors.lastMoveHighlight)
                : isLight
                    ? Color(BoardColors.lightSquare)
                    : Color(BoardColors.darkSquare),
        border: isInCheck
            ? Border.all(color: Colors.red, width: 3)
            : isLegalCapture
                ? Border.all(color: Colors.red.withOpacity(0.7), width: 3)
                : null,
      ),
      child: Stack(
        children: [
          // Professional solid pieces
          if (piece != null)
            Center(
              child: Text(
                PieceSymbols.getSymbol(piece),
                style: TextStyle(
                  fontSize: size * 0.80,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                  color: piece.color == PieceColor.white
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFF000000),
                  shadows: piece.color == PieceColor.white
                      ? [
                          // White pieces - strong black outline
                          const Shadow(
                            color: Color(0xFF000000),
                            blurRadius: 1,
                            offset: Offset(-1.5, -1.5),
                          ),
                          const Shadow(
                            color: Color(0xFF000000),
                            blurRadius: 1,
                            offset: Offset(1.5, -1.5),
                          ),
                          const Shadow(
                            color: Color(0xFF000000),
                            blurRadius: 1,
                            offset: Offset(-1.5, 1.5),
                          ),
                          const Shadow(
                            color: Color(0xFF000000),
                            blurRadius: 1,
                            offset: Offset(1.5, 1.5),
                          ),
                          const Shadow(
                            color: Color(0xFF000000),
                            blurRadius: 3,
                            offset: Offset(2, 3),
                          ),
                        ]
                      : [
                          // Black pieces - white outline
                          const Shadow(
                            color: Color(0xFFFFFFFF),
                            blurRadius: 1,
                            offset: Offset(-1.5, -1.5),
                          ),
                          const Shadow(
                            color: Color(0xFFFFFFFF),
                            blurRadius: 1,
                            offset: Offset(1.5, -1.5),
                          ),
                          const Shadow(
                            color: Color(0xFFFFFFFF),
                            blurRadius: 1,
                            offset: Offset(-1.5, 1.5),
                          ),
                          const Shadow(
                            color: Color(0xFFFFFFFF),
                            blurRadius: 1,
                            offset: Offset(1.5, 1.5),
                          ),
                          const Shadow(
                            color: Color(0xFF000000),
                            blurRadius: 4,
                            offset: Offset(2, 3),
                          ),
                        ],
                ),
              ),
            ),

          // Legal move indicator - much more visible!
          if (isLegalMove)
            Center(
              child: Container(
                width: size * 0.38,
                height: size * 0.38,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF587346),
                    width: size * 0.08,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF587346).withOpacity(0.4),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),

          // Capture indicator  
          if (isLegalCapture)
            Center(
              child: Container(
                width: size * 0.95,
                height: size * 0.95,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.redAccent.withOpacity(0.7),
                    width: size * 0.08,
                  ),
                ),
              ),
            ),

          // Rank and file labels
          if (square.col == 0)
            Positioned(
              top: 2,
              left: 4,
              child: Text(
                '${square.row + 1}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isLight ? const Color(0xFFB58863) : const Color(0xFFF0D9B5),
                ),
              ),
            ),
          if (square.row == 0)
            Positioned(
              bottom: 2,
              right: 4,
              child: Text(
                String.fromCharCode(97 + square.col),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: isLight ? const Color(0xFFB58863) : const Color(0xFFF0D9B5),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showPromotionDialog(ChessEngine engine, Move move) async {
    final promotionPiece = await showDialog<PieceType>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Promotion'),
        content: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final pieceType in [PieceType.queen, PieceType.rook, PieceType.bishop, PieceType.knight])
              GestureDetector(
                onTap: () => Navigator.of(context).pop(pieceType),
                child: Text(
                  PieceSymbols.getSymbol(ChessPiece(type: pieceType, color: move.piece.color)),
                  style: const TextStyle(fontSize: 48),
                ),
              ),
          ],
        ),
      ),
    );

    if (promotionPiece != null) {
      engine.makeMove(Move(
        piece: move.piece,
        from: move.from,
        to: move.to,
        captured: move.captured,
        promotion: promotionPiece,
      ));
    }
  }

  /// Get asset path for piece image
  String _getPieceAssetPath(ChessPiece piece) {
    final color = piece.color == PieceColor.white ? 'w' : 'b';
    String type;
    
    switch (piece.type) {
      case PieceType.king:
        type = 'king';
        break;
      case PieceType.queen:
        type = 'queen';
        break;
      case PieceType.rook:
        type = 'rook';
        break;
      case PieceType.bishop:
        type = 'bishop';
        break;
      case PieceType.knight:
        type = 'knight';
        break;
      case PieceType.pawn:
        type = 'pawn';
        break;
    }
    
    return 'assets/pieces/${color}_$type.png';
  }
}
