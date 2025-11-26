class PurchaseItemModel {
  final String itemName;
  final int quantity;
  final double unitCost;

  PurchaseItemModel({
    required this.itemName,
    required this.quantity,
    required this.unitCost,
  });

  double get total => quantity * unitCost;
}

class PurchaseModel {
  final int id;
  final int proveedorId;
  final DateTime date;
  final List<PurchaseItemModel> items;
  final bool isCompleted;

  PurchaseModel({
    required this.id,
    required this.proveedorId,
    required this.date,
    required this.items,
    this.isCompleted = false,
  });

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.total);

  PurchaseModel copyWith({
    int? id,
    int? proveedorId,
    DateTime? date,
    List<PurchaseItemModel>? items,
    bool? isCompleted,
  }) {
    return PurchaseModel(
      id: id ?? this.id,
      proveedorId: proveedorId ?? this.proveedorId,
      date: date ?? this.date,
      items: items ?? this.items,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
