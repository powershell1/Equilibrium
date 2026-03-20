import 'package:http/http.dart' as http;
import 'dart:convert'; // For decoding the JSON response
import 'package:shared_preferences/shared_preferences.dart';

const String API_URL = "http://pummiphach.trueddns.com:38313";
const String _authTokenKey = "auth_token";

class APIResponse {
  final bool success;
  final String? message;

  APIResponse(this.success, {this.message});
}

class UserInfoResponse extends APIResponse {
  final String userId;
  final String username;
  final String email;
  final List<String> iotDevices;

  UserInfoResponse(bool success, this.userId, this.username, this.email, this.iotDevices)
      : super(success);
}

enum MeasurementFrequency {
  daily,
  weekly,
  monthly,
  yearly,
}

class APIHandler {
  String authToken;

  APIHandler([this.authToken = ""]);

  void setAuthToken(String token) {
    authToken = token;
  }

  // Save auth token to persistent storage
  Future<void> saveAuthToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    authToken = token;
  }

  // Load auth token from persistent storage
  Future<void> loadAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_authTokenKey) ?? "";
    authToken = token;
  }

  // Clear auth token from persistent storage
  Future<void> clearAuthToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    authToken = "";
  }

  Future<Map<String, dynamic>> getDeviceInfo(String deviceId) async {
    final url = Uri.parse("$API_URL/api/device-info?iotId=$deviceId");
    final response = await http.get(url, headers: {
      'Authorization': authToken,
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] ? data['deviceInfo'] : {};
    } else {
      return {};
    }
  }

  Future<bool> getIotState(String deviceId) async {
    final url = Uri.parse("$API_URL/api/iot-state?deviceId=$deviceId");
    final response = await http.get(url, headers: {
      'Authorization': authToken,
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (!data['success']) return false;
      return data['state'] == "1";
    } else {
      return false;
    }
  }

  Future<bool> setIotState(String deviceId, bool state) async {
    final url = Uri.parse("$API_URL/api/iot-state");
    final response = await http.post(url, headers: {
      'Authorization': authToken,
    }, body: {
      'iotId': deviceId,
      'state': state ? "1" : "0",
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'];
    } else {
      return false;
    }
  }

  Future<Map<String, dynamic>> getMeasurements(MeasurementFrequency frequency) async {
    final url = Uri.parse("$API_URL/api/measurements?frequency=${frequency.name}");
    final response = await http.get(url, headers: {
      'Authorization': authToken,
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['success'] ? data['measurements'] : {};
    } else {
      return {};
    }
  }

  Future<bool> login(String email, String password) async {
    final url = Uri.parse("$API_URL/api/login");
    final response = await http.post(url, body: {
      'email': email,
      'password': password,
    });
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['success']) {
        final token = data['userAuth'];
        await saveAuthToken(token);
        return true;
      }
      return false;
    } else {
      return false;
    }
  }

  Future<UserInfoResponse> getUserInfo() async {
    final url = Uri.parse("$API_URL/api/user-info");
    final response = await http.get(url, headers: {
      'Authorization': authToken,
    });
    final data = jsonDecode(response.body);
    return UserInfoResponse(
      data['success'],
      data['userInfo']['userId'] ?? "",
      data['userInfo']['username'] ?? "",
      data['userInfo']['email'] ?? "",
      List<String>.from(data['userInfo']['iotDevices'] ?? []),
    );
  }
}

final APIHandler apiHandler = APIHandler();