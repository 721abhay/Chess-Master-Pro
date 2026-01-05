// Chess Models - Core data structures for chess game

/// Piece colors
enum PieceColor {
  white('w'),
  black('b');

  final String symbol;
  const PieceColor(this.symbol);

  PieceColor get opposite => this == PieceColor.white ? PieceColor.black : PieceColor.white;
}

/// Piece types
enum PieceType {
  pawn('p'),
  knight('n'),
  bishop('b'),
  rook('r'),
  queen('q'),
  king('k');

  final String symbol;
  const PieceType(this.symbol);
}

/// Represents a chess piece
class ChessPiece {
  final PieceType type;
  final PieceColor color;

  const ChessPiece({required this.type, required this.color});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChessPiece &&
          runtimeType == other.runtimeType &&
          type == other.type &&
          color == other.color;

  @override
  int get hashCode => type.hashCode ^ color.hashCode;

  @override
 String toString() => '${color.symbol}${type.symbol}';
}

/// Represents a square on the chess board
class Square {
  final int row; // 0-7, where 0 is rank 1, 7 is rank 8
  final int col; // 0-7, where 0 is file 'a', 7 is file 'h'

  const Square(this.row, this.col);

  bool get isValid => row >= 0 && row < 8 && col >= 0 && col < 8;

  String get algebraic => '${String.fromCharCode(97 + col)}${row + 1}';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Square &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          col == other.col;

  @override
  int get hashCode => row.hashCode ^ col.hashCode;

  @override
  String toString() => algebraic;
}

/// Represents a chess move
class Move {
  final ChessPiece piece;
  final Square from;
  final Square to;
  final ChessPiece? captured;
  final PieceType? promotion;
  final String? castling; // 'kingside' or 'queenside'
  final bool isEnPassant;
  final bool isCheck;
  final bool isCheckmate;

  const Move({
    required this.piece,
    required this.from,
    required this.to,
    this.captured,
    this.promotion,
    this.castling,
    this.isEnPassant = false,
    this.isCheck = false,
    this.isCheckmate = false,
  });

  /// Convert move to algebraic notation
  String toAlgebraic() {
    if (castling != null) {
      return castling == 'kingside' ? 'O-O' : 'O-O-O';
    }

    String notation = piece.type != PieceType.pawn ? piece.type.symbol.toUpperCase() : '';

    if (captured != null) {
      if (piece.type == PieceType.pawn) {
        notation += String.fromCharCode(97 + from.col);
      }
      notation += 'x';
    }

    notation += to.algebraic;

    if (promotion != null) {
      notation += '=${promotion!.symbol.toUpperCase()}';
    }

    if (isCheckmate) {
      notation += '#';
    } else if (isCheck) {
      notation += '+';
    }

    return notation;
  }

  @override
  String toString() => toAlgebraic();
}

/// Castling rights
class CastlingRights {
  final bool whiteKingside;
  final bool whiteQueenside;
  final bool blackKingside;
  final bool blackQueenside;

  const CastlingRights({
    this.whiteKingside = true,
    this.whiteQueenside = true,
    this.blackKingside = true,
    this.blackQueenside = true,
  });

  CastlingRights copyWith({
    bool? whiteKingside,
    bool? whiteQueenside,
    bool? blackKingside,
    bool? blackQueenside,
  }) {
    return CastlingRights(
      whiteKingside: whiteKingside ?? this.whiteKingside,
      whiteQueenside: whiteQueenside ?? this.whiteQueenside,
      blackKingside: blackKingside ?? this.blackKingside,
      blackQueenside: blackQueenside ?? this.blackQueenside,
    );
  }
}

/// Complete game state
class GameState {
  final List<List<ChessPiece?>> board;
  final PieceColor turn;
  final CastlingRights castlingRights;
  final Square? enPassantSquare;
  final int halfMoveClock;
  final int fullMoveNumber;
  final List<Move> moveHistory;
  final bool isCheck;
  final bool isCheckmate;
  final bool isStalemate;
  final bool isDraw;

