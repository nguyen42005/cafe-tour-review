import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/cloudinary_service.dart';
import '../services/post_service.dart';
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

  // Venue data
  String _selectedVenueId = '';
  String _selectedVenueName = 'Chọn quán cà phê';
  String get selectedVenueId => _selectedVenueId;
  String get selectedVenueName => _selectedVenueName;

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

      // 1. Upload images to Cloudinary
      for (var imageFile in _selectedImages) {
        final url = await _cloudinaryService.uploadImage(imageFile);
        if (url != null) {
          imageUrls.add(url);
        }
      }

      // 2. Create PostModel
      final post = PostModel(
        id: '', // Firestore sẽ tự tạo ID
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
      await _postService.createPost(post);

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

