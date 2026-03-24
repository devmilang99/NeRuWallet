import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:neruwallet/features/auth/domain/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserModel?> signUpWithEmailPassword(String email, String password, String name) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      await cred.user!.updateDisplayName(name);
      return _saveAndReturnUser(cred, nameOverride: name);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<UserModel?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      return _saveAndReturnUser(cred);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential cred = await _auth.signInWithCredential(credential);
      return _saveAndReturnUser(cred);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<UserModel?> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final OAuthProvider provider = OAuthProvider('apple.com');
      final OAuthCredential credential = provider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      UserCredential cred = await _auth.signInWithCredential(credential);
      
      String name = (cred.user?.displayName == null || cred.user!.displayName!.isEmpty) 
          ? (appleCredential.givenName ?? 'Apple User') 
          : cred.user!.displayName!;
          
      return _saveAndReturnUser(cred, nameOverride: name);
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<UserModel?> _saveAndReturnUser(UserCredential cred, {String? nameOverride}) async {
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

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect(); // Forces account picker next time
      // Clear remember_me so next launch shows the login screen
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('remember_me');
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
    } catch (e) {
      debugPrint("Error deleting account: $e");
    }
  }
}
