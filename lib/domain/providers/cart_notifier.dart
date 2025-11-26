import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/product_model.dart';
import '../../data/models/cart_item_model.dart';

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItemModel>>((
  ref,
) {
  return CartNotifier();
});

class CartNotifier extends StateNotifier<List<CartItemModel>> {
  CartNotifier() : super([]);

  double get total => state.fold(
    0.0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );

  void addItem(ProductModel product, {int quantity = 1}) {
    // Lógica de adición al carrito y validación de stock
    final existingIndex = state.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingIndex != -1) {
      final updatedItem = state[existingIndex];
      final newQuantity = updatedItem.quantity + quantity;

      // Regla del Negocio: No exceder el stock
      if (newQuantity > product.stock) {
        // Podríamos mostrar un mensaje de error aquí
        return;
      }
      updatedItem.quantity = newQuantity;
      state = [...state];
    } else {
      state = [...state, CartItemModel(product: product, quantity: quantity)];
    }
  }

  void removeItem(int productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  void clearCart() {
    state = [];
  }
}
