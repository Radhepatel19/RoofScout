import 'package:flutter/material.dart';
import 'package:roofscout/features/properties/screens/property_details_page.dart';
import 'package:roofscout/features/properties/services/property_like_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RecentlyPostedWidget extends StatefulWidget {
  final List<Map<String, dynamic>> properties;
  const RecentlyPostedWidget({super.key, required this.properties});

  @override
  State<RecentlyPostedWidget> createState() => _RecentlyPostedWidgetState();
}

class _RecentlyPostedWidgetState extends State<RecentlyPostedWidget> {
  final ScrollController _scrollController = ScrollController();
  int _currentIndex = 0;

  Set<int> _favoritePropertyIds = {};
  int? _userId;
  bool _isTogglingFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadUserLikes();
    _scrollController.addListener(_updateCurrentIndex);
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

  void _updateCurrentIndex() {
    final position = _scrollController.position;
    final currentScroll = position.pixels;
    final itemWidth = 220.0; // Adjust based on your card width
    final index = (currentScroll / itemWidth).round();

    if (index != _currentIndex) {
      setState(() => _currentIndex = index);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateCurrentIndex);
    _scrollController.dispose();
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
                  "No recently posted properties in this city",
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
            height: 320,
            child: Stack(
              children: [
                // PROPERTY CARDS LIST
                ListView.builder(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.only(left: 4, right: 20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: widget.properties.length,
                  itemBuilder: (context, index) {
                    final property = widget.properties[index];
                    return Container(
                      width: 220,
                      margin: EdgeInsets.only(
                        right: index == widget.properties.length - 1 ? 0 : 16,
                      ),
                      child: RecentPropertyCard(
                        property: property,
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
              ],
            ),
          ),

        const SizedBox(height: 16),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildTimeFilter("Just Now", true),
                const SizedBox(width: 12),
                _buildTimeFilter("Today", false),
                const SizedBox(width: 12),
                _buildTimeFilter("This Week", false),
                const SizedBox(width: 12),
                _buildTimeFilter("Last 30 Days", false),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTimeFilter(String label, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0066FF) : Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFF0066FF) : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isActive ? Colors.white : Colors.grey[700],
        ),
      ),
    );
  }
}

// Professional Recent Property Card Widget
class RecentPropertyCard extends StatefulWidget {
  final Map<String, dynamic> property;
  final VoidCallback onTap;
  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const RecentPropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.isFavorite,
    required this.onFavoriteToggle,
  });

  @override
  State<RecentPropertyCard> createState() => _RecentPropertyCardState();
}

class _RecentPropertyCardState extends State<RecentPropertyCard> {

  @override
  Widget build(BuildContext context) {
    final priceVal = double.tryParse(widget.property['price'].toString()) ?? 0.0;
    final isForRent = (widget.property['listing_type'] ?? '').toString().toLowerCase() == 'rent';
    final priceText = isForRent
        ? "₹${(priceVal / 1000).toStringAsFixed(0)}K/mo"
        : (priceVal >= 10000000 
            ? "₹${(priceVal / 10000000).toStringAsFixed(1)}Cr" 
            : "₹${(priceVal / 100000).toStringAsFixed(1)}L");

    final List<String> images = widget.property['images'] != null ? List<String>.from(widget.property['images']) : [];
    final imgUrl = images.isNotEmpty ? images[0] : "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600";
    final isNew = true; // For recent items, always flag as new or high visibility
    final postedTimeText = "Just now";
    final propertyType = widget.property['property_type'] ?? 'Apartment';
    final location = widget.property['full_address'] ?? widget.property['city'] ?? "Location";
    final furnishingText = widget.property['furnishing'] ?? 'Furnished';

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey[100]!),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[100]!,
              blurRadius: 15,
              offset: const Offset(0, 6),
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
                    top: Radius.circular(18),
                  ),
                  child: Image.network(
                    imgUrl,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 140,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 1.5,
                            color: Colors.grey[400],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // "NEW" BADGE
                if (isNew)
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B00), Color(0xFFFF8C42)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B00).withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            "NEW",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Favorite Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: widget.onFavoriteToggle,
                    child: Container(
                      padding: const EdgeInsets.all(6),
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
                        size: 18,
                        color: widget.isFavorite ? Colors.red : Colors.grey[600],
                      ),
                    ),
                  ),
                ),

                // Property Type Badge
                Positioned(
                  bottom: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      propertyType,
                      style: const TextStyle(
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
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title and Price
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.property['title'] ?? 'Property',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey[900],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                location,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Price and Time
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          priceText,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0066FF),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Posted Time
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0066FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 12,
                                    color: Color(0xFF0066FF),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    postedTimeText,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF0066FF),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quick View
                            GestureDetector(
                              onTap: widget.onTap,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0066FF),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.arrow_forward_rounded,
                                  size: 14,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // BOTTOM INFO BAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(18),
                ),
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Beds
                  Row(
                    children: [
                      Icon(
                        Icons.bed_rounded,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.property['bedrooms'] ?? 2}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),

                  // Baths
                  Row(
                    children: [
                      Icon(
                        Icons.bathtub_rounded,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${widget.property['bathrooms'] ?? 2}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),

                  // Area
                  Row(
                    children: [
                      Icon(
                        Icons.square_foot_rounded,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "${(widget.property['area'] ?? 1200).toString().split('.')[0]}",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[800],
                        ),
                      ),
                    ],
                  ),

                  // Furnishing
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      furnishingText.split(' ')[0],
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey[700],
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
}