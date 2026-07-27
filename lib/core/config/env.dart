enum Environment { dev, prod }

class Env {
  static late Environment currentEnv;

  static bool get isDev => currentEnv == Environment.dev;
  static bool get isProd => currentEnv == Environment.prod;

  // Aqui você pode adicionar as URLs do Supabase para cada ambiente
  static String get supabaseUrl => isDev ? 'URL_DEV' : 'URL_PROD';
}
