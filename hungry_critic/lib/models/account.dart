import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

enum SignInMethod { EMAIL, GOOGLE, FACEBOOK }

@JsonSerializable()
class Credentials {
  final SignInMethod method;

  final String identifier;

  final String firebaseId;

  Credentials(this.method, this.identifier, this.firebaseId);

  factory Credentials.fromJson(Map<String, dynamic> json) => _$CredentialsFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialsToJson(this);
}

@JsonSerializable()
class AuthReceipt {
  AuthReceipt({
    required this.id,
    required this.token,
    required this.fresh,
  });

  factory AuthReceipt.fromJson(Map<String, dynamic> json) => _$AuthReceiptFromJson(json);

  final String id;

  final String token;

  final bool fresh;
}

@JsonSerializable()
class Account {
  Account({
    required this.creds,
    required this.token,
  });

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  late UserProfile profile;

  final Credentials creds;

  final String token;

  Map<String, dynamic> toJson() => _$AccountToJson(this);
}

enum UserRole { CUSTOMER, OWNER, ADMIN }

@JsonSerializable(includeIfNull: false)
class UserProfile {
  UserProfile({
    required this.id,
    this.email,
    this.name,
    this.role = UserRole.CUSTOMER,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

  final String id;

  String? email;

  String? name;

  UserRole role;

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  void update(UserProfile profile) {
    role = profile.role;
    name = profile.name ?? name;
  }

  UserProfile copyWith({String? name, UserRole? role}) {
    return UserProfile(
      id: id,
      name: name ?? this.name,
      role: role ?? this.role,
    );
  }
}
