// Four Player Chess Engine

import 'package:flutter/foundation.dart';
import '../models/chess_models.dart';
import '../models/four_player_models.dart';

class FourPlayerChessEngine extends ChangeNotifier {
  late FourPlayerGameState _state;

  FourPlayerChessEngine({FourPlayerMode mode = FourPlayerMode.freeForAll}) {
    _state = _initializeGame(mode);
  }

  FourPlayerGameState get state => _state;

  /// Initialize new 4-player game
  FourPlayerGameState _initializeGame(FourPlayerMode mode) {
    final board = List.generate(
      14,
      (row) => List.generate(14, (col) => null as FourPlayerPiece?),
    );

    // Setup White pieces (South, rows 0-1: major pieces back at 0, pawns front at 1)
    _setupPlayerPieces(board, FourPlayerColor.white, 0, 1);

    // Setup Black pieces (North, rows 12-13: major pieces back at 13, pawns front at 12)
    _setupPlayerPieces(board, FourPlayerColor.black, 13, 12);

    // Setup Red pieces (East, cols 12-13: major pieces back at 13, pawns front at 12)
    _setupPlayerPiecesVertical(board, FourPlayerColor.red, 13, 12);

    // Setup Blue pieces (West, cols 0-1: major pieces back at 0, pawns front at 1)  
    _setupPlayerPiecesVertical(board, FourPlayerColor.blue, 0, 1);

    return FourPlayerGameState(
      board: board,
      currentTurn: FourPlayerColor.white,
      eliminated: {},
      mode: mode,
      moveHistory: [],
      inCheck: {
        FourPlayerColor.white: false,
        FourPlayerColor.black: false,
        FourPlayerColor.red: false,
        FourPlayerColor.blue: false,
      },
    );
  }

  /// Setup pieces for horizontal players (White/Black)
  void _setupPlayerPieces(
    List<List<FourPlayerPiece?>> board,
    FourPlayerColor color,
    int backRow,
    int pawnRow,
  ) {
    // Back row pieces (standard: R-N-B-K-Q-B-N-R for white facing up)
    board[backRow][3] = FourPlayerPiece(type: PieceType.rook, color: color);
    board[backRow][4] = FourPlayerPiece(type: PieceType.knight, color: color);
    board[backRow][5] = FourPlayerPiece(type: PieceType.bishop, color: color);
    board[backRow][6] = FourPlayerPiece(type: PieceType.queen, color: color);   // Queen on d-file
    board[backRow][7] = FourPlayerPiece(type: PieceType.king, color: color);    // King on e-file
    board[backRow][8] = FourPlayerPiece(type: PieceType.bishop, color: color);
    board[backRow][9] = FourPlayerPiece(type: PieceType.knight, color: color);
    board[backRow][10] = FourPlayerPiece(type: PieceType.rook, color: color);

    // Pawns
    for (int col = 3; col <= 10; col++) {
      board[pawnRow][col] = FourPlayerPiece(type: PieceType.pawn, color: color);
    }
  }

  /// Setup pieces for vertical players (Red/Blue)
  void _setupPlayerPiecesVertical(
    List<List<FourPlayerPiece?>> board,
    FourPlayerColor color,
    int backCol,
    int pawnCol,
  ) {
    // Back row pieces (vertical players: same relative order)
    board[3][backCol] = FourPlayerPiece(type: PieceType.rook, color: color);
    board[4][backCol] = FourPlayerPiece(type: PieceType.knight, color: color);
    board[5][backCol] = FourPlayerPiece(type: PieceType.bishop, color: color);
    board[6][backCol] = FourPlayerPiece(type: PieceType.queen, color: color);   // Queen
    board[7][backCol] = FourPlayerPiece(type: PieceType.king, color: color);    // King
    board[8][backCol] = FourPlayerPiece(type: PieceType.bishop, color: color);
    board[9][backCol] = FourPlayerPiece(type: PieceType.knight, color: color);
    board[10][backCol] = FourPlayerPiece(type: PieceType.rook, color: color);

    // Pawns
    for (int row = 3; row <= 10; row++) {
      board[row][pawnCol] = FourPlayerPiece(type: PieceType.pawn, color: color);
    }
  }

