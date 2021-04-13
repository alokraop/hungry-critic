class AppConfig {
  const AppConfig({required this.http, required this.env});

  final Environment env;

  final HttpOptions http;
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
