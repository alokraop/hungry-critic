import 'main.dart';
import 'shared/config.dart';

const config = AppConfig(
  http: HttpOptions(secure: false, host: '192.168.0.11', port: 9999),
  env: Environment.LOCAL,
);

void main() => startApp(config);