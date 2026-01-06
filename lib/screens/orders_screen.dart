import 'package:flutter/material.dart';
import '../api/order_service.dart';
import '../screens/dish_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  final OrderService _orderService = OrderService();

  bool _isLoading = true;
  bool _hasError = false;
  List<Map<String, dynamic>> _orders = [];

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

  Future<void> _loadOrders() async {
    try {
      final result =
          await _orderService.getOrders(userId: "user-1");

      if (!mounted) return;

      setState(() {
        _orders = result;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mon historique de commandes"),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_hasError) {
      return const Center(
        child: Text("Erreur lors du chargement des commandes."),
      );
    }

    if (_orders.isEmpty) {
      return const Center(
        child: Text("Aucune commande pour le moment."),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: _orders.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final order = _orders[index];

        return Card(
          elevation: 2,
          child: ListTile(
            leading: const Icon(Icons.receipt_long),
            title: Text("Commande #${order['id']}"),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Plat : ${order['recipeId']}"),
                Text("Statut : ${order['status']}"),
                if (order['feedback'] != null)
                  Text(
                    "Feedback : ${order['feedback'] == true ? '👍' : '👎'}",
                  ),
              ],
            ),
            trailing: const Icon(Icons.chevron_right),

            // ✅ NAVIGATION VERS LE DÉTAIL
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DishDetailScreen(
                    recipeId: order['recipeId'],
                    fromOrder: true,
                    existingFeedback: order['feedback'],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
