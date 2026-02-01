import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/models.dart';
import '../utils/app_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  late Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  factory ApiService() {
    return _instance;
  }

  ApiService._internal() {
    _initializeDio();
  }

  void _initializeDio() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        contentType: 'application/json',
        responseType: ResponseType.json,
      ),
    );

    // Add interceptor for token handling
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.read(key: 'auth_token');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          if (error.response?.statusCode == 401) {
            // Token expired or invalid
            _storage.delete(key: 'auth_token');
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Auth Endpoints
  Future<LoginResponse?> login(String username, String password) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'];
        final token = data['token'];
        await _storage.write(key: 'auth_token', value: token);
        return LoginResponse.fromJson(data);
      }
    } on DioError catch (e) {
      final resp = e.response?.data;
      final message = resp is Map && resp.containsKey('message') ? resp['message'] : resp?.toString() ?? e.message;
      // Log server-provided error message to help debugging
      // ignore: avoid_print
      print('Login failed: $message');
      return null;
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<bool> register(String username, String email, String password, String fullName) async {
    try {
      final response = await _dio.post(
        '/api/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'fullName': fullName,
        },
      );
      return response.statusCode == 200 && response.data['success'] == true;
    } on DioError catch (e) {
      final resp = e.response?.data;
      final message = resp is Map && resp.containsKey('message') ? resp['message'] : resp?.toString() ?? e.message;
      // Log server-provided error message to help debugging
      // ignore: avoid_print
      print('Register failed: $message');
      return false;
    } catch (e) {
      rethrow;
    }
  }

  // Courts Endpoints
  Future<List<Court>> getCourts() async {
    try {
      final response = await _dio.get('/api/courts');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((court) => Court.fromJson(court)).toList();
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }

  // Bookings Endpoints
  Future<Booking?> createBooking(int courtId, DateTime startTime, DateTime endTime) async {
    try {
      final response = await _dio.post(
        '/api/bookings',
        data: {
          'courtId': courtId,
          'startTime': startTime.toIso8601String(),
          'endTime': endTime.toIso8601String(),
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return Booking.fromJson(response.data['data']);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<List<Booking>> getMyBookings() async {
    try {
      final response = await _dio.get('/api/bookings/my-bookings');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((booking) => Booking.fromJson(booking)).toList();
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }

  Future<List<Booking>> getCalendar(int courtId, DateTime date) async {
    try {
      final response = await _dio.get(
        '/api/bookings/calendar',
        queryParameters: {
          'courtId': courtId,
          'date': date.toIso8601String(),
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((booking) => Booking.fromJson(booking)).toList();
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }

  Future<bool> cancelBooking(int bookingId) async {
    try {
      final response = await _dio.delete('/api/bookings/$bookingId');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  // Wallet Endpoints
  Future<WalletTransaction?> depositWallet(double amount, String? proofImageUrl) async {
    try {
      final response = await _dio.post(
        '/api/wallet/deposit',
        data: {
          'amount': amount,
          'proofImageUrl': proofImageUrl,
          'description': 'Deposit request from mobile app',
        },
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        return WalletTransaction.fromJson(response.data['data']);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<double> getWalletBalance() async {
    try {
      final response = await _dio.get('/api/wallet/balance');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return (response.data['data'] ?? 0).toDouble();
      }
    } catch (e) {
      rethrow;
    }
    return 0;
  }

  Future<List<WalletTransaction>> getTransactionHistory({int pageNumber = 1, int pageSize = 10}) async {
    try {
      final response = await _dio.get(
        '/api/wallet/transactions',
        queryParameters: {
          'pageNumber': pageNumber,
          'pageSize': pageSize,
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((tx) => WalletTransaction.fromJson(tx)).toList();
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }

  // Tournament Endpoints
  Future<List<Tournament>> getTournaments() async {
    try {
      final response = await _dio.get('/api/tournaments');
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        return data.map((tournament) => Tournament.fromJson(tournament)).toList();
      }
    } catch (e) {
      rethrow;
    }
    return [];
  }

  Future<Tournament?> getTournament(int tournamentId) async {
    try {
      final response = await _dio.get('/api/tournaments/$tournamentId');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return Tournament.fromJson(response.data['data']);
      }
    } catch (e) {
      rethrow;
    }
    return null;
  }

  Future<bool> joinTournament(int tournamentId, {String? teamName}) async {
    try {
      final response = await _dio.post(
        '/api/tournaments/$tournamentId/join',
        data: {
          'teamName': teamName,
        },
      );

      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> leaveTournament(int tournamentId) async {
    try {
      final response = await _dio.delete('/api/tournaments/$tournamentId/leave');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  // Court Management
  Future<void> createCourt(String name, String location, double hourlyRate) async {
    try {
      final response = await _dio.post(
        '/api/courts',
        data: {
          'name': name,
          'location': location,
          'hourlyRate': hourlyRate,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create court');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateCourt(int courtId, String name, String location, double hourlyRate) async {
    try {
      final response = await _dio.put(
        '/api/courts/$courtId',
        data: {
          'name': name,
          'location': location,
          'hourlyRate': hourlyRate,
        },
      );
      if (response.statusCode != 200) {
        throw Exception('Failed to update court');
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteCourt(int courtId) async {
    try {
      final response = await _dio.delete('/api/courts/$courtId');
      if (response.statusCode != 200) {
        throw Exception('Failed to delete court');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Wallet Management
  Future<bool> approveDeposit(int transactionId) async {
    try {
      final response = await _dio.put('/api/wallet/approve/$transactionId');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> rejectDeposit(int transactionId) async {
    try {
      final response = await _dio.put('/api/wallet/reject/$transactionId');
      return response.statusCode == 200 && response.data['success'] == true;
    } catch (e) {
      rethrow;
    }
  }

  // Tournament Management
  Future<void> createTournament(
    String name,
    String description,
    DateTime startDate,
    DateTime endDate,
    double entryFee,
    int maxParticipants,
  ) async {
    try {
      final response = await _dio.post(
        '/api/tournaments',
        data: {
          'name': name,
          'description': description,
          'startDate': startDate.toIso8601String(),
          'endDate': endDate.toIso8601String(),
          'entryFee': entryFee,
          'maxParticipants': maxParticipants,
        },
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception('Failed to create tournament');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: 'auth_token');
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'auth_token');
    return token != null && token.isNotEmpty;
  }
}

class LoginResponse {
  final String token;
  final User user;

  LoginResponse({required this.token, required this.user});

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      token: json['token'] ?? '',
      user: User.fromJson(json['user']),
    );
  }
}
