class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;
  final Map<String, dynamic>? errors;
  final int? statusCode;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
    this.errors,
    this.statusCode,
  });

  /// Extracts the first human-readable validation error message
  String get firstErrorMessage {
    if (errors != null && errors!.isNotEmpty) {
      final firstVal = errors!.values.first;
      if (firstVal is List && firstVal.isNotEmpty) {
        return firstVal.first.toString();
      }
      return firstVal.toString();
    }
    if (message.contains('SQLSTATE') ||
        message.contains('Duplicate entry') ||
        message.contains('Integrity constraint violation')) {
      if (message.contains('pan_number') || message.contains('pan')) {
        return 'This PAN card number is already registered with another account. Please enter your valid unique PAN card number.';
      }
      if (message.contains('aadhaar')) {
        return 'This Aadhaar card number is already registered with another account.';
      }
      return 'A conflict occurred with an existing account record. Please check your PAN and ID numbers.';
    }
    return message;
  }
}
