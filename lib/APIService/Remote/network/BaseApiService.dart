abstract class BaseApiService {

  // final String baseUrl = "https://bondingbackend.onrender.com/api/v1/";
  // final String baseUrl = "https://api.voicey.in/api/v1/";
  final String baseUrl = "http://192.168.0.22:7000/api/v1/";

  final String baseUrlV2 = "";

  Future<dynamic> getResponse(String url);

  Future<dynamic> postResponse(String url, {Map<String, dynamic>? body});

  Future<dynamic> postResponseV2(String url, {Map<String, dynamic>? body});
}
