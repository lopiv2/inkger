import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:inkger/frontend/utils/auth_provider.dart';
import 'package:provider/provider.dart';

class ApiService {
  static final Dio dio = Dio(BaseOptions(
    baseUrl: 'http://localhost:3000',
    connectTimeout: const Duration(seconds: 5),
    receiveTimeout: const Duration(seconds: 5),
    headers: {'Content-Type': 'application/json'},
  ));

  static void initializeInterceptors(BuildContext context) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        if (authProvider.isAuthenticated) {
          options.headers['Authorization'] = 'Bearer ${authProvider.token}';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final authProvider = Provider.of<AuthProvider>(context, listen: false);
          await authProvider.logout();
          Navigator.of(context).pushNamedAndRemoveUntil(
            '/login', 
            (Route<dynamic> route) => false
          );
        }
        return handler.next(error);
      },
    ));
  }
}