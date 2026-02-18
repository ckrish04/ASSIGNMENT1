class CartItem {
  final String productId;
  int quantity;

  CartItem({required this.productId, required this.quantity});

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      productId: json['product_id'],
      quantity: json['quantity'],
    );
  }
}

class Order {
  final String orderId;
  final String referenceId;
  final double orderTotal;
  final String orderTimestamp;
  final String status;
  final List<OrderItem> items;

  Order({
    required this.orderId,
    required this.referenceId,
    required this.orderTotal,
    required this.orderTimestamp,
    required this.status,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      orderId: json['order_id'],
      referenceId: json['reference_id'],
      orderTotal: (json['order_total'] as num).toDouble(),
      orderTimestamp: json['order_timestamp'],
      status: json['status'] ?? 'PLACED',
      items: (json['items'] as List)
          .map((i) => OrderItem.fromJson(i))
          .toList(),
    );
  }
}

class OrderItem {
  final String productId;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      productId: json['product_id'],
      quantity: json['quantity'],
      price: (json['price'] as num).toDouble(),
    );
  }
}
