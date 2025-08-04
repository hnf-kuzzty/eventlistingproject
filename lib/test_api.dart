import 'dart:convert';
import 'package:http/http.dart' as http;

void main() async {
  await testAPI();
}

Future<void> testAPI() async {
  const String baseUrl = 'http://103.160.63.165/api';

  print('Testing API endpoints...\n');

  // Test 1: Get Events
  try {
    print('1. Testing GET /events');
    final eventsResponse = await http.get(
      Uri.parse('$baseUrl/events'),
      headers: {'Content-Type': 'application/json'},
    );

    print('Status Code: ${eventsResponse.statusCode}');
    print('Response: ${eventsResponse.body}\n');

    if (eventsResponse.statusCode == 200) {
      final data = jsonDecode(eventsResponse.body);
      print('✅ Events endpoint working');
      print('Found ${data['events']?.length ?? 0} events\n');
    } else {
      print('❌ Events endpoint failed\n');
    }
  } catch (e) {
    print('❌ Error testing events endpoint: $e\n');
  }

  // Test 2: Register User (you might want to use a test email)
  try {
    print('2. Testing POST /auth/register');
    final registerResponse = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': 'Test User',
        'email': 'test${DateTime.now().millisecondsSinceEpoch}@example.com',
        'password': 'password123',
      }),
    );

    print('Status Code: ${registerResponse.statusCode}');
    print('Response: ${registerResponse.body}\n');

    if (registerResponse.statusCode == 201 || registerResponse.statusCode == 200) {
      print('✅ Registration endpoint working\n');
    } else {
      print('❌ Registration endpoint failed\n');
    }
  } catch (e) {
    print('❌ Error testing registration endpoint: $e\n');
  }

  // Test 3: Login
  try {
    print('3. Testing POST /auth/login');
    final loginResponse = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': 'existing_user@example.com', // Use an existing user
        'password': 'password123',
      }),
    );

    print('Status Code: ${loginResponse.statusCode}');
    print('Response: ${loginResponse.body}\n');

    if (loginResponse.statusCode == 200) {
      print('✅ Login endpoint working\n');
    } else {
      print('❌ Login endpoint failed\n');
    }
  } catch (e) {
    print('❌ Error testing login endpoint: $e\n');
  }
}
