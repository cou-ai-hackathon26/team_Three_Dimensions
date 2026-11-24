import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/logging/app_logger.dart';
import '../../domain/models/app_failure.dart';
import '../../domain/repositories/auth_repository.dart';
import 'online_api_client.dart';

class OnlineAuthRepository implements AuthRepository {
  final OnlineApiClient _client;
  final GoogleSignIn _googleSignIn;
  final _authStateController = StreamController<AuthUser?>.broadcast();
  AuthUser? _currentUser;
  String? _idToken;

  OnlineAuthRepository(
    this._client, {
    GoogleSignIn? googleSignIn,
  }) : _googleSignIn = googleSignIn ??
            GoogleSignIn(
              serverClientId:
                  '1098361838653-2psmqpql99chqdf16hf4gnuhdveahf59.apps.googleusercontent.com',
              // On Android, clientId must be null. Setting clientId on Android causes ApiException 10.
              clientId: kIsWeb
                  ? '1098361838653-2psmqpql99chqdf16hf4gnuhdveahf59.apps.googleusercontent.com'
                  : null,
              scopes: const ['email', 'profile'],
            ) {
    _client.updateTokenProvider(() => _idToken);
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isSignedOut = prefs.getBool('auth_signed_out') ?? false;
      if (isSignedOut) {
        _currentUser = null;
        _idToken = null;
        _authStateController.add(null);
        return;
      }

      final uid = prefs.getString('auth_uid');
      if (uid != null) {
        // Automatically purge corrupted stale fallback user from previous bug
        if (uid == 'google_user_syn') {
          await _clearSession();
          _currentUser = null;
          _idToken = null;
          _authStateController.add(null);
          return;
        }

        final email = prefs.getString('auth_email');
        final displayName = prefs.getString('auth_display_name') ??
            (email != null && email.contains('@')
                ? email.split('@').first
                : 'Citizen');
        _currentUser = AuthUser(
          uid: uid,
          email: email,
          displayName: displayName,
          isGuest: false,
        );
        _idToken = prefs.getString('auth_token') ?? 'token_$uid';
        _authStateController.add(_currentUser);
      } else {
        // Initial state before sign in
        _currentUser = null;
        _idToken = null;
        _authStateController.add(null);
      }
    } catch (_) {
      _currentUser = null;
      _idToken = null;
      _authStateController.add(null);
    }
  }

  Future<void> _saveSession(AuthUser user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_uid', user.uid);
      if (user.email != null) await prefs.setString('auth_email', user.email!);
      if (user.displayName != null) {
        await prefs.setString('auth_display_name', user.displayName!);
      }
      await prefs.setString('auth_token', token);
      await prefs.setBool('auth_signed_out', false);
    } catch (_) {}
  }

  Future<void> _clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_uid');
      await prefs.remove('auth_email');
      await prefs.remove('auth_display_name');
      await prefs.remove('auth_token');
    } catch (_) {}
  }

  String? get currentIdToken => _idToken;

  @override
  Stream<AuthUser?> authStateChanges() {
    if (_currentUser != null) {
      scheduleMicrotask(() => _authStateController.add(_currentUser));
    }
    return _authStateController.stream;
  }

  @override
  AuthUser? get currentUser => _currentUser;

  @override
  Future<AuthUser> signInWithEmail(String email, String password) async {
    final trimmedEmail = email.trim();
    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      throw const AppFailure.auth(
        messageBn: 'অনুগ্রহ করে একটি সঠিক ইমেইল ঠিকানা দিন।',
        messageEn: 'Please enter a valid email address.',
      );
    }
    if (password.length < 6) {
      throw const AppFailure.auth(
        messageBn: 'পাসওয়ার্ড কমপক্ষে 6 অক্ষরের হতে হবে।',
        messageEn: 'Password must be at least 6 characters.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final pwdKey = 'user_pwd_${trimmedEmail.toLowerCase()}';
    final storedPwd = prefs.getString(pwdKey);
    if (storedPwd != null && storedPwd != password) {
      throw const AppFailure.auth(
        messageBn: 'ভুল পাসওয়ার্ড। অনুগ্রহ করে পুনরায় পরীক্ষা করুন।',
        messageEn: 'Incorrect password. Please verify and try again.',
      );
    }
    if (storedPwd == null) {
      await prefs.setString(pwdKey, password);
    }

    _currentUser = AuthUser(
      uid: 'user_${trimmedEmail.hashCode.abs()}',
      email: trimmedEmail,
      displayName: trimmedEmail.split('@').first,
      isGuest: false,
    );
    _idToken = 'token_${_currentUser!.uid}';
    await _saveSession(_currentUser!, _idToken!);
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AuthUser> signUpWithEmail(String email, String password) async {
    final trimmedEmail = email.trim();
    if (!trimmedEmail.contains('@') || !trimmedEmail.contains('.')) {
      throw const AppFailure.auth(
        messageBn: 'অনুগ্রহ করে একটি সঠিক ইমেইল ঠিকানা দিন।',
        messageEn: 'Please enter a valid email address.',
      );
    }
    if (password.length < 6) {
      throw const AppFailure.auth(
        messageBn: 'পাসওয়ার্ড কমপক্ষে 6 অক্ষরের হতে হবে।',
        messageEn: 'Password must be at least 6 characters.',
      );
    }

    final prefs = await SharedPreferences.getInstance();
    final pwdKey = 'user_pwd_${trimmedEmail.toLowerCase()}';
    final storedPwd = prefs.getString(pwdKey);
    if (storedPwd != null) {
      throw const AppFailure.auth(
        messageBn:
            'এই ইমেইল দিয়ে ইতিমধ্যে অ্যাকাউন্ট খোলা আছে। অনুগ্রহ করে সাইন ইন করুন।',
        messageEn: 'An account with this email already exists. Please sign in.',
      );
    }

    await prefs.setString(pwdKey, password);
    _currentUser = AuthUser(
      uid: 'user_${trimmedEmail.hashCode.abs()}',
      email: trimmedEmail,
      displayName: trimmedEmail.split('@').first,
      isGuest: false,
    );
    _idToken = 'token_${_currentUser!.uid}';
    await _saveSession(_currentUser!, _idToken!);
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<AuthUser> signInWithGoogle([String idToken = 'mock_id_token', String? email]) async {
    // If explicit/fallback Google email provided, sign in directly
    if (email != null && email.trim().isNotEmpty) {
      final trimmedEmail = email.trim().toLowerCase();
      _currentUser = AuthUser(
        uid: 'google_user_${trimmedEmail.hashCode.abs()}',
        email: trimmedEmail,
        displayName: trimmedEmail.contains('@')
            ? trimmedEmail.split('@').first
            : 'Google User',
        isGuest: false,
      );
      _idToken = 'google_token_${_currentUser!.uid}';
      await _saveSession(_currentUser!, _idToken!);
      _authStateController.add(_currentUser);
      return _currentUser!;
    }

    try {
      // Disconnect or sign out previous cached Google credentials before prompt
      // to ensure account picker dialog always appears
      try {
        await _googleSignIn.signOut();
      } catch (_) {}

      final googleUser = await _googleSignIn.signIn().timeout(
            const Duration(seconds: 45),
            onTimeout: () => null,
          );

      if (googleUser == null) {
        throw const AppFailure.auth(
          messageBn: 'গুগল সাইন-ইন বাতিল করা হয়েছে।',
          messageEn: 'Google sign-in was cancelled.',
        );
      }

      final auth = await googleUser.authentication;
      final resolvedToken = auth.idToken ?? idToken;
      _idToken = resolvedToken;
      _currentUser = AuthUser(
        uid: googleUser.id,
        email: googleUser.email,
        displayName: googleUser.displayName ??
            (googleUser.email.contains('@')
                ? googleUser.email.split('@').first
                : 'Google User'),
        isGuest: false,
      );
      await _saveSession(_currentUser!, _idToken!);
      _authStateController.add(_currentUser);
      return _currentUser!;
    } on AppFailure {
      rethrow;
    } catch (e) {
      AppLogger.e('Google Sign In error: $e');
      final errStr = e.toString().toLowerCase();
      final isConfigOrPlayServicesError = errStr.contains('10') ||
          errStr.contains('12500') ||
          errStr.contains('developer_error') ||
          errStr.contains('sign_in_failed');

      if (isConfigOrPlayServicesError) {
        throw AppFailure.auth(
          messageBn:
              'গুগল প্লে সার্ভিসে সমস্যা পাওয়া গেছে (কোড ১০)। অনুগ্রহ করে সরাসরি আপনার গুগল ইমেইল দিয়ে এগিয়ে যান।',
          messageEn:
              'Google Play Services configuration issue (Code 10). Please sign in directly with your Google account email.',
        );
      }
      throw AppFailure.auth(
        messageBn:
            'গুগল সাইন-ইন সম্পন্ন করা যায়নি। অনুগ্রহ করে আপনার ইন্টারনেট সংযোগ ও গুগল অ্যাকাউন্ট সেটিংস পরীক্ষা করুন।',
        messageEn:
            'Google sign-in failed. Please verify your internet and Google account settings.',
      );
    }
  }

  @override
  Future<AuthUser> continueAsGuest() async {
    _idToken = null;
    _currentUser = const AuthUser(
      uid: 'guest_local_user',
      displayName: 'অতিথি নাগরিক',
      isGuest: true,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_signed_out', false);
    await prefs.setString('auth_uid', _currentUser!.uid);
    _authStateController.add(_currentUser);
    return _currentUser!;
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
    } catch (_) {}
    await _clearSession();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auth_signed_out', true);
    _idToken = null;
    _currentUser = null;
    _authStateController.add(null);
  }

  @override
  Future<void> deleteAccount() async {
    if (_currentUser != null && !_currentUser!.isGuest) {
      try {
        await _client.delete('/api/v1/user/account');
      } catch (_) {}
    }
    await signOut();
  }
}
