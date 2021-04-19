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
  );
}

Account _$AccountFromJson(Map<String, dynamic> json) {
  return Account(
    id: json['id'] as String,
    email: json['email'] as String?,
    name: json['name'] as String?,
    role: _decodeRole(json['role'] as int?),
    settings: Settings.fromJson(json['settings'] as Map<String, dynamic>),
  );
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'name': instance.name,
      'role': _encodeRole(instance.role),
      'settings': instance.settings,
    };

Settings _$SettingsFromJson(Map<String, dynamic> json) {
  return Settings(
    blocked: json['blocked'] as bool,
    initialized: json['initialized'] as bool,
    method: _decodeMethod(json['method'] as int?),
    attempts: json['attempts'] as int,
  );
}

Map<String, dynamic> _$SettingsToJson(Settings instance) => <String, dynamic>{
      'blocked': instance.blocked,
      'initialized': instance.initialized,
      'method': _encodeMethod(instance.method),
      'attempts': instance.attempts,
    };