  /// Get legal moves from a square
  List<FourPlayerMove> getLegalMovesFrom(Square from) {
    final piece = _state.board[from.row][from.col];
    if (piece == null || piece.color != _state.currentTurn || _state.eliminated.contains(piece.color)) {
      return [];
    }

    final moves = _getPseudoLegalMoves(from, piece);
    
    // Filter out moves that leave own king in check
    return moves.where((move) {
      final testState = _applyMove(move);
      return !_isKingInCheck(testState, piece.color);
    }).toList();
  }

  /// Get pseudo-legal moves (doesn't check for own king safety)
  List<FourPlayerMove> _getPseudoLegalMoves(Square from, FourPlayerPiece piece) {
    switch (piece.type) {
      case PieceType.pawn:
        return _getPawnMoves(from, piece);
      case PieceType.knight:
        return _getKnightMoves(from, piece);
      case PieceType.bishop:
        return _getSlidingMoves(from, piece, [[-1, -1], [-1, 1], [1, -1], [1, 1]]);
      case PieceType.rook:
        return _getSlidingMoves(from, piece, [[-1, 0], [1, 0], [0, -1], [0, 1]]);
      case PieceType.queen:
        return _getSlidingMoves(from, piece, [
          [-1, -1], [-1, 1], [1, -1], [1, 1],
          [-1, 0], [1, 0], [0, -1], [0, 1]
        ]);
      case PieceType.king:
        final kingMoves = _getKingMoves(from, piece);
        // Add castling moves
        kingMoves.addAll(_getCastlingMoves(from, piece));
        return kingMoves;
    }
  }

  /// Get pawn moves (direction depends on player color)
  List<FourPlayerMove> _getPawnMoves(Square from, FourPlayerPiece piece) {
    final moves = <FourPlayerMove>[];
    int direction;
    int startRow;

    // Determine pawn direction based on color
    switch (piece.color) {
      case FourPlayerColor.white:
        direction = 1; // Move up
        startRow = 1;
        break;
      case FourPlayerColor.black:
        direction = -1; // Move down
        startRow = 12;
        break;
      case FourPlayerColor.red:
        direction = -1; // Move left
        startRow = 12;
        break;
      case FourPlayerColor.blue:
        direction = 1; // Move right
        startRow = 1;
        break;
    }

    // For horizontal players (white/black)
    if (piece.color == FourPlayerColor.white || piece.color == FourPlayerColor.black) {
      // Forward move
      final newRow = from.row + direction;
      if (newRow >= 0 && newRow < 14 && _state.board[newRow][from.col] == null &&
          FourPlayerGameState.isPlayableSquare(newRow, from.col)) {
        moves.add(FourPlayerMove(
          piece: piece,
          from: from,
          to: Square(newRow, from.col),
        ));

        // Double move from start
        if (from.row == startRow) {
          final doubleRow = from.row + (direction * 2);
          if (_state.board[doubleRow][from.col] == null &&
              FourPlayerGameState.isPlayableSquare(doubleRow, from.col)) {
            moves.add(FourPlayerMove(
              piece: piece,
              from: from,
              to: Square(doubleRow, from.col),
            ));
          }
        }
      }

      // Captures
      for (final colOffset in [-1, 1]) {
        final newRow = from.row + direction;
        final newCol = from.col + colOffset;
        if (newRow >= 0 && newRow < 14 && newCol >= 0 && newCol < 14 &&
            FourPlayerGameState.isPlayableSquare(newRow, newCol)) {
          final target = _state.board[newRow][newCol];
          if (target != null && _canCapture(piece.color, target.color)) {
            moves.add(FourPlayerMove(
              piece: piece,
              from: from,
              to: Square(newRow, newCol),
              captured: target,
            ));
          }
        }
      }

      // En Passant
      if (_state.enPassantSquare != null) {
        for (final colOffset in [-1, 1]) {
          final targetSquare = Square(from.row + direction, from.col + colOffset);
          if (targetSquare == _state.enPassantSquare) {
            moves.add(FourPlayerMove(
              piece: piece,
              from: from,
              to: targetSquare,
              captured: _state.board[from.row][from.col + colOffset],
            ));
          }
        }
      }
    } else {
      // Vertical players (red/blue) - pawns move along columns
      // Forward move
      final newCol = from.col + direction;
      if (newCol >= 0 && newCol < 14 && _state.board[from.row][newCol] == null &&
          FourPlayerGameState.isPlayableSquare(from.row, newCol)) {
        moves.add(FourPlayerMove(
          piece: piece,
          from: from,
          to: Square(from.row, newCol),
        ));

        // Double move from start
        if (from.col == startRow) {
          final doubleCol = from.col + (direction * 2);
          if (_state.board[from.row][doubleCol] == null &&
              FourPlayerGameState.isPlayableSquare(from.row, doubleCol)) {
            moves.add(FourPlayerMove(
              piece: piece,
              from: from,
              to: Square(from.row, doubleCol),
            ));
          }
        }
      }

      // Captures
      for (final rowOffset in [-1, 1]) {
        final newRow = from.row + rowOffset;
        final newCol = from.col + direction;
        if (newRow >= 0 && newRow < 14 && newCol >= 0 && newCol < 14 &&
            FourPlayerGameState.isPlayableSquare(newRow, newCol)) {
          final target = _state.board[newRow][newCol];
          if (target != null && _canCapture(piece.color, target.color)) {
            moves.add(FourPlayerMove(
              piece: piece,
              from: from,
              to: Square(newRow, newCol),
              captured: target,
            ));
          }
        }
      }

      // En Passant for vertical
      if (_state.enPassantSquare != null) {
        for (final rowOffset in [-1, 1]) {
          final targetSquare = Square(from.row + rowOffset, from.col + direction);
          if (targetSquare == _state.enPassantSquare) {
            moves.add(FourPlayerMove(
              piece: piece,
              from: from,
              to: targetSquare,
              captured: _state.board[from.row + rowOffset][from.col],
            ));
          }
        }
      }
    }

    return moves;
  }

