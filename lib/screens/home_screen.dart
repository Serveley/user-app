import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/service_bloc.dart';
import '../blocs/vendor_bloc.dart';
import '../services/location_service.dart';
import 'services_screen.dart';
import 'vendors_screen.dart';
import 'vendor_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _locationText = 'Getting location...';

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      final address = await LocationService.getAddressFromPosition(position);
      setState(() {
        _locationText = address ?? '${position.latitude.toStringAsFixed(2)}, ${position.longitude.toStringAsFixed(2)}';
      });
    } else {
      setState(() {
        _locationText = 'Location unavailable';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.location_on, color: Colors.indigo),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _locationText,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.indigo,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Good Morning! 👋',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'What service do you need today?',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Search Bar
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const VendorsScreen()),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                    border: Border.all(color: Colors.grey.shade100),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search_rounded, color: Colors.indigo),
                      SizedBox(width: 12),
                      Text(
                        'Search services or vendors...',
                        style: TextStyle(color: Colors.grey, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Categories Section
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Categories',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ServicesScreen()),
                      );
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.indigo,
                    ),
                    child: const Text('See All', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),

          // Categories Grid
          BlocBuilder<ServiceBloc, ServiceState>(
            builder: (context, state) {
              if (state is ServicesLoaded) {
                final categories = state.categories.take(6).toList();
                return SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.05,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final category = categories[index];
                        return _buildCategoryCard(category, context);
                      },
                      childCount: categories.length,
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              );
            },
          ),

          // Popular Services Section
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 16.0),
              child: Text(
                'Popular Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          // Popular Services List
          BlocBuilder<ServiceBloc, ServiceState>(
            builder: (context, state) {
              if (state is ServicesLoaded) {
                final services = state.services.take(6).toList();
                return SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final service = services[index];
                        return _buildServiceCard(service, context);
                      },
                      childCount: services.length,
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox());
            },
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),

          // Nearby Vendors Section
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Nearby Vendors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),

          // Load Nearby Vendors
          SliverToBoxAdapter(
            child: FutureBuilder(
              future: LocationService.getCurrentPosition(),
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final position = snapshot.data!;
                  context.read<VendorBloc>().add(LoadVendors(
                    lat: position.latitude,
                    lng: position.longitude,
                  ));
                }
                return BlocBuilder<VendorBloc, VendorState>(
                  builder: (context, state) {
                    if (state is VendorsLoaded) {
                      final vendors = state.vendors.take(3).toList();
                      return Column(
                        children: vendors.map((vendor) => _buildVendorCard(vendor, context)).toList(),
                      );
                    } else if (state is VendorLoading) {
                      return const Center(child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ));
                    }
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('Enable location to see nearby vendors'),
                    );
                  },
                );
              },
            ),
          ),

          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(String category, BuildContext context) {
    final icons = {
      'Home Services': Icons.home_repair_service_rounded,
      'Personal Care': Icons.spa_rounded,
      'Cleaning': Icons.cleaning_services_rounded,
      'Repairs': Icons.handyman_rounded,
      'Automotive': Icons.local_car_wash_rounded,
      'Beauty': Icons.face_rounded,
      'Wellness': Icons.self_improvement_rounded,
      'Other': Icons.more_horiz_rounded,
    };

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const ServicesScreen(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.indigo.withOpacity(0.06),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.indigo.withOpacity(0.03)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icons[category] ?? Icons.category_rounded,
              color: Colors.indigo,
              size: 28,
            ),
            const SizedBox(height: 8),
            Text(
              category,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(dynamic service, BuildContext context) {
    final serviceIcons = {
      'plumbing': Icons.plumbing_rounded,
      'electrical': Icons.electrical_services_rounded,
      'carpentry': Icons.handyman_rounded,
      'painting': Icons.format_paint_rounded,
      'ac': Icons.ac_unit_rounded,
      'pest': Icons.pest_control_rounded,
      'cleaning': Icons.cleaning_services_rounded,
      'deep-clean': Icons.wash_rounded,
      'sofa': Icons.chair_rounded,
      'carpet': Icons.border_outer_rounded,
      'shoe': Icons.directions_walk_rounded,
      'laundry': Icons.local_laundry_service_rounded,
      'window': Icons.window_rounded,
      'massage': Icons.spa_rounded,
      'hair': Icons.content_cut_rounded,
      'nail': Icons.fingerprint_rounded,
      'makeup': Icons.face_rounded,
      'fitness': Icons.fitness_center_rounded,
      'yoga': Icons.self_improvement_rounded,
      'car-wash': Icons.local_car_wash_rounded,
      'detailing': Icons.auto_awesome_rounded,
      'mechanic': Icons.build_rounded,
      'tire': Icons.circle_outlined,
      'battery': Icons.battery_charging_full_rounded,
      'appliance': Icons.kitchen_rounded,
      'mobile': Icons.smartphone_rounded,
      'computer': Icons.computer_rounded,
      'tv': Icons.tv_rounded,
      'water': Icons.water_drop_rounded,
      'ac-repair': Icons.ac_unit_rounded,
      'spa': Icons.hot_tub_rounded,
      'facial': Icons.face_retouching_natural_rounded,
      'body': Icons.accessibility_rounded,
      'meditation': Icons.self_improvement_rounded,
      'moving': Icons.local_shipping_rounded,
      'garden': Icons.yard_rounded,
      'pet': Icons.pets_rounded,
      'event': Icons.celebration_rounded,
      'camera': Icons.camera_alt_rounded,
      'tutor': Icons.school_rounded,
      'driver': Icons.drive_eta_rounded,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.indigo.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            serviceIcons[service.icon] ?? Icons.design_services_rounded,
            color: Colors.indigo,
            size: 24,
          ),
        ),
        title: Text(
          service.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          service.category,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
        ),
        trailing: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.grey),
        ),
        onTap: () {
          context.read<VendorBloc>().add(LoadVendors(serviceId: service.id));
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VendorsScreen(serviceId: service.id, serviceName: service.name),
            ),
          );
        },
      ),
    );
  }

  Widget _buildVendorCard(dynamic vendor, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.storefront_rounded, color: Colors.green, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vendor.businessName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    vendor.address?['city'] ?? 'Location unavailable',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, size: 18, color: Colors.amber),
                      Text(
                        ' ${vendor.rating.toStringAsFixed(1)} ',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                      ),
                      Text(
                        '(${vendor.totalReviews})',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VendorDetailsScreen(vendorId: vendor.id),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              child: const Text('Book', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
