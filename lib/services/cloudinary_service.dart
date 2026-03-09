import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class CloudinaryService {
  static const String cloudName = 'dujjo36wf';
  static const String uploadPreset = 'reviewCoffee';
  static const String apiUrl =
      'https://api.cloudinary.com/v1_1/$cloudName/upload';

  /// Hàm upload 1 tấm ảnh lên Cloudinary
  /// Trả về đường link (URL) của ảnh trên đám mây nếu thành công, ngược lại trả về null.
  Future<String?> uploadImage(File imageFile) async {
    debugPrint('➡️ CloudinaryService: Bắt đầu tiến trình upload ảnh...');
    try {
      if (!imageFile.existsSync()) {
        debugPrint(
          '❌ CloudinaryService: File ảnh không tồn tại tại đường dẫn: ${imageFile.path}',
        );
        return null;
      }

      debugPrint('➡️ CloudinaryService: Khởi tạo MultipartRequest tới $apiUrl');
      final request = http.MultipartRequest('POST', Uri.parse(apiUrl))
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      debugPrint('➡️ CloudinaryService: Đang send request chờ phản hồi...');
      final response = await request.send();
      debugPrint(
        '➡️ CloudinaryService: Đã nhận phản hồi (StatusCode: ${response.statusCode})',
      );

      final responseData = await response.stream.toBytes();
      final responseString = String.fromCharCodes(responseData);
      final jsonMap = jsonDecode(responseString);

      if (response.statusCode == 200 || response.statusCode == 201) {
        debugPrint(
          '✅ CloudinaryService: Upload thành công! URL: ${jsonMap['secure_url']}',
        );
        return jsonMap['secure_url'] as String?;
      } else {
        // Ghi nhận lỗi từ Cloudinary
        debugPrint(
          '❌ CloudinaryService Upload Error: ${jsonMap['error']['message']}',
        );
        return null;
      }
    } catch (e) {
      debugPrint('❌ CloudinaryService Exception during upload: $e');
      return null;
    }
  }

  /// Hàm upload nhiều ảnh cùng lúc
  Future<List<String>> uploadMultipleImages(List<File> imageFiles) async {
    List<String> uploadedUrls = [];
    for (var file in imageFiles) {
      final url = await uploadImage(file);
      if (url != null) {
        uploadedUrls.add(url);
      }
    }
    return uploadedUrls;
  }
}
