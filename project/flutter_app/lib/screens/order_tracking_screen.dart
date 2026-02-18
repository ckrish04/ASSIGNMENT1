import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  final String referenceId;
  const OrderTrackingScreen(
      {super.key, required this.orderId, required this.referenceId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  String _status = 'PLACED';
  bool _isLoading = true;

  final _statuses = ['PLACED', 'PACKED', 'OUT_FOR_DELIVERY', 'DELIVERED'];
  final _icons = [
    Icons.receipt_long,
    Icons.inventory_2,
    Icons.local_shipping,
    Icons.check_circle,
  ];
  final _labels = [
    'Order Placed',
    'Packed',
    'Out for Delivery',
    'Delivered',
  ];

  @override
  void initState() {
    super.initState();
    _fetchStatus();
  }

  Future<void> _fetchStatus() async {
    try {
      final api = context.read<AuthProvider>().api;
      final data = await api.getDeliveryStatus(widget.orderId);
      setState(() {
        _status = data['current_status'];
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _statuses.indexOf(_status);

    return Scaffold(
      appBar: AppBar(title: const Text('Order Tracking')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Order ${widget.referenceId}',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 32),
                  ...List.generate(_statuses.length, (i) {
                    final isCompleted = i <= currentIndex;
                    final isActive = i == currentIndex;
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isCompleted
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[300],
                              ),
                              child: Icon(_icons[i],
                                  size: 20,
                                  color: isCompleted
                                      ? Colors.white
                                      : Colors.grey),
                            ),
                            if (i < _statuses.length - 1)
                              Container(
                                width: 3,
                                height: 40,
                                color: isCompleted
                                    ? Theme.of(context).colorScheme.primary
                                    : Colors.grey[300],
                              ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              _labels[i],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight:
                                    isActive ? FontWeight.bold : FontWeight.normal,
                                color: isCompleted ? null : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                  const Spacer(),
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _fetchStatus,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Refresh Status'),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/home'),
                      child: const Text('Back to Home'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
