import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _api = ApiService();
  String? _token;
  String? _userId;
  String? _name;
  bool _isLoading = false;

  ApiService get api => _api;
  String? get token => _token;
  String? get userId => _userId;
  String? get name => _name;
  bool get isLoggedIn => _token != null;
  bool get isLoading => _isLoading;

  Future<void> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _api.register(name, email, password);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> login(String email, String password, String otp) async {
    _isLoading = true;
    notifyListeners();
    try {
      final data = await _api.login(email, password, otp);
      _token = data['access_token'];
      _userId = data['user_id'];
      _name = data['name'];
      _api.setToken(_token!);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() {
    _token = null;
    _userId = null;
    _name = null;
    notifyListeners();
  }
}