  /// Get knight moves
  List<FourPlayerMove> _getKnightMoves(Square from, FourPlayerPiece piece) {
    final moves = <FourPlayerMove>[];
    const offsets = [
      [-2, -1], [-2, 1], [-1, -2], [-1, 2],
      [1, -2], [1, 2], [2, -1], [2, 1],
    ];

    for (final offset in offsets) {
      final newRow = from.row + offset[0];
      final newCol = from.col + offset[1];
      
      if (newRow >= 0 && newRow < 14 && newCol >= 0 && newCol < 14 &&
          FourPlayerGameState.isPlayableSquare(newRow, newCol)) {
        final target = _state.board[newRow][newCol];
        
        if (target == null) {
          moves.add(FourPlayerMove(piece: piece, from: from, to: Square(newRow, newCol)));
        } else if (_canCapture(piece.color, target.color)) {
          moves.add(FourPlayerMove(
            piece: piece,
            from: from,
            to: Square(newRow, newCol),
            captured: target,
          ));
        }
      }
    }

    return moves;
  }

  /// Get sliding piece moves (bishop, rook, queen)
  List<FourPlayerMove> _getSlidingMoves(
    Square from,
    FourPlayerPiece piece,
    List<List<int>> directions,
  ) {
    final moves = <FourPlayerMove>[];

    for (final dir in directions) {
      int newRow = from.row + dir[0];
      int newCol = from.col + dir[1];

      while (newRow >= 0 && newRow < 14 && newCol >= 0 && newCol < 14 &&
          FourPlayerGameState.isPlayableSquare(newRow, newCol)) {
        final target = _state.board[newRow][newCol];

        if (target == null) {
          moves.add(FourPlayerMove(piece: piece, from: from, to: Square(newRow, newCol)));
        } else {
          if (_canCapture(piece.color, target.color)) {
            moves.add(FourPlayerMove(
              piece: piece,
              from: from,
              to: Square(newRow, newCol),
              captured: target,
            ));
          }
          break; // Can't move past this piece
        }

        newRow += dir[0];
        newCol += dir[1];
      }
    }

    return moves;
  }

