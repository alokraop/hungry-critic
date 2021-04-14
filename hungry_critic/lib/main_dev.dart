import 'dart:convert';

import 'main.dart';
import 'shared/config.dart';

final config = AppConfig(
  http: HttpOptions(host: 'api.dev.blendapp.in', port: 443),
  env: Environment.DEV,
);

void main() => startApp(config);
