// Constants for Chess App

import '../models/chess_models.dart';

/// Board dimensions
const int boardSize = 8;
const int numSquares = 64;

/// Piece values (in centipawns)
const Map<PieceType, int> pieceValues = {
  PieceType.pawn: 100,
  PieceType.knight: 320,
  PieceType.bishop: 330,
  PieceType.rook: 500,
  PieceType.queen: 900,
  PieceType.king: 20000,
};

/// Colors for chess board
class BoardColors {
  static const lightSquare = 0xFFFFCE9E; // Warm light tan
  static const darkSquare = 0xFFD18B47; // Rich warm brown
  static const selectedSquare = 0xBBAAEE55; // Bright yellow-green
  static const legalMoveIndicator = 0xE0646F40; // Dark green dot
  static const checkIndicator = 0xD0FF0000; // Bright red
  static const lastMoveHighlight = 0x90CDD422; // Yellow highlight
}

/// API configuration
class ApiConfig {
  // Android emulator uses 10.0.2.2 to access host machine's localhost
  static const String baseUrl = 'http://10.0.2.2:3001';
  // For physical device on same network, use your computer's IP:
  // static const String baseUrl = 'http://192.168.1.XXX:3001';
  // For production:
  // static const String baseUrl = 'https://your-backend.com';
}

/// AI difficulty levels
enum AIDifficulty {
  easy('easy', 3),
  medium('medium', 5),
  hard('hard', 7);

  final String name;
  final int depth;
  const AIDifficulty(this.name, this.depth);
}
