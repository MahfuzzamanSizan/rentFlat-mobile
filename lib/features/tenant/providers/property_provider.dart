import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/property_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class PropertySearchState {
  final List<PropertyModel> properties;
  final bool isLoading;
  final String? error;
  final PropertyFilter filter;
  final bool hasMore;
  final int page;

  const PropertySearchState({
    this.properties = const [],
    this.isLoading = false,
    this.error,
    this.filter = const PropertyFilter(),
    this.hasMore = true,
    this.page = 0,
  });

  PropertySearchState copyWith({
    List<PropertyModel>? properties,
    bool? isLoading,
    String? error,
    PropertyFilter? filter,
    bool? hasMore,
    int? page,
  }) {
    return PropertySearchState(
      properties: properties ?? this.properties,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      filter: filter ?? this.filter,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
    );
  }
}

class PropertySearchNotifier extends StateNotifier<PropertySearchState> {
  PropertySearchNotifier() : super(const PropertySearchState());

  final _api = ApiService.instance;

  Future<void> search({PropertyFilter? filter, bool reset = true}) async {
    if (reset) {
      state = state.copyWith(isLoading: true, properties: [], page: 0, filter: filter, error: null);
    } else {
      if (!state.hasMore || state.isLoading) return;
      state = state.copyWith(isLoading: true);
    }

    try {
      final params = {
        ...(filter ?? state.filter).toQueryParams(),
        'page': reset ? 0 : state.page,
        'size': 10,
      };
      final response = await _api.get(ApiConstants.properties, params: params);
      final data = response.data;
      final List<dynamic> content = data['content'] ?? data;
      final items = content.map((e) => PropertyModel.fromJson(e)).toList();
      final newPage = reset ? 1 : state.page + 1;
      state = state.copyWith(
        properties: reset ? items : [...state.properties, ...items],
        isLoading: false,
        hasMore: items.length == 10,
        page: newPage,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<PropertyModel?> getProperty(String id) async {
    try {
      final response = await _api.get(ApiConstants.propertyById(id));
      return PropertyModel.fromJson(response.data);
    } catch (_) {
      return null;
    }
  }
}

final propertySearchProvider = StateNotifierProvider<PropertySearchNotifier, PropertySearchState>(
  (ref) => PropertySearchNotifier(),
);

// Shortlist provider — syncs with backend API
class ShortlistNotifier extends StateNotifier<List<String>> {
  ShortlistNotifier() : super([]);
  final _api = ApiService.instance;

  Future<void> loadShortlist() async {
    try {
      final response = await _api.get(ApiConstants.shortlist);
      final List<dynamic> data = response.data;
      state = data.map<String>((e) => e['id'] as String).toList();
    } catch (_) {}
  }

  Future<void> toggle(String propertyId) async {
    final isShortlisted = state.contains(propertyId);
    // Optimistic update
    if (isShortlisted) {
      state = state.where((id) => id != propertyId).toList();
    } else {
      state = [...state, propertyId];
    }
    try {
      if (isShortlisted) {
        await _api.delete(ApiConstants.shortlistProperty(propertyId));
      } else {
        await _api.post(ApiConstants.shortlistProperty(propertyId));
      }
    } catch (_) {
      // Revert on failure
      if (isShortlisted) {
        state = [...state, propertyId];
      } else {
        state = state.where((id) => id != propertyId).toList();
      }
    }
  }

  bool isShortlisted(String propertyId) => state.contains(propertyId);
}

final shortlistProvider = StateNotifierProvider<ShortlistNotifier, List<String>>(
  (ref) => ShortlistNotifier()..loadShortlist(),
);

// Areas provider
final areasProvider = FutureProvider<List<AreaModel>>((ref) async {
  try {
    final response = await ApiService.instance.get(ApiConstants.areas);
    final List<dynamic> data = response.data;
    return data.map((e) => AreaModel.fromJson(e)).toList();
  } catch (_) {
    return [];
  }
});