  /// Get king moves
  List<FourPlayerMove> _getKingMoves(Square from, FourPlayerPiece piece) {
    final moves = <FourPlayerMove>[];
    const offsets = [
      [-1, -1], [-1, 0], [-1, 1],
      [0, -1], [0, 1],
      [1, -1], [1, 0], [1, 1],
    ];

    for (final offset in offsets) {
      final newRow = from.row + offset[0];
      final newCol = from.col + offset[1];

      if (newRow >= 0 && newRow < 14 && newCol >= 0 && newCol < 14 &&
          FourPlayerGameState.isPlayableSquare(newRow, newCol)) {
        final target = _state.board[newRow][newCol];

        if (target == null) {
          moves.add(FourPlayerMove(piece: piece, from: from, to: Square(newRow, newCol)));
        } else if (_canCapture(piece.color, target.color)) {
          moves.add(FourPlayerMove(
            piece: piece,
            from: from,
            to: Square(newRow, newCol),
            captured: target,
          ));
        }
      }
    }

    return moves;
  }

  /// Check if one color can capture another
  bool _canCapture(FourPlayerColor attacker, FourPlayerColor target) {
    if (attacker == target) return false;

    if (_state.mode == FourPlayerMode.teams) {
      // Can't capture teammate
      final attackerTeam = _getTeam(attacker);
      final targetTeam = _getTeam(target);
      return attackerTeam != targetTeam;
    }

    return true; // Free-for-all: can capture any opponent
  }

  /// Get team for a color
  int _getTeam(FourPlayerColor color) {
    return (color == FourPlayerColor.white || color == FourPlayerColor.black) ? 1 : 2;
  }

  /// Get castling moves
  List<FourPlayerMove> _getCastlingMoves(Square from, FourPlayerPiece piece) {
    if (piece.hasMoved || _state.inCheck[piece.color] == true) return [];
    
    final moves = <FourPlayerMove>[];
    
    // Horizontal players (White/Black)
    if (piece.color == FourPlayerColor.white || piece.color == FourPlayerColor.black) {
      final row = from.row;
      // Kingside (assuming king on col 6, rook on col 10)
      _checkCastling(moves, piece, row, 6, 10, [7, 8, 9]);
      // Queenside (assuming king on col 6, rook on col 3)
      _checkCastling(moves, piece, row, 6, 3, [5, 4]);
    } else {
      // Vertical players (Red/Blue)
      final col = from.col;
      // Kingside (assuming king on row 6, rook on row 10)
      _checkCastlingVertical(moves, piece, col, 6, 10, [7, 8, 9]);
      // Queenside (assuming king on row 6, rook on row 3)
      _checkCastlingVertical(moves, piece, col, 6, 3, [5, 4]);
    }
    
    return moves;
  }

  void _checkCastling(List<FourPlayerMove> moves, FourPlayerPiece king, int row, int kCol, int rCol, List<int> bCols) {
    final rook = _state.board[row][rCol];
    if (rook?.type == PieceType.rook && rook?.color == king.color && !rook!.hasMoved) {
      // Check if squares are empty
      if (bCols.every((c) => _state.board[row][c] == null)) {
        // Check if king passes through check (only for nearest 2 squares)
        // Simplified: just check destination for now
        final destCol = kCol < rCol ? kCol + 2 : kCol - 2;
        moves.add(FourPlayerMove(
          piece: king,
          from: Square(row, kCol),
          to: Square(row, destCol),
        ));
      }
    }
  }

  void _checkCastlingVertical(List<FourPlayerMove> moves, FourPlayerPiece king, int col, int kRow, int rRow, List<int> bRows) {
    final rook = _state.board[rRow][col];
    if (rook?.type == PieceType.rook && rook?.color == king.color && !rook!.hasMoved) {
      if (bRows.every((r) => _state.board[r][col] == null)) {
        final destRow = kRow < rRow ? kRow + 2 : kRow - 2;
        moves.add(FourPlayerMove(
          piece: king,
          from: Square(kRow, col),
          to: Square(destRow, col),
        ));
      }
    }
  }

