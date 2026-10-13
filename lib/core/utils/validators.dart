class FormValidators {
  FormValidators._();

  // Check name
  static String? validateName(String? value) {
    if (value == null || value.trim().length < 2) {
      return 'Please enter your name.';
    }

    return null;
  }

  // Check email
  static String? validateEmail(String? value) {
    if (value == null ||
        !RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(value.trim())) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  // Check password
  static String? validatePassword(String? value) {
    if (value == null || value.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  // Check confirm password
  static String? validateConfirmPassword(String? value, String password) {
    if (value != password) {
      return 'Passwords do not match.';
    }

    return null;
  }
}
