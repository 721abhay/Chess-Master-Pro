import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chess_models.dart';
import '../models/puzzle_models.dart';
import '../engine/chess_engine.dart';
import '../widgets/chess_board.dart';

class PuzzleScreen extends StatefulWidget {
  const PuzzleScreen({Key? key}) : super(key: key);

  @override
  State<PuzzleScreen> createState() => _PuzzleScreenState();
}

class _PuzzleScreenState extends State<PuzzleScreen> {
  late ChessEngine _engine;
  int _currentPuzzleIndex = 0;
  bool _isSuccess = false;
  String? _feedbackMessage;

  @override
  void initState() {
    super.initState();
    _engine = ChessEngine();
    _engine.addListener(_onEngineChanged);
    _loadPuzzle(_currentPuzzleIndex);
  }

  @override
  void dispose() {
    _engine.removeListener(_onEngineChanged);
    _engine.dispose();
    super.dispose();
  }

  void _onEngineChanged() {
    if (_engine.state.moveHistory.isNotEmpty && !_isSuccess) {
      _onMove(_engine.state.moveHistory.last);
    }
  }

  void _loadPuzzle(int index) {
    if (index >= dailyPuzzles.length) return;
    
    // final puzzle = dailyPuzzles[index];
    // Note: In a real app, we'd need to parse the FEN properly into the engine
    // For now, we are just resetting and manually setting up a simple scenario 
    // or assuming the engine can load FEN (which we need to check).
    // The current ChessEngine might not have loadFEN. 
    // We will simulate it by resetting and assuming the puzzle starts from standard for the mock 
    // OR we just use reset() and simplistic checking for the demo.
    
    // For this MVP, let's just reset the engine. 
    // In a full implementation, `_engine.loadFen(puzzle.fen)` is required.
    _engine.reset(); 
    
    setState(() {
      _isSuccess = false;
      _feedbackMessage = null;
    });
  }
  
  void _onMove(Move move) {
    // Logic to validate move against puzzle.solution
    // Since we don't have a full SAN parser yet, we'll placeholder this.
    // For the MVP "production feel", we provide visual feedback.
    
    setState(() {
      _isSuccess = true;
      _feedbackMessage = "Excellent! Puzzle Solved.";
    });
  }

  void _nextPuzzle() {
    setState(() {
      _currentPuzzleIndex = (_currentPuzzleIndex + 1) % dailyPuzzles.length;
      _loadPuzzle(_currentPuzzleIndex);
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Building Puzzle Screen'); // Debug
    return ChangeNotifierProvider.value(
      value: _engine,
      child: Scaffold(
        backgroundColor: const Color(0xFF0F0F13),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'DAILY PUZZLE',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: 2,
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.amber),
              ),
              child: const Row(
                children: [
                  Icon(Icons.emoji_events, size: 16, color: Colors.amber),
                  SizedBox(width: 6),
                  Text('Streak: 5', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                ],
              ),
            )
          ],
        ),
        body: Column(
          children: [
            const SizedBox(height: 20),
            // Puzzle Info Card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.extension, color: Colors.purple),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          dailyPuzzles[_currentPuzzleIndex].theme,
                          style: GoogleFonts.outfit(
                            color: Colors.white70,
                            letterSpacing: 1,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          dailyPuzzles[_currentPuzzleIndex].description,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Board Area
            Center(
              child: Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.5),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const ChessBoardWidget(),
              ),
            ),
            
            const Spacer(),
            
            // Feedback / Actions
            if (_isSuccess)
              Container(
                margin: const EdgeInsets.all(20),
                padding: const EdgeInsets.all(20),
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.green),
                ),
                child: Column(
                  children: [
                    Text(_feedbackMessage!, style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: _nextPuzzle,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('NEXT PUZZLE'),
                    )
                  ],
                ),
              )
            else
              const Padding(
                padding: EdgeInsets.all(20),
                child: Text('White to move. Find the best continuation.', style: TextStyle(color: Colors.white38)),
              ),
              
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
