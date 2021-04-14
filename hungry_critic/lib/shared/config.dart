import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:json_annotation/json_annotation.dart';

part 'config.g.dart';

@JsonSerializable(createToJson: false)
class AppProps {
  AppProps({
    required this.twitterKey,
    required this.twitterSecret,
  });

  factory AppProps.fromJson(Map<String, dynamic> json) => _$AppPropsFromJson(json);

  AppProps? _instance;



  final String twitterKey;

  final String twitterSecret;
}

class AppConfig {
  AppConfig({
    required this.http,
    required this.env,
  });

  final Environment env;

  final HttpOptions http;

  late final AppProps props;
}

enum Environment { LOCAL, DEV, PROD }

class EndpointOptions {
  const EndpointOptions({required this.host, required this.port, required this.secure});

  final String host;
  final int port;
  final bool secure;
}

typedef Uri UriCreator([String primary, List<String> segments, Map<String, dynamic>? query]);

class HttpOptions {
  const HttpOptions({
    required this.host,
    required this.port,
    this.secure = true,
    this.basePath = '',
  });

  final String host;
  final int port;
  final bool secure;

  final String basePath;

  UriCreator withBase(String path) {
    return HttpOptions(
      secure: this.secure,
      host: this.host,
      port: this.port,
      basePath: path,
    ).createUri;
  }

  Uri createUri([
    String primary = '',
    List<String> segments = const [],
    Map<String, dynamic>? query,
  ]) {
    return Uri(
      scheme: secure ? 'https' : 'http',
      host: this.host,
      port: this.port,
      pathSegments: [this.basePath, if (primary.isNotEmpty) primary, ...segments],
      queryParameters: query,
    );
  }
}
