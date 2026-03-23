import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import '../models/user_model.dart';
import '../models/post_model.dart';
import '../services/user_service.dart';
import '../services/cloudinary_service.dart';
import '../services/post_service.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserService _userService = UserService();
  final PostService _postService = PostService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  UserModel? _currentUser;
  List<PostModel> _userPosts = [];
  List<PostModel> _hiddenPosts = [];
  List<PostModel> _savedPosts = [];
  bool _isLoading = true;
  bool _isUploading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;
  List<PostModel> get userPosts => _userPosts;
  List<PostModel> get hiddenPosts => _hiddenPosts;
  List<PostModel> get savedPosts => _savedPosts;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;
  String? get errorMessage => _errorMessage;

  ProfileViewModel() {
    loadUserProfile();
  }

  Future<void> refreshProfile() async {
    await loadUserProfile();
  }

  void clearProfile() {
    _currentUser = null;
    _userPosts = [];
    _hiddenPosts = [];
    _savedPosts = [];
    notifyListeners();
  }

  Future<void> loadUserProfile() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _userService.getUser(uid);

      // Nếu user chưa tồn tại trong Firestore, tạo bản ghi mới
      if (_currentUser == null) {
        final firebaseUser = FirebaseAuth.instance.currentUser!;
        _currentUser = UserModel(
          id: firebaseUser.uid,
          email: firebaseUser.email ?? '',
          displayName: firebaseUser.displayName ?? 'Chưa cập nhật tên',
          photoUrl: firebaseUser.photoURL ?? '',
          exp: 0,
          title: 'Tân Binh',
          followers: 0,
          following: 0,
          placesVisited: 0,
          postsCount: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        await _userService.saveUser(_currentUser!);
      }

      // Tải danh sách bài viết của user
      final postsStream = _postService.getPosts(userId: uid);
      final allUserPosts = await postsStream.first;

      _userPosts = allUserPosts.where((p) => !p.isHidden).toList();
      _hiddenPosts = allUserPosts.where((p) => p.isHidden).toList();

      // Cập nhật số lượng bài viết nếu khác biệt
      if (_currentUser!.postsCount != _userPosts.length) {
        _currentUser!.postsCount = _userPosts.length;
        await _userService.updatePartialUser(uid, {
          'postsCount': _userPosts.length,
        });
      }

      // Tải danh sách bài viết đã lưu
      if (_currentUser!.savedPostIds.isNotEmpty) {
        _savedPosts = await _postService.getPostsByIds(
          _currentUser!.savedPostIds,
        );
      } else {
        _savedPosts = [];
      }
    } catch (e) {
      _errorMessage = 'Lỗi tải thông tin: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> isFollowing(String targetUid) async {
    if (_currentUser == null) return false;
    return await _userService.isFollowing(_currentUser!.id, targetUid);
  }

  Future<bool> followUser(String targetUid) async {
    if (_currentUser == null) return false;
    try {
      await _userService.followUser(_currentUser!, targetUid);
      // Cập nhật local state nếu cần, hoặc reload profile
      await loadUserProfile();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi follow: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> unfollowUser(String targetUid) async {
    if (_currentUser == null) return false;
    try {
      await _userService.unfollowUser(_currentUser!.id, targetUid);
      await loadUserProfile();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi unfollow: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> deletePost(String postId) async {
    if (_currentUser == null) return false;
    try {
      await _postService.deletePost(postId, _currentUser!.id);
      await loadUserProfile();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi xóa bài: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleHidePost(String postId, bool isHidden) async {
    if (_currentUser == null) return false;
    try {
      await _postService.toggleHidePost(postId, isHidden);
      await loadUserProfile();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi ẩn bài: $e';
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateDisplayName(String newName) async {
    if (_currentUser == null || newName.trim().isEmpty) return false;

    _isUploading = true;
    notifyListeners();

    try {
      await _userService.updatePartialUser(_currentUser!.id, {
        'displayName': newName.trim(),
      });
      _currentUser!.displayName = newName.trim();

      // Cập nhật luôn cho FirebaseAuth
      await FirebaseAuth.instance.currentUser?.updateDisplayName(
        newName.trim(),
      );

      _isUploading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi đổi tên: $e';
      _isUploading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> uploadAvatar({ImageSource source = ImageSource.gallery}) async {
    debugPrint('➡️ ProfileViewModel: Bắt đầu hàm uploadAvatar');
    if (_currentUser == null) {
      debugPrint('❌ ProfileViewModel: currentUser đang null');
      return false;
    }

    // Yêu cầu thư viện ảnh hoặc máy ảnh
    debugPrint('➡️ ProfileViewModel: Đang mở ImagePicker với source: $source');
    final XFile? image = await _picker.pickImage(
      source: source,
      imageQuality: 70,
    );

    if (image == null) {
      debugPrint('⚠️ ProfileViewModel: Người dùng đã huỷ chọn ảnh');
      return false;
    }

    debugPrint(
      '➡️ ProfileViewModel: Đã chốt được ảnh ở đường dẫn: ${image.path}',
    );
    _isUploading = true;
    notifyListeners();

    try {
      debugPrint('➡️ ProfileViewModel: Chuyển đổi sang File Object (dart:io)');
      final File imageFile = File(image.path);

      // Đẩy lên Cloudinary
      debugPrint(
        '➡️ ProfileViewModel: Bắt đầu gọi truyền vào CloudinaryService...',
      );
      final String? imageUrl = await _cloudinaryService.uploadImage(imageFile);

      if (imageUrl != null) {
        debugPrint(
          '✅ ProfileViewModel: Upload Cloudinary xong, đang cập nhật User Firestore...',
        );
        // Cập nhật link mới vào Firestore
        await _userService.updatePartialUser(_currentUser!.id, {
          'photoUrl': imageUrl,
        });
        _currentUser!.photoUrl = imageUrl;

        // Cập nhật luôn FirebaseAuth
        debugPrint('✅ ProfileViewModel: Cập nhật vào FirebaseAuth');
        await FirebaseAuth.instance.currentUser?.updatePhotoURL(imageUrl);

        _isUploading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('❌ ProfileViewModel: Cloudinary không trả về hình ảnh');
        _errorMessage = 'Upload ảnh lên mây thất bại.';
      }
    } catch (e) {
      debugPrint('❌ ProfileViewModel: Lỗi try-catch lúc upload ảnh: $e');
      _errorMessage = 'Có lỗi xảy ra khi cập nhật Ảnh đại diện: $e';
    }

    _isUploading = false;
    notifyListeners();
    return false;
  }
}
