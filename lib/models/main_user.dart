import '../helper/constants.dart';

class MainUser {
  MainUser({
    required this.id,
    required this.createdAt,
    required this.pushToken,
    required this.college,
    required this.name,
    required this.year,
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
  late String year;
  late String phoneNumber;
  late String email;
  late List customers;
  late bool isVerified;
  String userType = UserType.others.toString();
  Map<String, List<String>> cart = {};

  MainUser.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    createdAt = json['created_at'] ?? '';
    pushToken = json['push_token'] ?? '';
    college = json['college'] ?? '';
    name = json['name'] ?? 'Unknown';
    year = json['year'] ?? '';
    phoneNumber = json['phone_number'] ?? '';
    email = json['email'] ?? '';
    customers = json['customers'] ?? [];
    isVerified = json['isVerified'] ?? false;
    userType = json['user_type'] ?? UserType.others.toString();

    if (json['cart'] is Map) {
      cart = (json['cart'] as Map).map<String, List<String>>(
        (key, value) => MapEntry(
          key as String,
          (value as List).map((item) => item.toString()).toList(),
        ),
      );
    } else {
      cart = {};
    }
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['created_at'] = createdAt;
    data['push_token'] = pushToken;
    data['college'] = college;
    data['name'] = name;
    data['year'] = year;
    data['phone_number'] = phoneNumber;
    data['email'] = email;
    data['customers'] = customers;
    data['isVerified'] = isVerified;
    data['user_type'] = userType;
    data['cart'] = cart;
    return data;
  }
}
