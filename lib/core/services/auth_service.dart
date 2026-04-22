import 'package:firebase_auth/firebase_auth.dart';
import 'package:project/core/utils/result.dart';

class AuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  Future<Result<User>> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return Result.success(credential.user);
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'An error occurred.';
      if (e.code == 'user-not-found') {
        message = 'No user found for that email.';
      } else if (e.code == 'wrong-password') {
        message = 'Wrong password provided.';
      } else if (e.code == 'invalid-credential') {
        message = 'Invalid email or password.';
      }
      return Result.error(message);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  // Handle user registration
  Future<Result<User?>> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return Result.success(credential.user);
    } on FirebaseAuthException catch (e) {
      String message = e.message ?? 'An error occurred.';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'The account already exists for that email.';
      }
      return Result.error(message);
    } catch (e) {
      return Result.error(e.toString());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
