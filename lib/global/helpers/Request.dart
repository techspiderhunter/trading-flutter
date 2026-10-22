import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:techspiderhunter/includes/Storage.dart';

import '../models/ServerResponse.dart';
import 'Config.dart';

/// Shared HTTP client for every feature module.
class Request {
  Request._();

  static const Duration _timeout = Duration(seconds: Config.timeoutDuration);

  static Future<ServerResponse> get(String endpoint,
          {bool auth = false, Map<String, dynamic>? query}) =>
      _send('GET', endpoint, auth: auth, query: query);
  static Future<ServerResponse> post(String endpoint, Map<String, dynamic> body,
          {bool auth = false, Map<String, dynamic>? query}) =>
      _send('POST', endpoint, auth: auth, query: query, body: body);
  static Future<ServerResponse> put(String endpoint, Map<String, dynamic> body,
          {bool auth = false, Map<String, dynamic>? query}) =>
      _send('PUT', endpoint, auth: auth, query: query, body: body);
  static Future<ServerResponse> patch(
          String endpoint, Map<String, dynamic> body,
          {bool auth = false, Map<String, dynamic>? query}) =>
      _send('PATCH', endpoint, auth: auth, query: query, body: body);
  static Future<ServerResponse> delete(String endpoint,
          {bool auth = false,
          Map<String, dynamic>? query,
          Map<String, dynamic>? body}) =>
      _send('DELETE', endpoint, auth: auth, query: query, body: body);

  static Future<ServerResponse> multipart(
    String method,
    String endpoint,
    Map<String, String> fields, {
    bool auth = false,
    Map<String, String>? files,
  }) async {
    try {
      final request = http.MultipartRequest(method, _uri(endpoint, null));
      request.headers.addAll(_headers(auth)..remove('Content-Type'));
      request.fields.addAll(fields);
      if (files != null) {
        for (final entry in files.entries) {
          if (entry.value.isNotEmpty) {
            request.files.add(
              await http.MultipartFile.fromPath(entry.key, entry.value),
            );
          }
        }
      }
      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      return ServerResponse.fromHttp(response.statusCode, response.body);
    } on TimeoutException {
      return ServerResponse.error('Request timed out. Please try again.');
    } on http.ClientException catch (error) {
      debugPrint('Multipart connection failed: ${error.message}');
      return ServerResponse.error('Cannot connect to the server.');
    } catch (error, stackTrace) {
      debugPrint('Unexpected multipart error: $error\n$stackTrace');
      return ServerResponse.error('Unable to submit the form.');
    }
  }

  static Future<ServerResponse> _send(String method, String endpoint,
      {required bool auth,
      Map<String, dynamic>? query,
      Map<String, dynamic>? body}) async {
    try {
      final request = http.Request(method, _uri(endpoint, query));
      request.headers.addAll(_headers(auth));
      if (body != null) request.body = jsonEncode(body);
      final streamed = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamed);
      return ServerResponse.fromHttp(response.statusCode, response.body);
    } on TimeoutException {
      return ServerResponse.error('Request timed out. Please try again.');
    } on http.ClientException catch (error) {
      debugPrint('API connection failed: ${error.message}');
      return ServerResponse.error(
        kIsWeb
            ? 'Cannot reach the API. Check the API URL and server CORS settings.'
            : 'Cannot connect to the server. Please try again.',
      );
    } on SocketException catch (error) {
      debugPrint('API socket failed: $error');
      return ServerResponse.error('No internet connection.');
    } on FormatException catch (error) {
      debugPrint('API response parsing failed: $error');
      return ServerResponse.error('The server returned an invalid response.');
    } catch (error, stackTrace) {
      debugPrint('Unexpected API error: $error\n$stackTrace');
      return ServerResponse.error('Unexpected API error: $error');
    }
  }

  static Map<String, String> _headers(bool auth) {
    final result = Map<String, String>.from(Config.defaultHeaders);
    final token = LocalStorage.read(LocalStorage.tokenKey);
    if (auth && token != null && token.isNotEmpty)
      result['Authorization'] = 'Bearer $token';
    return result;
  }

  static Uri _uri(String endpoint, Map<String, dynamic>? query) {
    final normalized = endpoint.startsWith('/') ? endpoint : '/$endpoint';
    final uri = Uri.parse('${Config.baseUrl}$normalized');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(
        queryParameters: query.map((key, value) =>
            MapEntry(key, value == null ? '' : value.toString())));
  }
}
