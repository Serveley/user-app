import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/service_bloc.dart';
import '../blocs/vendor_bloc.dart';
import 'vendors_screen.dart';

class ServicesScreen extends StatefulWidget {
  const ServicesScreen({super.key});

  @override
  State<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends State<ServicesScreen> {
  String? _selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Services'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Category Filter
          BlocBuilder<ServiceBloc, ServiceState>(
            builder: (context, state) {
              if (state is ServicesLoaded) {
                return Container(
                  height: 60,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: state.categories.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: const Text('All'),
                            selected: _selectedCategory == null,
                            onSelected: (selected) {
                              setState(() => _selectedCategory = null);
                              context.read<ServiceBloc>().add(LoadServices());
                            },
                            selectedColor: Colors.indigo,
                            labelStyle: TextStyle(
                              color: _selectedCategory == null ? Colors.white : Colors.black,
                            ),
                          ),
                        );
                      }
                      final category = state.categories[index - 1];
                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(category),
                          selected: _selectedCategory == category,
                          onSelected: (selected) {
                            setState(() => _selectedCategory = selected ? category : null);
                            if (selected) {
                              context.read<ServiceBloc>().add(LoadServicesByCategory(category));
                            }
                          },
                          selectedColor: Colors.indigo,
                          labelStyle: TextStyle(
                            color: _selectedCategory == category ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    },
                  ),
                );
              }
              return const SizedBox();
            },
          ),

          // Services Grid
          Expanded(
            child: BlocBuilder<ServiceBloc, ServiceState>(
              builder: (context, state) {
                if (state is ServiceLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is ServicesLoaded) {
                  if (state.services.isEmpty) {
                    return const Center(
                      child: Text('No services available'),
                    );
                  }

                  return GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 0.85,
                    ),
                    itemCount: state.services.length,
                    itemBuilder: (context, index) {
                      final service = state.services[index];
                      return _buildServiceCard(service, context);
                    },
                  );
                }

                if (state is ServiceError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ServiceBloc>().add(LoadServices());
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
        ],
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

    return GestureDetector(
      onTap: () {
        context.read<VendorBloc>().add(LoadVendors(serviceId: service.id));
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VendorsScreen(
              serviceId: service.id,
              serviceName: service.name,
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.indigo.withOpacity(0.1),
                Colors.purple.withOpacity(0.1),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    serviceIcons[service.icon] ?? Icons.design_services,
                    size: 40,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  service.name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.indigo.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    service.category,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.indigo,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
