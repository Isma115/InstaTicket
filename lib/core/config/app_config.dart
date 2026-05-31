// #region Configuracion | Funcionalidad | Configuracion de API remota
class AppConfig {
  AppConfig._();
  static const _macLanApiBaseUrl = 'http://192.168.1.60:4000';

  static String get apiBaseUrl {
    const fromEnvironment = String.fromEnvironment('API_BASE_URL');

    if (fromEnvironment.trim().isNotEmpty) {
      return _normalize(fromEnvironment);
    }

    return _normalize(_macLanApiBaseUrl);
  }

  static String _normalize(String rawUrl) {
    final trimmed = rawUrl.trim();

    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }

    return trimmed;
  }
}
// #endregion
