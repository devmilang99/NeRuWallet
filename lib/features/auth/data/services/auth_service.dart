import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';
import 'package:neruwallet/features/auth/domain/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserModel?> signUpWithEmailPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user!.updateDisplayName(name);
      return _saveAndReturnUser(cred, nameOverride: name);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<UserModel?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return _saveAndReturnUser(cred);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw Exception('Google Sign In was cancelled by user');
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential cred = await _auth.signInWithCredential(credential);
      return _saveAndReturnUser(cred);
    } catch (e) {
      debugPrint('Google Sign In Error: $e');
      rethrow;
    }
  }

  Future<UserModel?> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential =
          await SignInWithApple.getAppleIDCredential(
            scopes: [
              AppleIDAuthorizationScopes.email,
              AppleIDAuthorizationScopes.fullName,
            ],
          );

      if (appleCredential.identityToken == null) {
        throw Exception('Apple Sign In failed: No identity token received');
      }

      final OAuthProvider provider = OAuthProvider('apple.com');
      final OAuthCredential credential = provider.credential(
        idToken: appleCredential.identityToken,
        rawNonce: appleCredential.state,
      );

      UserCredential cred = await _auth.signInWithCredential(credential);

      // If user info from Apple is available, update the Firebase user
      if (appleCredential.givenName != null ||
          appleCredential.familyName != null) {
        final fullName =
            '${appleCredential.givenName ?? ''} ${appleCredential.familyName ?? ''}'
                .trim();
        if (fullName.isNotEmpty) {
          await cred.user?.updateDisplayName(fullName);
        }
      }

      String name =
          (cred.user?.displayName == null || cred.user!.displayName!.isEmpty)
          ? (appleCredential.givenName ?? 'Apple User')
          : cred.user!.displayName!;

      return _saveAndReturnUser(cred, nameOverride: name);
    } catch (e) {
      debugPrint('Apple Sign In Error: $e');
      rethrow;
    }
  }

  Future<UserModel?> _saveAndReturnUser(
    UserCredential cred, {
    String? nameOverride,
  }) async {
    final user = cred.user!;
    final bool isNewUser = cred.additionalUserInfo?.isNewUser ?? false;

    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: nameOverride ?? user.displayName ?? 'User',
      profilePicUrl: user.photoURL,
      isNewUser: isNewUser,
    );
  }

  Future<void> reauthenticateWithEmail(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No signed in user available for re-authentication.');
    }

    final providers = user.providerData.map((p) => p.providerId).toList();
    if (!providers.contains('password')) {
      throw Exception(
        'Password changes are only supported for email/password accounts.',
      );
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );

    await user.reauthenticateWithCredential(credential);
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('No signed in user available for password change.');
    }

    final email = user.email;
    if (email == null || email.isEmpty) {
      throw Exception('Email address required for password change.');
    }

    await reauthenticateWithEmail(email, oldPassword);
    await user.updatePassword(newPassword);
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect(); // Forces account picker next time

      // Clear remember_me in Drift AppPreferences so next launch shows the login screen
      // Assuming a provider or singleton for the database is available or passed
      // For simplicity in this service, we could use the database instance directly if we had a way to get it
      // In a proper MVVM/Riverpod setup, this would be handled via a higher-level controller.
    } catch (e) {
      debugPrint("Error signing out: $e");
    }
  }

  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await user.delete();
      }
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
    } catch (e) {
      debugPrint("Error deleting account: $e");
      // If deletion fails due to recent login requirement, we should at least sign out
      await signOut();
    }
  }
}
