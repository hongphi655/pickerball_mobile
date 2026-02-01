import 'package:flutter/material.dart';
import 'dart:convert';
import '../models/models.dart';
import '../services/api_service.dart';

class AuthProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  User? _currentUser;
  String? _token;
  bool _isLoggedIn = false;
  bool _isLoading = false;
  String? _errorMessage;

  AuthProvider() {
    // Set up unauthorized callback
    ApiService.onUnauthorized = _handleUnauthorized;
  }

  User? get currentUser => _currentUser;
  String? get token => _token;
  bool get isLoggedIn => _isLoggedIn;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  bool get isTokenValid {
    return _isLoggedIn && _currentUser != null && _token != null;
  }

  void _handleUnauthorized() {
    _currentUser = null;
    _token = null;
    _isLoggedIn = false;
    notifyListeners();
    // ignore: avoid_print
    print('User unauthorized - cleared auth state');
  }

  Future<void> checkLoginStatus() async {
    _isLoggedIn = await _apiService.isLoggedIn();
    if (_isLoggedIn) {
      // Extract user info from stored token
      try {
        final token = await _apiService.getStoredToken();
        if (token != null && token.isNotEmpty) {
          _token = token;
          // Decode JWT to extract user claims
          final parts = token.split('.');
          if (parts.length == 3) {
            // Decode payload (add padding if needed)
            String payload = parts[1];
            final padding = 4 - payload.length % 4;
            if (padding != 4) {
              payload += '=' * padding;
            }
            final decoded = jsonDecode(utf8.decode(base64.decode(payload)));
            
            // Extract roles - can be string or list
            List<String> userRoles = [];
            final roleKey = 'http://schemas.microsoft.com/ws/2008/06/identity/claims/role';
            if (decoded.containsKey(roleKey)) {
              final roleValue = decoded[roleKey];
              if (roleValue is String) {
                userRoles = [roleValue];
              } else if (roleValue is List) {
                userRoles = List<String>.from(roleValue);
              }
            }
            
            // Extract user info from JWT claims
            _currentUser = User(
              id: decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ?? 'unknown',
              username: decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name'] ?? 'User',
              email: decoded['http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress'] ?? '',
              roles: userRoles,
            );
            // ignore: avoid_print
            print('Auth restored from token: ${_currentUser?.username} (roles: $userRoles)');
          }
        }
      } catch (e) {
        // ignore: avoid_print
        print('Error checking login status: $e');
        _isLoggedIn = false;
      }
    }
    notifyListeners();
  }

  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await _apiService.login(username, password);
      if (response != null) {
        _currentUser = response.user;
        _token = response.token;
        _isLoggedIn = true;
        // debug log roles
        // ignore: avoid_print
        print('User roles: ${_currentUser?.roles}');
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'Invalid credentials';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> register(String username, String email, String password, String fullName) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.register(username, email, password, fullName);
      if (success) {
        return true;
      } else {
        _errorMessage = 'Registration failed';
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _currentUser = null;
    _token = null;
    _isLoggedIn = false;
    await _apiService.logout();
    notifyListeners();
  }
}

class WalletProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  double _balance = 0;
  List<WalletTransaction> _transactions = [];
  bool _isLoading = false;
  String? _errorMessage;

  double get balance => _balance;
  List<WalletTransaction> get transactions => _transactions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getBalance() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _balance = await _apiService.getWalletBalance();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getTransactions({int pageNumber = 1, int pageSize = 10}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _transactions = await _apiService.getTransactionHistory(
        pageNumber: pageNumber,
        pageSize: pageSize,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deposit(double amount, String? proofImageUrl) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final transaction = await _apiService.depositWallet(amount, proofImageUrl);
      if (transaction != null) {
        await getBalance();
        return true;
      } else {
        _errorMessage = 'Deposit failed';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> approveDeposit(int transactionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.approveDeposit(transactionId);
      await getTransactions(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> rejectDeposit(int transactionId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.rejectDeposit(transactionId);
      await getTransactions(); // Refresh list
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class BookingProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Booking> _myBookings = [];
  List<Booking> _calendarBookings = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Booking> get myBookings => _myBookings;
  List<Booking> get calendarBookings => _calendarBookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getMyBookings() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _myBookings = await _apiService.getMyBookings();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getCalendar(int courtId, DateTime date) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _calendarBookings = await _apiService.getCalendar(courtId, date);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createBooking(int courtId, DateTime startTime, DateTime endTime) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final booking = await _apiService.createBooking(courtId, startTime, endTime);
      if (booking != null) {
        await getMyBookings();
        return true;
      } else {
        _errorMessage = 'Failed to create booking';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> cancelBooking(int bookingId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.cancelBooking(bookingId);
      if (success) {
        await getMyBookings();
        return true;
      } else {
        _errorMessage = 'Failed to cancel booking';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class TournamentProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Tournament> _tournaments = [];
  Tournament? _selectedTournament;
  bool _isLoading = false;
  String? _errorMessage;

  List<Tournament> get tournaments => _tournaments;
  Tournament? get selectedTournament => _selectedTournament;
  List<TournamentParticipantModel> _participants = [];
  List<TournamentParticipantModel> get participants => _participants;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getTournaments() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _tournaments = await _apiService.getTournaments();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getTournament(int tournamentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedTournament = await _apiService.getTournament(tournamentId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> joinTournament(int tournamentId, {String? teamName}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.joinTournament(tournamentId, teamName: teamName);
      if (success) {
        await getTournaments();
        return true;
      } else {
        _errorMessage = 'Failed to join tournament';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> leaveTournament(int tournamentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.leaveTournament(tournamentId);
      if (success) {
        await getTournaments();
        return true;
      } else {
        _errorMessage = 'Failed to leave tournament';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTournament(
    String name,
    String description,
    DateTime startDate,
    DateTime endDate,
    double entryFee,
    int maxParticipants,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.createTournament(
        name,
        description,
        startDate,
        endDate,
        entryFee,
        maxParticipants,
      );
      await getTournaments();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getParticipants(int tournamentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _participants = await _apiService.getTournamentParticipants(tournamentId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateTournament(int tournamentId, String name, DateTime startDate, DateTime endDate, String format, double entryFee, double prizePool) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updated = await _apiService.updateTournament(tournamentId, name, startDate, endDate, format, entryFee, prizePool);
      if (updated != null) {
        await getTournaments();
        return true;
      } else {
        _errorMessage = 'Failed to update tournament';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteTournament(int tournamentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.deleteTournament(tournamentId);
      if (success) {
        await getTournaments();
        return true;
      } else {
        _errorMessage = 'Failed to delete tournament';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> generateSchedule(int tournamentId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _apiService.generateTournamentSchedule(tournamentId);
      if (success) {
        return true;
      } else {
        _errorMessage = 'Failed to generate schedule';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class CourtProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Court> _courts = [];
  List<Court> _filteredCourts = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  // Filter state
  String _searchQuery = '';
  double? _maxPrice;
  double? _minRating;
  bool _sortByPrice = false;

  List<Court> get courts => _filteredCourts.isEmpty ? _courts : _filteredCourts;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  
  // Search & filter getters
  String get searchQuery => _searchQuery;
  double? get maxPrice => _maxPrice;
  double? get minRating => _minRating;
  bool get sortByPrice => _sortByPrice;

  Future<void> getCourts({bool forceRefresh = false}) async {
    // Return cached data if still valid and not forcing refresh
    if (!forceRefresh && _lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration &&
        _courts.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _courts = await _apiService.getCourts();
      _applyFilters(); // Apply filters to new data
      _lastFetchTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search courts by name/location
  void searchCourts(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by price
  void filterByPrice(double? maxPrice) {
    _maxPrice = maxPrice;
    _applyFilters();
    notifyListeners();
  }

  // Filter by rating
  void filterByRating(double? minRating) {
    _minRating = minRating;
    _applyFilters();
    notifyListeners();
  }

  // Sort by price
  void setSortByPrice(bool enable) {
    _sortByPrice = enable;
    _applyFilters();
    notifyListeners();
  }

  // Apply all filters and search
  void _applyFilters() {
    _filteredCourts = _courts.where((court) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!court.name.toLowerCase().contains(query) &&
            !(court.location?.toLowerCase().contains(query) ?? false)) {
          return false;
        }
      }

      // Price filter
      if (_maxPrice != null && court.pricePerHour > _maxPrice!) {
        return false;
      }

      // Rating filter (if court has rating - dummy for now)
      // if (_minRating != null && (court.rating ?? 0) < _minRating!) {
      //   return false;
      // }

      return true;
    }).toList();

    // Sort by price if enabled
    if (_sortByPrice) {
      _filteredCourts.sort((a, b) => a.pricePerHour.compareTo(b.pricePerHour));
    }
  }

  // Clear all filters
  void clearFilters() {
    _searchQuery = '';
    _maxPrice = null;
    _minRating = null;
    _sortByPrice = false;
    _filteredCourts = [];
    notifyListeners();
  }

  Future<void> createCourt(String name, String location, double hourlyRate) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.createCourt(name, location, hourlyRate);
      await getCourts(forceRefresh: true); // Refresh list
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      // Log error for debugging
      // ignore: avoid_print
      print('Court creation error: $e');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateCourt(int courtId, String name, String location, double hourlyRate) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.updateCourt(courtId, name, location, hourlyRate);
      await getCourts(forceRefresh: true); // Refresh list
      _errorMessage = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      // Log error for debugging
      // ignore: avoid_print
      print('Court update error: $e');
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteCourt(int courtId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.deleteCourt(courtId);
      await getCourts(forceRefresh: true); // Refresh list
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

class MemberProvider extends ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Member> _members = [];
  List<Booking> _memberBookings = [];
  bool _isLoading = false;
  String? _errorMessage;
  DateTime? _lastFetchTime;
  static const Duration _cacheDuration = Duration(minutes: 5);

  List<Member> get members => _members;
  List<Booking> get memberBookings => _memberBookings;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> getMembers({bool forceRefresh = false}) async {
    // Return cached data if still valid and not forcing refresh
    if (!forceRefresh && _lastFetchTime != null && 
        DateTime.now().difference(_lastFetchTime!) < _cacheDuration &&
        _members.isNotEmpty) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _members = await _apiService.getMembers();
      _lastFetchTime = DateTime.now();
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> getMemberBookings(int memberId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _memberBookings = await _apiService.getMemberBookings(memberId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
