// Four Player Chess Models

import 'package:flutter/material.dart';
import '../models/chess_models.dart';

/// Four player colors
enum FourPlayerColor {
  white,  // South position
  black,  // North position  
  red,    // East position
  blue,   // West position
}

/// Game mode for 4-player chess
enum FourPlayerMode {
  freeForAll,  // Every player for themselves
  teams,       // white+black vs red+blue
}

/// Extended chess piece with 4 colors
class FourPlayerPiece {
  final PieceType type;
  final FourPlayerColor color;
  final bool hasMoved;

  const FourPlayerPiece({
    required this.type,
    required this.color,
    this.hasMoved = false,
  });

  FourPlayerPiece copyWith({
    PieceType? type,
    FourPlayerColor? color,
    bool? hasMoved,
  }) {
    return FourPlayerPiece(
      type: type ?? this.type,
      color: color ?? this.color,
      hasMoved: hasMoved ?? this.hasMoved,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FourPlayerPiece &&
          type == other.type &&
          color == other.color;

  @override
  int get hashCode => type.hashCode ^ color.hashCode;

  /// Get display color for UI
  Color getDisplayColor() {
    switch (color) {
      case FourPlayerColor.white:
        return const Color(0xFFFFFFFF);
      case FourPlayerColor.black:
        return const Color(0xFF000000);
      case FourPlayerColor.red:
        return const Color(0xFFFF0000);
      case FourPlayerColor.blue:
        return const Color(0xFF0066FF);
    }
  }
}

/// 4-player chess move
class FourPlayerMove {
  final FourPlayerPiece piece;
  final Square from;
  final Square to;
  final FourPlayerPiece? captured;
  final PieceType? promotion;
  final bool isCheck;
  final bool isCheckmate;

  const FourPlayerMove({
    required this.piece,
    required this.from,
    required this.to,
    this.captured,
    this.promotion,
    this.isCheck = false,
    this.isCheckmate = false,
  });
}

/// Game state for 4-player chess
class FourPlayerGameState {
  final List<List<FourPlayerPiece?>> board; // 14x14 board
  final FourPlayerColor currentTurn;
  final Set<FourPlayerColor> eliminated;
  final FourPlayerMode mode;
  final List<FourPlayerMove> moveHistory;
  final Map<FourPlayerColor, bool> inCheck;
  final Square? enPassantSquare;
  
  FourPlayerColor? winner; // For free-for-all
  Set<FourPlayerColor>? winningTeam; // For team mode

  FourPlayerGameState({
    required this.board,
    required this.currentTurn,
    required this.eliminated,
    required this.mode,
    required this.moveHistory,
    required this.inCheck,
    this.enPassantSquare,
    this.winner,
    this.winningTeam,
  });

  /// Get next player in turn rotation (clockwise)
  FourPlayerColor getNextTurn() {
    final order = [
      FourPlayerColor.white,
      FourPlayerColor.red,
      FourPlayerColor.black,
      FourPlayerColor.blue,
    ];
    
    int currentIndex = order.indexOf(currentTurn);
    
    // Find next non-eliminated player
    for (int i = 1; i <= 4; i++) {
      final nextIndex = (currentIndex + i) % 4;
      final nextColor = order[nextIndex];
      if (!eliminated.contains(nextColor)) {
        return nextColor;
      }
    }
    
    return currentTurn; // Shouldn't reach here
  }

  /// Check if game is over
  bool get isGameOver {
    final activePlayers = FourPlayerColor.values
        .where((c) => !eliminated.contains(c))
        .toSet();
    
    if (mode == FourPlayerMode.freeForAll) {
      return activePlayers.length <= 1;
    } else {
      // Team mode: check if one team is completely eliminated
      final whiteBlackAlive = !eliminated.contains(FourPlayerColor.white) ||
                               !eliminated.contains(FourPlayerColor.black);
      final redBlueAlive = !eliminated.contains(FourPlayerColor.red) ||
                          !eliminated.contains(FourPlayerColor.blue);
      return !whiteBlackAlive || !redBlueAlive;
    }
  }

  /// Check if square is in playable area (cross shape)
  static bool isPlayableSquare(int row, int col) {
    // 14x14 board with cross shape
    // Center 8x8 is always playable
    if (row >= 3 && row < 11 && col >= 3 && col < 11) {
      return true;
    }
    
    // Top/bottom extensions
    if ((row < 3 || row >= 11) && (col >= 3 && col < 11)) {
      return true;
    }
    
    // Left/right extensions
    if ((col < 3 || col >= 11) && (row >= 3 && row < 11)) {
      return true;
    }
    
    return false;
  }

  FourPlayerGameState copyWith({
    List<List<FourPlayerPiece?>>? board,
    FourPlayerColor? currentTurn,
    Set<FourPlayerColor>? eliminated,
    FourPlayerMode? mode,
    List<FourPlayerMove>? moveHistory,
    Map<FourPlayerColor, bool>? inCheck,
    Square? enPassantSquare,
    FourPlayerColor? winner,
    Set<FourPlayerColor>? winningTeam,
  }) {
    return FourPlayerGameState(
      board: board ?? this.board.map((row) => List<FourPlayerPiece?>.from(row)).toList(),
      currentTurn: currentTurn ?? this.currentTurn,
      eliminated: eliminated ?? Set<FourPlayerColor>.from(this.eliminated),
      mode: mode ?? this.mode,
      moveHistory: moveHistory ?? List<FourPlayerMove>.from(this.moveHistory),
      inCheck: inCheck ?? Map<FourPlayerColor, bool>.from(this.inCheck),
      enPassantSquare: enPassantSquare ?? this.enPassantSquare,
      winner: winner ?? this.winner,
      winningTeam: winningTeam ?? (this.winningTeam != null ? Set<FourPlayerColor>.from(this.winningTeam!) : null),
    );
  }
}
