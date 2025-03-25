import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inkger/frontend/utils/auth_provider.dart';
import 'package:provider/provider.dart';

class ApiService {
  static final Dio dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:3000',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 30), // Longer timeout for uploads
    ),
  );

  // Initialize without context for basic requests
  static void initialize() {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        responseHeader: true,
        responseBody: true,
        error: true,
      ),
    );
  }

  // Initialize with context for authenticated requests
  static void initializeWithContext(BuildContext context) {
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Only add auth header if context is available
          try {
            final authProvider = Provider.of<AuthProvider>(
              context,
              listen: false,
            );
            if (authProvider.isAuthenticated) {
              options.headers['Authorization'] = 'Bearer ${authProvider.token}';
            }
          } catch (e) {
            debugPrint('Could not access AuthProvider: $e');
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              final authProvider = Provider.of<AuthProvider>(
                context,
                listen: false,
              );
              await authProvider.logout();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (Route<dynamic> route) => false,
              );
            } catch (e) {
              debugPrint('Error handling 401: $e');
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Special method for file uploads
  static Future<Response> uploadFile({
    required String path,
    required FormData data,
    BuildContext? context,
    ProgressCallback? onSendProgress,
  }) async {
    final options = Options(
      contentType: 'multipart/form-data',
      headers: context != null 
          ? {'Authorization': 'Bearer ${Provider.of<AuthProvider>(context, listen: false).token}'}
          : null,
    );

    return dio.post(
      path,
      data: data,
      options: options,
      onSendProgress: onSendProgress,
    );
  }
  
}
