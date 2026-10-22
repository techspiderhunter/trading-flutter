class LoginModel {
  final String token;
  final Map<String, dynamic>? user;

  const LoginModel({required this.token, this.user});

  factory LoginModel.fromJson(Map<String, dynamic> json) {
    final nestedUser = json['user'];
    return LoginModel(
      token: (json['token'] ?? json['access_token'] ?? '').toString(),
      user: nestedUser is Map<String, dynamic> ? nestedUser : null,
    );
  }
}
