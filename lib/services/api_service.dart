import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../utils/constants.dart';
import '../models/api_response.dart';
import '../models/user.dart';
import '../models/event.dart';

class ApiService {
  static const String _baseUrl = "http://103.160.63.165/api";
  static const Duration _timeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  static Future<http.Response> _makeRequest(
      Future<http.Response> Function() request,
      {int retries = _maxRetries}) async {
    for (int attempt = 1; attempt <= retries; attempt++) {
      try {
        final response = await request().timeout(_timeout);
        return response;
      } on TimeoutException {
        if (attempt == retries) {
          throw TimeoutException(
              'Request timed out after $retries attempts', _timeout);
        }
        await Future.delayed(Duration(seconds: attempt * 2));
      } catch (e) {
        if (attempt == retries) rethrow;
        await Future.delayed(Duration(seconds: attempt));
      }
    }
    throw Exception('Max retries exceeded');
  }

  static Future<ApiResponse<Map<String, dynamic>>> register({
    required String name,
    required String email,
    required String studentNumber,
    required String major,
    required int classYear,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      final response = await _makeRequest(() =>
          http.post(
            Uri.parse('$_baseUrl/register'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'name': name,
              'email': email,
              'student_number': studentNumber,
              'major': major,
              'class_year': classYear,
              'password': password,
              'password_confirmation': passwordConfirmation,
            }),
          ));

      final data = jsonDecode(response.body);
      return ApiResponse<Map<String, dynamic>>(
        success: response.statusCode == 201,
        message: data['message'] ?? 'Registration failed',
        data: data['data'],
      );
    } on TimeoutException {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Connection timeout. The server is taking too long to respond.',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  static Future<ApiResponse<Map<String, dynamic>>> login({
    required String studentNumber,
    required String password,
  }) async {
    try {
      final response = await _makeRequest(() =>
          http.post(
            Uri.parse('$_baseUrl/login'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'student_number': studentNumber,
              'password': password,
            }),
          ));

      final data = jsonDecode(response.body);
      return ApiResponse<Map<String, dynamic>>(
        success: response.statusCode == 200,
        message: data['message'] ?? 'Login failed',
        data: data['data'],
      );
    } on TimeoutException {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Connection timeout. Please check your internet connection and try again.',
      );
    } catch (e) {
      return ApiResponse<Map<String, dynamic>>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  static Future<ApiResponse<List<Event>>> getEvents({
    String? search,
    String? category,
    String? date,
    int? limit,
    String? token,
  }) async {
    try {
      Map<String, String> queryParams = {};
      if (search != null) queryParams['search'] = search;
      if (category != null) queryParams['category'] = category;
      if (date != null) queryParams['date'] = date;
      if (limit != null) queryParams['limit'] = limit.toString();

      final uri = Uri.parse('$_baseUrl/events').replace(
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      final response = await _makeRequest(() =>
          http.get(uri, headers: headers));
      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        List<dynamic> eventsList = [];

        if (data is Map) {
          if (data.containsKey('data') && data['data'] is List) {
            eventsList = data['data'];
          } else if (data.containsKey('data') &&
              data['data'] is Map &&
              data['data'].containsKey('events')) {
            eventsList = data['data']['events'];
          } else if (data.containsKey('events') && data['events'] is List) {
            eventsList = data['events'];
          }
        } else if (data is List) {
          eventsList = data;
        }

        if (eventsList.isNotEmpty) {
          List<Event> events = eventsList.map((eventJson) {
            try {
              return Event.fromJson(eventJson);
            } catch (e) {
              rethrow;
            }
          }).toList();

          return ApiResponse<List<Event>>(
            success: true,
            message: 'Events loaded successfully',
            data: events,
          );
        } else {
          return ApiResponse<List<Event>>(
            success: true,
            message: 'No events found',
            data: [],
          );
        }
      } else {
        return ApiResponse<List<Event>>(
          success: false,
          message: data['message'] ??
              'Failed to load events (${response.statusCode})',
        );
      }
    } on TimeoutException {
      return ApiResponse<List<Event>>(
        success: false,
        message: 'Connection timeout. Please try again.',
      );
    } catch (e) {
      return ApiResponse<List<Event>>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }

  static Future<ApiResponse<Event>> createEvent({
    required String name,
    required String description,
    required String startDate,
    required String endDate,
    required String time,
    required String location,
    required int maxParticipants,
    required String category,
    required double price, // <-- New field
    String? imageUrl,
    required String token,
  }) async {
    try {
      final requestBody = {
        'title': name,
        // backend expects 'title'
        'description': description,
        'start_date': startDate,
        'end_date': endDate,
        // required: set equal to start_date if no end_date selection
        'time': time,
        'location': location,
        'max_attendees': maxParticipants,
        'category': category,
        'price': price,
        // <-- Include price
        if (imageUrl != null && imageUrl.isNotEmpty) 'image_url': imageUrl,
      };

      print('Sending to API: ${jsonEncode(requestBody)}');

      final response = await _makeRequest(() =>
          http.post(
            Uri.parse('$_baseUrl/events'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(requestBody),
          ));

      final data = jsonDecode(response.body);
      print('Raw API response: ${response.body}');

      if (response.statusCode == 201) {
        if (data['success'] == true && data['data'] != null) {
          final event = Event.fromJson(data['data']);
          return ApiResponse<Event>(
            success: true,
            message: data['message'] ?? 'Event created successfully',
            data: event,
          );
        } else {
          return ApiResponse<Event>(
            success: false,
            message: data['message'] ?? 'Unexpected response format',
          );
        }
      } else {
        return ApiResponse<Event>(
          success: false,
          message: data['message'] ??
              'Failed to create event (${response.statusCode})',
        );
      }
    } on TimeoutException {
      return ApiResponse<Event>(
        success: false,
        message: 'Connection timeout. Please try again.',
      );
    } catch (e) {
      return ApiResponse<Event>(
        success: false,
        message: 'Network error: $e',
      );
    }
  }
}