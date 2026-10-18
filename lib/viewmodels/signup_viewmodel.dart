import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignupViewModel extends ChangeNotifier {
  bool isLoading = false;
  bool _isDisposed = false;

  void _setLoading(bool value) {
    isLoading = value;

    if (!_isDisposed) {
      notifyListeners();
    }
  }

  Future<String?> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    if (isLoading) {
      return 'Please wait for the current operation to finish.';
    }

    _setLoading(true);

    UserCredential? userCredential;

    try {
      userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: email.trim(),
            password: password,
          );

      final user = userCredential.user;

      if (user == null) {
        return 'Unable to create your account. Please try again.';
      }

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name.trim(),
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return null;
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use':
          return 'This email is already registered.';
        case 'invalid-email':
          return 'Please enter a valid email address.';
        case 'weak-password':
          return 'Please choose a stronger password.';
        case 'network-request-failed':
          return 'Check your internet connection.';
        case 'operation-not-allowed':
          return 'Email/Password sign-up is not enabled.';
        default:
          return 'Unable to create your account. Please try again.';
      }
    } on FirebaseException catch (e) {
      // Firestore failed after the Auth account was created.
      if (userCredential?.user != null) {
        try {
          await userCredential!.user!.delete();
        } on FirebaseAuthException {
          // Cleanup can fail, for example if recent authentication is required.
          return 'Profile saving failed. Your account may still exist. '
              'Please check Firebase before trying again.';
        } catch (_) {
          return 'Profile saving failed. Your account may still exist. '
              'Please check Firebase before trying again.';
        }
      }

      if (e.code == 'permission-denied') {
        return 'Firestore access denied. Check your security rules.';
      }

      return 'Unable to save your profile. Please try again.';
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
