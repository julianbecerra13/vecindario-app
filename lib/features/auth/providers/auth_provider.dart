import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vecindario_app/features/auth/repositories/auth_repository.dart';
import 'package:vecindario_app/shared/providers/firebase_providers.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(firebaseAuthProvider));
});

final authStateChangesProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

enum AuthStatus { unauthenticated, authenticated, noCommunity, pendingApproval }