  const GameState({
    required this.board,
    required this.turn,
    required this.castlingRights,
    this.enPassantSquare,
    this.halfMoveClock = 0,
    this.fullMoveNumber = 1,
    this.moveHistory = const [],
    this.isCheck = false,
    this.isCheckmate = false,
    this.isStalemate = false,
    this.isDraw = false,
  });

  GameState copyWith({
    List<List<ChessPiece?>>? board,
    PieceColor? turn,
    CastlingRights? castlingRights,
    Square? enPassantSquare,
    int? halfMoveClock,
    int? fullMoveNumber,
    List<Move>? moveHistory,
    bool? isCheck,
    bool? isCheckmate,
    bool? isStalemate,
    bool? isDraw,
  }) {
    return GameState(
      board: board ?? this.board,
      turn: turn ?? this.turn,
      castlingRights: castlingRights ?? this.castlingRights,
      enPassantSquare: enPassantSquare ?? this.enPassantSquare,
      halfMoveClock: halfMoveClock ?? this.halfMoveClock,
      fullMoveNumber: fullMoveNumber ?? this.fullMoveNumber,
      moveHistory: moveHistory ?? this.moveHistory,
      isCheck: isCheck ?? this.isCheck,
      isCheckmate: isCheckmate ?? this.isCheckmate,
      isStalemate: isStalemate ?? this.isStalemate,
      isDraw: isDraw ?? this.isDraw,
    );
  }

  /// Get list of all captured pieces
  Map<PieceColor, List<ChessPiece>> getCapturedPieces() {
    final initial = <PieceType, int>{
      PieceType.pawn: 8,
      PieceType.knight: 2,
      PieceType.bishop: 2,
      PieceType.rook: 2,
      PieceType.queen: 1,
    };

    final whiteCaptured = <ChessPiece>[];
    final blackCaptured = <ChessPiece>[];

    // Count pieces on board
    final whitePieces = <PieceType, int>{};
    final blackPieces = <PieceType, int>{};

    for (final row in board) {
      for (final piece in row) {
        if (piece != null && piece.type != PieceType.king) {
          if (piece.color == PieceColor.white) {
            whitePieces[piece.type] = (whitePieces[piece.type] ?? 0) + 1;
          } else {
            blackPieces[piece.type] = (blackPieces[piece.type] ?? 0) + 1;
          }
        }
      }
    }

    // Calculate captured pieces
    for (final entry in initial.entries) {
      final whiteCount = whitePieces[entry.key] ?? 0;
      final blackCount = blackPieces[entry.key] ?? 0;

      // Black has captured white pieces
      for (int i = 0; i < entry.value - whiteCount; i++) {
        blackCaptured.add(ChessPiece(type: entry.key, color: PieceColor.white));
      }

      // White has captured black pieces
      for (int i = 0; i < entry.value - blackCount; i++) {
        whiteCaptured.add(ChessPiece(type: entry.key, color: PieceColor.black));
      }
    }

    return {
      PieceColor.white: whiteCaptured,
      PieceColor.black: blackCaptured,
    };
  }
}

/// Unicode symbols for chess pieces
class PieceSymbols {
  static const white = {
    PieceType.pawn: '♙',
    PieceType.knight: '♘',
    PieceType.bishop: '♗',
    PieceType.rook: '♖',
    PieceType.queen: '♕',
    PieceType.king: '♔',
  };

  static const black = {
    PieceType.pawn: '♟',
    PieceType.knight: '♞',
    PieceType.bishop: '♝',
    PieceType.rook: '♜',
    PieceType.queen: '♛',
    PieceType.king: '♚',
  };

  static String getSymbol(ChessPiece piece) {
    return piece.color == PieceColor.white
        ? white[piece.type]!
        : black[piece.type]!;
  }
}
