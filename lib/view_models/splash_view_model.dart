import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:geolocator/geolocator.dart'; // Sẽ thêm sau khi add dependency

class SplashViewModel extends ChangeNotifier {
  bool _isLoading = true;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Future<void> initializeApp() async {
    // Giả lập load dữ liệu và kiểm tra trạng thái
    await Future.delayed(const Duration(seconds: 3));

    // Logic kiểm tra đăng nhập thực tế
    final user = FirebaseAuth.instance.currentUser;
    _isLoggedIn = user != null;

    // Logic kiểm tra vị trí (Placeholder)
    // LocationPermission permission = await Geolocator.checkPermission();

    _isLoading = false;
    notifyListeners();
  }
}