  /// Apply a move and return new state
  FourPlayerGameState _applyMove(FourPlayerMove move) {
    var newBoard = _state.board.map((row) => List<FourPlayerPiece?>.from(row)).toList();
    var enPassantSquare = null as Square?;

    // Handle Castling (side-effect: move rook)
    if (move.piece.type == PieceType.king && (move.from.col - move.to.col).abs() > 1) {
      // Horizontal kingside
      if (move.to.col == 8) {
        newBoard[move.to.row][7] = newBoard[move.to.row][10]!.copyWith(hasMoved: true);
        newBoard[move.to.row][10] = null;
      } 
      // Horizontal queenside
      else if (move.to.col == 4) {
        newBoard[move.to.row][5] = newBoard[move.to.row][3]!.copyWith(hasMoved: true);
        newBoard[move.to.row][3] = null;
      }
    } else if (move.piece.type == PieceType.king && (move.from.row - move.to.row).abs() > 1) {
      // Vertical kingside
      if (move.to.row == 8) {
        newBoard[7][move.to.col] = newBoard[10][move.to.col]!.copyWith(hasMoved: true);
        newBoard[10][move.to.col] = null;
      }
      // Vertical queenside
      else if (move.to.row == 4) {
        newBoard[5][move.to.col] = newBoard[3][move.to.col]!.copyWith(hasMoved: true);
        newBoard[3][move.to.col] = null;
      }
    }
    
    // Vertical castling needs same logic... (omitted for brevity in first pass)

    // Set pieces
    newBoard[move.to.row][move.to.col] = move.piece.copyWith(hasMoved: true);
    newBoard[move.from.row][move.from.col] = null;

    // Handle En Passant capture side-effect
    if (move.piece.type == PieceType.pawn && move.to == _state.enPassantSquare) {
      if (move.piece.color == FourPlayerColor.white || move.piece.color == FourPlayerColor.black) {
        newBoard[move.from.row][move.to.col] = null;
      } else {
        newBoard[move.to.row][move.from.col] = null;
      }
    }

    // Set En Passant potential for next turn
    if (move.piece.type == PieceType.pawn && (move.from.row - move.to.row).abs() == 2) {
      enPassantSquare = Square((move.from.row + move.to.row) ~/ 2, move.from.col);
    } else if (move.piece.type == PieceType.pawn && (move.from.col - move.to.col).abs() == 2) {
      enPassantSquare = Square(move.from.row, (move.from.col + move.to.col) ~/ 2);
    }

    return _state.copyWith(
      board: newBoard,
      enPassantSquare: enPassantSquare,
    );
  }

  /// Check if a king is in check
  bool _isKingInCheck(FourPlayerGameState testState, FourPlayerColor kingColor) {
    Square? kingPos;
    for (int row = 0; row < 14; row++) {
      for (int col = 0; col < 14; col++) {
        final piece = testState.board[row][col];
        if (piece?.type == PieceType.king && piece?.color == kingColor) {
          kingPos = Square(row, col);
          break;
        }
      }
      if (kingPos != null) break;
    }

    if (kingPos == null) return false;

    // Check if any opponent piece can attack the king
    for (int row = 0; row < 14; row++) {
      for (int col = 0; col < 14; col++) {
        final piece = testState.board[row][col];
        if (piece != null && piece.color != kingColor) {
          if (_canCapture(piece.color, kingColor) && 
              _canAttackSquare(testState, Square(row, col), kingPos)) {
            return true;
          }
        }
      }
    }

    return false;
  }

