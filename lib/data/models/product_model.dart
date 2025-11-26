class ProductModel {
  final int id;
  final String name;
  final double price; // DECIMAL(10,2)
  final int stock;
  final String category;
  final bool isAvailable; // Estado de disponibilidad

  ProductModel({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
    required this.category,
    this.isAvailable = true,
  });
}
