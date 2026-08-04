import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:neruwallet/core/services/preference_service.dart';
import 'package:neruwallet/core/utils/logger.dart';
import 'package:neruwallet/features/auth/domain/models/user_model.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

final authServiceProvider = Provider<AuthService>((ref) => AuthService(ref));

class AuthService {
  final Ref _ref;
  final sb.SupabaseClient _supabase = sb.Supabase.instance.client;
  late final GoogleSignIn _googleSignIn;

  UserModel? get currentUser {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return UserModel(
      uid: user.id,
      email: user.email ?? '',
      name: user.userMetadata?['full_name'] ?? 'User',
      profilePicUrl: user.userMetadata?['avatar_url'],
    );
  }

  AuthService(this._ref) {
    _googleSignIn = GoogleSignIn(
      serverClientId: dotenv.env['GOOGLE_WEB_CLIENT_ID'],
    );
  }

  Future<UserModel?> signUpWithEmailPassword(
    String email,
    String password,
    String name, {
    Map<String, String>? initialPreferences,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': name},
      );

      if (response.user == null) return null;

      final userId = response.user!.id;

      // Batch upsert initial preferences (PIN, Question, etc.)
      final prefsToSync = <Map<String, dynamic>>[
        {
          'user_id': userId,
          'key': 'registration_data',
          'value': 'Email: $email, Name: $name',
        },
      ];

      if (initialPreferences != null) {
        initialPreferences.forEach((key, value) {
          prefsToSync.add({'user_id': userId, 'key': key, 'value': value});
        });
      }

      await _supabase
          .from('app_preferences')
          .upsert(prefsToSync, onConflict: 'user_id,key')
          .then((_) => AppLogger.i('Initial security data synced'))
          .catchError((e) => AppLogger.e('Initial sync failed', e));

      return UserModel(
        uid: userId,
        email: response.user!.email ?? '',
        name: name,
        isNewUser: true,
      );
    } catch (e) {
      AppLogger.e('Supabase SignUp Error', e);
      rethrow;
    }
  }

  /// Checks if an email is already registered.
  /// Note: This often requires a custom Postgres function (RPC) in Supabase
  /// because the 'auth.users' table is not directly accessible from the client.
  Future<bool> isEmailAvailable(String email) async {
    try {
      // If you have a public 'profiles' table that syncs with auth.users,
      // you could query it here. For example:
      // final res = await _supabase.from('profiles').select('id').eq('email', email).maybeSingle();
      // return res == null;

      // Alternatively, using a dedicated RPC is the most secure way:
      final res = await _supabase.rpc(
        'check_email_exists',
        params: {'email_input': email},
      );
      return !(res as bool);
    } catch (e) {
      AppLogger.e('Email Check Error', e);
      return true; // Fallback to true to not block signup if check fails
    }
  }

  Future<UserModel?> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) return null;

      return UserModel(
        uid: response.user!.id,
        email: response.user!.email ?? '',
        name: response.user!.userMetadata?['full_name'] ?? 'User',
      );
    } catch (e) {
      AppLogger.e('Supabase SignIn Error', e);
      rethrow;
    }
  }

  Future<UserModel?> signInWithGoogle() async {
    try {
      // 1. Trigger Google Sign In flow
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null || idToken == null) {
        throw Exception('Failed to get Google authentication tokens');
      }

      // 2. Sign into Supabase with the ID Token
      final response = await _supabase.auth.signInWithIdToken(
        provider: sb.OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      if (response.user == null) return null;

      final name =
          response.user!.userMetadata?['full_name'] ??
          googleUser.displayName ??
          'User';

      final user = response.user!;
      final session = response.session;

      // Determine if new user based on timestamps
      final isNewUser =
          session != null &&
          user.lastSignInAt != null &&
          DateTime.parse(
                user.createdAt,
              ).difference(DateTime.parse(user.lastSignInAt!)).inSeconds.abs() <
              5;

      // Move upsert to a background task so it doesn't block or fail the login if DB schema/RLS has issues
      await _supabase
          .from('app_preferences')
          .upsert({
            'user_id': user.id,
            'key': 'registration_data',
            'value': 'Google Login: ${user.email}, Name: $name',
          })
          .then((_) => AppLogger.i('Registration data synced'))
          .catchError((e) => AppLogger.e('Registration sync failed', e));

      return UserModel(
        uid: user.id,
        email: user.email ?? '',
        name: name,
        profilePicUrl: user.userMetadata?['avatar_url'] ?? googleUser.photoUrl,
        isNewUser: isNewUser,
      );
    } catch (e) {
      AppLogger.e('Google Sign In Error', e);
      rethrow;
    }
  }

  Future<UserModel?> signInWithApple() async {
    try {
      final rawNonce = _supabase.auth.generateRawNonce();
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: rawNonce,
      );

      if (appleCredential.identityToken == null) {
        throw Exception('Apple Sign In failed: No identity token received');
      }

      final response = await _supabase.auth.signInWithIdToken(
        provider: sb.OAuthProvider.apple,
        idToken: appleCredential.identityToken!,
        nonce: rawNonce,
      );

      if (response.user == null) return null;

      return UserModel(
        uid: response.user!.id,
        email: response.user!.email ?? '',
        name: response.user!.userMetadata?['full_name'] ?? 'Apple User',
        isNewUser:
            response.session?.user.createdAt ==
            response.session?.user.lastSignInAt,
      );
    } catch (e) {
      AppLogger.e('Apple Sign In Error', e);
      rethrow;
    }
  }

  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      await _supabase.auth.updateUser(sb.UserAttributes(password: newPassword));
    } catch (e) {
      AppLogger.e('Password Change Error', e);
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _supabase.auth.signOut();
      await _ref.read(preferenceServiceProvider).clearAuthPreferences();
    } catch (e) {
      AppLogger.e('Error during signOut', e);
    }
  }

  /// Validates the current session with the Supabase server.
  /// Returns true if the session is still valid.
  Future<bool> validateSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return false;

      // Attempt to get the user from the server to verify session validity
      final response = await _supabase.auth.getUser();
      return response.user != null;
    } catch (e) {
      AppLogger.e('Session validation failed', e);
      return false;
    }
  }

  Future<void> deleteAccount() async {
    try {
      // Supabase user deletion usually requires administrative privileges or a service role
      // if done from the client. However, for a mock app, we'll just sign out
      // or redirect to a function if implemented.
      // In Supabase, users can be deleted via edge functions or SQL triggers.
      await _supabase.auth.signOut();
      await _googleSignIn.signOut();
    } catch (e) {
      AppLogger.e('Error deleting account', e);
      await signOut();
    }
  }
}
