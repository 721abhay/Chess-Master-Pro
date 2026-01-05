// Simple AI Evaluation for Chess

import '../models/chess_models.dart';
import '../engine/chess_engine.dart';

class SimpleAI {
  // Piece values in centipawns
  static const Map<PieceType, int> pieceValues = {
    PieceType.pawn: 100,
    PieceType.knight: 320,
    PieceType.bishop: 330,
    PieceType.rook: 500,
    PieceType.queen: 900,
    PieceType.king: 20000,
  };

  /// Get AI move based on difficulty
  static Move? getAIMove(ChessEngine engine, String difficulty) {
    final legalMoves = engine.getLegalMoves();
    if (legalMoves.isEmpty) return null;

    switch (difficulty) {
      case 'easy':
        return _getEasyMove(legalMoves);
      case 'medium':
        return _getMediumMove(engine, legalMoves);
      case 'hard':
        return _getHardMove(engine, legalMoves);
      default:
        return _getEasyMove(legalMoves);
    }
  }

  /// Easy: Random move (no strategy)
  static Move _getEasyMove(List<Move> legalMoves) {
    final randomIndex = DateTime.now().millisecondsSinceEpoch % legalMoves.length;
    return legalMoves[randomIndex];
  }

  /// Medium: Prefers captures and checks
  static Move _getMediumMove(ChessEngine engine, List<Move> legalMoves) {
    // Prioritize: Checkmates > Checks > Captures > Random
    
    // Look for checkmate
    for (final move in legalMoves) {
      if (move.isCheckmate) return move;
    }

    // Look for checks
    final checks = legalMoves.where((m) => m.isCheck).toList();
    if (checks.isNotEmpty) {
      return checks[DateTime.now().millisecondsSinceEpoch % checks.length];
    }

    // Look for captures (prefer higher value pieces)
    final captures = legalMoves.where((m) => m.captured != null).toList();
    if (captures.isNotEmpty) {
      captures.sort((a, b) {
        final valueA = pieceValues[a.captured!.type] ?? 0;
        final valueB = pieceValues[b.captured!.type] ?? 0;
        return valueB.compareTo(valueA); // Descending
      });
      return captures.first;
    }

    // Random move
    return _getEasyMove(legalMoves);
  }

  /// Hard: Evaluation-based move selection (minimax depth 1)
  static Move _getHardMove(ChessEngine engine, List<Move> legalMoves) {
    Move? bestMove;
    int bestScore = -999999;

    for (final move in legalMoves) {
      // Make move on a copy
      final testEngine = ChessEngine();
      testEngine.loadFromState(engine.state);
      testEngine.makeMove(move);

      // Evaluate position
      final score = _evaluatePosition(testEngine.state);

      if (score > bestScore) {
        bestScore = score;
        bestMove = move;
      }
    }

    return bestMove ?? _getEasyMove(legalMoves);
  }

  /// Simple position evaluation
  static int _evaluatePosition(GameState state) {
    if (state.isCheckmate) {
      return state.turn == PieceColor.white ? -999999 : 999999;
    }
    if (state.isStalemate || state.isDraw) {
      return 0;
    }

    int score = 0;

    // Count material
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = state.board[row][col];
        if (piece != null) {
          final value = pieceValues[piece.type] ?? 0;
          score += piece.color == PieceColor.black ? value : -value;
        }
      }
    }

    // Bonus for center control (simplified)
    for (int row = 3; row <= 4; row++) {
      for (int col = 3; col <= 4; col++) {
        final piece = state.board[row][col];
        if (piece != null && piece.type == PieceType.pawn) {
          score += piece.color == PieceColor.black ? 10 : -10;
        }
      }
    }

    return score;
  }
}
