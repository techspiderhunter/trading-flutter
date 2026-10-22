/// Centralized Global Form & Regulatory Validator Class
/// Used across Authentication, KYC, Profile, and Form inputs.
class Validators {
  /// General required field validation
  static String? required(String? v, [String fieldName = 'This field']) {
    if (v == null || v.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Full name validation (min 3 chars, letters and spaces only)
  static String? name(String? v, [String fieldName = 'Full Name']) {
    if (v == null || v.trim().isEmpty) {
      return '$fieldName is required';
    }
    final trimmed = v.trim();
    if (trimmed.length < 3) {
      return '$fieldName must be at least 3 characters';
    }
    final nameRegex = RegExp(r"^[a-zA-Z\s.'-]+$");
    if (!nameRegex.hasMatch(trimmed)) {
      return 'Please enter a valid legal name (letters only)';
    }
    return null;
  }

  /// RFC-compliant Email address validation
  static String? email(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Email address is required';
    }
    final trimmed = v.trim();
    final emailRegex = RegExp(r'^[\w\.-]+@[\w\.-]+\.\w{2,}$');
    if (!emailRegex.hasMatch(trimmed)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Indian 10-digit mobile phone validation (starts with 6, 7, 8, 9)
  static String? phone(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Phone number is required';
    }
    final digits = v.trim().replaceAll(RegExp(r'\D'), '');
    if (digits.length != 10) {
      return 'Enter a valid 10-digit mobile number';
    }
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(digits)) {
      return 'Mobile number must start with 6, 7, 8, or 9';
    }
    return null;
  }

  /// Password validation (minimum 6 characters)
  static String? password(String? v, [int minLength = 6]) {
    if (v == null || v.isEmpty) {
      return 'Password is required';
    }
    if (v.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
        return null;
  }

  /// Password confirmation match validator
  static String? confirmPassword(String? v, String? originalPassword) {
    if (v == null || v.isEmpty) {
      return 'Please confirm your password';
    }
    if (v != originalPassword) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Standard Indian PAN Card validation (Format: 5 letters, 4 digits, 1 letter)
  /// Example: ABCDE1234F
  static String? pan(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'PAN number is required for SEBI compliance';
    }
    final trimmed = v.trim().toUpperCase();
    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(trimmed)) {
      return 'Invalid PAN format (e.g. ABCDE1234F)';
    }
    return null;
  }

  /// 12-digit Indian Aadhaar card number validation
  static String? aadhaar(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Aadhaar number is required';
    }
    final digits = v.trim().replaceAll(RegExp(r'\D'), '');
    if (digits.length != 12) {
      return 'Aadhaar must be exactly 12 digits';
    }
    return null;
  }

  /// Date of Birth & statutory 18+ age validation
  static String? dob(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Date of birth is required';
    }
    final trimmed = v.trim();
    DateTime? date;

    // Handle YYYY-MM-DD or DD/MM/YYYY or DD-MM-YYYY
    try {
      if (trimmed.contains('-')) {
        final parts = trimmed.split('-');
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            // YYYY-MM-DD
            date = DateTime.parse(trimmed);
          } else {
            // DD-MM-YYYY
            date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
        }
      } else if (trimmed.contains('/')) {
        final parts = trimmed.split('/');
        if (parts.length == 3) {
          if (parts[0].length == 4) {
            date = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
          } else {
            date = DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
          }
        }
      }
    } catch (_) {
      return 'Enter valid date (YYYY-MM-DD or DD/MM/YYYY)';
    }

    if (date == null) {
      return 'Enter valid date (YYYY-MM-DD or DD/MM/YYYY)';
    }

    final today = DateTime.now();
    final adultDate = DateTime(today.year - 18, today.month, today.day);
    if (date.isAfter(adultDate)) {
      return 'You must be at least 18 years old to trade';
    }

    return null;
  }

  /// Indian 6-digit Pincode validation
  static String? pincode(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Pincode is required';
    }
    final digits = v.trim().replaceAll(RegExp(r'\D'), '');
    if (digits.length != 6) {
      return 'Enter a valid 6-digit postal pincode';
    }
    return null;
  }

  /// Address validation (min 5 chars)
  static String? address(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Residential address is required';
    }
    if (v.trim().length < 5) {
      return 'Address must be at least 5 characters';
    }
    return null;
  }

  /// City validation
  static String? city(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'City is required';
    }
    if (v.trim().length < 2) {
      return 'Enter valid city name';
    }
    return null;
  }

  /// State validation
  static String? state(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'State is required';
    }
    if (v.trim().length < 2) {
      return 'Enter valid state name';
    }
    return null;
  }

  /// Numeric amount validation
  static String? amount(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Amount is required';
    }
    final parsed = double.tryParse(v.trim());
    if (parsed == null || parsed <= 0) {
      return 'Enter a valid positive amount';
    }
    return null;
  }
}
