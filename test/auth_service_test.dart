import 'package:flutter_test/flutter_test.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/models/user.dart';
import 'package:flutter_application_1/services/auth_service.dart';

import 'support/fake_auth_backends.dart';

class DeniedProfileReadRepository extends FakeUserProfileRepository {
  @override
  Future<AppUser?> getProfile(String userId) async {
    throw FirebaseException(
      plugin: 'cloud_firestore',
      code: 'permission-denied',
    );
  }
}

void main() {
  test('login requires a registered account and matching password', () async {
    final authProvider = FakeAuthProvider();
    final profileRepository = FakeUserProfileRepository();
    final authService = createFakeAuthService(
      authProvider: authProvider,
      profileRepository: profileRepository,
    );

    expect(
      await authService.login('person@gmail.com', 'secret'),
      AuthResult.accountNotFound,
    );
    expect(
      await authService.register('Person', 'person@gmail.com', 'secret'),
      AuthResult.success,
    );
    expect(profileRepository.saveCount, 1);
    await authService.logout();

    expect(
      await authService.login('PERSON@gmail.com', 'wrong-secret'),
      AuthResult.incorrectCredentials,
    );
    expect(
      await authService.login('PERSON@gmail.com', 'secret'),
      AuthResult.success,
    );
    expect(authService.currentUser?.email, 'person@gmail.com');
    expect(authService.getUsers(), hasLength(1));
    expect(profileRepository.saveCount, 1);
  });

  test('password reset sends a normalized email address', () async {
    final authProvider = FakeAuthProvider();
    final authService = createFakeAuthService(authProvider: authProvider);

    expect(
      await authService.sendPasswordResetEmail(' Person@gmail.com '),
      PasswordResetResult.success,
    );
    expect(authProvider.passwordResetEmail, 'person@gmail.com');
    expect(
      await authService.sendPasswordResetEmail(' '),
      PasswordResetResult.invalidInput,
    );
  });

  test(
    'login succeeds when optional Firestore profile read is denied',
    () async {
      final authProvider = FakeAuthProvider();
      final authService = createFakeAuthService(authProvider: authProvider);
      await authService.register('Person', 'person@gmail.com', 'secret');
      await authService.logout();

      final returningUserService = createFakeAuthService(
        authProvider: authProvider,
        profileRepository: DeniedProfileReadRepository(),
      );

      expect(
        await returningUserService.login('person@gmail.com', 'secret'),
        AuthResult.success,
      );
      expect(returningUserService.currentUser?.email, 'person@gmail.com');
    },
  );

  test('regular accounts do not receive the admin role', () async {
    final authService = createFakeAuthService();

    expect(
      await authService.register('Jordan', 'jordan@gmail.com', 'demo'),
      AuthResult.success,
    );
    expect(authService.currentUser?.isAdmin, isFalse);
    expect(authService.getUsers(), hasLength(1));
  });

  test('duplicate email addresses cannot be registered', () async {
    final authService = createFakeAuthService();

    expect(
      await authService.register('Jordan', 'jordan@gmail.com', 'secret'),
      AuthResult.success,
    );
    expect(
      await authService.register('Another Jordan', 'JORDAN@gmail.com', 'other'),
      AuthResult.accountAlreadyExists,
    );
    expect(authService.getUsers(), hasLength(1));
  });

  test('profile updates email and optional user details', () async {
    final authProvider = FakeAuthProvider();
    final profileRepository = FakeUserProfileRepository();
    final authService = createFakeAuthService(
      authProvider: authProvider,
      profileRepository: profileRepository,
    );
    await authService.register('Jordan', 'jordan@gmail.com', 'demo');

    expect(
      await authService.updateCurrentUser(
        name: 'Jordan Green',
        email: 'jordan.green@example.com',
        phoneNumber: '555-0100',
        location: 'Portland',
        profileImagePath: '/profiles/profile.jpg',
      ),
      ProfileUpdateResult.success,
    );
    expect(authService.currentUser?.name, 'Jordan Green');
    expect(authService.currentUser?.email, 'jordan.green@example.com');
    expect(authService.currentUser?.phoneNumber, '555-0100');
    expect(authService.currentUser?.location, 'Portland');
    expect(authService.currentUser?.profileImagePath, '/profiles/profile.jpg');
    expect(authService.getUsers().single.email, 'jordan.green@example.com');

    await authService.logout();
    final returningUserService = createFakeAuthService(
      authProvider: authProvider,
      profileRepository: profileRepository,
    );
    expect(
      await returningUserService.login('jordan.green@example.com', 'demo'),
      AuthResult.success,
    );
    expect(returningUserService.currentUser?.name, 'Jordan Green');
    expect(returningUserService.currentUser?.phoneNumber, '555-0100');
    expect(returningUserService.currentUser?.location, 'Portland');
    expect(
      returningUserService.currentUser?.profileImagePath,
      '/profiles/profile.jpg',
    );
  });

  test('profile update cannot take another user email', () async {
    final authService = createFakeAuthService();
    await authService.register('Jordan', 'jordan@gmail.com', 'demo');
    await authService.register('Taylor', 'taylor@gmail.com', 'demo');

    expect(
      await authService.updateCurrentUser(
        name: 'Taylor',
        email: 'jordan@gmail.com',
        phoneNumber: '',
        location: '',
        profileImagePath: '',
      ),
      ProfileUpdateResult.emailAlreadyInUse,
    );
    expect(authService.currentUser?.email, 'taylor@gmail.com');
  });
}
