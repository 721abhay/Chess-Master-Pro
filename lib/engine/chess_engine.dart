// Chess Engine - Core game logic and move generation
// Simplified version focusing on essential functionality

import '../models/chess_models.dart';
import 'package:flutter/foundation.dart';

class ChessEngine extends ChangeNotifier {
  late GameState _state;

  ChessEngine() {
    _state = _createInitialState();
  }

  GameState get state => _state;

  /// Initialize starting position
  GameState _createInitialState() {
    final board = List.generate(8, (_) => List<ChessPiece?>.filled(8, null));

    // Set up pawns
    for (int i = 0; i < 8; i++) {
      board[1][i] = const ChessPiece(type: PieceType.pawn, color: PieceColor.white);
      board[6][i] = const ChessPiece(type: PieceType.pawn, color: PieceColor.black);
    }

    // Set up pieces
    const backRank = [
      PieceType.rook,
      PieceType.knight,
      PieceType.bishop,
      PieceType.queen,
      PieceType.king,
      PieceType.bishop,
      PieceType.knight,
      PieceType.rook,
    ];

    for (int i = 0; i < 8; i++) {
      board[0][i] = ChessPiece(type: backRank[i], color: PieceColor.white);
      board[7][i] = ChessPiece(type: backRank[i], color: PieceColor.black);
    }

    return GameState(
      board: board,
      turn: PieceColor.white,
      castlingRights: const CastlingRights(),
    );
  }

  /// Make a move
  bool makeMove(Move move) {
    // Validate move is in legal moves
    final legalMoves = getLegalMoves();
    final isLegal = legalMoves.any((m) =>
        m.from == move.from &&
        m.to == move.to &&
        (m.promotion == null || m.promotion == move.promotion));

    if (!isLegal) return false;

    // Create new board
    final newBoard = _copyBoard(_state.board);

    // Make the move
    newBoard[move.to.row][move.to.col] = newBoard[move.from.row][move.from.col];
    newBoard[move.from.row][move.from.col] = null;

    // Handle promotion
    if (move.promotion != null) {
      newBoard[move.to.row][move.to.col] =
          ChessPiece(type: move.promotion!, color: move.piece.color);
    }

    // Handle castling
    if (move.castling != null) {
      if (move.castling == 'kingside') {
        final rookFrom = Square(move.from.row, 7);
        final rookTo = Square(move.from.row, 5);
        newBoard[rookTo.row][rookTo.col] = newBoard[rookFrom.row][rookFrom.col];
        newBoard[rookFrom.row][rookFrom.col] = null;
      } else {
        final rookFrom = Square(move.from.row, 0);
        final rookTo = Square(move.from.row, 3);
        newBoard[rookTo.row][rookTo.col] = newBoard[rookFrom.row][rookFrom.col];
        newBoard[rookFrom.row][rookFrom.col] = null;
      }
    }

    // Handle en passant
    if (move.isEnPassant) {
      final captureRow = move.piece.color == PieceColor.white ? move.to.row - 1 : move.to.row + 1;
      newBoard[captureRow][move.to.col] = null;
    }

    // Update castling rights
    final newCastlingRights = _updateCastlingRights(move);

    // Update en passant square
    Square? newEnPassant;
    if (move.piece.type == PieceType.pawn && (move.to.row - move.from.row).abs() == 2) {
      final enPassantRow = move.piece.color == PieceColor.white ? move.from.row + 1 : move.from.row - 1;
      newEnPassant = Square(enPassantRow, move.from.col);
    }

    // Switch turns
    final newTurn = _state.turn.opposite;

    // Update move counters
    final newHalfMoveClock = (move.captured != null || move.piece.type == PieceType.pawn) ? 0 : _state.halfMoveClock + 1;
    final newFullMoveNumber = newTurn == PieceColor.white ? _state.fullMoveNumber + 1 : _state.fullMoveNumber;

    // Check game status
    _state = GameState(
      board: newBoard,
      turn: newTurn,
      castlingRights: newCastlingRights,
      enPassantSquare: newEnPassant,
      halfMoveClock: newHalfMoveClock,
      fullMoveNumber: newFullMoveNumber,
      moveHistory: [..._state.moveHistory, move],
    );

    // Update check/checkmate status
    _state = _state.copyWith(
      isCheck: _isInCheck(_state.board, newTurn),
      isCheckmate: _isCheckmate(),
      isStalemate: _isStalemate(),
      isDraw: _isDraw(),
    );

    notifyListeners();
    return true;
  }

