import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class ApiService {
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        if (_token != null) 'Authorization': 'Bearer $_token',
      };

  // ─── AUTH ─────────────────────────────────────

  Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.userService}/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );
    if (res.statusCode == 201) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Registration failed');
  }

  Future<Map<String, dynamic>> login(
      String email, String password, String otp) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.userService}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password, 'otp': otp}),
    );
    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      _token = data['access_token'];
      return data;
    }
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Login failed');
  }

  Future<Map<String, dynamic>> getProfile() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.userService}/profile'),
      headers: _headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to get profile');
  }

  // ─── PRODUCTS ─────────────────────────────────

  Future<List<dynamic>> getProducts({String? category}) async {
    String url = '${ApiConfig.productService}/products';
    if (category != null) url += '?category=$category';
    final res = await http.get(Uri.parse(url));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load products');
  }

  Future<Map<String, dynamic>> getProduct(String id) async {
    final res =
        await http.get(Uri.parse('${ApiConfig.productService}/products/$id'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Product not found');
  }

  Future<List<dynamic>> getCategories() async {
    final res =
        await http.get(Uri.parse('${ApiConfig.productService}/categories'));
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load categories');
  }

  // ─── CART ─────────────────────────────────────

  Future<void> addToCart(String productId, int quantity) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.cartOrderService}/cart/add'),
      headers: _headers,
      body: jsonEncode({'product_id': productId, 'quantity': quantity}),
    );
    if (res.statusCode != 200) throw Exception('Failed to add to cart');
  }

  Future<void> removeFromCart(String productId) async {
    final res = await http.post(
      Uri.parse('${ApiConfig.cartOrderService}/cart/remove'),
      headers: _headers,
      body: jsonEncode({'product_id': productId}),
    );
    if (res.statusCode != 200) throw Exception('Failed to remove from cart');
  }

  Future<Map<String, dynamic>> getCart() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.cartOrderService}/cart'),
      headers: _headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load cart');
  }

  // ─── ORDERS ───────────────────────────────────

  Future<Map<String, dynamic>> createOrder() async {
    final res = await http.post(
      Uri.parse('${ApiConfig.cartOrderService}/order/create'),
      headers: _headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception(jsonDecode(res.body)['detail'] ?? 'Failed to create order');
  }

  Future<List<dynamic>> getOrders() async {
    final res = await http.get(
      Uri.parse('${ApiConfig.cartOrderService}/orders'),
      headers: _headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to load orders');
  }

  // ─── DELIVERY ─────────────────────────────────

  Future<Map<String, dynamic>> getDeliveryStatus(String orderId) async {
    final res = await http.get(
      Uri.parse('${ApiConfig.deliveryService}/order/$orderId/status'),
      headers: _headers,
    );
    if (res.statusCode == 200) return jsonDecode(res.body);
    throw Exception('Failed to get delivery status');
  }
}
