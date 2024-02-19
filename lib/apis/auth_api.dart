import 'package:firebase_auth/firebase_auth.dart';

class AuthAPI {
  static Future<String?> loginWithEmail(String email, String password) async {
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          {
            return 'Invalid Email';
          }
        case 'user-not-found':
          {
            return 'User not created';
          }
        case 'wrong-password':
          {
            return 'Wrong Password';
          }
        default:
          {
            return 'Something Went Wrong';
          }
      }
    }
  }

  static Future<String?> logout(String email, String password) async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      switch(e.code) {
        default:
          return 'Something Went Wrong';
      }
    }
  }
}