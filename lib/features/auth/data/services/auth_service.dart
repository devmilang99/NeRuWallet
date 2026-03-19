import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:flutter/foundation.dart';
import 'package:neruwallet/features/auth/domain/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserModel?> signUpWithEmailPassword(String email, String password, String name) async {
    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      // Store name in Firebase Auth display name since we aren't using Firestore
      await cred.user!.updateDisplayName(name);
      
      return UserModel(
        uid: cred.user!.uid, 
        email: email, 
        name: name,
      );
    } catch (e) {
      debugPrint(e.toString());
      rethrow;
    }
  }

  Future<UserModel?> signInWithEmailPassword(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(email: email, password: password);
      
      return UserModel(
        uid: cred.user!.uid,
        email: email,
        name: cred.user!.displayName ?? 'User',
      );
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
    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      name: nameOverride ?? user.displayName ?? 'User',
      profilePicUrl: user.photoURL,
    );
  }
}
