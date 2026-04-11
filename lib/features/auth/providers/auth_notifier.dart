import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/core/errors/failures.dart';
import 'package:vecindario_app/core/utils/logger.dart';
import 'package:vecindario_app/features/auth/repositories/auth_repository.dart';
import 'package:vecindario_app/features/auth/providers/auth_provider.dart';
import 'package:vecindario_app/shared/models/user_model.dart';
import 'package:vecindario_app/shared/providers/current_user_provider.dart';
import 'package:vecindario_app/shared/repositories/user_repository.dart';

class AuthState {
  final bool isLoading;
  final String? error;
  final String? verificationId;
  final bool phoneVerified;

  const AuthState({
    this.isLoading = false,
    this.error,
    this.verificationId,
    this.phoneVerified = false,
  });

  AuthState copyWith({
    bool? isLoading,
    String? error,
    String? verificationId,
    bool? phoneVerified,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      verificationId: verificationId ?? this.verificationId,
      phoneVerified: phoneVerified ?? this.phoneVerified,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;
  final UserRepository _userRepository;

  AuthNotifier(this._authRepository, this._userRepository)
      : super(const AuthState());

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.signInWithEmail(email, password);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      AppLogger.error('Error en login', e);
      state = state.copyWith(isLoading: false, error: 'Error inesperado');
      return false;
    }
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await _authRepository.signUpWithEmail(
        email: email,
        password: password,
        displayName: name,
      );

      final user = UserModel(
        id: credential.user!.uid,
        displayName: name,
        email: email,
        phone: phone,
        createdAt: DateTime.now(),
      );
      await _userRepository.createUser(user);

      state = state.copyWith(isLoading: false);
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      AppLogger.error('Error en registro', e);
      state = state.copyWith(isLoading: false, error: 'Error inesperado');
      return false;
    }
  }

  Future<bool> loginWithGoogle() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await _authRepository.signInWithGoogle();
      await _ensureUserDocument(credential);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      AppLogger.error('Error en Google Sign-In', e);
      state = state.copyWith(isLoading: false, error: 'Error inesperado');
      return false;
    }
  }

  Future<bool> loginWithApple() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final credential = await _authRepository.signInWithApple();
      await _ensureUserDocument(credential);
      state = state.copyWith(isLoading: false);
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      AppLogger.error('Error en Apple Sign-In', e);
      state = state.copyWith(isLoading: false, error: 'Error inesperado');
      return false;
    }
  }

  Future<void> _ensureUserDocument(UserCredential credential) async {
    final uid = credential.user!.uid;
    final existingUser = await _userRepository.getUser(uid);
    if (existingUser == null) {
      final user = UserModel(
        id: uid,
        displayName: credential.user!.displayName ?? '',
        email: credential.user!.email ?? '',
        phone: credential.user!.phoneNumber ?? '',
        photoURL: credential.user!.photoURL,
        createdAt: DateTime.now(),
      );
      await _userRepository.createUser(user);
    }
  }

  // --- Verificación OTP ---

  Future<void> sendPhoneOTP(String phoneNumber) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.verifyPhoneNumber(
        phoneNumber: '+57$phoneNumber',
        onCodeSent: (verificationId, _) {
          state = state.copyWith(
            isLoading: false,
            verificationId: verificationId,
          );
        },
        onVerificationCompleted: (credential) async {
          // Auto-verificación en Android
          try {
            await _authRepository.linkPhoneCredential(
              state.verificationId ?? '',
              credential.smsCode ?? '',
            );
            state = state.copyWith(isLoading: false, phoneVerified: true);
          } catch (_) {}
        },
        onFailed: (message) {
          state = state.copyWith(isLoading: false, error: message);
        },
      );
    } catch (e) {
      AppLogger.error('Error enviando OTP', e);
      state = state.copyWith(isLoading: false, error: 'Error al enviar código');
    }
  }

  Future<bool> verifyOTP(String smsCode) async {
    if (state.verificationId == null) {
      state = state.copyWith(error: 'Primero solicita el código');
      return false;
    }
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.linkPhoneCredential(
        state.verificationId!,
        smsCode,
      );
      state = state.copyWith(isLoading: false, phoneVerified: true);
      return true;
    } on AuthFailure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
      return false;
    } catch (e) {
      AppLogger.error('Error verificando OTP', e);
      state = state.copyWith(isLoading: false, error: 'Código inválido');
      return false;
    }
  }

  Future<void> resetPassword(String email) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authRepository.resetPassword(email);
      state = state.copyWith(isLoading: false);
    } on AuthFailure catch (e) {
      state = state.copyWith(isLoading: false, error: e.message);
    }
  }

  Future<void> logout() async {
    await _authRepository.signOut();
  }
}

final authNotifierProvider =
    StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(
    ref.watch(authRepositoryProvider),
    ref.watch(userRepositoryProvider),
  );
});
