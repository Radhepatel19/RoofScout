import 'dart:async' show Timer;
import 'package:flutter/material.dart';
import 'package:roofscout/features/properties/screens/review_property_page.dart';
import 'package:roofscout/features/properties/widgets/feedback_section.dart';
import 'package:roofscout/features/properties/screens/property_report_page.dart';
import 'package:roofscout/features/enquiries/screens/property_enquiries_page.dart';
import 'package:roofscout/features/enquiries/services/enquiry_service.dart';
import 'package:roofscout/features/properties/services/property_service.dart';
import 'package:roofscout/features/properties/services/saved_property_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roofscout/features/home/widgets/banner_carousel.dart' show BannerCarousel;
import 'package:roofscout/features/properties/widgets/property_card.dart' show PropertyCard;
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PropertyDetailsPage extends StatefulWidget {
  final int propertyId;
  const PropertyDetailsPage({super.key, this.propertyId = 1});

  @override
  State<PropertyDetailsPage> createState() => _PropertyDetailsPageState();
}



class _PropertyDetailsPageState extends State<PropertyDetailsPage> {
  Map<String, dynamic>? propertyDetails;
  bool isLoading = true;
  String errorMsg = "";

  bool _isFavorite = false;
  bool _isFavoriteLoading = false;
  int? _userId;

  List<bool> likedList = [false, false, false];
  final List<String> fallbackImageList = [
    "https://images.unsplash.com/photo-1600585154340-be6161a56a0c",
    "https://images.unsplash.com/photo-1568605114967-8130f3a36994",
    "https://images.unsplash.com/photo-1522708323590-d24dbb6b0267",
  ];

  @override
  void initState() {
    super.initState();
    _fetchPropertyDetails();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    if (userId != null) {
      if (mounted) {
        setState(() {
          _userId = userId;
        });
      }
      final result = await SavedPropertyService.checkIfSaved(
        userId, 
        widget.propertyId,
      );
      if (result['success'] && mounted) {
        setState(() {
          _isFavorite = result['is_saved'] ?? false;
        });
      }
    }
  }

