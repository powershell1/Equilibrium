import 'package:http/http.dart' as http;
import 'dart:convert'; // For decoding the JSON response
import 'package:shared_preferences/shared_preferences.dart';

const String API_URL = "http://pummiphach.trueddns.com:38313";
const String _authTokenKey = "auth_token";

class APIResponse {
  final bool success;
  final String? message;

  APIResponse({required this.success, this.message});
}

class UserInfoResponse extends APIResponse {
  final String userId;
  final String username;
  final String email;
  final List<String> iotDevices;

  UserInfoResponse({
    required bool success,
    String? message,
    this.userId = "",
    this.username = "",
    this.email = "",
    this.iotDevices = const [],
  }) : super(success: success, message: message);
}

class DeviceInfoResponse extends APIResponse {
  final Map<String, dynamic> deviceInfo;

  DeviceInfoResponse({
    required bool success,
    String? message,
    this.deviceInfo = const {},
  }) : super(success: success, message: message);
}

class IotStateResponse extends APIResponse {
  final bool state;

  IotStateResponse({
    required bool success,
    String? message,
    this.state = false,
  }) : super(success: success, message: message);
}

class MeasurementsResponse extends APIResponse {
  final List<dynamic> measurements;

  MeasurementsResponse({
    required bool success,
    String? message,
    this.measurements = const [],
  }) : super(success: success, message: message);
}

class LoginResponse extends APIResponse {
  final String? token;

  LoginResponse({
    required bool success,
    String? message,
    this.token,
  }) : super(success: success, message: message);
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

  Future<Map<String, dynamic>> _get(String endpoint) async {
    try {
      final url = Uri.parse("$API_URL$endpoint");
      final response = await http.get(url, headers: {
        'Authorization': authToken,
      }).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is Map<String, dynamic> ? data : {'success': false, 'message': 'Invalid response type'};
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<Map<String, dynamic>> _post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final url = Uri.parse("$API_URL$endpoint");
      final response = await http.post(url, headers: {
        'Authorization': authToken,
      }, body: body).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data is Map<String, dynamic> ? data : {'success': false, 'message': 'Invalid response type'};
      } else {
        return {'success': false, 'message': 'Server error: ${response.statusCode}'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: $e'};
    }
  }

  Future<DeviceInfoResponse> getDeviceInfo(String deviceId) async {
    final data = await _get("/api/device-info?iotId=$deviceId");
    return DeviceInfoResponse(
      success: data['success'] ?? false,
      message: data['message'],
      deviceInfo: (data['success'] == true) ? (data['deviceInfo'] ?? {}) : {},
    );
  }

  Future<IotStateResponse> getIotState(String deviceId) async {
    final data = await _get("/api/iot-state?deviceId=$deviceId");
    return IotStateResponse(
      success: data['success'] ?? false,
      message: data['message'],
      state: data['state'] == "1",
    );
  }

  Future<APIResponse> setIotState(String deviceId, bool state) async {
    final data = await _post("/api/iot-state", body: {
      'iotId': deviceId,
      'state': state ? "1" : "0",
    });
    return APIResponse(
      success: data['success'] ?? false,
      message: data['message'],
    );
  }

  Future<MeasurementsResponse> getMeasurements(MeasurementFrequency frequency) async {
    final data = await _get("/api/measurements?frequency=${frequency.name}");
    return MeasurementsResponse(
      success: data['success'] ?? false,
      message: data['message'],
      measurements: (data['success'] == true) ? (data['measurements'] ?? []) : [],
    );
  }

  Future<LoginResponse> login(String email, String password) async {
    final data = await _post("/api/login", body: {
      'email': email,
      'password': password,
    });
    if (data['success'] == true) {
      final token = data['userAuth'];
      await saveAuthToken(token);
      return LoginResponse(
        success: true,
        message: data['message'],
        token: token,
      );
    }
    return LoginResponse(success: false, message: data['message']);
  }

  Future<UserInfoResponse> getUserInfo() async {
    final data = await _get("/api/user-info");
    if (data['success'] == true) {
      final userInfo = data['userInfo'] ?? {};
      return UserInfoResponse(
        success: true,
        message: data['message'],
        userId: userInfo['userId'] ?? "",
        username: userInfo['username'] ?? "",
        email: userInfo['email'] ?? "",
        iotDevices: List<String>.from(userInfo['iotDevices'] ?? []),
      );
    }
    return UserInfoResponse(success: false, message: data['message']);
  }
}

final APIHandler apiHandler = APIHandler();

class FakeGlobalVariable {
  static bool connectedDevice = false;
}