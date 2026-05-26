import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../services/storage_service.dart';
import '../constants/api_constants.dart';
import 'package:dio/dio.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({
    required this.status,
    this.user,
    this.error,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.unknown);
  factory AuthState.authenticated(UserModel user) =>
      AuthState(status: AuthStatus.authenticated, user: user);
  factory AuthState.unauthenticated() =>
      const AuthState(status: AuthStatus.unauthenticated);

  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isOwner => user?.isOwner ?? false;
  bool get isTenant => user?.isTenant ?? false;
}

class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier() : super(AuthState.initial());

  final _api = ApiService.instance;

  Future<void> initialize() async {
    String? token;
    try {
      token = await StorageService.getAccessToken()
          .timeout(const Duration(seconds: 3));
    } catch (_) {
      state = AuthState.unauthenticated();
      return;
    }
    if (token == null) {
      state = AuthState.unauthenticated();
      return;
    }
    try {
      final response = await _api.get(ApiConstants.me)
          .timeout(const Duration(seconds: 5));
      final user = UserModel.fromJson(response.data);
      state = AuthState.authenticated(user);
    } catch (_) {
      state = AuthState.unauthenticated();
    }
  }

  Future<void> sendOtp(String phone) async {
    try {
      await _api.post(ApiConstants.sendOtp, data: {'phone': phone});
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<Map<String, dynamic>> verifyOtp(
      String phone,
      String otp, {
        String? role,
        String? fullName,
      }) async {
    try {
      final response = await _api.post(
        ApiConstants.verifyOtp,
        data: {
          'phone': phone,
          'otp': otp,
          if (role != null) 'role': role,
          if (fullName != null) 'fullName': fullName,
        },
      );
      final data = response.data as Map<String, dynamic>;
      await StorageService.saveTokens(
        accessToken: data['accessToken'],
        refreshToken: data['refreshToken'],
      );
      await refreshProfile();
      return data;
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> completeProfile({
    required String fullName,
    required String role,
    String? email,
  }) async {
    try {
      final response = await _api.put(ApiConstants.me, data: {
        'fullName': fullName,
        'role': role,
        'email': email,
      });
      final user = UserModel.fromJson(response.data);
      await StorageService.saveUserId(user.id);
      await StorageService.saveUserRole(user.role.name);
      state = AuthState.authenticated(user);
    } on DioException catch (e) {
      throw ApiException.fromDioError(e);
    }
  }

  Future<void> refreshProfile() async {
    try {
      final response = await _api.get(ApiConstants.me)
          .timeout(const Duration(seconds: 5));
      final user = UserModel.fromJson(response.data);
      state = AuthState.authenticated(user);
    } catch (_) {}
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiConstants.logout);
    } catch (_) {}
    await StorageService.clearAll();
    state = AuthState.unauthenticated();
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
      (ref) => AuthNotifier(),
);