  Future<void> _toggleFavorite() async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save properties')),
      );
      return;
    }

    if (_isFavoriteLoading) return;

    setState(() {
      _isFavoriteLoading = true;
      _isFavorite = !_isFavorite;
    });

    Map<String, dynamic> result;
    if (_isFavorite) {
      // _isFavorite was toggled to true → user wants to SAVE
      result = await SavedPropertyService.saveProperty(_userId!, widget.propertyId);
    } else {
      // _isFavorite was toggled to false → user wants to UNSAVE
      result = await SavedPropertyService.unsaveProperty(_userId!, widget.propertyId);
    }

    if (!result['success']) {
      if (mounted) {
        setState(() {
          _isFavorite = !_isFavorite;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to update saved property')),
        );
      }
    }

    if (mounted) {
      setState(() {
        _isFavoriteLoading = false;
      });
    }
  }

  Future<void> _fetchPropertyDetails() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = "";
    });
    try {
      final data = await PropertyService.getPropertyById(widget.propertyId);
      if (mounted) {
        setState(() {
          propertyDetails = data;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMsg = e.toString();
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Color(0xFF0066FF))),
      );
    }

    if (errorMsg.isNotEmpty || propertyDetails == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, color: Colors.redAccent, size: 60),
                const SizedBox(height: 16),
                Text(
                  "Failed to load property details",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 8),
                Text(
                  errorMsg,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _fetchPropertyDetails,
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0066FF)),
                  child: const Text("Retry", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        ),
      );
    }

    final p = propertyDetails!;
    final List<String> images = p['images'] != null && (p['images'] as List).isNotEmpty
        ? List<String>.from(p['images'])
        : fallbackImageList;

    final price = p['price'] ?? 0.0;
    final listingType = p['listing_type'] ?? 'Rent';
    final priceText = listingType.toString().toLowerCase() == 'rent'
        ? "₹${(price is num ? price : double.parse(price.toString())).toStringAsFixed(0)} / month"
        : "₹${(price is num ? price : double.parse(price.toString())).toStringAsFixed(0)}";

    final title = "${p['bedrooms'] ?? 2}BHK ${p['furnishing'] ?? 'Furnished'} ${p['property_type'] ?? 'Apartment'}";
    final location = "${p['full_address'] ?? p['city'] ?? 'Surat, Gujarat'}";

    final amenitiesList = p['amenities'] != null ? List<String>.from(p['amenities']) : [];
    final reviewsList = p['reviews'] != null ? List<dynamic>.from(p['reviews']) : [];

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      body: CustomScrollView(
        slivers: [
          // App Bar with Banner
          SliverAppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            pinned: true,
            floating: true,
            snap: true,
            titleSpacing: 0,
            title: const Row(
              children: [
                Text(
                  "Roof",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0066FF),
                  ),
                ),
                Text(
                  "Scout",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFFF6B35),
                  ),
                ),
              ],
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: SizedBox(
                width: 40,
                height: 40,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18,
                    color: Colors.black87,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: Icon(
                          _isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          size: 22,
                          color: _isFavorite ? const Color(0xFF0066FF) : Colors.black87,
                        ),
                        onPressed: _toggleFavorite,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.share,
                          size: 20,
                          color: Colors.black87,
                        ),
                        onPressed: () {},
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Main Content
          SliverToBoxAdapter(
            child: Stack(
              children: [
                // Banner Carousel
                BannerCarousel(
                  bannerList: images,
                  height: 240,
                  borderRadius: BorderRadius.zero,
                  showIndicator: true,
                  autoScroll: true,
                  autoScrollDuration: const Duration(seconds: 4),
                ),

                // Gradient Overlay at bottom
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.3),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price & Basic Info
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          priceText,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0066FF),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_rounded,
                              size: 18,
                              color: Color(0xFF64748B),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                location,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFF475569),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Overview
                  const Text(
                    'Overview',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Text(
                      p['description'] ?? 'No description available for this property.',
                      style: const TextStyle(
                        fontSize: 15,
                        color: Color(0xFF475569),
                        height: 1.6,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Property Details
                  const Text(
                    'Property Details',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildDetailItem('${p['bedrooms'] ?? 2}', 'Beds', Icons.bed_rounded),
                        _buildDetailItem('${p['bathrooms'] ?? 2}', 'Baths', Icons.bathtub_rounded),
                        _buildDetailItem(
                          '${(p['area'] ?? 1200).toString().split('.')[0]}',
                          'Sq Ft',
                          Icons.square_foot_rounded,
                        ),
                        _buildDetailItem('${p['floor_number'] ?? 0}/${p['total_floors'] ?? 0}', 'Floor', Icons.stairs_rounded),
                        _buildDetailItem(
                          '${p['facing'] ?? 'East'}',
                          'Facing',
                          Icons.wb_sunny_rounded,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Insights & Reports Section
                  const Text(
                    "Insights & Reports",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildActionCard(
                          context,
                          "Market Report",
                          "Price trends & analytics",
                          Icons.analytics_outlined,
                          const Color(0xFF0066FF),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PropertyReportPage(propertyId: widget.propertyId),
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildActionCard(
                          context,
                          "Enquiries",
                          "Manage your leads",
                          Icons.message_outlined,
                          const Color(0xFFFF6B35),
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PropertyEnquiriesPage(propertyId: widget.propertyId),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Highlights
                  const Text(
                    'Highlights',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: amenitiesList.isNotEmpty
                        ? amenitiesList.map((a) => _buildTag(a)).toList()
                        : [
                            _buildTag('Prime Location'),
                            _buildTag('24x7 Security'),
                            _buildTag('Fully Furnished'),
                            _buildTag('Parking'),
                          ],
                  ),

                  const SizedBox(height: 24),

                  // Photos
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Photos',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0066FF),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'View All',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 200,
                          margin: const EdgeInsets.only(right: 12),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: NetworkImage(images[index]),
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Furnishings
                  const Text(
                    'Furnishings',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFacility(Icons.bed_rounded, 'Bed'),
                        _buildFacility(Icons.tv_rounded, 'TV'),
                        _buildFacility(Icons.chair_rounded, 'Sofa'),
                        _buildFacility(Icons.kitchen_rounded, 'Fridge'),
                        _buildFacility(Icons.table_bar_rounded, 'Dining Table'),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Contact Form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Contact Agent / Request Callback',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.person_outline_rounded,
                              color: Color(0xFF0066FF),
                            ),
                            labelText: 'Your Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF0066FF)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(
                              Icons.phone_outlined,
                              color: Color(0xFF0066FF),
                            ),
                            labelText: 'Phone Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(color: Color(0xFF0066FF)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () async {
                              final prefs = await SharedPreferences.getInstance();
                              final userId = prefs.getInt("user_id") ?? 1;

                              final response = await EnquiryService.sendEnquiry(
                                propertyId: widget.propertyId,
                                userId: userId,
                                message: "Inquiry from contact details page form",
                                contactPhone: "1234567890",
                                contactEmail: "user@example.com",
                              );

                              if (response['success'] == true) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Enquiry sent successfully!'), backgroundColor: Colors.green),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(response['message'] ?? 'Failed to send enquiry'), backgroundColor: Colors.red),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF0066FF),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Send Enquiry',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Similar Homes
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Similar Homes For You',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0066FF),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 220,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: images.length,
                      itemBuilder: (context, index) {
                        return Container(
                          width: 220,
                          margin: const EdgeInsets.only(right: 16),
                          child: PropertyCard(
                            imageUrl: images[index],
                            title: p['title'] ?? "Premium Roof Space",
                            location: p['city'] ?? "Vesu, Surat",
                            bedrooms: p['bedrooms'] ?? 3,
                            bathrooms: p['bathrooms'] ?? 2,
                            area: "${(p['area'] ?? 1450).toString().split('.')[0]} sqft",
                            isLiked: likedList[index % likedList.length],
                            onLikeToggle: () {
                              setState(() {
                                likedList[index % likedList.length] = !likedList[index % likedList.length];
                              });
                            },
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Locality
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Explore Locality',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          location,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF475569),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Safe locality, nearby hospitals, schools, malls, restaurants, and metro connectivity.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Location (Map) Section
                  const Text(
                    'Location',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: GoogleMap(
                        initialCameraPosition: const CameraPosition(
                          target: LatLng(21.1702, 72.8311), // Surat coordinates
                          zoom: 14,
                        ),
                        markers: {
                          const Marker(
                            markerId: MarkerId('property_location'),
                            position: LatLng(21.1702, 72.8311),
                          ),
                        },
                        zoomControlsEnabled: false,
                        mapToolbarEnabled: false,
                        myLocationButtonEnabled: false,
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Rate Property
                  _buildRatingSection(context),

                  const SizedBox(height: 24),

                  // Reviews
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Resident Reviews',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ReviewPropertyPage(propertyId: widget.propertyId),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF0066FF),
                          padding: EdgeInsets.zero,
                        ),
                        child: const Text(
                          'See All',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 140,
                    child: reviewsList.isEmpty
                        ? const Center(child: Text("No reviews yet. Be the first to review!"))
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: reviewsList.length,
                            itemBuilder: (context, index) {
                              final rev = reviewsList[index];
                              final revName = rev['full_name'] ?? 'User';
                              final formattedDate = rev['created_at'] != null
                                  ? rev['created_at'].toString().split('T')[0]
                                  : 'Today';

                              return Container(
                                width: 240,
                                margin: const EdgeInsets.only(right: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        CircleAvatar(
                                          radius: 20,
                                          backgroundColor: const Color(0xFF0066FF),
                                          child: Text(
                                            revName[0].toUpperCase(),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                revName,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14,
                                                  color: Color(0xFF1E293B),
                                                ),
                                              ),
                                              Text(
                                                formattedDate,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Color(0xFF94A3B8),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const Icon(
                                          Icons.star,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${rev['rating'] ?? 5}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1E293B),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    Expanded(
                                      child: Text(
                                        rev['review_text'] ?? '',
                                        style: const TextStyle(
                                          fontSize: 13,
                                          color: Color(0xFF475569),
                                          height: 1.4,
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),

                  const SizedBox(height: 24),

                  // Feedback
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Are you finding us helpful?',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 12),
                        FeedbackSection(),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFF0066FF)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.message_rounded,
                      color: Color(0xFF0066FF),
                      size: 20,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'WhatsApp',
                      style: TextStyle(
                        color: Color(0xFF0066FF),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.phone_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      p['owner_phone'] != null ? 'Call Owner' : 'Call Agent',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String value, String label, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFF0066FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: const Color(0xFF0066FF)),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
      ],
    );
  }

  Widget _buildFacility(IconData icon, String label) {
    return Column(
      children: [
        Icon(icon, size: 28, color: const Color(0xFF0066FF)),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF0066FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.2)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF0066FF),
        ),
      ),
    );
  }

  Widget _buildRatingSection(BuildContext context) {
    int selectedRating = 0;
    final TextEditingController reviewController = TextEditingController();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066FF).withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Rate This Property",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Share your experience to help others",
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 16),

              // Star Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    splashRadius: 20,
                    onPressed: () {
                      setState(() {
                        selectedRating = index + 1;
                      });
                    },
                    icon: Icon(
                      index < selectedRating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: Colors.amber,
                      size: 32,
                    ),
                  );
                }),
              ),
              const SizedBox(height: 16),

              // Review Input
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: reviewController,
                  maxLines: 4,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    contentPadding: EdgeInsets.all(16),
                    hintText: "Write your review about the property...",
                    hintStyle: TextStyle(color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (selectedRating == 0 || reviewController.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please select stars and write a review before submitting.",
                          ),
                          backgroundColor: Colors.red,
                        ),
                      );
                      return;
                    }

                    // Call real service to submit review!
                    final response = await PropertyService.postReview(
                      widget.propertyId,
                      selectedRating,
                      reviewController.text,
                    );

                    if (response['success'] == true) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Review submitted successfully!"),
                          backgroundColor: Colors.green,
                        ),
                      );
                      reviewController.clear();
                      setState(() {
                        selectedRating = 0;
                      });
                      // Reload property details to display the fresh review!
                      _fetchPropertyDetails();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(response['message'] ?? "Failed to submit review"),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text(
                    "Submit Review",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(color: color.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
