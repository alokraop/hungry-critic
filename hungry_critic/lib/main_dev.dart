import 'main.dart';
import 'shared/config.dart';

const config = AppConfig(
  http: HttpOptions(host: 'api.dev.blendapp.in', port: 443),
  env: Environment.DEV,
);

void main() => startApp(config);