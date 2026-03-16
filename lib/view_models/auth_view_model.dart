import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/user_service.dart';
import '../models/user_model.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  UserModel? get user => _user;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Logic Đăng nhập Email/Password
  Future<UserModel?> loginWithEmail(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _errorMessage = "Vui lòng nhập đầy đủ Email và Mật khẩu.";
      notifyListeners();
      return null;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final credential = await _authService.signInWithEmail(email, password);
      _setLoading(false);

      if (credential.user != null) {
        // Lấy model thật từ Firestore để check Role
        _user = await UserService().getUser(credential.user!.uid);
        _setLoading(false);
        return _user;
      }
      _setLoading(false);
      return null;
    } catch (e, stackTrace) {
      debugPrint('Login Error: $e');
      debugPrint('Stack Trace: $stackTrace');
      // Xử lý một số thông báo lỗi thân thiện hơn
      if (e is FirebaseAuthException) {
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          _errorMessage = 'Tài khoản hoặc mật khẩu không chính xác.';
        } else if (e.code == 'wrong-password') {
          _errorMessage = 'Mật khẩu không chính xác.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'Email không hợp lệ.';
        } else if (e.code == 'user-disabled') {
          _errorMessage = 'Tài khoản này đã bị vô hiệu hóa.';
        } else {
          _errorMessage = 'Lỗi đăng nhập: ${e.message}';
        }
      } else if (e.toString().contains('user-not-found')) {
        _errorMessage = 'Tài khoản không tồn tại.';
      } else if (e.toString().contains('wrong-password')) {
        _errorMessage = 'Mật khẩu không chính xác.';
      } else if (e.toString().contains('invalid-email')) {
        _errorMessage = 'Email không hợp lệ.';
      } else {
        _errorMessage = 'Đăng nhập thất bại. Vui lòng thử lại sau. ($e)';
      }
      _setLoading(false);
      return null;
    }
  }

  // Logic Đăng ký Email/Password
  Future<bool> signUpWithEmail(
    String name,
    String email,
    String password,
  ) async {
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _errorMessage = "Vui lòng nhập đầy đủ thông tin.";
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      final credential = await _authService.signUpWithEmail(email, password);
      // Cập nhật tên người dùng Firebase Auth
      await credential.user?.updateDisplayName(name);

      // Khởi tạo UserModel lưu vào Firestore
      if (credential.user != null) {
        final newUser = UserModel(
          id: credential.user!.uid,
          email: email,
          displayName: name,
          photoUrl: '', // Chưa có ảnh lúc đầu
          exp: 0,
          title: 'Thành viên mới',
          followers: 0,
          following: 0,
          placesVisited: 0,
          postsCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await UserService().saveUser(newUser);
      }

      _setLoading(false);
      return true;
    } catch (e) {
      debugPrint('Register Error: $e'); // Logn in lỗi thực tế
      if (e is FirebaseAuthException) {
        if (e.code == 'email-already-in-use') {
          _errorMessage = 'Email này đã được sử dụng cho một tài khoản khác.';
        } else if (e.code == 'weak-password') {
          _errorMessage = 'Mật khẩu quá yếu. Vui lòng chọn mật khẩu mạnh hơn.';
        } else if (e.code == 'invalid-email') {
          _errorMessage = 'Email không hợp lệ.';
        } else {
          _errorMessage = 'Lỗi đăng ký: ${e.message}';
        }
      } else if (e.toString().contains('email-already-in-use')) {
        _errorMessage = 'Email đã được sử dụng.';
      } else if (e.toString().contains('weak-password')) {
        _errorMessage = 'Mật khẩu quá yếu.';
      } else if (e.toString().contains('invalid-email')) {
        _errorMessage = 'Email không hợp lệ.';
      } else {
        _errorMessage = 'Đăng ký thất bại. Vui lòng thử lại. ($e)';
      }
      _setLoading(false);
      return false;
    }
  }

  // Logic Google Login
  Future<void> loginWithGoogle() async {
    // Implement Google Auth logic here
  }

  // Logic Đăng xuất
  Future<void> logout() async {
    await _authService.signOut();
    _user = null;
    notifyListeners();
  }
}
