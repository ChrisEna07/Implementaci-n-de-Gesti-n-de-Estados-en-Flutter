import 'package:flutter_riverpod/flutter_riverpod.dart';

// Modelo simple para un ítem del carrito
class CartItem {
  final int productId;
  final String name;
  final double price;
  int quantity;

  CartItem(
      {required this.productId,
      required this.name,
      required this.price,
      this.quantity = 1});
}

// Estado para la gestión de ventas (incluye el carrito)
class SaleState {
  final List<CartItem> cart;
  final double total;

  SaleState({required this.cart, required this.total});
}

final saleProvider = StateNotifierProvider<SaleNotifier, SaleState>((ref) {
  return SaleNotifier();
});

class SaleNotifier extends StateNotifier<SaleState> {
  SaleNotifier() : super(SaleState(cart: [], total: 0.0));

  void addItemToCart(int productId, String name, double price) {
    final existingItem = state.cart.firstWhere(
      (item) => item.productId == productId,
      orElse: () => CartItem(productId: 0, name: '', price: 0.0, quantity: 0),
    );

    if (existingItem.productId != 0) {
      // Si existe, incrementa la cantidad
      existingItem.quantity++;
    } else {
      // Si no existe, añade un nuevo ítem
      state.cart.add(CartItem(productId: productId, name: name, price: price));
    }
    _recalculateTotal();
  }

  void removeItemFromCart(int productId) {
    state.cart.removeWhere((item) => item.productId == productId);
    _recalculateTotal();
  }

  void _recalculateTotal() {
    final newTotal =
        state.cart.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
    state = SaleState(cart: state.cart, total: newTotal);
  }

  // HU_104: Registrar Venta (Simulación)
  Future<String> registerSale(String clientName) async {
    if (state.cart.isEmpty) {
      return 'Error: El carrito de ventas está vacío.';
    }

    await Future.delayed(const Duration(milliseconds: 500));

    final total = state.total;

    // Limpiar carrito después de la venta
    state = SaleState(cart: [], total: 0.0);

    return 'Venta registrada exitosamente para $clientName. Total: \$${total.toStringAsFixed(2)}. (HU_104)';
  }
}
