import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inkger/frontend/utils/auth_provider.dart';
import 'package:inkger/frontend/utils/constants.dart';
import 'package:provider/provider.dart';

class ApiService {
  static late final Dio dio;
  static BuildContext? _globalContext;

  static void initialize(BuildContext context) {
    _globalContext = context;

    dio = Dio(
      BaseOptions(
        baseUrl: 'http://${Constants.ApiIP}:3000',
        connectTimeout: const Duration(seconds: 5),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            // Usar el contexto global si no se proporciona uno específico
            final context =
                options.extra['context'] as BuildContext? ?? _globalContext;

            if (context != null) {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              if (authProvider.token != null) {
                options.headers['Authorization'] =
                    'Bearer ${authProvider.token}';
              }
            }
          } catch (e) {
            debugPrint('Error en interceptor de request: $e');
          }
          /*debugPrint('🌐 Request: ${options.method} ${options.uri}');
          debugPrint('📤 Headers: ${options.headers}');
          debugPrint('📦 Body: ${options.data}');*/
          return handler.next(options);
        },
        onResponse: (response, handler) {
          /*debugPrint('✅ Response: ${response.statusCode}');
          debugPrint('📥 Data: ${response.data}');*/
          return handler.next(response);
        },
        onError: (error, handler) async {
          /*debugPrint('❌ Error: ${error.message}');
          debugPrint('🛑 Response: ${error.response?.data}');*/
          try {
            if (error.response?.statusCode == 401) {
              final context =
                  error.requestOptions.extra['context'] as BuildContext? ??
                  _globalContext;
              if (context != null) {
                final authProvider = Provider.of<AuthProvider>(
                  context,
                  listen: false,
                );
                await authProvider.logout();
                _navigateToLogin(context);
              }
            }
          } catch (e) {
            debugPrint('Error en interceptor de error: $e');
          }
          return handler.next(error);
        },
      ),
    );
  }

  static void _navigateToLogin(BuildContext context) {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  static Future<Response> request({
    required String method,
    required String path,
    dynamic data,
    Map<String, dynamic>? queryParams,
    BuildContext? context,
    Options? options,
    ProgressCallback? onSendProgress,
  }) async {
    try {
      final requestOptions =
          options?.copyWith(method: method, extra: {'context': context}) ??
          Options(method: method, extra: {'context': context});

      return await dio.request(
        path,
        data: data,
        queryParameters: queryParams,
        options: requestOptions,
      );
    } on DioException catch (e) {
      debugPrint('Error en $method $path: ${e.message}');
      if (e.response != null) {
        debugPrint('Response data: ${e.response?.data}');
        debugPrint('Response status: ${e.response?.statusCode}');
      }
      rethrow;
    }
  }

  static Future<Response> uploadFile({
    required Uint8List fileBytes,
    required String fileName,
    required String fileType,
    required String uploadPath,
    Map<String, dynamic>? metadata,
    BuildContext? context,
    ProgressCallback? onSendProgress,
    CancelToken? cancelToken,
  }) async {
    try {
      // Crear el objeto de datos que será convertido a JSON
      final uploadData = {
        'type': fileType.toLowerCase(),
        'uploadPath': uploadPath,
        if (metadata != null) 'metadata': metadata,
      };

      final formData = FormData.fromMap({
        'file': MultipartFile.fromBytes(fileBytes, filename: fileName),
        'uploadData': jsonEncode(uploadData), // Enviamos todo como JSON string
      });

      return await dio.post(
        '/api/upload', // Asegúrate que esta ruta coincide con tu endpoint
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
          extra: {'context': context},
        ),
        onSendProgress: onSendProgress,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      debugPrint('Error en uploadFile: ${e.message}');
      rethrow;
    }
  }

  // Helpers para métodos HTTP comunes
  static Future<Response> get(
    String path, {
    BuildContext? context,
    Map<String, dynamic>? params,
    Options? options,
  }) => request(
    method: 'GET',
    path: path,
    queryParams: params,
    context: context,
    options: options,
  );

  static Future<Response> post(
    String path, {
    dynamic data,
    BuildContext? context,
    Options? options,
  }) => request(
    method: 'POST',
    path: path,
    data: data,
    context: context,
    options: options,
  );

  static Future<Response> put(
    String path, {
    dynamic data,
    BuildContext? context,
    Options? options,
  }) => request(
    method: 'PUT',
    path: path,
    data: data,
    context: context,
    options: options,
  );

  static Future<Response> delete(
    String path, {
    BuildContext? context,
    dynamic data,
    Options? options,
  }) => request(
    method: 'DELETE',
    path: path,
    context: context,
    data: data,
    options: options,
  );
}
