import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class GetApiResponse {
  final bool    status;
  final dynamic data;
  final String? message;
  final Map<String, dynamic> _raw;

  const GetApiResponse({
    required this.status,
    required this.data,
    this.message,
    required Map<String, dynamic> raw,
  }) : _raw = raw;

  Map<String, dynamic> toJson() => _raw;
}

class GetApiProvider {
  static const String _baseUrl = 'https://your-api-domain.com';

  final Dio _dio = Dio(BaseOptions(
    baseUrl:        _baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers:        {'Content-Type': 'application/json'},
  ));

  Future<void> onGetProvider({
    required String url,
    required FutureOr<void> Function(GetApiResponse result) onSuccess,
    required FutureOr<void> Function(dynamic error)        onError,
  }) async {
    try {
      final res  = await _dio.get<Map<String, dynamic>>(url);
      final body = res.data;
      if (body == null) { await onError('Empty response'); return; }
      await onSuccess(_parse(body));
    } catch (e) {
      if (kDebugMode) debugPrint('[API] GET $url error: $e');
      await onError(e);
    }
  }

  Future<void> onGetProviderWithParam({
    required String url,
    required Map<String, dynamic> param,
    required FutureOr<void> Function(GetApiResponse result) onSuccess,
    required FutureOr<void> Function(dynamic error)        onError,
  }) async {
    try {
      final res  = await _dio.get<Map<String, dynamic>>(url, queryParameters: param);
      final body = res.data;
      if (body == null) { await onError('Empty response'); return; }
      await onSuccess(_parse(body));
    } catch (e) {
      if (kDebugMode) debugPrint('[API] GET $url error: $e');
      await onError(e);
    }
  }

  Future<void> onGetProviderWithParamMap({
    required String url,
    required Map<String, dynamic> param,
    required FutureOr<void> Function(dynamic payload) onSuccess,
    required FutureOr<void> Function(dynamic error)   onError,
  }) async {
    try {
      final res = await _dio.get<dynamic>(url, queryParameters: param);
      await onSuccess(res.data);
    } catch (e) {
      if (kDebugMode) debugPrint('[API] GET $url error: $e');
      await onError(e);
    }
  }

  Future<void> onPostProvider({
    required String url,
    required Map<String, dynamic> data,
    required FutureOr<void> Function(dynamic result) onSuccess,
    required FutureOr<void> Function(dynamic error)  onError,
  }) async {
    try {
      final res = await _dio.post<dynamic>(url, data: data);
      await onSuccess(res.data);
    } catch (e) {
      if (kDebugMode) debugPrint('[API] POST $url error: $e');
      await onError(e);
    }
  }

  static GetApiResponse _parse(Map<String, dynamic> body) => GetApiResponse(
        status:  body['status']  as bool? ?? false,
        data:    body['data'],
        message: body['message'] as String?,
        raw:     body,
      );
}
