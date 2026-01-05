import 'package:socket_io_client/socket_io_client.dart' as socket_io;
import '../models/chess_models.dart';
import '../models/four_player_models.dart';
import 'four_player_engine.dart';

class OnlineFourPlayerEngine extends FourPlayerChessEngine {
  late socket_io.Socket socket;
  final String serverUrl;
  String? roomId;
  FourPlayerColor? playerColor;
  bool isConnected = false;
  int playerCount = 0;

  OnlineFourPlayerEngine({required this.serverUrl, FourPlayerMode mode = FourPlayerMode.freeForAll}) 
      : super(mode: mode) {
    _initSocket();
  }

  void _initSocket() {
    socket = socket_io.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.onConnect((_) {
      isConnected = true;
      notifyListeners();
    });

    socket.onDisconnect((_) {
      isConnected = false;
      notifyListeners();
    });

    socket.on('player_joined', (data) {
      playerCount++;
      notifyListeners();
    });

    socket.on('receive_move', (data) {
      final moveData = data['move'];
      final from = Square(moveData['from']['row'], moveData['from']['col']);
      final to = Square(moveData['to']['row'], moveData['to']['col']);
      
      // Find the move in legal moves to ensure full logic
      final moves = getLegalMovesFrom(from);
      final move = moves.firstWhere(
        (m) => m.to == to,
        orElse: () => FourPlayerMove(
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

  void joinRoom(String id, FourPlayerColor color) {
    roomId = id;
    playerColor = color;
    socket.emit('join_room', id);
    notifyListeners();
  }

  @override
  void makeMove(FourPlayerMove move) {
    // Only allow moving if it's the player's turn and their color
    if (playerColor != null && state.currentTurn != playerColor) return;
    
    super.makeMove(move);
    
    if (roomId != null) {
      socket.emit('send_move', {
        'roomId': roomId,
        'move': {
          'from': {'row': move.from.row, 'col': move.from.col},
          'to': {'row': move.to.row, 'col': move.to.col},
        }
      });
    }
  }

  @override
  void reset({FourPlayerMode? mode}) {
    if (roomId != null) {
      socket.emit('game_reset', roomId);
    }
    super.reset(mode: mode);
  }

  @override
  void dispose() {
    socket.dispose();
    super.dispose();
  }
}
