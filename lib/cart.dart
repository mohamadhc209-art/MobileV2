class CartItem {
  final int id;
  final String name;
  final double price;
  final String image;
  int qty;

  CartItem({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.qty,
  });
}

class Cart {
  static final List<CartItem> items = [];

  static void addItem(CartItem item) {
    final index = items.indexWhere((e) => e.id == item.id);

    if (index != -1) {
      items[index].qty += item.qty;
    } else {
      items.add(item);
    }
  }

 
  static void removeItem(int index) {
    if (index >= 0 && index < items.length) {
      items.removeAt(index);
    }
  }

  static void clear() {
    items.clear();
  }


  static double get total {
    double sum = 0;
    for (var item in items) {
      sum += item.price * item.qty;
    }
    return sum;
  }
}
