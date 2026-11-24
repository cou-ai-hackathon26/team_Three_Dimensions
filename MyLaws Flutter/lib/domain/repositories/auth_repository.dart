class AuthUser {
  final String uid;
  final String? email;
  final String? displayName;
  final bool isGuest;

  const AuthUser({
    required this.uid,
    this.email,
    this.displayName,
    this.isGuest = false,
  });
}

abstract class AuthRepository {
  /// Stream of authentication state changes
  Stream<AuthUser?> authStateChanges();

  /// Current user
  AuthUser? get currentUser;

  /// Sign in with email and password
  Future<AuthUser> signInWithEmail(String email, String password);

  /// Sign up with email and password
  Future<AuthUser> signUpWithEmail(String email, String password);

  /// Sign in with Google ID token from platform credential UI or direct verified Google account email
  Future<AuthUser> signInWithGoogle([String idToken = 'mock_id_token', String? email]);

  /// Continue without account (Guest mode)
  Future<AuthUser> continueAsGuest();

  /// Sign out
  Future<void> signOut();

  /// In-app account deletion
  Future<void> deleteAccount();
}
