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

@JsonSerializable(includeIfNull: false)
class Credentials {
  @JsonKey(toJson: _encodeMethod, fromJson: _decodeMethod)
  final SignInMethod method;

  final String identifier;

  final String firebaseId;

  Credentials(this.method, this.identifier, this.firebaseId);

  factory Credentials.fromJson(Map<String, dynamic> json) => _$CredentialsFromJson(json);

  Map<String, dynamic> toJson() => _$CredentialsToJson(this);
}

@JsonSerializable(createToJson: false, includeIfNull: false)
class AuthReceipt {
  AuthReceipt({
    required this.id,
    required this.token,
  });

  factory AuthReceipt.fromJson(Map<String, dynamic> json) => _$AuthReceiptFromJson(json);

  final String id;

  final String token;
}

@JsonSerializable(includeIfNull: false)
class Account {
  Account({
    required this.id,
    this.email,
    this.name,
    this.role = UserRole.USER,
    required this.settings,
  });

  factory Account.fromJson(Map<String, dynamic> json) => _$AccountFromJson(json);

  factory Account.fromRow(Map<String, dynamic> row) {
    final account = Account.fromJson(row);
    return account..token = row['token'];
  }

  final String id;

  String? email;

  String? name;

  @JsonKey(toJson: _encodeRole, fromJson: _decodeRole)
  UserRole role;

  @JsonKey(ignore: true)
  late String token;

  Settings settings;

  bool get initialized => settings.initialized || role == UserRole.ADMIN;

  Map<String, dynamic> toJson() => _$AccountToJson(this);

  Map<String, dynamic> toRow() {
    final json = toJson();
    return json..['token'] = token;
  }

  void update(Account account) {
    role = account.role;
    name = account.name ?? name;
    settings = account.settings;
  }

  Account copyWith({String? name, UserRole? role, Settings? settings}) {
    return Account(
      id: id,
      email: email,
      name: name ?? this.name,
      role: role ?? this.role,
      settings: settings ?? this.settings,
    )..token = token;
  }
}

@JsonSerializable(includeIfNull: false)
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

  bool operator ==(other) {
    return other is Settings && initialized == other.initialized && blocked == other.blocked;
  }

  @override
  int get hashCode => '$attempts $blocked $initialized'.hashCode;

  Map<String, dynamic> toJson() => _$SettingsToJson(this);

  Settings copyWith({bool? blocked, bool? initialized}) {
    return Settings(
      attempts: this.attempts,
      initialized: initialized ?? this.initialized,
      method: this.method,
      blocked: blocked ?? this.blocked,
    );
  }
}

enum AuthStatus {
  NONE,
  NEW_ACCOUNT,
  EXISTING_ACCOUNT,
  DUPLICATE,
  NO_ACCOUNT,
  UNVERIFIED,
  WEAK_PASSWORD,
  INCORRECT_CREDS,
  BLOCKED,
  ERROR
}
