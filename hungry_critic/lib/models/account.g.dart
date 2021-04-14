// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Credentials _$CredentialsFromJson(Map<String, dynamic> json) {
  return Credentials(
    _decodeMethod(json['method'] as int?),
    json['identifier'] as String,
    json['firebaseId'] as String,
  );
}

Map<String, dynamic> _$CredentialsToJson(Credentials instance) =>
    <String, dynamic>{
      'method': _encodeMethod(instance.method),
      'identifier': instance.identifier,
      'firebaseId': instance.firebaseId,
    };

AuthReceipt _$AuthReceiptFromJson(Map<String, dynamic> json) {
  return AuthReceipt(
    id: json['id'] as String,
    token: json['token'] as String,
    fresh: json['fresh'] as bool,
  );
}

Account _$AccountFromJson(Map<String, dynamic> json) {
  return Account(
    id: json['id'] as String,
    method: _decodeMethod(json['method'] as int?),
    email: json['email'] as String?,
    name: json['name'] as String?,
    role: _decodeRole(json['role'] as int?),
  );
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'id': instance.id,
      'method': _encodeMethod(instance.method),
      'email': instance.email,
      'name': instance.name,
      'role': _encodeRole(instance.role),
    };
