import 'package:dio/dio.dart';

class ApiService {
  static final dio = Dio(
    BaseOptions(
      baseUrl: 'http://localhost:8080', // URL base de tu API
      connectTimeout: const Duration(
        seconds: 5,
      ), // Tiempo de espera para la conexión
      receiveTimeout: const Duration(
        seconds: 5,
      ), // Tiempo de espera para recibir datos
    ),
  );

  ApiService() {
    // Configura la URL base del backend
    dio.options.baseUrl = 'http://localhost:3000';
    dio.options.headers = {'Content-Type': 'application/json'};
  }

  // Método para hacer login
  Future<Response> login(String username, String password) async {
    final dio = Dio();
    final response = await dio.post(
      'http://localhost:3000/api/login',
      data: {'username': username, 'password': password},
    );
    return response;
  }
}
