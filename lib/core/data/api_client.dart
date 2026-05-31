// region Lógica Backend Frontend: cliente HTTP para API InstaTicket
import 'dart:convert';
import 'dart:io';

import '../config/app_config.dart';

class ApiException implements Exception {
  const ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() {
    if (statusCode == null) {
      return message;
    }

    return '$message (status: $statusCode)';
  }
}

class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final HttpClient _httpClient = HttpClient();

  Future<Map<String, dynamic>> getJson(
    String path, {
    Map<String, String>? query,
  }) {
    return _request(
      method: 'GET',
      path: path,
      query: query,
    );
  }

  Future<Map<String, dynamic>> postJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? query,
  }) {
    return _request(
      method: 'POST',
      path: path,
      body: body,
      query: query,
    );
  }

  Future<Map<String, dynamic>> putJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? query,
  }) {
    return _request(
      method: 'PUT',
      path: path,
      body: body,
      query: query,
    );
  }

  Future<Map<String, dynamic>> patchJson(
    String path, {
    required Map<String, dynamic> body,
    Map<String, String>? query,
  }) {
    return _request(
      method: 'PATCH',
      path: path,
      body: body,
      query: query,
    );
  }

  Future<Map<String, dynamic>> deleteJson(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) {
    return _request(
      method: 'DELETE',
      path: path,
      body: body,
      query: query,
    );
  }

  Future<Map<String, dynamic>> _request({
    required String method,
    required String path,
    Map<String, dynamic>? body,
    Map<String, String>? query,
  }) async {
    final uri = Uri.parse('${AppConfig.apiBaseUrl}$path').replace(
      queryParameters: query,
    );

    final request = await _httpClient.openUrl(method, uri);
    request.headers.contentType = ContentType.json;
    request.headers.set(HttpHeaders.acceptHeader, 'application/json');

    if (body != null) {
      request.write(jsonEncode(body));
    }

    final response = await request.close();
    final responseBody = await response.transform(utf8.decoder).join();

    if (responseBody.isEmpty) {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return const <String, dynamic>{};
      }

      throw ApiException(
        'La API devolvio una respuesta vacia.',
        statusCode: response.statusCode,
      );
    }

    late final Map<String, dynamic> decoded;

    try {
      decoded = jsonDecode(responseBody) as Map<String, dynamic>;
    } catch (_) {
      throw ApiException(
        'No se pudo interpretar la respuesta de la API.',
        statusCode: response.statusCode,
      );
    }

    final ok = decoded['ok'];

    if (response.statusCode < 200 ||
        response.statusCode >= 300 ||
        ok == false) {
      final message = decoded['error']?.toString().trim();

      throw ApiException(
        message?.isNotEmpty == true
            ? message!
            : 'Error inesperado al llamar a la API.',
        statusCode: response.statusCode,
      );
    }

    return decoded;
  }
}
// endregion
