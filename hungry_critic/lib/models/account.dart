import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

enum SignInMethod { EMAIL, GOOGLE, FACEBOOK }

class EmailData {
  final String email;

  final String password;

  bool create;

  EmailData(this.email, this.password, this.create);
}

enum UserRole { USER, OWNER, ADMIN }

_encodeMethod(SignInMethod method) => method.index;
_decodeMethod(int? index) {
  return SignInMethod.values.firstWhere(
    (v) => v.index == index,
    orElse: () => SignInMethod.EMAIL,
  );
}

_encodeRole(UserRole role) => role.index;
_decodeRole(int? index) {
  return UserRole.values.firstWhere(
    (v) => v.index == index,
    orElse: () => UserRole.USER,
  );
}

@JsonSerializable()
class Credentials {
  @JsonKey(toJson: _encodeMethod, fromJson: _decodeMethod)
  final SignInMethod method;

  final String identifier;

  final String firebaseId;

  Credentials(this.method, this.identifier, this.firebaseId);

  factory Credentials.fromJson(Map<String, dynamic> json) => _$CredentialsFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialsToJson(this);
}

@JsonSerializable(createToJson: false)
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
    required this.id,
    required this.method,
    this.email,
    this.name,
    this.role = UserRole.USER,
  });

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  factory Account.fromRow(Map<String, dynamic> row) {
    final account = Account.fromJson(row);
    return account..token = row['token'];
  }

  final String id;

  @JsonKey(toJson: _encodeMethod, fromJson: _decodeMethod)
  final SignInMethod method;

  String? email;

  String? name;

  @JsonKey(toJson: _encodeRole, fromJson: _decodeRole)
  UserRole role;

  @JsonKey(ignore: true)
  late String token;

  Map<String, dynamic> toJson() => _$AccountToJson(this);

  Map<String, dynamic> toRow() {
    final json = toJson();
    return json..['token'] = token;
  }

  void update(Account account) {
    role = account.role;
    name = account.name ?? name;
  }

  Account copyWith({String? name, UserRole? role}) {
    return Account(
      id: id,
      method: method,
      email: email,
      name: name ?? this.name,
      role: role ?? this.role,
    )..token = token;
  }
}

@JsonSerializable()
class User extends Account {
  User({
    required String id,
    required SignInMethod method,
    String? email,
    String? name,
    UserRole role = UserRole.USER,
    required this.settings,
  }) : super(
          id: id,
          method: method,
          email: email,
          name: name,
          role: role,
        );

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  final Settings settings;

  Map<String, dynamic> toJson() => _$UserToJson(this);
}

@JsonSerializable()
class Settings {
  Settings({
    required this.blocked,
    required this.initialized,
    required this.method,
    required this.attempts,
  });

  final bool blocked;

  final bool initialized;

  @JsonKey(toJson: _encodeMethod, fromJson: _decodeMethod)
  final SignInMethod method;

  final int attempts;

  factory Settings.fromJson(Map<String, dynamic> json) => _$SettingsFromJson(json);

  Map<String, dynamic> toJson() => _$SettingsToJson(this);
}

enum AuthStatus {
  NONE,
  NEW_ACCOUNT,
  EXISTING_ACCOUNT,
  DUPLICATE,
  NO_ACCOUNT,
  UNVERIFIED,
  INCORRECT_CREDS,
  ERROR
}
