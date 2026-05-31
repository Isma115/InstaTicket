// region Lógica Configuración Frontend: configuración de API remota
import 'dart:io';

class AppConfig {
  AppConfig._();

  static String get apiBaseUrl {
    const fromEnvironment = String.fromEnvironment('API_BASE_URL');

    if (fromEnvironment.trim().isNotEmpty) {
      return _normalize(fromEnvironment);
    }

    final defaultUrl =
        Platform.isAndroid ? 'http://10.0.2.2:4000' : 'http://127.0.0.1:4000';

    return _normalize(defaultUrl);
  }

  static String _normalize(String rawUrl) {
    final trimmed = rawUrl.trim();

    if (trimmed.endsWith('/')) {
      return trimmed.substring(0, trimmed.length - 1);
    }

    return trimmed;
  }
}
// endregion
