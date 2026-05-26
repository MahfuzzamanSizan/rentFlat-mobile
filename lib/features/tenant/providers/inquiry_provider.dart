import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/inquiry_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class TenantInquiryNotifier extends StateNotifier<AsyncValue<List<InquiryModel>>> {
  TenantInquiryNotifier() : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiService.instance.get(ApiConstants.tenantInquiries);
      final List<dynamic> data = response.data['content'] ?? response.data;
      state = AsyncValue.data(data.map((e) => InquiryModel.fromJson(e)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final tenantInquiryProvider =
    StateNotifierProvider<TenantInquiryNotifier, AsyncValue<List<InquiryModel>>>(
  (ref) => TenantInquiryNotifier()..load(),
);
