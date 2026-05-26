import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/lease_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class OwnerLeaseNotifier extends StateNotifier<AsyncValue<List<LeaseModel>>> {
  OwnerLeaseNotifier() : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiService.instance.get(
        ApiConstants.leases,
        params: {'role': 'owner'},
      );
      final List<dynamic> data = response.data['content'] ?? response.data;
      state = AsyncValue.data(data.map((e) => LeaseModel.fromJson(e)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> createLease(Map<String, dynamic> data) async {
    await ApiService.instance.post(ApiConstants.leases, data: data);
    await load();
  }

  Future<void> recordPayment(String leaseId, Map<String, dynamic> data) async {
    await ApiService.instance.post(ApiConstants.leasePayments(leaseId), data: data);
  }

  Future<void> terminateLease(String leaseId, String reason) async {
    await ApiService.instance.post(ApiConstants.terminateLease(leaseId), data: {'reason': reason});
    await load();
  }
}

final ownerLeaseProvider =
    StateNotifierProvider<OwnerLeaseNotifier, AsyncValue<List<LeaseModel>>>(
  (ref) => OwnerLeaseNotifier()..load(),
);
