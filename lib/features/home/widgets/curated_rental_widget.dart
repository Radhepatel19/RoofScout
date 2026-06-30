import 'package:flutter/material.dart';
import 'package:roofscout/features/properties/screens/property_view_page.dart';

class CuratedRentalWidget extends StatefulWidget {
  const CuratedRentalWidget({super.key});

  @override
  State<CuratedRentalWidget> createState() => _CuratedRentalWidgetState();
}

class _CuratedRentalWidgetState extends State<CuratedRentalWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.75);
  int _currentPage = 0;

  final List<Map<String, dynamic>> _curatedRentals = [
    {
      'id': '1',
      'title': 'Skyline Luxury Studio',
      'subtitle': 'Premium fully furnished studio',
      'location': 'Bodakdev, Ahmedabad',
      'price': 20000,
      'originalPrice': 25000,
      'discount': '20% off',
      'bedrooms': 1,
      'bathrooms': 1,
      'area': 650,
      'areaUnit': 'sq ft',
      'image': 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&auto=format&fit=crop',
      'amenities': ['Fully Furnished', 'Pool Access', 'Gym', '24x7 Security'],
      'rating': 4.8,
      'isVerified': true,
      'isExclusive': true,
      'postedDaysAgo': 2,
    },
    {
      'id': '2',
      'title': 'Urban Luxury 2BHK',
      'subtitle': 'Modern apartment with city view',
      'location': 'SG Highway, Ahmedabad',
      'price': 50000,
      'originalPrice': 55000,
      'discount': '9% off',
      'bedrooms': 2,
      'bathrooms': 2,
      'area': 1250,
      'areaUnit': 'sq ft',
      'image': 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&auto=format&fit=crop',
      'amenities': ['Fully Furnished', 'Swimming Pool', 'Gym', 'Club House'],
      'rating': 4.6,
      'isVerified': true,
      'isExclusive': false,
      'postedDaysAgo': 1,
    },
    {
      'id': '3',
      'title': 'Cozy Studio Apartment',
      'subtitle': 'Perfect for students & professionals',
      'location': 'Vastrapur, Ahmedabad',
      'price': 15000,
      'originalPrice': 18000,
      'discount': '17% off',
      'bedrooms': 1,
      'bathrooms': 1,
      'area': 550,
      'areaUnit': 'sq ft',
      'image': 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&auto=format&fit=crop',
      'amenities': ['Semi Furnished', 'WiFi Included', 'Housekeeping', 'Parking'],
      'rating': 4.3,
      'isVerified': true,
      'isExclusive': true,
      'postedDaysAgo': 3,
    },
    {
      'id': '4',
      'title': 'Premium 3BHK Penthouse',
      'subtitle': 'Luxury living with panoramic views',
      'location': 'Prahlad Nagar, Ahmedabad',
      'price': 85000,
      'originalPrice': 95000,
      'discount': '11% off',
      'bedrooms': 3,
      'bathrooms': 3,
      'area': 1850,
      'areaUnit': 'sq ft',
      'image': 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&auto=format&fit=crop',
      'amenities': ['Fully Furnished', 'Private Terrace', 'Jacuzzi', 'Smart Home'],
      'rating': 4.9,
      'isVerified': true,
      'isExclusive': true,
      'postedDaysAgo': 5,
    },
  ];

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),

        // RENTAL CAROUSEL
        SizedBox(
          child: Stack(
            children: [
              SizedBox(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _curatedRentals.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 240,
                      child: CuratedRentalCard(
                        rental: _curatedRentals[index],
                        index: index,
                        isActive: index == _currentPage,
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RoofHomePage(),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
              ),

            ],
          ),
        ),

        const SizedBox(height: 16),

        // QUICK STATS
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[100]!),
            boxShadow: [
              BoxShadow(
                color: Colors.grey[50]!,
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("Avg. Rent", "₹37.5K"),
              Container(
                height: 30,
                width: 1,
                color: Colors.grey[200],
              ),
              _buildStatItem("Properties", "2,500+"),
              Container(
                height: 30,
                width: 1,
                color: Colors.grey[200],
              ),
              _buildStatItem("Avg. Rating", "4.7"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0066FF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Curated Rental Card Widget
class CuratedRentalCard extends StatelessWidget {
  final Map<String, dynamic> rental;
  final int index;
  final bool isActive;
  final VoidCallback onTap;

  const CuratedRentalCard({
    super.key,
    required this.rental,
    required this.index,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final price = rental['price'];
    final originalPrice = rental['originalPrice'];
    final discount = rental['discount'];
    final priceText = "₹${(price / 1000).toStringAsFixed(0)}K/month";

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200]!,
              blurRadius: isActive ? 20 : 12,
              offset: Offset(0, isActive ? 8 : 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.network(
                  rental['image'] as String,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                          color: const Color(0xFF0066FF),
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Section - Badges
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Discount Badge
                        if (discount != null)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B00), Color(0xFFFF8C42)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              discount,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        const Spacer(),
                        // Verified Badge
                        if (rental['isVerified'])
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF00B894),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Row(
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  "Verified",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    // Bottom Section - Details
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          rental['title'] as String,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 8),

                        // Subtitle
                        Text(
                          rental['subtitle'] as String,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),

                        const SizedBox(height: 16),

                        // Price & Features Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Price
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  priceText,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                                if (originalPrice != null)
                                  Text(
                                    "₹${(originalPrice / 1000).toStringAsFixed(0)}K",
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white.withOpacity(0.7),
                                      decoration: TextDecoration.lineThrough,
                                    ),
                                  ),
                              ],
                            ),

                            // Quick Features
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.bed_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${rental['bedrooms']}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.bathtub_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${rental['bathrooms']}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Icon(
                                    Icons.square_foot_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    "${rental['area']}",
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Amenities
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: (rental['amenities'] as List<String>)
                              .take(3)
                              .map((amenity) => Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              amenity,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withOpacity(0.9),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ))
                              .toList(),
                        ),

                        const SizedBox(height: 20),

                        // View Details Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: onTap,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF0066FF),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              "View Details",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}