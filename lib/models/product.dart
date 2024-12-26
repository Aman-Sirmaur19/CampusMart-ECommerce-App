class Product {
  Product({
    required this.id,
    required this.seller_id,
    required this.title,
    required this.description,
    this.price = 0,
    required this.quantity,
    this.days = 0,
  });

  late final String id;
  late final String seller_id;
  late final String title;
  late final String description;
  late final int price;
  late final int quantity;
  late final int days;

  Product.fromJson(Map<String, dynamic> json) {
    id = json['id'].toString();
    seller_id = json['seller_id'].toString();
    title = json['title'].toString();
    description = json['description'].toString();
    price = json['price'];
    quantity = json['quantity'];
    days = json['days'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['seller_id'] = seller_id;
    data['title'] = title;
    data['description'] = description;
    data['price'] = price;
    data['quantity'] = quantity;
    data['days'] = days;
    return data;
  }
}
