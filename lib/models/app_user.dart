import 'role.dart';

class AppUser {
  final int id;
  final String username;
  final String displayName;
  final Role role;
  final int? readerId;

  const AppUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
    this.readerId,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int? ?? 0,
      username: '${json['username'] ?? ''}',
      displayName: '${json['displayName'] ?? json['username'] ?? ''}',
      role: Role.parse('${json['role'] ?? ''}'),
      readerId: json['readerId'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'displayName': displayName,
        'role': role.id,
        'readerId': readerId,
      };
}

class AuthTokens {
  final String accessToken;
  final String refreshToken;
  final AppUser user;

  const AuthTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: '${json['accessToken'] ?? ''}',
      refreshToken: '${json['refreshToken'] ?? ''}',
      user: AppUser.fromJson(Map<String, dynamic>.from(json['user'] as Map? ?? const {})),
    );
  }
}
