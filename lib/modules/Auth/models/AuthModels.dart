class RegisterParams {
  final String name;
  final String email;
  final String phone;
  final String password;
  final String passwordConfirmation;

  RegisterParams({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() => {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'phone': phone.trim(),
        'password': password,
        'password_confirmation': passwordConfirmation,
      };
}

class LoginParams {
  final String email;
  final String password;
  final bool direct;

  LoginParams({
    required this.email,
    required this.password,
    this.direct = false,
  });

  Map<String, dynamic> toJson() => {
        'email': email.trim().toLowerCase(),
        'password': password,
        if (direct) 'direct': true,
      };
}

class VerifyOtpParams {
  final String email;
  final String otp;

  VerifyOtpParams({
    required this.email,
    required this.otp,
  });

  Map<String, dynamic> toJson() => {
        'email': email.trim().toLowerCase(),
        'otp': otp.trim(),
      };
}