  /// Helper to check if a piece at [from] can attack [target]
  bool _canAttackSquare(FourPlayerGameState state, Square from, Square target) {
    final piece = state.board[from.row][from.col];
    if (piece == null) return false;

    // We can use the existing movement logic but with a dummy state for sliding pieces
    // to avoid recursion or complex state management.
    // For now, let's implement basic attack vectors.
    final rowDiff = (target.row - from.row).abs();
    final colDiff = (target.col - from.col).abs();

    switch (piece.type) {
      case PieceType.pawn:
        // Pawns attack diagonally
        int direction;
        switch (piece.color) {
          case FourPlayerColor.white: direction = 1; break;
          case FourPlayerColor.black: direction = -1; break;
          case FourPlayerColor.red: direction = -1; break; // Vertical pawn
          case FourPlayerColor.blue: direction = 1; break; // Vertical pawn
        }
        
        if (piece.color == FourPlayerColor.white || piece.color == FourPlayerColor.black) {
          return (target.row - from.row) == direction && colDiff == 1;
        } else {
          return (target.col - from.col) == direction && rowDiff == 1;
        }

      case PieceType.knight:
        return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2);

      case PieceType.king:
        return rowDiff <= 1 && colDiff <= 1;

      case PieceType.rook:
        if (from.row != target.row && from.col != target.col) return false;
        return _isPathClear(state, from, target);

      case PieceType.bishop:
        if (rowDiff != colDiff) return false;
        return _isPathClear(state, from, target);

      case PieceType.queen:
        if (from.row != target.row && from.col != target.col && rowDiff != colDiff) return false;
        return _isPathClear(state, from, target);
    }
  }

  /// Check if path is clear between two squares (exclusive)
  bool _isPathClear(FourPlayerGameState state, Square from, Square to) {
    final rowStep = (to.row - from.row).compareTo(0);
    final colStep = (to.col - from.col).compareTo(0);

    int currRow = from.row + rowStep;
    int currCol = from.col + colStep;

    while (currRow != to.row || currCol != to.col) {
      if (state.board[currRow][currCol] != null) return false;
      currRow += rowStep;
      currCol += colStep;
    }
    return true;
  }

  /// Make a move
  void makeMove(FourPlayerMove move) {
    // 1. Apply move to get new state
    var newState = _applyMove(move);
    
    // 2. Handle Pawn Promotion (Auto-Queen for simplicity)
    final piece = newState.board[move.to.row][move.to.col];
    if (piece?.type == PieceType.pawn) {
      bool shouldPromote = false;
      switch (piece!.color) {
        case FourPlayerColor.white: if (move.to.row == 13) shouldPromote = true; break;
        case FourPlayerColor.black: if (move.to.row == 0) shouldPromote = true; break;
        case FourPlayerColor.red: if (move.to.col == 0) shouldPromote = true; break;
        case FourPlayerColor.blue: if (move.to.col == 13) shouldPromote = true; break;
      }
      if (shouldPromote) {
        newState.board[move.to.row][move.to.col] = piece.copyWith(type: PieceType.queen);
      }
    }

    // 3. Update Move History
    final history = List<FourPlayerMove>.from(_state.moveHistory);
    history.add(move);
    newState = newState.copyWith(moveHistory: history);

    // 4. Update Check Statuses and handle elimination
    newState = _updateGameStatus(newState);

    // 5. Rotate Turn
    newState = newState.copyWith(currentTurn: newState.getNextTurn());
    
    _state = newState;
    notifyListeners();
  }

  /// Update check statuses and handle player elimination
  FourPlayerGameState _updateGameStatus(FourPlayerGameState state) {
    final newInCheck = Map<FourPlayerColor, bool>.from(state.inCheck);
    final newEliminated = Set<FourPlayerColor>.from(state.eliminated);
    
    for (final color in FourPlayerColor.values) {
      if (newEliminated.contains(color)) continue;
      
      // Check if king is missing (captured)
      bool kingExists = false;
      for (int r = 0; r < 14; r++) {
        for (int c = 0; c < 14; c++) {
          final p = state.board[r][c];
          if (p?.color == color && p?.type == PieceType.king) {
            kingExists = true;
            break;
          }
        }
        if (kingExists) break;
      }
      
      if (!kingExists) {
        newEliminated.add(color);
        continue;
      }

      // Check if in check
      final inCheck = _isKingInCheck(state, color);
      newInCheck[color] = inCheck;

      // Check for checkmate (no legal moves if in check)
      if (inCheck) {
        bool hasLegalMove = false;
        for (int r = 0; r < 14; r++) {
          for (int c = 0; c < 14; c++) {
            final p = state.board[r][c];
            if (p?.color == color) {
              final moves = _getPseudoLegalMoves(Square(r, c), p!);
              for (final m in moves) {
                final testState = _applyMove(m);
                if (!_isKingInCheck(testState, color)) {
                  hasLegalMove = true;
                  break;
                }
              }
            }
            if (hasLegalMove) break;
          }
          if (hasLegalMove) break;
        }
        
        if (!hasLegalMove) {
          newEliminated.add(color);
        }
      }
    }

    return state.copyWith(
      inCheck: newInCheck,
      eliminated: newEliminated,
    );
  }

  /// Reset game
  void reset({FourPlayerMode? mode}) {
    _state = _initializeGame(mode ?? _state.mode);
    notifyListeners();
  }
}
