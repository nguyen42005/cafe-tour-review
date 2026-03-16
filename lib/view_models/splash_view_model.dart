import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class SplashViewModel extends ChangeNotifier {
  final UserService _userService = UserService();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  UserModel? _userProfile;
  UserModel? get userProfile => _userProfile;

  Position? _currentPosition;
  Position? get currentPosition => _currentPosition;

  Future<void> initializeApp() async {
    _isLoading = true;
    notifyListeners();

    // Chạy song song các tác vụ khởi tạo
    await Future.wait([
      _handleAuth(),
      _handleLocation(),
      Future.delayed(
        const Duration(seconds: 2),
      ), // Đảm bảo splash hiện ít nhất 2s
    ]);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> _handleAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      _userProfile = await _userService.getUser(user.uid);
      _isLoggedIn = _userProfile != null;
    } else {
      _isLoggedIn = false;
    }
  }

  Future<void> _handleLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return;

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      if (permission == LocationPermission.deniedForever) return;

      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (e) {
      debugPrint('Location Error: $e');
    }
  }
}
