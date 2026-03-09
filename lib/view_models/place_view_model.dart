import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/place_model.dart';
import '../services/place_service.dart';
import '../services/cloudinary_service.dart';

class PlaceViewModel extends ChangeNotifier {
  final PlaceService _placeService = PlaceService();
  final CloudinaryService _cloudinaryService = CloudinaryService();
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Form Fields
  File? _coverImage;
  File? get coverImage => _coverImage;

  final List<File?> _subImages = [null, null, null]; // [Space, Menu, Other]
  List<File?> get subImages => _subImages;

  final List<String> _selectedAmenities = ['Wifi miễn phí', 'Máy lạnh'];
  List<String> get selectedAmenities => _selectedAmenities;

  String _selectedCategoryId = '';
  String _selectedCategoryName = '';
  String get selectedCategoryId => _selectedCategoryId;
  String get selectedCategoryName => _selectedCategoryName;

  // Status for duplication check
  PlaceModel? _duplicateFound;
  PlaceModel? get duplicateFound => _duplicateFound;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void setCategory(String id, String name) {
    _selectedCategoryId = id;
    _selectedCategoryName = name;
    notifyListeners();
  }

  Future<void> pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _coverImage = File(image.path);
      notifyListeners();
    }
  }

  Future<void> pickSubImage(int index) async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _subImages[index] = File(image.path);
      notifyListeners();
    }
  }

  void toggleAmenity(String amenity) {
    if (_selectedAmenities.contains(amenity)) {
      _selectedAmenities.remove(amenity);
    } else {
      _selectedAmenities.add(amenity);
    }
    notifyListeners();
  }

  Future<bool> submitPlace({
    required String name,
    required String address,
    required double lat,
    required double lng,
    required String openTime,
    required String closeTime,
    required String priceMin,
    required String priceMax,
    required String categoryId,
    required String categoryName,
    required String userId,
  }) async {
    if (_coverImage == null) {
      _errorMessage = 'Vui lòng chọn ảnh bìa cho địa điểm';
      notifyListeners();
      return false;
    }

    if (categoryId.isEmpty || categoryName.isEmpty) {
      _errorMessage = 'Vui lòng chọn danh mục địa điểm';
      notifyListeners();
      return false;
    }

    _setLoading(true);
    _errorMessage = null;

    try {
      // 1. Kiểm tra trùng lặp theo tên + địa chỉ + tọa độ
      final duplicate = await _placeService.findDuplicatePlace(
        name: name,
        address: address,
        lat: lat,
        lng: lng,
      );
      if (duplicate != null) {
        _duplicateFound = duplicate;
        _setLoading(false);
        return false;
      }

      // 2. Upload ảnh bìa
      final String? coverUrl = await _cloudinaryService.uploadImage(_coverImage!);
      if (coverUrl == null) throw Exception('Tải ảnh bìa thất bại');

      // 3. Upload các ảnh phụ (nếu có)
      final List<String> subUrls = [];
      for (var file in _subImages) {
        if (file != null) {
          final url = await _cloudinaryService.uploadImage(file);
          if (url != null) subUrls.add(url);
        }
      }

      // 4. Lưu vào Firestore
      final newPlace = PlaceModel(
        id: '',
        name: name,
        address: address,
        lat: lat,
        lng: lng,
        openTime: openTime,
        closeTime: closeTime,
        priceMin: priceMin,
        priceMax: priceMax,
        categoryId: categoryId,
        categoryName: categoryName,
        amenities: _selectedAmenities,
        coverImage: coverUrl,
        subImages: subUrls,
        status: 'pending',
        createdBy: userId,
        createdAt: DateTime.now(),
      );

      await _placeService.addPlace(newPlace);

      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }

  void clearDuplicate() {
    _duplicateFound = null;
    notifyListeners();
  }
}



