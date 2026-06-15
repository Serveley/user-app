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
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey),
                      SizedBox(width: 8),
                      Text(
                        'Search services or vendors...',
                        style: TextStyle(color: Colors.grey),
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
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const ServicesScreen()),
                      );
                    },
                    child: const Text('See All'),
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
                      childAspectRatio: 1,
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
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Popular Services',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Nearby Vendors',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
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
      'Home Services': Icons.home_repair_service,
      'Personal Care': Icons.spa,
      'Cleaning': Icons.cleaning_services,
      'Repairs': Icons.handyman,
      'Automotive': Icons.local_car_wash,
      'Beauty': Icons.face,
      'Wellness': Icons.self_improvement,
      'Other': Icons.more_horiz,
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
          color: Colors.indigo.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icons[category] ?? Icons.category,
              color: Colors.indigo,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              category,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceCard(dynamic service, BuildContext context) {
    final serviceIcons = {
      'plumbing': Icons.plumbing,
      'electrical': Icons.electrical_services,
      'carpentry': Icons.handyman,
      'painting': Icons.format_paint,
      'ac': Icons.ac_unit,
      'pest': Icons.pest_control,
      'cleaning': Icons.cleaning_services,
      'deep-clean': Icons.wash,
      'sofa': Icons.chair,
      'carpet': Icons.carpet,
      'shoe': Icons.directions_walk,
      'laundry': Icons.local_laundry_service,
      'window': Icons.window,
      'massage': Icons.spa,
      'hair': Icons.content_cut,
      'nail': Icons.touch_app,
      'makeup': Icons.face,
      'fitness': Icons.fitness_center,
      'yoga': Icons.self_improvement,
      'car-wash': Icons.local_car_wash,
      'detailing': Icons.auto_awesome,
      'mechanic': Icons.build,
      'tire': Icons.circle,
      'battery': Icons.battery_charging_full,
      'appliance': Icons.kitchen,
      'mobile': Icons.smartphone,
      'computer': Icons.computer,
      'tv': Icons.tv,
      'water': Icons.water_drop,
      'ac-repair': Icons.ac_unit,
      'spa': Icons.hot_tub,
      'facial': Icons.face_retouching_natural,
      'body': Icons.accessibility,
      'meditation': Icons.self_improvement,
      'moving': Icons.local_shipping,
      'garden': Icons.yard,
      'pet': Icons.pets,
      'event': Icons.celebration,
      'camera': Icons.camera_alt,
      'tutor': Icons.school,
      'driver': Icons.drive_eta,
    };

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.indigo.withOpacity(0.1),
          child: Icon(
            serviceIcons[service.icon] ?? Icons.design_services,
            color: Colors.indigo,
          ),
        ),
        title: Text(service.name),
        subtitle: Text(service.category, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Colors.green.withOpacity(0.1),
          child: const Icon(Icons.store, color: Colors.green),
        ),
        title: Text(vendor.businessName),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(vendor.address?['city'] ?? 'Location unavailable'),
            Row(
              children: [
                const Icon(Icons.star, size: 14, color: Colors.amber),
                Text(' ${vendor.rating.toStringAsFixed(1)} (${vendor.totalReviews})'),
              ],
            ),
          ],
        ),
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VendorDetailsScreen(vendorId: vendor.id),
              ),
            );
          },
          child: const Text('Book'),
        ),
      ),
    );
  }
}
