import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/constants.dart';

class ApiService {
  final _storage = const FlutterSecureStorage();

  Future<Map<String, String>> _getHeaders() async {
    String? token = await _storage.read(key: AppConfig.keyToken);
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Cookie': 'CSH_SESSION=$token',
    };
  }

  // --- AUTH ---
  Future<Map<String, dynamic>> login(String email, String password, String code2FA) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/login.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
          '2fa_code': code2FA
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        if (data['data']['session_token'] != null) {
          await _storage.write(key: AppConfig.keyToken, value: data['data']['session_token']);
        }
        await _storage.write(key: AppConfig.keyUser, value: jsonEncode(data['data']));
      }
      return data;
    } catch (e) {
      return {'success': false, 'message': 'Connection Error: $e'};
    }
  }

  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/register.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(userData),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Registration Error: $e'};
    }
  }

  Future<Map<String, dynamic>> resetPasswordRequest(String email) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/auth/reset_password_request.php'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Error: $e'};
    }
  }

  // --- USER DATA ---
  Future<Map<String, dynamic>> getDashboardData() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/user/profile.php'), headers: headers);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getReferrals() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/user/referrals.php'), headers: headers);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getTransactions() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/user/transactions.php'), headers: headers);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  // --- TRADING ---
  Future<Map<String, dynamic>> submitGiftCard(Map<String, dynamic> data, String? imagePath) async {
    try {
      final headers = await _getHeaders();
      var request = http.MultipartRequest('POST', Uri.parse('${AppConfig.baseUrl}/giftcards/submit.php'));
      request.headers.addAll(headers);
      
      // Add fields
      data.forEach((key, value) {
        if (value != null) request.fields[key] = value.toString();
      });

      // Add image
      if (imagePath != null) {
        request.files.add(await http.MultipartFile.fromPath('card_image', imagePath));
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Upload Error: $e'};
    }
  }

  // --- WALLET ---
  Future<Map<String, dynamic>> getBanks() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/banks/list.php'), headers: headers);
      if (response.statusCode == 200) return jsonDecode(response.body);
      return {'success': false, 'message': 'Failed to load banks'};
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> getBankAccounts() async {
    try {
      final headers = await _getHeaders();
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/user/bank_account.php'), headers: headers);
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> addBankAccount(Map<String, dynamic> data) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
          Uri.parse('${AppConfig.baseUrl}/user/bank_account.php'),
          headers: headers,
          body: jsonEncode(data)
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': e.toString()};
    }
  }

  Future<Map<String, dynamic>> fundAccount(double amount, String provider, String method) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/payments/initialize.php'),
        headers: headers,
        body: jsonEncode({'amount': amount, 'provider': provider, 'method': method}),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Payment Error: $e'};
    }
  }

  Future<Map<String, dynamic>> withdrawFunds(double amount, String method, Map<String, dynamic> details, String pin) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/withdrawals/request.php'),
        headers: headers,
        body: jsonEncode({
          'amount': amount,
          'withdrawal_method': method,
          'withdrawal_details': details,
          'transaction_pin': pin
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Withdrawal Error: $e'};
    }
  }

  // --- UTILITIES ---
  Future<Map<String, dynamic>> payBill(String serviceId, double amount, String customerId, String pin) async {
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        Uri.parse('${AppConfig.baseUrl}/bills/pay.php'),
        headers: headers,
        body: jsonEncode({
          'service_id': serviceId,
          'amount': amount,
          'customer_id': customerId,
          'transaction_pin': pin
        }),
      );
      return jsonDecode(response.body);
    } catch (e) {
      return {'success': false, 'message': 'Bill Payment Error: $e'};
    }
  }
}
