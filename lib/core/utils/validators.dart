import 'package:email_validator/email_validator.dart';

/// Validation utilities for forms and input fields.
class Validators {
  // Prevent instantiation
  Validators._();

  /// Validates email address.
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }

    if (!EmailValidator.validate(value)) {
      return 'Please enter a valid email address';
    }

    return null;
  }

  /// Validates password.
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }

    if (value.length < 8) {
      return 'Password must be at least 8 characters';
    }

    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }

    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }

    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null;
  }

  /// Validates required field.
  static String? validateRequired(String? value,
      [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates minimum length.
  static String? validateMinLength(String? value, int minLength,
      [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (value.length < minLength) {
      return '$fieldName must be at least $minLength characters';
    }

    return null;
  }

  /// Validates maximum length.
  static String? validateMaxLength(String? value, int maxLength,
      [String fieldName = 'This field']) {
    if (value != null && value.length > maxLength) {
      return '$fieldName must not exceed $maxLength characters';
    }
    return null;
  }

  /// Validates phone number (basic).
  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }

    // Remove non-numeric characters
    final digitsOnly = value.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length < 10) {
      return 'Please enter a valid phone number';
    }

    return null;
  }

  /// Validates URL.
  static String? validateUrl(String? value) {
    if (value == null || value.isEmpty) {
      return null; // URL is optional
    }

    final urlPattern = RegExp(
      r'^https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)$',
    );

    if (!urlPattern.hasMatch(value)) {
      return 'Please enter a valid URL';
    }

    return null;
  }

  /// Validates numeric value.
  static String? validateNumeric(String? value,
      [String fieldName = 'This field']) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }

    if (double.tryParse(value) == null) {
      return '$fieldName must be a number';
    }

    return null;
  }

  /// Validates positive number.
  static String? validatePositiveNumber(String? value,
      [String fieldName = 'This field']) {
    final numericError = validateNumeric(value, fieldName);
    if (numericError != null) return numericError;

    final number = double.parse(value!);
    if (number <= 0) {
      return '$fieldName must be greater than 0';
    }

    return null;
  }
}
