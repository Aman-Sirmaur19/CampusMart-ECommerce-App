class MainUser {
  MainUser({
    required this.id,
    required this.pushToken,
    required this.name,
    required this.email,
    required this.college,
    required this.createdAt,
    required this.customers,
    required this.isVerified,
  });

  late String id;
  late String pushToken;
  late String name;
  late String email;
  late String college;
  late String createdAt;
  late List customers;
  late bool isVerified;

  MainUser.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    pushToken = json['push_token'] ?? '';
    name = json['name'] ?? 'Unknown';
    email = json['email'] ?? '';
    college = json['college'] ?? '';
    createdAt = json['created_at'] ?? '';
    customers = json['customers'] ?? '';
    isVerified = json['isVerified'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['push_token'] = pushToken;
    data['name'] = name;
    data['email'] = email;
    data['college'] = college;
    data['created_at'] = createdAt;
    data['customers'] = customers;
    data['isVerified'] = isVerified;
    return data;
  }
}
