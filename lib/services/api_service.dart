import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/service.dart';
import '../models/vendor.dart';

class ApiService {
  // Change this to your backend URL
  static const String baseUrl = 'http://10.0.2.2:5000/api';
  // For physical device use your computer's IP
  // static const String baseUrl = 'http://192.168.1.100:5000/api';

  static Future<List<Service>> getServices() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/services'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['services'] as List)
              .map((s) => Service.fromJson(s))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching services: $e');
      return [];
    }
  }

  static Future<List<Service>> getServicesByCategory(String category) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/user/services/category/$category'),
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['services'] as List)
              .map((s) => Service.fromJson(s))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching services by category: $e');
      return [];
    }
  }

  static Future<List<String>> getCategories() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/categories'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['categories'] as List).map((c) => c.toString()).toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching categories: $e');
      return [];
    }
  }

  static Future<List<Vendor>> getVendors({
    String? serviceId,
    double? lat,
    double? lng,
    double radius = 10000,
  }) async {
    try {
      String url = '$baseUrl/user/vendors?';
      if (serviceId != null) url += 'serviceId=$serviceId&';
      if (lat != null) url += 'lat=$lat&';
      if (lng != null) url += 'lng=$lng&';
      url += 'radius=$radius';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['vendors'] as List)
              .map((v) => Vendor.fromJson(v))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error fetching vendors: $e');
      return [];
    }
  }

  static Future<Vendor?> getVendorById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/user/vendors/$id'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return Vendor.fromJson(data['vendor']);
        }
      }
      return null;
    } catch (e) {
      print('Error fetching vendor: $e');
      return null;
    }
  }

  static Future<List<Vendor>> searchVendors({
    String? query,
    String? serviceId,
    double? lat,
    double? lng,
    double radius = 15000,
  }) async {
    try {
      String url = '$baseUrl/user/search?';
      if (query != null) url += 'query=$query&';
      if (serviceId != null) url += 'serviceId=$serviceId&';
      if (lat != null) url += 'lat=$lat&';
      if (lng != null) url += 'lng=$lng&';
      url += 'radius=$radius';

      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          return (data['vendors'] as List)
              .map((v) => Vendor.fromJson(v))
              .toList();
        }
      }
      return [];
    } catch (e) {
      print('Error searching vendors: $e');
      return [];
    }
  }
}
