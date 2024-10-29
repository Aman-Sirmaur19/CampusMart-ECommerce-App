class Product {
  Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.quantity,
  });

  late final String id;
  late final String title;
  late final String description;
  late final int price;
  late final int quantity;

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    title = json['title'].toString();
    description = json['description'].toString();
    price = json['price'];
    quantity = json['quantity'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['title'] = title;
    data['description'] = description;
    data['price'] = price;
    data['quantity'] = quantity;
    return data;
  }
}
