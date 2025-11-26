class CategoryModel {
  final int id;
  String name; // VARCHAR(50)
  String description; // TEXT
  bool isActive; // Estado Activo/Inactivo

  CategoryModel({
    required this.id,
    required this.name,
    this.description = '',
    this.isActive = true,
  });
}
