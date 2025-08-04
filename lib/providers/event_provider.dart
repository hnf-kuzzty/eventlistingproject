import 'package:flutter/foundation.dart';
import '../models/event.dart';
import '../services/api_service.dart';
import '../providers/auth_provider.dart';

class EventProvider with ChangeNotifier {
  AuthProvider? _authProvider;

  List<Event> _events = [];
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;

  // Setter for AuthProvider
  void setAuthProvider(AuthProvider authProvider) {
    _authProvider = authProvider;
  }

  // Getters
  List<Event> get events => _events;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String? get selectedCategory => _selectedCategory;

  List<Event> get displayedEvents {
    List<Event> filtered = _events;

    // Apply category filter
    if (_selectedCategory != null) {
      filtered = filtered.where((event) => event.category == _selectedCategory).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((event) {
        return event.name.toLowerCase().contains(query) ||
            event.description.toLowerCase().contains(query) ||
            event.location.toLowerCase().contains(query) ||
            event.category.toLowerCase().contains(query);
      }).toList();
    }

    return filtered;
  }

  void updateSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void updateCategoryFilter(String? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> loadEvents() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await ApiService.getEvents(
        token: _authProvider?.token,
      );

      if (response.success && response.data != null) {
        _events = response.data!;
      } else {
        _setError(response.message ?? 'Failed to load events');
      }
    } catch (e) {
      _setError('Failed to load events: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createEvent(Event event) async {
    _clearError();

    try {
      if (_authProvider?.token == null) {
        throw Exception('Authentication required');
      }

      // Debug logging - Add this temporarily
      print('Creating event with data:');
      print('Name: ${event.name}');
      print('Description: ${event.description}');
      print('Date: ${event.date}');
      print('Time: ${event.time}');
      print('Location: ${event.location}');
      print('Max Participants: ${event.maxParticipants}');
      print('Category: ${event.category}');
      print('Image URL: ${event.imageUrl}');
      print('Token exists: ${_authProvider!.token != null}');

      final response = await ApiService.createEvent(
        name: event.name,
        description: event.description,
        startDate: event.date,
        endDate: event.endDate,
        time: event.time,
        location: event.location,
        maxParticipants: event.maxParticipants,
        category: event.category,
        imageUrl: event.imageUrl,
        price: event.price, // <-- ADD THIS LINE
        token: _authProvider!.token!,
      );

      print('API Response - Success: ${response.success}');
      print('API Response - Message: ${response.message}');

      if (response.success && response.data != null) {
        _events.add(response.data!);
        notifyListeners();
      } else {
        throw Exception(response.message ?? 'Failed to create event');
      }
    } catch (e) {
      print('Error creating event: $e');
      _setError('Failed to create event: ${e.toString()}');
      rethrow; // Re-throw to handle in UI
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearData() {
    _events.clear();
    _searchQuery = '';
    _selectedCategory = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }
}