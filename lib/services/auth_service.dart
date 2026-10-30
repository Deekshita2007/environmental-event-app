import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../models/user.dart';

enum AuthResult {
  success,
  accountNotFound,
  incorrectCredentials,
  accountAlreadyExists,
  invalidInput,
  error,
}

enum ProfileUpdateResult {
  success,
  emailVerificationSent,
  invalidInput,
  emailAlreadyInUse,
}

enum PasswordResetResult { success, invalidInput, error }

abstract interface class AuthGateway {
  Future<AppUser> login(String email, String password);
  Future<AppUser> register(String name, String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<bool> updateProfile(AppUser user);
  Future<void> logout();
}

abstract interface class UserProfileRepository {
  Future<AppUser?> getProfile(String userId);
  Future<void> saveProfile(AppUser user);
}

class FirebaseAuthProvider implements AuthGateway {
  FirebaseAuthProvider({this.firebaseAuth});

  final FirebaseAuth? firebaseAuth;
  FirebaseAuth get _auth => firebaseAuth ?? FirebaseAuth.instance;

  @override
  Future<AppUser> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user was returned after signing in.',
      );
    }
    return _toAppUser(user);
  }

  @override
  Future<AppUser> register(String name, String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user was returned after account creation.',
      );
    }

    await user.updateDisplayName(name);
    await user.reload();
    return _toAppUser(_auth.currentUser ?? user);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<bool> updateProfile(AppUser user) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'You must be signed in to update your profile.',
      );
    }

    if (firebaseUser.email?.toLowerCase() != user.email.toLowerCase()) {
      await firebaseUser.verifyBeforeUpdateEmail(user.email);
      await firebaseUser.updateDisplayName(user.name);
      return true;
    }
    await firebaseUser.updateDisplayName(user.name);
    await firebaseUser.reload();
    return false;
  }

  @override
  Future<void> logout() => _auth.signOut();

  AppUser _toAppUser(User user) {
    final email = (user.email ?? '').toLowerCase();
    return AppUser(
      id: user.uid,
      name: user.displayName ?? '',
      email: email,
      isAdmin: email == AuthService.adminEmail,
      phoneNumber: user.phoneNumber ?? '',
    );
  }
}

class FirestoreUserProfileRepository implements UserProfileRepository {
  FirestoreUserProfileRepository({this.firestore});

  final FirebaseFirestore? firestore;
  FirebaseFirestore get _database => firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _profiles =>
      _database.collection('users');

  @override
  Future<AppUser?> getProfile(String userId) async {
    final snapshot = await _profiles.doc(userId).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;

    return AppUser(
      id: userId,
      name: data['name'] as String? ?? '',
      email: data['email'] as String? ?? '',
      isAdmin: data['isAdmin'] as bool? ?? false,
      phoneNumber: data['phoneNumber'] as String? ?? '',
      location: data['location'] as String? ?? '',
      profileImagePath: data['profileImagePath'] as String?,
    );
  }

  @override
  Future<void> saveProfile(AppUser user) {
    return _profiles.doc(user.id).set({
      'name': user.name,
      'email': user.email,
      'isAdmin': user.isAdmin,
      'phoneNumber': user.phoneNumber,
      'location': user.location,
      'profileImagePath': user.profileImagePath,
    }, SetOptions(merge: true));
  }
}

class AuthService {
  static const adminEmail = 'admin@ecoconnect.com';

  AuthService({
    AuthGateway? authProvider,
    UserProfileRepository? profileRepository,
  }) : _authProvider = authProvider ?? FirebaseAuthProvider(),
       _profileRepository =
           profileRepository ?? FirestoreUserProfileRepository();

  final AuthGateway _authProvider;
  final UserProfileRepository _profileRepository;
  AppUser? _currentUser;
  final Map<String, AppUser> _usersById = {};

  AppUser? get currentUser => _currentUser;
  List<AppUser> getUsers() => List.unmodifiable(_usersById.values);

