class Env {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://arymacloudfindcafe.imrnes.team',
  );
}