  /// Get all legal moves
  List<Move> getLegalMoves() {
    final pseudoLegalMoves = _getPseudoLegalMoves(_state.board, _state.turn);
    return pseudoLegalMoves.where((move) => !_wouldBeInCheck(move)).toList();
  }

  /// Get legal moves from a specific square
  List<Move> getLegalMovesFrom(Square from) {
    return getLegalMoves().where((m) => m.from == from).toList();
  }

  /// Generate pseudo-legal moves (without checking for check)
  List<Move> _getPseudoLegalMoves(List<List<ChessPiece?>> board, PieceColor color) {
    final moves = <Move>[];

    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece == null || piece.color != color) continue;

        final from = Square(row, col);

        switch (piece.type) {
          case PieceType.pawn:
            moves.addAll(_getPawnMoves(board, from, piece));
            break;
          case PieceType.knight:
            moves.addAll(_getKnightMoves(board, from, piece));
            break;
          case PieceType.bishop:
            moves.addAll(_getBishopMoves(board, from, piece));
            break;
          case PieceType.rook:
            moves.addAll(_getRookMoves(board, from, piece));
            break;
          case PieceType.queen:
            moves.addAll(_getQueenMoves(board, from, piece));
            break;
          case PieceType.king:
            moves.addAll(_getKingMoves(board, from, piece));
            break;
        }
      }
    }

    return moves;
  }

  /// Pawn moves
  List<Move> _getPawnMoves(List<List<ChessPiece?>> board, Square from, ChessPiece piece) {
    final moves = <Move>[];
    final direction = piece.color == PieceColor.white ? 1 : -1;
    final startRow = piece.color == PieceColor.white ? 1 : 6;
    final promotionRow = piece.color == PieceColor.white ? 7 : 0;

    // Forward move
    final forwardOne = Square(from.row + direction, from.col);
    if (forwardOne.isValid && board[forwardOne.row][forwardOne.col] == null) {
      if (forwardOne.row == promotionRow) {
        // Promotion
        for (final promoPiece in [PieceType.queen, PieceType.rook, PieceType.bishop, PieceType.knight]) {
         moves.add(Move(piece: piece, from: from, to: forwardOne, promotion: promoPiece));
        }
      } else {
        moves.add(Move(piece: piece, from: from, to: forwardOne));
      }

      // Double move from starting position
      if (from.row == startRow) {
        final forwardTwo = Square(from.row + direction * 2, from.col);
        if (board[forwardTwo.row][forwardTwo.col] == null) {
          moves.add(Move(piece: piece, from: from, to: forwardTwo));
        }
      }
    }

    // Captures
    for (final colOffset in [-1, 1]) {
      final captureSquare = Square(from.row + direction, from.col + colOffset);
      if (captureSquare.isValid) {
        final target = board[captureSquare.row][captureSquare.col];
        if (target != null && target.color != piece.color) {
          if (captureSquare.row == promotionRow) {
            for (final promoPiece in [PieceType.queen, PieceType.rook, PieceType.bishop, PieceType.knight]) {
              moves.add(Move(piece: piece, from: from, to: captureSquare, captured: target, promotion: promoPiece));
            }
          } else {
            moves.add(Move(piece: piece, from: from, to: captureSquare, captured: target));
          }
        }

        // En passant
        if (_state.enPassantSquare == captureSquare) {
          final capturedPawn = board[from.row][captureSquare.col]!;
          moves.add(Move(
            piece: piece,
            from: from,
            to: captureSquare,
            captured: capturedPawn,
            isEnPassant: true,
          ));
        }
      }
    }

    return moves;
  }

  /// Knight moves
  List<Move> _getKnightMoves(List<List<ChessPiece?>> board, Square from, ChessPiece piece) {
    final moves = <Move>[];
    final offsets = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1],
    ];

    for (final offset in offsets) {
      final to = Square(from.row + offset[0], from.col + offset[1]);
      if (to.isValid) {
        final target = board[to.row][to.col];
        if (target == null || target.color != piece.color) {
          moves.add(Move(piece: piece, from: from, to: to, captured: target));
        }
      }
    }

    return moves;
  }

  /// Bishop moves
  List<Move> _getBishopMoves(List<List<ChessPiece?>> board, Square from, ChessPiece piece) {
    return _getSlidingMoves(board, from, piece, [[-1, -1], [-1, 1], [1, -1], [1, 1]]);
  }

  /// Rook moves
  List<Move> _getRookMoves(List<List<ChessPiece?>> board, Square from, ChessPiece piece) {
    return _getSlidingMoves(board, from, piece, [[-1, 0], [1, 0], [0, -1], [0, 1]]);
  }

  /// Queen moves
  List<Move> _getQueenMoves(List<List<ChessPiece?>> board, Square from, ChessPiece piece) {
    return _getSlidingMoves(board, from, piece, [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1], [0, 1],
      [1, -1], [1, 0], [1, 1],
    ]);
  }

  /// King moves
  List<Move> _getKingMoves(List<List<ChessPiece?>> board, Square from, ChessPiece piece) {
    final moves = <Move>[];
    final offsets = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1], [0, 1],
      [1, -1], [1, 0], [1, 1],
    ];

    for (final offset in offsets) {
      final to = Square(from.row + offset[0], from.col + offset[1]);
      if (to.isValid) {
        final target = board[to.row][to.col];
        if (target == null || target.color != piece.color) {
          moves.add(Move(piece: piece, from: from, to: to, captured: target));
        }
      }
    }

    // Castling
    moves.addAll(_getCastlingMoves(board, from, piece));

    return moves;
  }

  /// Helper for sliding pieces (bishop, rook, queen)
  List<Move> _getSlidingMoves(List<List<ChessPiece?>> board, Square from, ChessPiece piece, List<List<int>> directions) {
    final moves = <Move>[];

    for (final dir in directions) {
      int row = from.row + dir[0];
      int col = from.col + dir[1];

      while (row >= 0 && row < 8 && col >= 0 && col < 8) {
        final target = board[row][col];
        final to = Square(row, col);

        if (target == null) {
          moves.add(Move(piece: piece, from: from, to: to));
        } else {
          if (target.color != piece.color) {
            moves.add(Move(piece: piece, from: from, to: to, captured: target));
          }
          break;
        }

        row += dir[0];
        col += dir[1];
      }
    }

    return moves;
  }

  /// Castling moves
  List<Move> _getCastlingMoves(List<List<ChessPiece?>> board, Square from, ChessPiece piece) {
    final moves = <Move>[];
    if (_isInCheck(board, piece.color)) return moves;

    // Kingside castling
    if ((piece.color == PieceColor.white && _state.castlingRights.whiteKingside) ||
        (piece.color == PieceColor.black && _state.castlingRights.blackKingside)) {
      if (board[from.row][5] == null && board[from.row][6] == null) {
        // Check if squares are not attacked
        if (!_isSquareAttacked(board, Square(from.row, 5), piece.color.opposite) &&
            !_isSquareAttacked(board, Square(from.row, 6), piece.color.opposite)) {
          moves.add(Move(
            piece: piece,
            from: from,
            to: Square(from.row, 6),
            castling: 'kingside',
          ));
        }
      }
    }

    // Queenside castling
    if ((piece.color == PieceColor.white && _state.castlingRights.whiteQueenside) ||
        (piece.color == PieceColor.black && _state.castlingRights.blackQueenside)) {
      if (board[from.row][1] == null &&
          board[from.row][2] == null &&
          board[from.row][3] == null) {
        if (!_isSquareAttacked(board, Square(from.row, 2), piece.color.opposite) &&
            !_isSquareAttacked(board, Square(from.row, 3), piece.color.opposite)) {
          moves.add(Move(
            piece: piece,
            from: from,
            to: Square(from.row, 2),
            castling: 'queenside',
          ));
        }
      }
    }

    return moves;
  }

  /// Check if a move would leave king in check
  bool _wouldBeInCheck(Move move) {
    final tempBoard = _copyBoard(_state.board);

    // Make move on temporary board
    tempBoard[move.to.row][move.to.col] = tempBoard[move.from.row][move.from.col];
    tempBoard[move.from.row][move.from.col] = null;

    if (move.isEnPassant) {
      final captureRow = move.piece.color == PieceColor.white ? move.to.row - 1 : move.to.row + 1;
      tempBoard[captureRow][move.to.col] = null;
    }

    return _isInCheck(tempBoard, move.piece.color);
  }

  /// Check if king is in check
  bool _isInCheck(List<List<ChessPiece?>> board, PieceColor color) {
    // Find king
    Square? kingSquare;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece?.type == PieceType.king && piece?.color == color) {
          kingSquare = Square(row, col);
          break;
        }
      }
      if (kingSquare != null) break;
    }

    if (kingSquare == null) return false;

    return _isSquareAttacked(board, kingSquare, color.opposite);
  }

  /// Check if a square is attacked by opponent
  bool _isSquareAttacked(List<List<ChessPiece?>> board, Square square, PieceColor byColor) {
    // Check all opponent pieces to see if they can attack this square
    for (int row = 0; row < 8; row++) {
   for (int col = 0; col < 8; col++) {
        final piece = board[row][col];
        if (piece == null || piece.color != byColor) continue;

        final from = Square(row, col);

        // Check if this piece can attack the target square
        switch (piece.type) {
          case PieceType.pawn:
            final direction = piece.color == PieceColor.white ? 1 : -1;
            for (final colOffset in [-1, 1]) {
              final attackSquare = Square(from.row + direction, from.col + colOffset);
              if (attackSquare == square) return true;
            }
            break;

          case PieceType.knight:
            final offsets = [
              [-2, -1], [-2, 1], [-1, -2], [-1, 2],
              [1, -2], [1, 2], [2, -1], [2, 1],
            ];
            for (final offset in offsets) {
              final attackSquare = Square(from.row + offset[0], from.col + offset[1]);
              if (attackSquare == square) return true;
            }
            break;

          case PieceType.bishop:
          case PieceType.queen:
            final directions = [[-1, -1], [-1, 1], [1, -1], [1, 1]];
            if (_canReachAlongRay(board, from, square, directions)) return true;
            if (piece.type == PieceType.bishop) break;
            // Queen continues to check rook directions
            continue queen;

          queen:
          case PieceType.rook:
            final directions = [[-1, 0], [1, 0], [0, -1], [0, 1]];
            if (_canReachAlongRay(board, from, square, directions)) return true;
            break;

          case PieceType.king:
            if ((from.row - square.row).abs() <= 1 && (from.col - square.col).abs() <= 1) {
              return true;
            }
            break;
        }
      }
    }

    return false;
  }

  /// Helper to check if a piece can reach a square along sliding directions
  bool _canReachAlongRay(List<List<ChessPiece?>> board, Square from, Square target, List<List<int>> directions) {
    for (final dir in directions) {
      int row = from.row + dir[0];
      int col = from.col + dir[1];

      while (row >= 0 && row < 8 && col >= 0 && col < 8) {
        if (row == target.row && col == target.col) return true;
        if (board[row][col] != null) break; // Blocked
        row += dir[0];
        col += dir[1];
      }
    }
    return false;
  }

  /// Check for checkmate
  bool _isCheckmate() {
    return _state.isCheck && getLegalMoves().isEmpty;
  }

  /// Check for stalemate
  bool _isStalemate() {
    return !_state.isCheck && getLegalMoves().isEmpty;
  }

  /// Check for draw
  bool _isDraw() {
    return _state.halfMoveClock >= 100 || _isInsufficientMaterial();
  }

  /// Check for insufficient material
  bool _isInsufficientMaterial() {
    final pieces = <ChessPiece>[];
    for (final row in _state.board) {
      for (final piece in row) {
        if (piece != null && piece.type != PieceType.king) {
          pieces.add(piece);
        }
      }
    }

    if (pieces.isEmpty) return true; // K vs K
    if (pieces.length == 1) {
      // K+N vs K or K+B vs K
      final piece = pieces.first;
      return piece.type == PieceType.knight || piece.type == PieceType.bishop;
    }

    return false;
  }

  /// Update castling rights after a move
  CastlingRights _updateCastlingRights(Move move) {
    var rights = _state.castlingRights;

    // King moves
    if (move.piece.type == PieceType.king) {
      if (move.piece.color == PieceColor.white) {
        rights = rights.copyWith(whiteKingside: false, whiteQueenside: false);
      } else {
        rights = rights.copyWith(blackKingside: false, blackQueenside: false);
      }
    }

    // Rook moves
    if (move.piece.type == PieceType.rook) {
      if (move.piece.color == PieceColor.white) {
        if (move.from.col == 0) rights = rights.copyWith(whiteQueenside: false);
        if (move.from.col == 7) rights = rights.copyWith(whiteKingside: false);
      } else {
        if (move.from.col == 0) rights = rights.copyWith(blackQueenside: false);
        if (move.from.col == 7) rights = rights.copyWith(blackKingside: false);
      }
    }

    return rights;
  }

  /// Copy board
  List<List<ChessPiece?>> _copyBoard(List<List<ChessPiece?>> board) {
    return board.map((row) => List<ChessPiece?>.from(row)).toList();
  }

  /// Reset game
  void reset() {
    _state = _createInitialState();
    notifyListeners();
  }

  /// Load state from another game state (for AI testing)
  void loadFromState(GameState state) {
    _state = state.copyWith(
      board: state.board.map((row) => List<ChessPiece?>.from(row)).toList(),
    );
  }

  /// Get FEN string
  String getFEN() {
    String fen = '';

    // Board position
    for (int row = 7; row >= 0; row--) {
      int emptyCount = 0;
      for (int col = 0; col < 8; col++) {
        final piece = _state.board[row][col];
        if (piece != null) {
          if (emptyCount > 0) {
            fen += emptyCount.toString();
            emptyCount = 0;
          }
          final symbol = piece.type.symbol;
          fen += piece.color == PieceColor.white ? symbol.toUpperCase() : symbol;
        } else {
          emptyCount++;
        }
      }
      if (emptyCount > 0) fen += emptyCount.toString();
      if (row > 0) fen += '/';
    }

    // Active color
    fen += ' ${_state.turn.symbol}';

    // Castling rights
    String castling = '';
    if (_state.castlingRights.whiteKingside) castling += 'K';
    if (_state.castlingRights.whiteQueenside) castling += 'Q';
    if (_state.castlingRights.blackKingside) castling += 'k';
    if (_state.castlingRights.blackQueenside) castling += 'q';
    fen += ' ${castling.isEmpty ? '-' : castling}';

    // En passant
    fen += ' ${_state.enPassantSquare?.algebraic ?? '-'}';

    // Move clocks
    fen += ' ${_state.halfMoveClock} ${_state.fullMoveNumber}';

    return fen;
  }
}
