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
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: Text(
          widget.serviceName ?? 'Vendors',
          style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20, letterSpacing: -0.5),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: Colors.grey.shade100,
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search vendors...',
                  hintStyle: const TextStyle(color: Colors.grey, fontWeight: FontWeight.w500),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.indigo),
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _searchController.clear();
                            _loadVendors();
                          },
                        )
                      : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade200),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: Colors.grey.shade100),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(color: Colors.indigo),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VendorDetailsScreen(vendorId: vendor.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: Colors.green, size: 26),
                  ),
                  const SizedBox(width: 14),
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
                        Row(
                          children: [
                            const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
                            Text(
                              ' ${vendor.rating.toStringAsFixed(1)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            Text(
                              ' (${vendor.totalReviews} reviews)',
                              style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: vendor.isActive ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      vendor.isActive ? 'Active' : 'Inactive',
                      style: TextStyle(
                        color: vendor.isActive ? Colors.green : Colors.red,
                        fontSize: 11,
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
                    const Icon(Icons.location_on_rounded, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${vendor.address['city']}${vendor.address['state'] != null ? ', ${vendor.address['state']}' : ''}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13, fontWeight: FontWeight.w500),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              if (enabledServices.isNotEmpty) ...[
                const Text(
                  'Services Offered:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: enabledServices.take(5).map((s) {
                    return Chip(
                      label: Text(
                        s.name,
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.indigo),
                      ),
                      backgroundColor: Colors.indigo.withOpacity(0.05),
                      padding: EdgeInsets.zero,
                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: BorderSide(color: Colors.indigo.withOpacity(0.05)),
                      ),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Call vendor
                      },
                      icon: const Icon(Icons.phone_rounded, size: 16),
                      label: const Text('Call', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.indigo,
                        side: BorderSide(color: Colors.indigo.withOpacity(0.4)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                      icon: const Icon(Icons.book_online_rounded, size: 16),
                      label: const Text('Book Now', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.indigo,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
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
