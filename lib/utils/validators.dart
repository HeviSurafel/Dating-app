class Validators {
  // FIXED: Returns String? Function(String?) - a validator function
  static String? Function(String?) required(String fieldName) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return '$fieldName is required';
      }
      return null;
    };
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  static String? phone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Phone is optional
    }
    final phoneRegex = RegExp(r'^[0-9]{10,15}$');
    if (!phoneRegex.hasMatch(value)) {
      return 'Please enter a valid phone number';
    }
    return null;
  }

  static String? name(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  static String? dateOfBirth(String? value) {
    if (value == null || value.isEmpty) {
      return 'Date of birth is required';
    }
    try {
      final date = DateTime.parse(value);
      final age = DateTime.now().difference(date).inDays ~/ 365;
      if (age < 18) {
        return 'You must be at least 18 years old';
      }
    } catch (e) {
      return 'Invalid date format';
    }
    return null;
  }

  // FIXED: Returns String? Function(String?) - a validator function
  static String? Function(String?) confirmPassword(String password) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != password) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  // FIXED: Returns String? Function(String?) - a validator function
  static String? Function(String?) maxLength(int max) {
    return (String? value) {
      if (value != null && value.length > max) {
        return 'Must be less than $max characters';
      }
      return null;
    };
  }

  // FIXED: Returns String? Function(String?) - a validator function
  static String? Function(String?) minLength(int min) {
    return (String? value) {
      if (value != null && value.isNotEmpty && value.length < min) {
        return 'Must be at least $min characters';
      }
      return null;
    };
  }
}