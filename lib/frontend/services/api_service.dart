import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio = Dio();

  ApiService() {
    // Configura la URL base del backend
    _dio.options.baseUrl = 'http://localhost:3000';
    _dio.options.headers = {'Content-Type': 'application/json'};
  }

  // Método para hacer login
  Future<Response> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/login',
        data: {'username': username, 'password': password},
      );
      return response;
    } on DioException catch (e) {
      throw e.response?.data['error'] ?? 'Error de conexión';
    }
  }
}