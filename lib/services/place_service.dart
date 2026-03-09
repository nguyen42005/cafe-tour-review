import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import '../models/place_model.dart';

class PlaceService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String _collection = 'places';

  Stream<List<PlaceModel>> getApprovedPlacesStream() {
    return _db
        .collection(_collection)
        .where('status', isEqualTo: 'approved')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => PlaceModel.fromJson(doc.data(), doc.id))
              .toList(),
        );
  }

  Stream<List<PlaceModel>> getPendingPlacesStream() {
    return _db
        .collection(_collection)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) {
          final places = snapshot.docs
              .map((doc) => PlaceModel.fromJson(doc.data(), doc.id))
              .toList();
          places.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return places;
        });
  }

  Future<String> addPlace(PlaceModel place) async {
    try {
      final docRef = await _db.collection(_collection).add(place.toJson());
      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi khi thêm địa điểm: $e');
    }
  }

  Future<void> updatePlaceStatus(String id, String status) async {
    try {
      await _db.collection(_collection).doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trạng thái: $e');
    }
  }

  // Thuật toán phát hiện trùng lặp nâng cao:
  // - Khoảng cách GPS (ưu tiên cao)
  // - Độ giống tên địa điểm
  // - Độ giống địa chỉ
  // Kết hợp theo score + rule cứng để bắt các trường hợp chắc chắn trùng.
  Future<PlaceModel?> findDuplicatePlace({
    required String name,
    required String address,
    required double lat,
    required double lng,
  }) async {
    try {
      final snapshot = await _db
          .collection(_collection)
          .where('status', isEqualTo: 'approved')
          .get();

      PlaceModel? bestMatch;
      double bestScore = 0;

      for (final doc in snapshot.docs) {
        final candidate = PlaceModel.fromJson(doc.data(), doc.id);

        final distanceMeters = Geolocator.distanceBetween(
          lat,
          lng,
          candidate.lat,
          candidate.lng,
        );

        // Lọc thô trước để giảm false-positive và tăng tốc.
        if (distanceMeters > 300) continue;

        final nameSimilarity = _textSimilarity(name, candidate.name);
        final addressSimilarity = _textSimilarity(address, candidate.address);
        final distanceScore = _distanceScore(distanceMeters);

        final combinedScore =
            (distanceScore * 0.50) + (nameSimilarity * 0.35) + (addressSimilarity * 0.15);

        final bool isStrongDuplicate =
            distanceMeters <= 35 ||
            (distanceMeters <= 120 && nameSimilarity >= 0.78) ||
            (distanceMeters <= 90 && addressSimilarity >= 0.80) ||
            (_normalize(name) == _normalize(candidate.name) && distanceMeters <= 250) ||
            combinedScore >= 0.82;

        if (isStrongDuplicate && combinedScore > bestScore) {
          bestScore = combinedScore;
          bestMatch = candidate;
        }
      }

      return bestMatch;
    } catch (e) {
      print('CheckDuplicate Error: $e');
      return null;
    }
  }

  double _distanceScore(double distanceMeters) {
    if (distanceMeters <= 30) return 1.0;
    if (distanceMeters <= 80) return 0.8;
    if (distanceMeters <= 150) return 0.55;
    if (distanceMeters <= 300) return 0.3;
    return 0.0;
  }

  double _textSimilarity(String a, String b) {
    final aTokens = _tokenize(a);
    final bTokens = _tokenize(b);

    if (aTokens.isEmpty || bTokens.isEmpty) return 0;

    final intersection = aTokens.where(bTokens.contains).length;
    final union = {...aTokens, ...bTokens}.length;

    if (union == 0) return 0;
    return intersection / union;
  }

  Set<String> _tokenize(String input) {
    final normalized = _normalize(input);
    return normalized
        .split(' ')
        .map((e) => e.trim())
        .where((e) => e.length > 1)
        .toSet();
  }

  String _normalize(String input) {
    String text = input.toLowerCase().trim();

    // Loại dấu tiếng Việt.
    const replacements = {
      'a': 'àáạảãâầấậẩẫăằắặẳẵ',
      'e': 'èéẹẻẽêềếệểễ',
      'i': 'ìíịỉĩ',
      'o': 'òóọỏõôồốộổỗơờớợởỡ',
      'u': 'ùúụủũưừứựửữ',
      'y': 'ỳýỵỷỹ',
      'd': 'đ',
    };

    replacements.forEach((ascii, chars) {
      for (int i = 0; i < chars.length; i++) {
        text = text.replaceAll(chars[i], ascii);
      }
    });

    // Chuẩn hóa ký tự đặc biệt thành khoảng trắng.
    text = text.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();

    return text;
  }
}
