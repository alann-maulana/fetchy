import 'package:dio/dio.dart';

class HttpClientService {
  late Dio _dio;

  HttpClientService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        validateStatus: (status) => true, // Accept all status codes
      ),
    );

    // Add interceptors for logging
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  Dio get dio => _dio;

  Future<Response> sendRequest({
    required String url,
    required String method,
    Map<String, dynamic>? headers,
    Map<String, dynamic>? queryParameters,
    dynamic body,
  }) async {
    try {
      final options = Options(
        method: method,
        headers: headers,
      );

      final response = await _dio.request(
        url,
        options: options,
        queryParameters: queryParameters,
        data: body,
      );

      return response;
    } catch (e) {
      rethrow;
    }
  }
}
