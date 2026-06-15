class VendorService {
  final String serviceId;
  final String name;
  final bool enabled;
  final double? price;

  VendorService({
    required this.serviceId,
    required this.name,
    required this.enabled,
    this.price,
  });

  factory VendorService.fromJson(Map<String, dynamic> json) {
    return VendorService(
      serviceId: json['service']?['_id'] ?? json['service'] ?? '',
      name: json['service']?['name'] ?? 'Unknown Service',
      enabled: json['enabled'] ?? false,
      price: json['price']?.toDouble(),
    );
  }
}

class Vendor {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String businessName;
  final Map<String, dynamic>? address;
  final List<double>? coordinates;
  final List<VendorService> services;
  final bool isActive;
  final double rating;
  final int totalReviews;

  Vendor({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.businessName,
    this.address,
    this.coordinates,
    required this.services,
    required this.isActive,
    this.rating = 0,
    this.totalReviews = 0,
  });

  factory Vendor.fromJson(Map<String, dynamic> json) {
    List<VendorService> services = [];
    if (json['services'] != null) {
      services = (json['services'] as List)
          .map((s) => VendorService.fromJson(s))
          .toList();
    }

    List<double>? coords;
    if (json['location']?['coordinates'] != null) {
      coords = (json['location']['coordinates'] as List)
          .map((c) => (c as num).toDouble())
          .toList();
    }

    return Vendor(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      businessName: json['businessName'] ?? '',
      address: json['address'],
      coordinates: coords,
      services: services,
      isActive: json['isActive'] ?? true,
      rating: (json['rating'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
    );
  }

  String get fullAddress {
    if (address == null) return 'Address not available';
    final parts = [
      address!['street'],
      address!['city'],
      address!['state'],
      address!['zipCode'],
    ].where((p) => p != null && p.toString().isNotEmpty).toList();
    return parts.isEmpty ? 'Address not available' : parts.join(', ');
  }
}
