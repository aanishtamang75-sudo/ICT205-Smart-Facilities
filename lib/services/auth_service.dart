import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<User?> login(String email, String password) async {
    final result = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  Future<User?> register(String email, String password) async {
    final result = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return result.user;
  }

  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String friendlyError(Object error) {
    final text = error.toString();
    if (text.contains('email-already-in-use')) {
      return 'This email is already registered';
    }
    if (text.contains('user-not-found') ||
        text.contains('wrong-password') ||
        text.contains('invalid-credential')) {
      return 'Invalid email or password';
    }
    if (text.contains('invalid-email')) {
      return 'Please enter a valid email';
    }
    if (text.contains('weak-password')) {
      return 'Password is too weak';
    }
    if (text.contains('network-request-failed')) {
      return 'Network error. Check your connection';
    }
    return 'Something went wrong. Please try again';
  }
}
