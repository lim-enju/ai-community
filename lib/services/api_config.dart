/// Central place for backend connection settings.
///
/// The backend (NestJS) is being built in parallel; until it is ready or
/// reachable, all services fall back to mock data so the UI keeps working.
class ApiConfig {
  ApiConfig._();

  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3000',
  );

  static const Duration timeout = Duration(seconds: 6);
}
