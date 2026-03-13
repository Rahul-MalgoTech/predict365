import 'dart:convert';
import 'dart:io';
import 'package:predict365/APIService/Remote/AppException.dart';
import 'package:predict365/APIService/Remote/network/BaseApiService.dart' show BaseApiService;
import 'package:http/http.dart' as http;
import 'package:predict365/AuthStorage/authStorage.dart';

class NetworkApiService extends BaseApiService {

  @override
  Future<Map<String, dynamic>> getResponse(String url) async {
    final String? token = await AuthStorage.instance.getToken();
    final headers = {
      "Authorization": "Bearer $token",
      "Accept": "application/json",
    };
    try {
      final response = await http.get(
        Uri.parse(baseUrl + url),
        headers: headers,
      );
      print("GET ${baseUrl + url} → ${response.statusCode}");
      return _decodeResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
  }

  /// Decodes an http.Response into Map<String, dynamic>.
  /// Handles double-encoded JSON (server wraps values as strings).
  Map<String, dynamic> _decodeResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        dynamic decoded = jsonDecode(response.body);
        // If top level is a String (fully double-encoded), decode again
        if (decoded is String) {
          decoded = jsonDecode(decoded);
        }
        if (decoded is Map) {
          return _deepConvert(decoded) as Map<String, dynamic>;
        }
        throw FetchDataException('Unexpected response format');
      case 400:
        throw BadRequestException(response.body);
      case 401:
      case 403:
        throw UnauthorisedException(response.body);
      case 404:
        throw UnauthorisedException(response.body);
      default:
        throw FetchDataException(
            'Error with server. Status: ${response.statusCode}');
    }
  }

  /// Recursively converts all nested Maps and Lists so every Map becomes
  /// Map<String, dynamic> and every String that looks like JSON is decoded.
  dynamic _deepConvert(dynamic value) {
    if (value is Map) {
      return Map<String, dynamic>.fromEntries(
          value.entries.map((e) => MapEntry(e.key.toString(), _deepConvert(e.value)))
      );
    }
    if (value is List) {
      return value.map(_deepConvert).toList();
    }
    // If a leaf value is a JSON string, decode it recursively
    if (value is String) {
      final trimmed = value.trim();
      if ((trimmed.startsWith('{') && trimmed.endsWith('}')) ||
          (trimmed.startsWith('[') && trimmed.endsWith(']'))) {
        try {
          return _deepConvert(jsonDecode(trimmed));
        } catch (_) {}
      }
    }
    return value;
  }

  Future getResponseV3(String url) async {
    dynamic responseJson;
    try {
      final response = await http.get(Uri.parse(url));
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  Future<Map<String, dynamic>> getResponseV2(
      String endpoint, {
        Map<String, String>? queryParams,
      }) async {
    final uri = Uri.parse(baseUrl + endpoint)
        .replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer ',
      'Accept': 'application/json',
    });
    if (response.statusCode == 200) {
      return json.decode(response.body) as Map<String, dynamic>;
    }
    throw Exception("HTTP ${response.statusCode}: ${response.body}");
  }

  Future<Map<String, dynamic>> uploadImageMultipart({
    required String endpoint,
    required File imageFile,
    String fieldName = 'image',
    String? token,
    Map<String, String>? additionalFields,
  }) async {
    final uri = Uri.parse(baseUrl + endpoint);
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });
    final multipartFile = await http.MultipartFile.fromPath(
      fieldName, imageFile.path,
      filename: imageFile.path.split(Platform.pathSeparator).last,
    );
    request.files.add(multipartFile);
    if (additionalFields != null) request.fields.addAll(additionalFields);
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print('Upload ${response.statusCode}: ${response.body}');
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      throw Exception("Upload failed - HTTP ${response.statusCode}: ${response.body}");
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
  }

  Future<Map<String, dynamic>> getResponseV4(
      String endpoint, {
        Map<String, String>? queryParams,
      }) async {
    final uri = Uri.parse(baseUrl + endpoint)
        .replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ',
    });
    if (response.statusCode == 200) {
      dynamic decoded = json.decode(response.body);
      if (decoded is String) decoded = json.decode(decoded);
      return decoded as Map<String, dynamic>;
    }
    throw Exception("HTTP ${response.statusCode}: ${response.body}");
  }

  Future<String> rawGetResponse(String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    final uri = Uri.parse(baseUrl + endpoint)
        .replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: {
      'Authorization': 'Bearer ',
      'Accept': 'application/json',
    });
    if (response.statusCode == 200) return response.body;
    throw Exception("HTTP ${response.statusCode}: ${response.body}");
  }

  @override
  Future<Map<String, dynamic>> putResponse(String url, {
    required Map<String, dynamic> body,
  }) async {
    final String? token = await AuthStorage.instance.getToken();
    final response = await http.put(
      Uri.parse(baseUrl + url),
      headers: {
        "Content-Type":  "application/json",
        "Accept":        "application/json",
        "Authorization": "Bearer $token",
      },
      body: json.encode(body),
    );
    print("PUT ${baseUrl + url} → ${response.statusCode}: ${response.body}");
    return json.decode(response.body) as Map<String, dynamic>;
  }

  @override
  Future postResponse(String url, {Map<String, dynamic>? body}) async {
    final String? token = await AuthStorage.instance.getToken();

    dynamic responseJson;
    var data = json.encode(body);
    var headers = {
      "Authorization": "Bearer $token",
      "content-type": "application/json",
      "Accept": "application/json",
    };
    try {
      await http.post(Uri.parse(baseUrl + url), headers: headers, body: data)
          .then((value) {
        responseJson = jsonDecode(value.body);
        print("POST ${baseUrl + url} → $responseJson");
      });
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  Future<dynamic> postResponseV2(String url, {Map<String, dynamic>? body}) async {
    dynamic responseJson;
    final data = json.encode(body);
    final headers = {
      "Authorization": "Bearer ",
      "content-type": "application/json",
      "Accept": "application/json",
    };
    try {
      await http.post(Uri.parse(baseUrl + url), headers: headers, body: data)
          .then((response) {
        try {
          responseJson = jsonDecode(response.body);
        } catch (e) {
          responseJson = response.body;
        }
        print("POST V2 ${baseUrl + url} → ${response.statusCode}");
      });
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  Future<dynamic> postResponseV3(String url, {Map<String, dynamic>? body}) async {
    return postResponseV2(url, body: body);
  }

  Future<Map<String, dynamic>> multipartProcedure(
      String url,
      List<http.MultipartFile> files, {
        Map<String, String>? fields,
        String? token,
      }) async {
    final uri = Uri.parse(baseUrl + url);
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });
    request.files.addAll(files);
    if (fields != null) request.fields.addAll(fields);
    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      print("Upload ${streamedResponse.statusCode}: ${response.body}");
      if (streamedResponse.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      throw Exception("Server error: ${streamedResponse.statusCode} - ${response.body}");
    } catch (e) {
      throw Exception("Upload failed: $e");
    }
  }

  Future getResponseFirebase(String url) async {
    dynamic responseJson;
    try {
      final response = await http.get(
        Uri.parse("https://fibitpro-2bcc3-default-rtdb.firebaseio.com/"),
      );
      responseJson = returnResponse(response);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
    return responseJson;
  }

  // Legacy — kept for backward compatibility
  dynamic returnResponse(http.Response response) {
    switch (response.statusCode) {
      case 200:
        return jsonDecode(response.body);
      case 400:
        throw BadRequestException(response.toString());
      case 401:
      case 403:
        throw UnauthorisedException(response.body.toString());
      case 404:
        throw UnauthorisedException(response.body.toString());
      default:
        throw FetchDataException(
            'Error occured while communication with server'
                ' with status code : ${response.statusCode}');
    }
  }
}