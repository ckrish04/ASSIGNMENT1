import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import 'order_confirmation_screen.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Cart')),
      body: cart.items.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.shopping_cart_outlined,
                      size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Your cart is empty',
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: cart.items.length,
              padding: const EdgeInsets.all(12),
              itemBuilder: (context, index) {
                final productId = cart.items.keys.elementAt(index);
                final quantity = cart.items[productId]!;
                final product = cart.products[productId];

                return Card(
                  child: ListTile(
                    leading: product != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(product.imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.image)),
                          )
                        : null,
                    title: Text(product?.name ?? productId,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: product != null
                        ? Text(
                            '₹${product.price.toStringAsFixed(0)} × $quantity = ₹${(product.price * quantity).toStringAsFixed(0)}')
                        : Text('Qty: $quantity'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline),
                          onPressed: () => cart.decrementItem(productId),
                        ),
                        Text('$quantity',
                            style:
                                const TextStyle(fontWeight: FontWeight.bold)),
                        IconButton(
                          icon: const Icon(Icons.add_circle_outline),
                          onPressed: () {
                            if (product != null) cart.addItem(product);
                          },
                        ),
                        IconButton(
                          icon:
                              const Icon(Icons.delete_outline, color: Colors.red),
                          onPressed: () => cart.removeItem(productId),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: cart.items.isEmpty
          ? null
          : Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.1), blurRadius: 10)
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total',
                            style: TextStyle(color: Colors.grey)),
                        Text('₹${cart.total.toStringAsFixed(0)}',
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  FilledButton(
                    onPressed: () => _placeOrder(context),
                    child: const Text('Place Order'),
                  ),
                ],
              ),
            ),
    );
  }

  Future<void> _placeOrder(BuildContext context) async {
    try {
      final api = context.read<AuthProvider>().api;
      // Sync cart to backend first
      final cart = context.read<CartProvider>();
      for (final entry in cart.items.entries) {
        await api.addToCart(entry.key, entry.value);
      }
      final order = await api.createOrder();
      cart.clear();
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => OrderConfirmationScreen(order: order),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Order failed: $e')),
        );
      }
    }
  }
}
