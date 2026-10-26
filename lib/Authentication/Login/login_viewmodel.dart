import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:taskora/Authentication/models/login_model.dart';

class LoginViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool _isDisposed = false;

  void _setLoading(bool value) {
    isLoading = value;

    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<String?> login(LoginModel model) async {
    if (isLoading) {
      return 'Please wait for the current operation to finish.';
    }

    _setLoading(true);

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: model.email.trim(),
        password: model.password,
      );

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'Please enter a valid email address.';

        case 'user-not-found':
        case 'invalid-credential':
        case 'wrong-password':
          return 'Incorrect email or password.';

        case 'user-disabled':
          return 'This account has been disabled.';

        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';

        case 'network-request-failed':
          return 'Check your internet connection.';

        case 'operation-not-allowed':
          return 'Email/Password sign-in is not enabled.';

        default:
          return 'Unable to log in. Please try again.';
      }
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  Future<String?> resetPassword(String email) async {
    if (isLoading) {
      return 'Please wait for the current operation to finish.';
    }

    _setLoading(true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'invalid-email':
          return 'Please enter a valid email address.';

        case 'too-many-requests':
          return 'Too many attempts. Please try again later.';

        case 'network-request-failed':
          return 'Check your internet connection.';

        default:
          return 'Unable to send the reset email. Please try again.';
      }
    } catch (_) {
      return 'Something went wrong. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
