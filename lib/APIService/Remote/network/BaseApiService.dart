abstract class BaseApiService {

  // final String baseUrl = "https://bondingbackend.onrender.com/api/v1/";
  // final String baseUrl = "https://api.voicey.in/api/v1/";
  final String baseUrl = "https://staging-api.predict365.com/api/";

  final String baseUrlV2 = "";

  Future<dynamic> getResponse(String url);

  Future<dynamic> postResponse(String url, {Map<String, dynamic>? body});

  Future<dynamic> postResponseV2(String url, {Map<String, dynamic>? body});
}
