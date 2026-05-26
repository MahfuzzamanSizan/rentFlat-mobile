import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/lease_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class TenantLeaseNotifier extends StateNotifier<AsyncValue<List<LeaseModel>>> {
  TenantLeaseNotifier() : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiService.instance.get(ApiConstants.leases);
      final List<dynamic> data = response.data['content'] ?? response.data;
      state = AsyncValue.data(data.map((e) => LeaseModel.fromJson(e)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> signLease(String leaseId) async {
    await ApiService.instance.post(ApiConstants.signLease(leaseId));
    await load();
  }
}

final tenantLeaseProvider =
    StateNotifierProvider<TenantLeaseNotifier, AsyncValue<List<LeaseModel>>>(
  (ref) => TenantLeaseNotifier()..load(),
);
