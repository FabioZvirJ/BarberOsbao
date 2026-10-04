class Branch {
  final String id;
  final String name;
  final String slug;
  final String address;
  final String? neighborhood;
  final String city;
  final String state;
  final String? phone;
  final String? avatarUrl;
  final bool active;
  final int employeesCount;
  final int servicesCount;

  const Branch({
    required this.id,
    required this.name,
    required this.slug,
    required this.address,
    this.neighborhood,
    this.city = 'Mallet',
    this.state = 'PR',
    this.phone,
    this.avatarUrl,
    this.active = true,
    this.employeesCount = 0,
    this.servicesCount = 0,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    final count = json['_count'] as Map<String, dynamic>?;
    return Branch(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      neighborhood: json['neighborhood']?.toString(),
      city: json['city']?.toString() ?? 'Mallet',
      state: json['state']?.toString() ?? 'PR',
      phone: json['phone']?.toString(),
      avatarUrl: json['avatarUrl']?.toString(),
      active: json['active'] == true,
      employeesCount: count?['employees'] as int? ?? 0,
      servicesCount: count?['services'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'slug': slug,
    'address': address,
    'neighborhood': neighborhood,
    'city': city,
    'state': state,
    'phone': phone,
    'avatarUrl': avatarUrl,
    'active': active,
  };

  String get fullAddress {
    final parts = [address];
    if (neighborhood != null && neighborhood!.isNotEmpty) parts.add(neighborhood!);
    parts.add('$city - $state');
    return parts.join(', ');
  }
}

