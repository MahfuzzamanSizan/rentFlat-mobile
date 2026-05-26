import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/models/inquiry_model.dart';
import '../../../core/services/api_service.dart';
import '../../../core/constants/api_constants.dart';

class OwnerInquiryNotifier extends StateNotifier<AsyncValue<List<InquiryModel>>> {
  OwnerInquiryNotifier() : super(const AsyncValue.loading());

  Future<void> load() async {
    state = const AsyncValue.loading();
    try {
      final response = await ApiService.instance.get(ApiConstants.ownerInquiries);
      final List<dynamic> data = response.data['content'] ?? response.data;
      state = AsyncValue.data(data.map((e) => InquiryModel.fromJson(e)).toList());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> accept(String inquiryId, {String? message}) async {
    await ApiService.instance.post(ApiConstants.acceptInquiry(inquiryId), data: {'message': message ?? ''});
    await load();
  }

  Future<void> reject(String inquiryId, {String? message}) async {
    await ApiService.instance.post(ApiConstants.rejectInquiry(inquiryId), data: {'message': message ?? ''});
    await load();
  }
}

final ownerInquiryProvider =
    StateNotifierProvider<OwnerInquiryNotifier, AsyncValue<List<InquiryModel>>>(
  (ref) => OwnerInquiryNotifier()..load(),
);
