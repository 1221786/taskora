import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ResetPasswordViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool _isDisposed = false;

  String? errorMessage;
  String? successMessage;

  void _setLoading(bool value) {
    isLoading = value;

    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<bool> sendResetLink(String email) async {
    final normalizedEmail = email.trim();

    if (!_validEmail(normalizedEmail)) {
      errorMessage = 'Please enter a valid email address.';
      successMessage = null;

      if (!_isDisposed) notifyListeners();
      return false;
    }

    if (isLoading) return false;

    errorMessage = null;
    successMessage = null;
    _setLoading(true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: normalizedEmail,
      );

      successMessage =
          'If an account exists for this email, '
          'a password reset link has been sent.';

      return true;
    } on FirebaseAuthException catch (error) {
      debugPrint(
        'Password reset failed '
        '[${error.code}]: ${error.message}',
      );

      switch (error.code) {
        case 'invalid-email':
          errorMessage = 'Please enter a valid email address.';
          break;

        case 'too-many-requests':
          errorMessage = 'Too many attempts. Please try again later.';
          break;

        case 'network-request-failed':
          errorMessage = 'Check your internet connection.';
          break;

        case 'operation-not-allowed':
          errorMessage = 'Email/Password authentication is not enabled.';
          break;

        default:
          errorMessage = 'Unable to send the reset email. Please try again.';
      }

      return false;
    } catch (error, stackTrace) {
      debugPrint('Password reset failed: $error\n$stackTrace');

      errorMessage = 'Something went wrong. Please try again.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  bool _validEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
