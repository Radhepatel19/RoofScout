import 'package:flutter/material.dart';
import 'package:roofscout/features/properties/screens/property_details_page.dart';
import 'package:roofscout/features/properties/services/property_like_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecommendedPropertiesWidget extends StatefulWidget {
  final List<Map<String, dynamic>> properties;
  const RecommendedPropertiesWidget({super.key, required this.properties});

  @override
  State<RecommendedPropertiesWidget> createState() => _RecommendedPropertiesWidgetState();
}

class _RecommendedPropertiesWidgetState extends State<RecommendedPropertiesWidget> {
  final PageController _pageController = PageController(viewportFraction: 0.85);
  bool _isLoading = false;

  Set<int> _favoritePropertyIds = {};
  int? _userId;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadUserLikes();
    _pageController.addListener(() {

    });
  }

  Future<void> _loadUserLikes() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    if (userId != null) {
      if (mounted) setState(() => _userId = userId);
      final result = await PropertyLikeService.getUserLikes(userId);
      if (result['success'] && mounted) {
        setState(() {
          final List likesData = result['data'] ?? [];
          _favoritePropertyIds = likesData.map<int>((l) => int.parse(l['property_id'].toString())).toSet();
        });
      }
    }
  }

  Future<void> _toggleFavorite(int propertyId) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save favorites')),
      );
      return;
    }

    if (_isTogglingFavorite) return;
    _isTogglingFavorite = true;

    final isCurrentlyFavorite = _favoritePropertyIds.contains(propertyId);

    setState(() {
      if (isCurrentlyFavorite) {
        _favoritePropertyIds.remove(propertyId);
      } else {
        _favoritePropertyIds.add(propertyId);
      }
    });

    Map<String, dynamic> result;
    if (!isCurrentlyFavorite) {
      result = await PropertyLikeService.likeProperty(
        propertyId: propertyId,
        userId: _userId!,
      );
    } else {
      result = await PropertyLikeService.unlikeProperty(
        propertyId: propertyId,
        userId: _userId!,
      );
    }

    if (!result['success']) {
      if (mounted) {
        setState(() {
          if (isCurrentlyFavorite) {
            _favoritePropertyIds.add(propertyId);
          } else {
            _favoritePropertyIds.remove(propertyId);
          }
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Failed to update favorite')),
        );
      }
    }

    _isTogglingFavorite = false;
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
        if (widget.properties.isEmpty)
          Container(
            height: 180,
            width: double.infinity,
            margin: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.grey[200]!, style: BorderStyle.solid),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.home_work_outlined, size: 48, color: Colors.grey[400]),
                const SizedBox(height: 12),
                Text(
                  "No recommended properties in this city",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Try selecting a different city above",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[400],
                  ),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 450,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.properties.length,
              itemBuilder: (context, index) {
                final property = widget.properties[index];
                return Container(
                  margin: EdgeInsets.only(
                    right: index == widget.properties.length - 1 ? 16 : 12,
                  ),
                  width: 320,  // ← FIXED WIDTH
                  child: PropertyCard(
                    property: property,
                    index: index,
                    onTap: () {
                      final propertyId = property['property_id'] ?? 1;
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyDetailsPage(propertyId: propertyId),
                        ),
                      );
                    },
                    isFavorite: _favoritePropertyIds.contains(property['property_id'] ?? 1),
                    onFavoriteToggle: () => _toggleFavorite(property['property_id'] ?? 1),
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 20),

        // QUICK STATS BAR
        if (!_isLoading && widget.properties.isNotEmpty) _buildQuickStats(),
      ],
    );
  }


  Widget _buildQuickStats() {
    double totalPr = 0;
    for (var p in widget.properties) {
      totalPr += double.tryParse((p['price'] ?? 0).toString()) ?? 0;
    }
    double avgPr = widget.properties.isNotEmpty ? totalPr / widget.properties.length : 0;
    String avgPriceText = "₹0";
    if (avgPr >= 10000000) {
      avgPriceText = "₹${(avgPr / 10000000).toStringAsFixed(1)}Cr";
    } else if (avgPr >= 100000) {
      avgPriceText = "₹${(avgPr / 100000).toStringAsFixed(0)}L";
    } else if (avgPr >= 1000) {
      avgPriceText = "₹${(avgPr / 1000).toStringAsFixed(0)}K";
    }

    double totalRa = 0;
    for (var p in widget.properties) {
      var r = p['rating'];
      double dRating = r is num ? r.toDouble() : double.tryParse(r.toString()) ?? 4.5;
      totalRa += dRating;
    }
    double avgRa = widget.properties.isNotEmpty ? totalRa / widget.properties.length : 4.5;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
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
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem("Avg. Price", avgPriceText),
          Container(
            height: 30,
            width: 1,
            color: Colors.grey[200],
          ),
          _buildStatItem("Properties", "${widget.properties.length}"),
          Container(
            height: 30,
            width: 1,
            color: Colors.grey[200],
          ),
          _buildStatItem("Avg. Rating", avgRa.toStringAsFixed(1)),
        ],
      ),
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

class PropertyCard extends StatefulWidget {
  final Map<String, dynamic> property;
  final int index;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const PropertyCard({
    super.key,
    required this.property,
    required this.index,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {

  @override
  Widget build(BuildContext context) {
    final priceVal = double.tryParse(widget.property['price'].toString()) ?? 0.0;
    final isForRent = (widget.property['listing_type'] ?? '').toString().toLowerCase() == 'rent';
    final priceText = isForRent
        ? "₹${(priceVal / 1000).toStringAsFixed(0)}K/month"
        : (priceVal >= 10000000 
            ? "₹${(priceVal / 10000000).toStringAsFixed(1)}Cr" 
            : "₹${(priceVal / 100000).toStringAsFixed(1)}L");

    final List<String> images = widget.property['images'] != null ? List<String>.from(widget.property['images']) : [];
    final imgUrl = images.isNotEmpty ? images[0] : "https://images.unsplash.com/photo-1568605114967-8130f3a36994?w=800";
    final ratingVal = widget.property['rating'] != null ? double.tryParse(widget.property['rating'].toString()) ?? 4.5 : 4.5;
    final subtitle = "${widget.property['bedrooms'] ?? 2} BHK ${widget.property['furnishing'] ?? 'Furnished'}";
    final location = widget.property['full_address'] ?? widget.property['city'] ?? "Location";
    final isVerified = widget.property['is_available'] == true || widget.property['is_available'] == 1;

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[100]!,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE SECTION
            Stack(
              children: [
                // Property Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    imgUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // Favorite Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: widget.onFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Icon(
                        widget.isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 20,
                        color: widget.isFavorite ? Colors.red : Colors.grey[600],
                      ),
                    ),
                  ),
                ),

                // Price Tag
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: Text(
                      priceText,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0066FF),
                      ),
                    ),
                  ),
                ),

                // Verified Badge
                if (isVerified)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B894),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "✓ Verified",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            // DETAILS SECTION
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.property['title'] ?? 'Property',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.orange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              ratingVal.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          location,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  // Property Features
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFeatureItem(
                          Icons.bed,
                          "${widget.property['bedrooms'] ?? 2} Beds",
                        ),
                        _buildFeatureItem(
                          Icons.bathtub,
                          "${widget.property['bathrooms'] ?? 2} Baths",
                        ),
                        _buildFeatureItem(
                          Icons.square_foot,
                          "${(widget.property['area'] ?? 1200).toString().split('.')[0]} Sq Ft",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // View Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: widget.onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        "View Details",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: const Color(0xFF0066FF),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}