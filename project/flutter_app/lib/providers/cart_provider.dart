import 'package:flutter/material.dart';
import '../models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<String, int> _items = {};
  final Map<String, Product> _products = {};

  Map<String, int> get items => _items;
  Map<String, Product> get products => _products;
  int get itemCount => _items.values.fold(0, (sum, q) => sum + q);

  double get total => _items.entries.fold(0.0, (sum, entry) {
        final product = _products[entry.key];
        if (product != null) return sum + product.price * entry.value;
        return sum;
      });

  void addItem(Product product) {
    _products[product.productId] = product;
    _items[product.productId] = (_items[product.productId] ?? 0) + 1;
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    _products.remove(productId);
    notifyListeners();
  }

  void decrementItem(String productId) {
    if (_items.containsKey(productId)) {
      if (_items[productId]! > 1) {
        _items[productId] = _items[productId]! - 1;
      } else {
        removeItem(productId);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    _products.clear();
    notifyListeners();
  }
}
