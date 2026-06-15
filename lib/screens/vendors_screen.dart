import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/vendor_bloc.dart';
import '../services/location_service.dart';
import 'vendor_details_screen.dart';

class VendorsScreen extends StatefulWidget {
  final String? serviceId;
  final String? serviceName;

  const VendorsScreen({super.key, this.serviceId, this.serviceName});

  @override
  State<VendorsScreen> createState() => _VendorsScreenState();
}

class _VendorsScreenState extends State<VendorsScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadVendors();
  }

  Future<void> _loadVendors() async {
    final position = await LocationService.getCurrentPosition();
    if (position != null) {
      context.read<VendorBloc>().add(LoadVendors(
        serviceId: widget.serviceId,
        lat: position.latitude,
        lng: position.longitude,
      ));
    } else {
      context.read<VendorBloc>().add(LoadVendors(serviceId: widget.serviceId));
    }
  }

  Future<void> _searchVendors(String query) async {
    final position = await LocationService.getCurrentPosition();
    context.read<VendorBloc>().add(SearchVendors(
      query: query.isEmpty ? null : query,
      serviceId: widget.serviceId,
      lat: position?.latitude,
      lng: position?.longitude,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceName ?? 'Vendors'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search vendors...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadVendors();
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[200],
              ),
              onChanged: (value) {
                if (value.isEmpty) {
                  _loadVendors();
                } else {
                  _searchVendors(value);
                }
              },
            ),
          ),

          // Vendors List
          Expanded(
            child: BlocBuilder<VendorBloc, VendorState>(
              builder: (context, state) {
                if (state is VendorLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is VendorsLoaded) {
                  if (state.vendors.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.store_off, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No vendors found',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.serviceId != null
                                ? 'No vendors available for this service'
                                : 'Try adjusting your search',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _loadVendors,
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: state.vendors.length,
                      itemBuilder: (context, index) {
                        final vendor = state.vendors[index];
                        return _buildVendorCard(vendor, context);
                      },
                    ),
                  );
                }

                if (state is VendorError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(state.message),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _loadVendors,
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                }

                return const Center(child: Text('Search for vendors'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVendorCard(dynamic vendor, BuildContext context) {
    final enabledServices = vendor.services.where((s) => s.enabled).toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VendorDetailsScreen(vendorId: vendor.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.indigo.withOpacity(0.1),
                    child: const Icon(Icons.store, color: Colors.indigo, size: 30),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          vendor.businessName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.amber),
                            Text(
                              ' ${vendor.rating.toStringAsFixed(1)}',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              ' (${vendor.totalReviews} reviews)',
                              style: const TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: vendor.isActive ? Colors.green : Colors.red,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      vendor.isActive ? 'Active' : 'Inactive',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (vendor.address != null && vendor.address['city'] != null)
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${vendor.address['city']}${vendor.address['state'] != null ? ', ${vendor.address['state']}' : ''}',
                        style: const TextStyle(color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              if (enabledServices.isNotEmpty) ...[
                const Text(
                  'Services:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: enabledServices.take(5).map((s) {
                    return Chip(
                      label: Text(
                        s.name,
                        style: const TextStyle(fontSize: 10),
                      ),
                      backgroundColor: Colors.indigo.withOpacity(0.1),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Call vendor
                      },
                      icon: const Icon(Icons.phone, size: 16),
                      label: const Text('Call'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VendorDetailsScreen(vendorId: vendor.id),
                          ),
                        );
                      },
                      icon: const Icon(Icons.book_online, size: 16),
                      label: const Text('Book Now'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
