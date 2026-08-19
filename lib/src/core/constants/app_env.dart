import 'package:envied/envied.dart';

part 'app_env.g.dart';

@Envied(path: '.env')
abstract class AppEnv {
  @EnviedField(varName: 'BASE_URL', obfuscate: true)
  static final String baseUrl = _AppEnv.baseUrl;
}
