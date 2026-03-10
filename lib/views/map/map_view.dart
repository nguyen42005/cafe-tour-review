import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geocoding/geocoding.dart' as geo;

import '../../core/theme/app_colors.dart';
import '../../models/category_model.dart';
import '../../models/place_model.dart';
import '../../services/category_service.dart';
import '../../services/place_service.dart';
import '../places/place_detail_view.dart';
import 'widgets/map_widgets.dart';

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  static const LatLng _fallbackCenter = LatLng(10.7769, 106.7009);
  static const double _searchRadiusMeters = 20000;

  final PlaceService _placeService = PlaceService();
  final CategoryService _categoryService = CategoryService();
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  OverlayEntry? _snackOverlayEntry;

  LatLng _mapCenter = _fallbackCenter;
  LatLng? _userLocation;
  LatLng? _searchCenter;
  bool _isLocating = false;

  String _activeQuery = '';
  PlaceModel? _selectedPlace;
  List<PlaceModel> _latestPlaces = const [];
  bool _didFallbackFocus = false;
  bool _showPlacePreview = false;
  bool _isSearchingAddress = false;
  bool _shouldFilterByText = true;

  void _showSnackBar(String message) {
    // Remove existing snack bar if any
    _snackOverlayEntry?.remove();

    _snackOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: 80, // Above bottom navigation bar
        left: 16,
        right: 16,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: const TextStyle(color: Colors.white, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_snackOverlayEntry!);

    // Auto dismiss after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      _snackOverlayEntry?.remove();
      _snackOverlayEntry = null;
    });
  }

  @override
  void initState() {
    super.initState();
    _detectUserLocation();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: SafeArea(
        bottom: false,
        child: StreamBuilder<List<CategoryModel>>(
          stream: _categoryService.getCategoriesStream(),
          builder: (context, categorySnapshot) {
            final categories = categorySnapshot.data ?? const <CategoryModel>[];
            final categoryById = {
              for (final c in categories.where((c) => c.isActive)) c.id: c,
            };
            final categoryByName = {
              for (final c in categories.where((c) => c.isActive))
                c.name.toLowerCase(): c,
            };

            return StreamBuilder<List<PlaceModel>>(
              stream: _placeService.getApprovedPlacesStream(),
              builder: (context, snapshot) {
                final allPlaces = snapshot.data ?? const <PlaceModel>[];
                _latestPlaces = allPlaces;
                final visiblePlaces = _computeVisiblePlaces(allPlaces);

                if (_selectedPlace != null &&
                    visiblePlaces.every((p) => p.id != _selectedPlace!.id)) {
                  _selectedPlace = null;
                  _showPlacePreview = false;
                }

                _ensureDataFocusWhenNeeded(visiblePlaces);

                return Stack(
                  children: [
                    Positioned.fill(
                      child: FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _mapCenter,
                          initialZoom:
                              12, // Zoom level phù hợp cho bán kính 20km
                          minZoom: 4,
                          maxZoom: 18,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.mobile',
                          ),
                          MarkerLayer(
                            markers: _buildPlaceMarkers(
                              visiblePlaces,
                              categoryById,
                              categoryByName,
                            ),
                          ),
                          if (_userLocation != null && !_isSearchingAddress)
                            CircleLayer(
                              circles: [
                                CircleMarker(
                                  point: _userLocation!,
                                  radius: 24,
                                  color: AppColors.primary.withOpacity(0.2),
                                  borderStrokeWidth: 0,
                                ),
                              ],
                            ),
                          if (_userLocation != null && !_isSearchingAddress)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _userLocation!,
                                  width: 18,
                                  height: 18,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                    MapHeaderOverlay(
                      controller: _searchController,
                      onSubmitted: _applySearch,
                      onTapSearch: () => _applySearch(_searchController.text),
                      onTapFilter: () {
                        _showSnackBar('Bộ lọc đang phát triển');
                      },
                      resultCount: visiblePlaces.length,
                    ),
                    MapFloatingActions(
                      isLocating: _isLocating,
                      onTapLayers: () {
                        _showSnackBar('Chọn lớp bản đồ đang phát triển');
                      },
                      onTapLocation: _detectUserLocation,
                    ),
                    MapPreviewOverlay(
                      visible: _showPlacePreview,
                      place: _selectedPlace,
                      onOpenDetail: () {
                        final place = _selectedPlace;
                        if (place == null) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceDetailView(place: place),
                          ),
                        );
                      },
                      onDirections: () => _openDirections(_selectedPlace),
                      onCheckIn: () {
                        final place = _selectedPlace;
                        if (place == null) return;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PlaceDetailView(place: place),
                          ),
                        );
                      },
                    ),
                    MapLoadingOverlay(
                      show: snapshot.connectionState == ConnectionState.waiting,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _ensureDataFocusWhenNeeded(List<PlaceModel> visiblePlaces) {
    if (visiblePlaces.isEmpty) return;

    final target = _selectedPlace ?? visiblePlaces.first;

    if (_activeQuery.isNotEmpty) {
      _didFallbackFocus = false;
      return;
    }

    final user = _userLocation;
    if (user == null) {
      if (_didFallbackFocus) return;
      _didFallbackFocus = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _mapController.move(LatLng(target.lat, target.lng), 13.6);
      });
      return;
    }

    final distance = Geolocator.distanceBetween(
      user.latitude,
      user.longitude,
      target.lat,
      target.lng,
    );

    if (distance > 30000 && !_didFallbackFocus) {
      _didFallbackFocus = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        _mapController.move(LatLng(target.lat, target.lng), 13.6);
      });
    }

    if (distance <= 30000) {
      _didFallbackFocus = false;
    }
  }

  List<PlaceModel> _computeVisiblePlaces(List<PlaceModel> places) {
    final user = _userLocation;
    final center = _searchCenter ?? user;

    if (_activeQuery.isNotEmpty && _shouldFilterByText) {
      return places.where((place) {
        final q = _activeQuery;
        final matched =
            place.name.toLowerCase().contains(q) ||
            place.address.toLowerCase().contains(q) ||
            place.categoryName.toLowerCase().contains(q);

        if (!matched) return false;

        // Nếu có trung tâm tìm kiếm hoặc vị trí user, lọc theo bán kính 20km
        if (center != null) {
          final distance = Geolocator.distanceBetween(
            center.latitude,
            center.longitude,
            place.lat,
            place.lng,
          );
          return distance <= _searchRadiusMeters;
        }

        return true;
      }).toList();
    }

    if (center == null) {
      return places.take(50).toList();
    }

    final nearby = places.where((place) {
      final distance = Geolocator.distanceBetween(
        center.latitude,
        center.longitude,
        place.lat,
        place.lng,
      );
      return distance <= _searchRadiusMeters;
    }).toList();

    nearby.sort((a, b) {
      final da = Geolocator.distanceBetween(
        center.latitude,
        center.longitude,
        a.lat,
        a.lng,
      );
      final db = Geolocator.distanceBetween(
        center.latitude,
        center.longitude,
        b.lat,
        b.lng,
      );
      return da.compareTo(db);
    });

    final result = nearby.take(50).toList();

    // Đảm bảo địa điểm đang chọn (nếu có trong nearby) luôn xuất hiện trong kết quả hiển thị
    if (_selectedPlace != null &&
        !result.any((p) => p.id == _selectedPlace!.id)) {
      final selectedInNearby = places
          .where((p) => p.id == _selectedPlace!.id)
          .toList();
      if (selectedInNearby.isNotEmpty) {
        result.add(selectedInNearby.first);
      }
    }

    return result;
  }

  List<Marker> _buildPlaceMarkers(
    List<PlaceModel> places,
    Map<String, CategoryModel> categoryById,
    Map<String, CategoryModel> categoryByName,
  ) {
    final markers = places.map((place) {
      final isSelected = _selectedPlace?.id == place.id;
      final icon = _resolveCategoryIcon(place, categoryById, categoryByName);

      return Marker(
        point: LatLng(place.lat, place.lng),
        width: isSelected ? 58 : 50,
        height: isSelected ? 70 : 60,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedPlace = place;
              _showPlacePreview = true;
            });
            _mapController.move(
              LatLng(place.lat, place.lng),
              _mapController.camera.zoom,
            );
          },
          child: MapCategoryMarker(icon: icon, isSelected: isSelected),
        ),
      );
    }).toList();

    // Đảm bảo địa điểm được chọn luôn có Marker ngay cả khi bị lọc
    if (_selectedPlace != null &&
        !places.any((p) => p.id == _selectedPlace!.id)) {
      final icon = _resolveCategoryIcon(
        _selectedPlace!,
        categoryById,
        categoryByName,
      );
      markers.add(
        Marker(
          point: LatLng(_selectedPlace!.lat, _selectedPlace!.lng),
          width: 58,
          height: 70,
          child: GestureDetector(
            onTap: () {
              setState(() => _showPlacePreview = true);
              _mapController.move(
                LatLng(_selectedPlace!.lat, _selectedPlace!.lng),
                _mapController.camera.zoom,
              );
            },
            child: MapCategoryMarker(icon: icon, isSelected: true),
          ),
        ),
      );
    }

    return markers;
  }

  IconData _resolveCategoryIcon(
    PlaceModel place,
    Map<String, CategoryModel> categoryById,
    Map<String, CategoryModel> categoryByName,
  ) {
    CategoryModel? category;
    if (place.categoryId.isNotEmpty) {
      category = categoryById[place.categoryId];
    }
    category ??= categoryByName[place.categoryName.toLowerCase()];

    final iconName = (category?.icon ?? '').trim().toLowerCase();
    switch (iconName) {
      case 'coffee':
      case 'local_cafe':
        return Icons.local_cafe;
      case 'restaurant':
        return Icons.restaurant;
      case 'bakery_dining':
        return Icons.bakery_dining;
      case 'icecream':
        return Icons.icecream;
      case 'beach':
        return Icons.beach_access;
      case 'forest':
        return Icons.forest;
      case 'mountain':
        return Icons.terrain;
      case 'nature':
        return Icons.nature_people;
      case 'hotel':
        return Icons.hotel;
      case 'map':
      case 'explore':
        return Icons.explore;
      case 'camera':
        return Icons.camera_alt;
      case 'favorite':
        return Icons.favorite;
      case 'star':
        return Icons.star;
      case 'pets':
        return Icons.pets;
      case 'event':
        return Icons.event;
      case 'shopping':
        return Icons.shopping_bag;
      default:
        return Icons.local_cafe;
    }
  }

  void _applySearch(String rawQuery) async {
    final query = rawQuery.trim();

    if (query.isEmpty) {
      // Trường hợp 1: Không nhập gì → Lấy vị trí hiện tại làm mốc
      setState(() {
        _activeQuery = '';
        _searchCenter = null;
        _shouldFilterByText = true;
        _didFallbackFocus = false;
        _showPlacePreview = false;
      });

      if (_userLocation != null) {
        _mapController.move(_userLocation!, 15);
      }
      return;
    }

    // Kiểm tra xem query có khớp chính xác với 1 địa điểm không
    final exactMatch = _findExactOrClosestMatch(query.toLowerCase());
    if (exactMatch != null) {
      // Trường hợp 3: Tìm thấy địa điểm chính xác → Hiển thị card ngay
      setState(() {
        _activeQuery = query.toLowerCase();
        _selectedPlace = exactMatch;
        _searchCenter = LatLng(exactMatch.lat, exactMatch.lng);
        _shouldFilterByText = true;
        _showPlacePreview = true;
        _didFallbackFocus = false;
      });
      _mapController.move(LatLng(exactMatch.lat, exactMatch.lng), 15);
      return;
    }

    // Trường hợp 2: Nhập địa chỉ chung → Geocoding để lấy tọa độ
    setState(() => _isSearchingAddress = true);

    try {
      List<geo.Location> locations = await geo.locationFromAddress(query);

      if (locations.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Không tìm thấy địa chỉ này')),
          );
        }
        setState(() => _isSearchingAddress = false);
        return;
      }

      final targetLocation = LatLng(
        locations.first.latitude,
        locations.first.longitude,
      );

      // Tìm kiếm các địa điểm trong bán kính 20km từ vị trí geocoding
      final matched = _latestPlaces.where((place) {
        final distance = Geolocator.distanceBetween(
          targetLocation.latitude,
          targetLocation.longitude,
          place.lat,
          place.lng,
        );
        return distance <= _searchRadiusMeters;
      }).toList();

      if (matched.isNotEmpty) {
        final first = matched.first;
        setState(() {
          _activeQuery = query.toLowerCase();
          _searchCenter = targetLocation;
          _selectedPlace = first;
          // Quan trọng: Đối với tìm kiếm khu vực, ta KHÔNG nên lọc theo text
          // trừ khi muốn tìm từ khóa cụ thể trong khu vực đó.
          // Ở đây ta ưu tiên hiển thị TẤT CẢ quán quanh khu vực tìm được.
          _shouldFilterByText = false;
          _showPlacePreview = true;
          _didFallbackFocus = false;
        });
        _mapController.move(targetLocation, 12);
      } else {
        // Không tìm thấy cafe khớp tên, nhưng vẫn đặt tâm tìm kiếm để hiển thị các quán xung quanh
        setState(() {
          _activeQuery = query.toLowerCase();
          _searchCenter = targetLocation;
          _selectedPlace = null;
          _shouldFilterByText = false;
          _showPlacePreview = false;
          _didFallbackFocus = false;
        });
        _mapController.move(targetLocation, 12);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Không có địa điểm nào trong bán kính 20km từ vị trí này',
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi khi tìm địa chỉ: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSearchingAddress = false);
      }
    }
  }

  PlaceModel? _findExactOrClosestMatch(String query) {
    for (final place in _latestPlaces) {
      final nameNormalized = _normalizeString(place.name);
      final addressNormalized = _normalizeString(place.address);
      final queryNormalized = _normalizeString(query);

      if (nameNormalized == queryNormalized) {
        return place;
      }

      if (nameNormalized.contains(queryNormalized) &&
          queryNormalized.length > 5) {
        return place;
      }

      if (addressNormalized.contains(queryNormalized) &&
          queryNormalized.length > 10) {
        return place;
      }
    }
    return null;
  }

  String _normalizeString(String input) {
    String text = input.toLowerCase().trim();
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
    text = text.replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    text = text.replaceAll(RegExp(r'\s+'), ' ').trim();
    return text;
  }

  Future<void> _detectUserLocation() async {
    setState(() => _isLocating = true);
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Dịch vụ vị trí đang tắt. Hãy bật GPS để tiếp tục.',
              ),
              action: SnackBarAction(
                label: 'Bật GPS',
                onPressed: Geolocator.openLocationSettings,
              ),
            ),
          );
        }
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Bạn đã chặn quyền vị trí. Hãy cấp quyền trong Cài đặt.',
              ),
              action: SnackBarAction(
                label: 'Cài đặt',
                onPressed: Geolocator.openAppSettings,
              ),
            ),
          );
        }
        return;
      }

      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Ứng dụng cần quyền vị trí để hoạt động chính xác.',
              ),
            ),
          );
        }
        return;
      }

      Position? pos;
      try {
        pos = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
          timeLimit: const Duration(seconds: 12),
        );
      } catch (_) {
        pos = await Geolocator.getLastKnownPosition();
      }

      if (pos == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Không lấy được vị trí. Hãy thử ra ngoài trời và thử lại.',
              ),
            ),
          );
        }
        return;
      }

      final target = LatLng(pos.latitude, pos.longitude);
      if (!mounted) return;

      setState(() {
        _userLocation = target;
        _mapCenter = target;
        _didFallbackFocus = false;
      });

      if (_activeQuery.isEmpty) {
        _mapController.move(target, 12); // Zoom 12 để hiển thị bán kính 20km
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể lấy vị trí hiện tại: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLocating = false);
      }
    }
  }

  Future<void> _openDirections(PlaceModel? place) async {
    if (place == null) return;

    final appUri = Uri.parse(
      'comgooglemaps://?daddr=${place.lat},${place.lng}&directionsmode=driving',
    );
    final webUri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.lat},${place.lng}&travelmode=driving',
    );

    if (await canLaunchUrl(appUri)) {
      await launchUrl(appUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (await canLaunchUrl(webUri)) {
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
      return;
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Không mở được Google Maps trên thiết bị này'),
      ),
    );
  }
}
