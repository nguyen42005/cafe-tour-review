import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';
import '../services/post_service.dart';
import '../services/user_service.dart';
import '../services/gamification_service.dart';
import '../models/post_model.dart';
import '../models/user_model.dart';

class CreatePostViewModel extends ChangeNotifier {
  final PostService _postService = PostService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  List<File> _selectedImages = [];
  List<File> get selectedImages => _selectedImages;

  double _rating = 4.0;
  double get rating => _rating;

  String _content = '';
  String get content => _content;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _editingPostId;
  bool get isEditing => _editingPostId != null;
  List<String> _existingImages = []; // Để giữ ảnh cũ nếu không đổi
  List<String> get existingImages => _existingImages;

  // Venue data
  String _selectedVenueId = '';
  String _selectedVenueName = 'Chọn quán cà phê';
  String get selectedVenueId => _selectedVenueId;
  String get selectedVenueName => _selectedVenueName;

  void initForEdit(PostModel post) {
    _editingPostId = post.id;
    _selectedVenueId = post.venueId;
    _selectedVenueName = post.venueName;
    _rating = post.rating;
    _content = post.content;
    _existingImages = post.images;
    _selectedImages = []; // Reset selected local files
    notifyListeners();
  }

  void reset() {
    _editingPostId = null;
    _selectedVenueId = '';
    _selectedVenueName = 'Chọn quán cà phê';
    _rating = 4.0;
    _content = '';
    _existingImages = [];
    _selectedImages = [];
    _isLoading = false;
    _errorMessage = null;
    notifyListeners();
  }

  void setVenue(String id, String name) {
    _selectedVenueId = id;
    _selectedVenueName = name;
    notifyListeners();
  }

  void setRating(double value) {
    _rating = value;
    notifyListeners();
  }

  void setContent(String value) {
    _content = value;
    notifyListeners();
  }

  Future<void> pickImages() async {
    if (_selectedImages.length >= 5) return;

    final List<XFile> images = await _picker.pickMultiImage();
    if (images.isNotEmpty) {
      // Giới hạn tối đa 5 ảnh
      final remainingSlots = 5 - _selectedImages.length;
      final newImages = images
          .take(remainingSlots)
          .map((xfile) => File(xfile.path))
          .toList();
      _selectedImages.addAll(newImages);
      notifyListeners();
    }
  }

  void removeImage(int index) {
    _selectedImages.removeAt(index);
    notifyListeners();
  }

  Future<bool> submitPost(UserModel user) async {
    if (_selectedVenueId.isEmpty) {
      _errorMessage = 'Vui lòng chọn địa điểm trước khi đăng bài';
      notifyListeners();
      return false;
    }

    if (_content.isEmpty) {
      _errorMessage = 'Vui lòng nhập nội dung bài viết';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      List<String> imageUrls = [];

      // 1. Upload images to Cloudinary (chỉ upload ảnh mới)
      for (var imageFile in _selectedImages) {
        final url = await _cloudinaryService.uploadImage(imageFile);
        if (url != null) {
          imageUrls.add(url);
        }
      }

      // Nếu không chọn ảnh mới, giữ ảnh cũ (hoặc logic hỗn hợp tuỳ bạn - ở đây cho đơn giản là edit content/rating)
      if (imageUrls.isEmpty && isEditing) {
        imageUrls = _existingImages;
      }

      // 2. Create/Update PostModel
      final post = PostModel(
        id: _editingPostId ?? '',
        userId: user.id,
        userName: user.displayName,
        userPhotoUrl: user.photoUrl,
        venueId: _selectedVenueId,
        venueName: _selectedVenueName,
        content: _content,
        rating: _rating,
        images: imageUrls,
        createdAt: DateTime.now(),
      );

      // 3. Save to Firestore
      if (isEditing) {
        // Cần thêm hàm update ở service hoặc dùng set/update trực tiếp
        // Ở đây ta có thể tận dụng _postsRef().doc().update()
        final db = FirebaseFirestore.instance;
        await db.collection('posts').doc(_editingPostId).update(post.toJson());
      } else {
        await _postService.createPost(post);
        // 4. Award EXP (Chỉ khi tạo mới)
        final userService = UserService();
        await userService.addExp(user.id, GamificationService.expPostReview);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = 'Lỗi khi đăng bài: $e';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
