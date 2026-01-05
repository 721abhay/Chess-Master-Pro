import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import '../models/chess_models.dart';
import 'chess_engine.dart';

class OnlineChessEngine extends ChessEngine {
  late socket_io.Socket socket;
  final String serverUrl;
  String? roomId;
  PieceColor? playerColor;
  bool isConnected = false;
  int playerCount = 0;

  OnlineChessEngine({required this.serverUrl}) : super() {
    _initSocket();
  }

  void _initSocket() {
    socket = socket_io.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.onConnect((_) {
      print('Connected to socket server');
      isConnected = true;
      notifyListeners();
    });

    socket.onDisconnect((_) {
      print('Disconnected from socket server');
      isConnected = false;
      notifyListeners();
    });

    socket.on('player_joined', (data) {
      playerCount++;
      print('Player joined. Total: $playerCount');
      notifyListeners();
    });

    socket.on('receive_move', (data) {
      final moveData = data['move'];
      final from = Square(moveData['from']['row'], moveData['from']['col']);
      final to = Square(moveData['to']['row'], moveData['to']['col']);
      
      // Find the move in legal moves to ensure full data (like promotion)
      final move = getLegalMoves().firstWhere(
        (m) => m.from == from && m.to == to,
        orElse: () => Move(
          piece: state.board[from.row][from.col]!,
          from: from,
          to: to,
        ),
      );

      super.makeMove(move);
      notifyListeners();
    });

    socket.on('game_reset_voted', (_) {
      super.reset();
      notifyListeners();
    });

    socket.connect();
  }

  void joinRoom(String id, PieceColor color) {
    roomId = id;
    playerColor = color;
    socket.emit('join_room', id);
    notifyListeners();
  }

  @override
  bool makeMove(Move move) {
    // Only allow moving if it's the player's turn and their color
    if (playerColor != null && state.turn != playerColor) return false;
    
    final success = super.makeMove(move);
    if (success && roomId != null) {
      socket.emit('send_move', {
        'roomId': roomId,
        'move': {
          'from': {'row': move.from.row, 'col': move.from.col},
          'to': {'row': move.to.row, 'col': move.to.col},
          'piece': move.piece.toString(),
        },
        'fen': getFEN(),
      });
    }
    return success;
  }

  @override
  void reset() {
    if (roomId != null) {
      socket.emit('game_reset', roomId);
    }
    super.reset();
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }
}
