class Service {
  final String id;
  final String name;
  final String description;
  final String category;
  final String icon;
  final bool isActive;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.icon,
    required this.isActive,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? 'Other',
      icon: json['icon'] ?? 'service',
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'category': category,
      'icon': icon,
      'isActive': isActive,
    };
  }
}
