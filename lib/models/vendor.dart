class Vendor {
  Vendor({
    required this.id,
    required this.createdAt,
    required this.pushToken,
    required this.college,
    required this.name,
    required this.shop,
    required this.phoneNumber,
    required this.email,
    required this.customers,
    required this.isVerified,
  });

  late String id;
  late String createdAt;
  late String pushToken;
  late String college;
  late String name;
  late String shop;
  late String phoneNumber;
  late String email;
  late List customers;
  late bool isVerified;

  Vendor.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    createdAt = json['created_at'] ?? '';
    pushToken = json['push_token'] ?? '';
    college = json['college'] ?? '';
    name = json['name'] ?? 'Unknown';
    shop = json['shop'] ?? '';
    phoneNumber = json['phone_number'] ?? '';
    email = json['email'] ?? '';
    customers = json['customers'] ?? [];
    isVerified = json['isVerified'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['push_token'] = pushToken;
    data['college'] = college;
    data['name'] = name;
    data['shop'] = shop;
    data['phone_number'] = phoneNumber;
    data['email'] = email;
    data['customers'] = customers;
    data['isVerified'] = isVerified;
    return data;
  }
}
