import 'package:json_annotation/json_annotation.dart';

part 'account.g.dart';

enum SignInMethod { EMAIL, GOOGLE, FACEBOOK }

class EmailData {
  final String email;

  final String password;

  final bool create;

  EmailData(this.email, this.password, this.create);
}

class SignInData {
  bool create;

  SignInMethod method;

  SignInData(this.create, this.method);
}

enum UserRole { CUSTOMER, OWNER, ADMIN }

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
    orElse: () => UserRole.CUSTOMER,
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
    this.role = UserRole.CUSTOMER,
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
