
class ChessPuzzle {
  final String id;
  final String fen;
  final List<String> solution; // SAN or LAN moves
  final String description;
  final int rating;
  final String theme;

  ChessPuzzle({
    required this.id,
    required this.fen,
    required this.solution,
    required this.description,
    required this.rating,
    required this.theme,
  });
}

// Mock Data for "Daily Puzzles"
final List<ChessPuzzle> dailyPuzzles = [
  ChessPuzzle(
    id: 'p1',
    fen: 'r1bqkb1r/pppp1ppp/2n2n2/4p2Q/2B1P3/8/PPPP1PPP/RNB1K1NR w KQkq - 4 4',
    solution: ['Qxf7#'],
    description: 'Scholar\'s Mate: Deliver checkmate in one move.',
    rating: 800,
    theme: 'Checkmate',
  ),
  ChessPuzzle(
    id: 'p2',
    fen: 'rnbqkbnr/pp1ppppp/2p5/8/6P1/5P2/PPPPP2P/RNBQKBNR b KQkq - 0 3',
    solution: ['Qh4#'],
    description: 'Fool\'s Mate Pattern: Punish the weak diagonals.',
    rating: 900,
    theme: 'Checkmate',
  ),
  ChessPuzzle(
    id: 'p3',
    fen: '5rk1/pp4pp/4p3/2p3q1/3P1n2/2P5/PP3QPP/5R1K b - - 0 1',
    solution: ['Nxg2', 'Qxg2', 'Rxf1+', 'Qxf1'],
    description: 'Tactical deflection and simplification.',
    rating: 1500,
    theme: 'Tactics',
  ),
];
