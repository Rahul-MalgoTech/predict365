// lib/Repository/OrderRepository.dart

import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:predict365/APIService/Remote/AppException.dart';
import 'package:predict365/APIService/Remote/network/NetworkApiService.dart';
import 'package:predict365/AuthStorage/authStorage.dart';
import 'package:predict365/Models/OrderModel.dart';

class OrderRepository {
  // Reuse baseUrl from NetworkApiService so it stays in sync with the rest of the app
  final String _baseUrl = NetworkApiService().baseUrl;

  Future<OrderResponse> placeOrder(OrderRequest request) async {
    final String? token = await AuthStorage.instance.getToken();

    final headers = {
      'Content-Type':  'application/json',
      'Accept':        'application/json',
      'Authorization': 'Bearer $token',
    };

    final body = json.encode(request.toJson());

    print('\n📤 POST /event/orders');
    print('📤 Body: $body');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/event/orders'),
        headers: headers,
        body: body,
      );

      print('📥 Status: ${response.statusCode}');
      print('📥 Body: ${response.body}');

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      return OrderResponse.fromJson(decoded);
    } on SocketException {
      throw FetchDataException('No Internet Connection');
    }
  }
}