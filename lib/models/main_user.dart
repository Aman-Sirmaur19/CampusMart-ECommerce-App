class MainUser {
  MainUser({
    required this.id,
    required this.name,
    required this.email,
    required this.college,
    required this.createdAt,
    required this.isVerified,
  });

  late String? id;
  late String name;
  late String email;
  late String college;
  late String createdAt;
  late bool isVerified;

  MainUser.fromJson(Map<String, dynamic> json) {
    id = json['id'] ?? '';
    name = json['name'] ?? 'Unknown';
    email = json['email'] ?? '';
    college = json['college'] ?? '';
    createdAt = json['created_at'] ?? '';
    isVerified = json['isVerified'] ?? false;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['id'] = id;
    data['name'] = name;
    data['email'] = email;
    data['college'] = college;
    data['created_at'] = createdAt;
    data['isVerified'] = isVerified;
    return data;
  }
}
