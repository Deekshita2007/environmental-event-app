import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/auth_service.dart';

class FakeAuthProvider implements AuthGateway {
  final Map<String, ({AppUser user, String password})> _accounts = {};
  String? passwordResetEmail;

  @override
  Future<AppUser> login(String email, String password) async {
    final account = _accounts[email];
    if (account == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }
    if (account.password != password) {
      throw FirebaseAuthException(code: 'wrong-password');
    }
    return account.user;
  }

  @override
  Future<AppUser> register(String name, String email, String password) async {
    if (_accounts.containsKey(email)) {
      throw FirebaseAuthException(code: 'email-already-in-use');
    }
    final user = AppUser(
      id: 'user-$email',
      name: name,
      email: email,
      isAdmin: email == AuthService.adminEmail,
    );
    _accounts[email] = (user: user, password: password);
    return user;
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    passwordResetEmail = email;
  }

  @override
  Future<bool> updateProfile(AppUser user) async {
    final account = _accounts.values.firstWhere(
      (account) => account.user.id == user.id,
    );
    _accounts.remove(account.user.email);
    _accounts[user.email] = (user: user, password: account.password);
    return false;
  }

  @override
  Future<void> logout() async {}
}

class FakeUserProfileRepository implements UserProfileRepository {
  final Map<String, AppUser> profiles = {};
  int saveCount = 0;

  @override
  Future<AppUser?> getProfile(String userId) async => profiles[userId];

  @override
  Future<void> saveProfile(AppUser user) async {
    saveCount++;
    profiles[user.id] = user;
  }
}

AuthService createFakeAuthService({
  FakeAuthProvider? authProvider,
  FakeUserProfileRepository? profileRepository,
}) {
  return AuthService(
    authProvider: authProvider ?? FakeAuthProvider(),
    profileRepository: profileRepository ?? FakeUserProfileRepository(),
  );
}
