import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/property_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class OwnerListingNotifier extends StateNotifier<AsyncValue<List<PropertyModel>>> {
  OwnerListingNotifier() : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiService.instance.get(ApiConstants.myProperties);
      final List<dynamic> data = response.data['content'] ?? response.data;
      state = AsyncValue.data(data.map((e) => PropertyModel.fromJson(e)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createListing(Map<String, dynamic> data) async {
    await ApiService.instance.post(ApiConstants.properties, data: data);
    await load();
  }

  Future<void> updateListing(String id, Map<String, dynamic> data) async {
    await ApiService.instance.put(ApiConstants.propertyById(id), data: data);
    await load();
  }

  Future<void> deleteListing(String id) async {
    await ApiService.instance.delete(ApiConstants.propertyById(id));
    await load();
  }

  Future<void> boostListing(String id, int days) async {
    await ApiService.instance.post(ApiConstants.boostProperty(id), data: {'days': days});
    await load();
  }
}

final ownerListingProvider =
    StateNotifierProvider<OwnerListingNotifier, AsyncValue<List<PropertyModel>>>(
  (ref) => OwnerListingNotifier()..load(),
);