  Future<AuthResult> login(String email, String password) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty || password.trim().isEmpty) {
      return AuthResult.invalidInput;
    }

    try {
      final authenticatedUser = await _authProvider.login(
        normalizedEmail,
        password,
      );
      AppUser? savedProfile;
      try {
        savedProfile = await _profileRepository.getProfile(
          authenticatedUser.id,
        );
      } on FirebaseException catch (error) {
        debugPrint('Could not load optional user profile: $error');
      }
      final user = (savedProfile ?? authenticatedUser).copyWith(
        email: normalizedEmail,
        name: (savedProfile?.name.isNotEmpty ?? false)
            ? savedProfile!.name
            : authenticatedUser.name,
      );
      final profile = AppUser(
        id: user.id,
        name: user.name,
        email: user.email,
        isAdmin: authenticatedUser.isAdmin,
        phoneNumber: user.phoneNumber,
        location: user.location,
        profileImagePath: user.profileImagePath,
      );
      _setCurrentUser(profile);
      return AuthResult.success;
    } on FirebaseAuthException catch (error) {
      return _mapAuthError(error);
    }
  }

  Future<AuthResult> register(
    String name,
    String email,
    String password,
  ) async {
    if (name.trim().isEmpty ||
        email.trim().isEmpty ||
        password.trim().isEmpty) {
      return AuthResult.invalidInput;
    }

    try {
      final user = await _authProvider.register(
        name.trim(),
        email.trim().toLowerCase(),
        password,
      );
      await _profileRepository.saveProfile(user);
      _setCurrentUser(user);
      return AuthResult.success;
    } on FirebaseAuthException catch (error) {
      return _mapAuthError(error);
    }
  }

  Future<PasswordResetResult> sendPasswordResetEmail(String email) async {
    final normalizedEmail = email.trim().toLowerCase();
    if (normalizedEmail.isEmpty) return PasswordResetResult.invalidInput;

    try {
      await _authProvider.sendPasswordResetEmail(normalizedEmail);
      return PasswordResetResult.success;
    } on FirebaseAuthException catch (error) {
      if (error.code == 'user-not-found') return PasswordResetResult.success;
      if (error.code == 'invalid-email') {
        return PasswordResetResult.invalidInput;
      }
      return PasswordResetResult.error;
    }
  }

  Future<ProfileUpdateResult> updateCurrentUser({
    required String name,
    required String email,
    required String phoneNumber,
    required String location,
    required String profileImagePath,
  }) async {
    final currentUser = _currentUser;
    final normalizedEmail = email.trim().toLowerCase();
    if (currentUser == null || name.trim().isEmpty || normalizedEmail.isEmpty) {
      return ProfileUpdateResult.invalidInput;
    }

    final hasEmailConflict = _usersById.values.any(
      (user) => user.email == normalizedEmail && user.id != currentUser.id,
    );
    if (hasEmailConflict) return ProfileUpdateResult.emailAlreadyInUse;

    final updatedUser = AppUser(
      id: currentUser.id,
      name: name.trim(),
      email: normalizedEmail,
      isAdmin: normalizedEmail == adminEmail,
      phoneNumber: phoneNumber.trim(),
      location: location.trim(),
      profileImagePath: profileImagePath.trim().isEmpty
          ? null
          : profileImagePath.trim(),
    );
    final emailChangePending = await _authProvider.updateProfile(updatedUser);
    final savedUser = emailChangePending
        ? AppUser(
            id: updatedUser.id,
            name: updatedUser.name,
            email: currentUser.email,
            isAdmin: currentUser.isAdmin,
            phoneNumber: updatedUser.phoneNumber,
            location: updatedUser.location,
            profileImagePath: updatedUser.profileImagePath,
          )
        : updatedUser;
    await _profileRepository.saveProfile(savedUser);
    _setCurrentUser(savedUser);
    return emailChangePending
        ? ProfileUpdateResult.emailVerificationSent
        : ProfileUpdateResult.success;
  }

  Future<void> logout() async {
    await _authProvider.logout();
    _currentUser = null;
  }

  void _setCurrentUser(AppUser user) {
    _currentUser = user;
    _usersById[user.id] = user;
  }

  AuthResult _mapAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return AuthResult.accountNotFound;
      case 'wrong-password':
      case 'invalid-credential':
        return AuthResult.incorrectCredentials;
      case 'email-already-in-use':
        return AuthResult.accountAlreadyExists;
      case 'invalid-email':
      case 'weak-password':
        return AuthResult.invalidInput;
      default:
        return AuthResult.error;
    }
  }
}
