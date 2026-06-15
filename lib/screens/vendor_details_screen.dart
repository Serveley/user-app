import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../blocs/vendor_bloc.dart';
import '../services/location_service.dart';

class VendorDetailsScreen extends StatefulWidget {
  final String vendorId;

  const VendorDetailsScreen({super.key, required this.vendorId});

  @override
  State<VendorDetailsScreen> createState() => _VendorDetailsScreenState();
}

class _VendorDetailsScreenState extends State<VendorDetailsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VendorBloc>().add(LoadVendorDetails(widget.vendorId));
  }

  Future<void> _launchPhone(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  Future<void> _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<VendorBloc, VendorState>(
        builder: (context, state) {
          if (state is VendorLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is VendorDetailsLoaded) {
            final vendor = state.vendor;
            final enabledServices = vendor.services.where((s) => s.enabled).toList();

            return CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.indigo,
                            Colors.purple.shade700,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          const CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.white,
                            child: Icon(Icons.store, size: 50, color: Colors.indigo),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            vendor.businessName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Rating Card
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Column(
                                  children: [
                                    Text(
                                      vendor.rating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        fontSize: 36,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    RatingBar.builder(
                                      initialRating: vendor.rating,
                                      minRating: 1,
                                      direction: Axis.horizontal,
                                      allowHalfRating: true,
                                      itemCount: 5,
                                      itemSize: 20,
                                      ignoreGestures: true,
                                      itemBuilder: (context, _) => const Icon(
                                        Icons.star,
                                        color: Colors.amber,
                                      ),
                                      onRatingUpdate: (_) {},
                                    ),
                                    Text('${vendor.totalReviews} reviews'),
                                  ],
                                ),
                                const Spacer(),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: vendor.isActive
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.red.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    vendor.isActive ? 'Available' : 'Unavailable',
                                    style: TextStyle(
                                      color: vendor.isActive ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Contact Info
                        const Text(
                          'Contact Information',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildContactTile(
                          icon: Icons.person,
                          title: 'Contact Person',
                          subtitle: vendor.name,
                        ),

                        _buildContactTile(
                          icon: Icons.phone,
                          title: 'Phone',
                          subtitle: vendor.phone,
                          onTap: () => _launchPhone(vendor.phone),
                        ),

                        _buildContactTile(
                          icon: Icons.email,
                          title: 'Email',
                          subtitle: vendor.email,
                          onTap: () => _launchEmail(vendor.email),
                        ),

                        _buildContactTile(
                          icon: Icons.location_on,
                          title: 'Address',
                          subtitle: vendor.fullAddress,
                        ),

                        const SizedBox(height: 24),

                        // Services Section
                        const Text(
                          'Available Services',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),

                        if (enabledServices.isEmpty)
                          const Card(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Text('No services available at the moment'),
                            ),
                          )
                        else
                          ...enabledServices.map((service) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const CircleAvatar(
                                backgroundColor: Colors.indigo,
                                child: Icon(Icons.design_services, color: Colors.white),
                              ),
                              title: Text(service.name),
                              trailing: service.price != null
                                  ? Text(
                                      '\$${service.price!.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.indigo,
                                      ),
                                    )
                                  : null,
                            ),
                          )),

                        const SizedBox(height: 24),

                        // Book Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: vendor.isActive
                                ? () {
                                    // TODO: Implement booking
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Booking feature coming soon!'),
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.book_online),
                            label: const Text(
                              'Book Now',
                              style: TextStyle(fontSize: 18),
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              backgroundColor: Colors.indigo,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          if (state is VendorError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<VendorBloc>().add(LoadVendorDetails(widget.vendorId));
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Loading vendor details...'));
        },
      ),
    );
  }

  Widget _buildContactTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.indigo),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        ),
        trailing: onTap != null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
        onTap: onTap,
      ),
    );
  }
}
