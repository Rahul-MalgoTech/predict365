// // lib/PredictScreens/AuthScreens/Service/google_auth_service.dart
//
// import 'package:google_sign_in/google_sign_in.dart';
//
// class GoogleAuthService {
//   GoogleAuthService._();
//   static final GoogleAuthService instance = GoogleAuthService._();
//
//   final GoogleSignIn _googleSignIn = GoogleSignIn(
//     scopes: ['email', 'profile'],
//   );
//
//   Future<String?> signIn() async {
//     try {
//       await _googleSignIn.signOut();
//
//       final account = await _googleSignIn.signIn();
//
//       print("🔵 Google account: $account");
//
//       if (account == null) {
//         print("🔴 Google sign-in: user cancelled");
//         return null;
//       }
//
//       final auth = await account.authentication;
//
//       print("🔵 idToken: ${auth.idToken}");
//       print("🔵 accessToken: ${auth.accessToken}");
//
//       if (auth.idToken == null) {
//         print("🔴 idToken is NULL — check google-services.json and SHA-1");
//         throw Exception('Google idToken is null. Check google-services.json setup.');
//       }
//
//       return auth.idToken;
//     } catch (e) {
//       print("🔴 GoogleAuthService error: $e");
//       rethrow;
//     }
//   }
//
//   Future<void> signOut() async {
//     try { await _googleSignIn.signOut(); } catch (_) {}
//   }
// }