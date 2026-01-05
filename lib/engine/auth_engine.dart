import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';

class UserProfile {
  final String id;
  final String username;
  final String email;
  final int rating;
  final int gamesWon;
  final int gamesPlayed;
  final String avatar;

  UserProfile({
    required this.id,
    required this.username,
    required this.email,
    required this.rating,
    required this.gamesWon,
    required this.gamesPlayed,
    required this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['_id'] ?? json['id'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      rating: json['rating'] ?? 1200,
      gamesWon: json['gamesWon'] ?? 0,
      gamesPlayed: json['gamesPlayed'] ?? 0,
      avatar: json['avatar'] ?? '',
    );
  }
}

class AuthEngine extends ChangeNotifier {
  UserProfile? _currentUser;
  String? _token;
  bool _isLoading = false;

  UserProfile? get currentUser => _currentUser;
  bool get isAuthenticated => _currentUser != null;
  bool get isLoading => _isLoading;

  Future<bool> register(String username, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = UserProfile.fromJson(data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Registration error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/api/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = UserProfile.fromJson(data['user']);
        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Login error: $e');
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _currentUser = null;
    _token = null;
    notifyListeners();
  }

  Map<String, String> get authHeaders {
    if (_token != null) {
      return {'x-auth-token': _token!, 'Content-Type': 'application/json'};
    }
    return {'Content-Type': 'application/json'};
  }
}
