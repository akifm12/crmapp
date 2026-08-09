import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/api_client.dart';
import '../../core/secure_storage.dart';
import '../../models/public_user.dart';
import '../compliance_calendar/compliance_provider.dart';

class AuthState {
  final PublicUser? user;
  final bool isLoading;

  const AuthState({this.user, this.isLoading = true});

  bool get isLoggedIn => user != null;

  AuthState copyWith({PublicUser? user, bool? isLoading, bool clearUser = false}) => AuthState(
        user: clearUser ? null : (user ?? this.user),
        isLoading: isLoading ?? this.isLoading,
      );
}

class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;

  AuthNotifier(this.ref) : super(const AuthState()) {
    _init();
    unauthorizedEvents.stream.listen((_) => _clear());
  }

  Future<void> _init() async {
    final token = await SecureStorage.readToken();
    if (token == null) {
      state = state.copyWith(isLoading: false);
      return;
    }
    try {
      final response = await ApiClient.instance.get('/account/me');
      state = AuthState(user: PublicUser.fromJson(response.data as Map<String, dynamic>), isLoading: false);
    } catch (_) {
      await SecureStorage.deleteToken();
      state = state.copyWith(isLoading: false, clearUser: true);
    }
  }

  Future<String?> login(String email, String password) async {
    try {
      final response = await ApiClient.instance.post('/auth/login', data: {
        'email': email,
        'password': password,
      });
      await _applyAuthResponse(response.data as Map<String, dynamic>);
      return null;
    } catch (e) {
      return _extractError(e);
    }
  }

  Future<String?> register({
    required String name,
    required String email,
    required String password,
    required bool subscribeToUpdates,
  }) async {
    try {
      final response = await ApiClient.instance.post('/auth/register', data: {
        'name': name,
        'email': email,
        'password': password,
        'password_confirmation': password,
        'subscribed_to_updates': subscribeToUpdates,
      });
      await _applyAuthResponse(response.data as Map<String, dynamic>);
      return null;
    } catch (e) {
      return _extractError(e);
    }
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post('/auth/logout');
    } catch (_) {
      // token may already be invalid — clearing locally is enough
    }
    await _clear();
  }

  Future<void> _applyAuthResponse(Map<String, dynamic> data) async {
    await SecureStorage.writeToken(data['token'] as String);
    state = AuthState(user: PublicUser.fromJson(data['user'] as Map<String, dynamic>), isLoading: false);
    ref.invalidate(complianceCalendarProvider);
  }

  Future<void> _clear() async {
    await SecureStorage.deleteToken();
    state = const AuthState(isLoading: false);
    ref.invalidate(complianceCalendarProvider);
  }

  String _extractError(Object e) {
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map) {
        final errors = data['errors'];
        if (errors is Map && errors.isNotEmpty) {
          final firstList = errors.values.first;
          if (firstList is List && firstList.isNotEmpty) return firstList.first.toString();
        }
        if (data['message'] != null) return data['message'].toString();
      }
    }
    return 'Something went wrong. Please try again.';
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) => AuthNotifier(ref));
