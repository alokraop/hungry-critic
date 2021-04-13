// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'account.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Credentials _$CredentialsFromJson(Map<String, dynamic> json) {
  return Credentials(
    _$enumDecode(_$SignInMethodEnumMap, json['method']),
    json['email'] as String,
    json['firebaseId'] as String,
  );
}

Map<String, dynamic> _$CredentialsToJson(Credentials instance) =>
    <String, dynamic>{
      'method': _$SignInMethodEnumMap[instance.method],
      'email': instance.email,
      'firebaseId': instance.firebaseId,
    };

K _$enumDecode<K, V>(
  Map<K, V> enumValues,
  Object? source, {
  K? unknownValue,
}) {
  if (source == null) {
    throw ArgumentError(
      'A value must be provided. Supported values: '
      '${enumValues.values.join(', ')}',
    );
  }

  return enumValues.entries.singleWhere(
    (e) => e.value == source,
    orElse: () {
      if (unknownValue == null) {
        throw ArgumentError(
          '`$source` is not one of the supported values: '
          '${enumValues.values.join(', ')}',
        );
      }
      return MapEntry(unknownValue, enumValues.values.first);
    },
  ).key;
}

const _$SignInMethodEnumMap = {
  SignInMethod.EMAIL: 'EMAIL',
  SignInMethod.GOOGLE: 'GOOGLE',
  SignInMethod.TWITTER: 'TWITTER',
};

AuthReceipt _$AuthReceiptFromJson(Map<String, dynamic> json) {
  return AuthReceipt(
    id: json['id'] as String,
    token: json['token'] as String,
    fresh: json['fresh'] as bool,
  );
}

Map<String, dynamic> _$AuthReceiptToJson(AuthReceipt instance) =>
    <String, dynamic>{
      'id': instance.id,
      'token': instance.token,
      'fresh': instance.fresh,
    };

Account _$AccountFromJson(Map<String, dynamic> json) {
  return Account(
    creds: Credentials.fromJson(json['creds'] as Map<String, dynamic>),
    token: json['token'] as String,
  )..profile = UserProfile.fromJson(json['profile'] as Map<String, dynamic>);
}

Map<String, dynamic> _$AccountToJson(Account instance) => <String, dynamic>{
      'profile': instance.profile,
      'creds': instance.creds,
      'token': instance.token,
    };

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return UserProfile(
    id: json['id'] as String,
    name: json['name'] as String?,
    role: _$enumDecode(_$UserRoleEnumMap, json['role']),
  );
}

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) {
  final val = <String, dynamic>{
    'id': instance.id,
  };

  void writeNotNull(String key, dynamic value) {
    if (value != null) {
      val[key] = value;
    }
  }

  writeNotNull('name', instance.name);
  val['role'] = _$UserRoleEnumMap[instance.role];
  return val;
}

const _$UserRoleEnumMap = {
  UserRole.CUSTOMER: 'CUSTOMER',
  UserRole.OWNER: 'OWNER',
  UserRole.ADMIN: 'ADMIN',
};
