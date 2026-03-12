import 'dart:async';
import 'dart:io';

import 'package:currencyx/common/constants/api.dart';
import 'package:currencyx/models/entity/network_error.dart';
import 'package:currencyx/models/rates/rates.dart';
import 'package:currencyx/models/symbols/symbols.dart';
import 'package:dart_mappable/dart_mappable.dart';
import 'package:dio/dio.dart';
import 'package:twofold/twofold.dart';

Future<Map<String, dynamic>> _get(
  String path, {
  Map<String, dynamic>? query,
  Object? body,
  Map<String, dynamic>? headers,
}) async {
  final dio =
      Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
          ),
        )
        ..options.baseUrl = AppConstants.baseUrl
        ..options.headers = {'apikey': AppConstants.apiKey};

  final response = await dio.request<dynamic>(
    path,
    data: body,
    queryParameters: query,
    options: Options(method: 'GET', headers: headers),
  );

  if (response.data is Map<String, dynamic>) {
    return response.data as Map<String, dynamic>;
  }
  throw const FormatException('Invalid server response');
}

Future<Twofold<T, NetworkError>> safeApiCall<T>(String path) async {
  try {
    final response = await _get(path);

    final result = MapperContainer.globals.fromValue<T>(response);
    return Twofold.success(result);
  } on DioException catch (e) {
    return Twofold.error(_mapDioExceptionToNetworkError(e));
  } on SocketException catch (e, st) {
    return Twofold.error(
      NetworkError(
        cause: e,
        stackTrace: st,
        message: 'No internet connection.',
      ),
    );
  } on TimeoutException catch (e, st) {
    return Twofold.error(
      NetworkError(
        cause: e,
        stackTrace: st,
        message: 'Request timed out. Please try again.',
      ),
    );
  } on IOException catch (e, st) {
    return Twofold.error(
      NetworkError(
        cause: e,
        stackTrace: st,
        httpCode: 502,
        message: 'Network I/O error.',
      ),
    );
  } on FormatException catch (e, st) {
    return Twofold.error(
      NetworkError(
        cause: e,
        stackTrace: st,
        httpCode: 500,
        message: 'Invalid server response.',
      ),
    );
  } catch (e, st) {
    return Twofold.error(
      NetworkError(
        cause: e,
        stackTrace: st,
        httpCode: 500,
        message: 'Something went wrong.',
      ),
    );
  }
}

NetworkError _mapDioExceptionToNetworkError(DioException e) {
  final errorInfo = _extractErrorInfo(e);
  return NetworkError(
    cause: e.error ?? e,
    stackTrace: e.stackTrace,
    httpCode: errorInfo.$1,
    message: errorInfo.$2,
  );
}

(int httpCode, String message) _extractErrorInfo(DioException e) {
  final data = e.response?.data;

  if (data is Map<String, dynamic>) {
    final msg = data['message'] ?? data['error'];
    final int code = data['code'] as int? ?? e.response?.statusCode ?? 0;
    if (msg is String && msg.isNotEmpty) {
      return (code, msg);
    }
  }

  switch (e.type) {
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.sendTimeout:
    case DioExceptionType.receiveTimeout:
      return (
        HttpStatus.gatewayTimeout,
        'Connection timed out. Please try again.',
      );

    case DioExceptionType.connectionError:
      return (HttpStatus.serviceUnavailable, 'No internet connection.');

    case DioExceptionType.cancel:
      return (499, 'Request was cancelled.');

    case DioExceptionType.badResponse:
      return (HttpStatus.badRequest, 'Bad http response.');

    case DioExceptionType.badCertificate:
      return (HttpStatus.badGateway, 'Bad certificate.');

    case DioExceptionType.unknown:
      return (HttpStatus.internalServerError, 'An unknown error occurred');
  }
}

class ApiService {
  Future<Twofold<Symbols, NetworkError>> fetchSymbols() =>
      safeApiCall<Symbols>('/symbols');

  Future<Twofold<Rates, NetworkError>> fetchLatestRates({
    String base = 'USD',
  }) => safeApiCall<Rates>('/latest?base=$base');
}
