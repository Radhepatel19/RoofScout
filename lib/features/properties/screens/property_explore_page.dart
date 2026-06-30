import 'package:flutter/material.dart';
import 'package:roofscout/features/properties/screens/property_filter_page.dart';
import 'package:roofscout/features/properties/services/property_service.dart';
import 'package:roofscout/features/properties/services/saved_property_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'property_details_page.dart';

class PropertyExploreViewPage extends StatefulWidget {
  final String name;
  final String? propertyType;
  final String? furnishingType;
  final int? bhkType;
  final String? budgetRange;

  const PropertyExploreViewPage({
    super.key,
    required this.name,
    this.propertyType,
    this.furnishingType,
    this.bhkType,
    this.budgetRange,
  });

  @override
  State<PropertyExploreViewPage> createState() => _PropertyExploreViewPageState();
}

class _PropertyExploreViewPageState extends State<PropertyExploreViewPage> {
  String selectedSort = "Relevance";
  List<Map<String, dynamic>> allProperties = [];
  List<Map<String, dynamic>> filteredProperties = [];
  bool isLoading = true;
  String errorMsg = "";

  Set<int> _favoritePropertyIds = {};
  int? _userId;
  bool _isTogglingFavorite = false;

  final List<String> sortOptions = ["Relevance", "Price: Low to High", "Price: High to Low", "Newest First"];

  @override
  void initState() {
    super.initState();
    _fetchAndFilterProperties();
  }

  Future<void> _fetchAndFilterProperties() async {
    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMsg = "";
    });
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getInt("user_id");
      if (userId != null) {
        _userId = userId;
        final likesResult = await SavedPropertyService.getSavedProperties(userId);
        if (likesResult['success']) {
          final List likesData = likesResult['data'] ?? [];
          _favoritePropertyIds = likesData
              .map<int>((like) => int.parse(like['property_id'].toString()))
              .toSet();
        }
      }

      final properties = await PropertyService.getProperties();
      if (mounted) {
        setState(() {
          allProperties = properties;
          _applyFiltersAndSorting();
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

  void _applyFiltersAndSorting() {
    var result = List<Map<String, dynamic>>.from(allProperties);

    // Filter by name/locality if not 'Top-Rated Properties'
    if (widget.name.toLowerCase() != 'top-rated properties' && widget.name.toLowerCase() != 'top-rated') {
      result = result.where((p) {
        final address = (p['full_address'] ?? '').toString().toLowerCase();
        final city = (p['city'] ?? '').toString().toLowerCase();
        final query = widget.name.toLowerCase();
        return address.contains(query) || city.contains(query);
      }).toList();
    }

    // Apply specific filters
    if (widget.propertyType != null) {
      result = result.where((p) => p['property_type'].toString().toLowerCase() == widget.propertyType!.toLowerCase()).toList();
    }

    if (widget.furnishingType != null) {
      result = result.where((p) => p['furnishing'].toString().toLowerCase() == widget.furnishingType!.toLowerCase()).toList();
    }

    if (widget.bhkType != null) {
      result = result.where((p) {
        final bhk = p['bedrooms'];
        return bhk != null && (bhk is num ? bhk.toInt() : int.tryParse(bhk.toString())) == widget.bhkType;
      }).toList();
    }

    // Apply sorting
    if (selectedSort == "Price: Low to High") {
      result.sort((a, b) {
        final pA = a['price'] ?? 0.0;
        final pB = b['price'] ?? 0.0;
        return pA.compareTo(pB);
      });
    } else if (selectedSort == "Price: High to Low") {
      result.sort((a, b) {
        final pA = a['price'] ?? 0.0;
        final pB = b['price'] ?? 0.0;
        return pB.compareTo(pA);
      });
    } else if (selectedSort == "Newest First") {
      result.sort((a, b) {
        final dA = a['property_id'] ?? 0;
        final dB = b['property_id'] ?? 0;
        return dB.compareTo(dA);
      });
    }

    filteredProperties = result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF)))
          : CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.white,
                  elevation: 1,
                  title: Text(
                    "Properties in ${widget.name}",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  leading: Padding(
                    padding: const EdgeInsets.only(left: 8.0),
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Container(
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
                          icon: const Icon(Icons.filter_alt_outlined, size: 20),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PropertyFilterPage(cityName: 'Surat'),
                              ),
                            );
                          },
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  ],
                ),

                // Main Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Box
                        _buildSearchBox(),

                        const SizedBox(height: 20),

                        // Active Filters
                        if (widget.propertyType != null || widget.furnishingType != null || widget.bhkType != null)
                          _buildActiveFilters(),

                        const SizedBox(height: 20),

                        // Results Header
                        _buildResultsHeader(),

                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),

                // Properties List
                if (filteredProperties.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final property = filteredProperties[index];
                        return Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            bottom: 20,
                          ),
                          child: _buildPropertyCard(property),
                        );
                      },
                      childCount: filteredProperties.length,
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 300,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off_rounded,
                              size: 60,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              "No properties found",
                              style: TextStyle(
                                fontSize: 18,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              "Try adjusting your filters",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: TextField(
                onChanged: (val) {
                  setState(() {
                    if (val.isEmpty) {
                      _applyFiltersAndSorting();
                    } else {
                      filteredProperties = filteredProperties.where((p) => p['title'].toString().toLowerCase().contains(val.toLowerCase())).toList();
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: "Search within ${widget.name}...",
                  hintStyle: const TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                ),
              ),
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: const BoxDecoration(
              color: Color(0xFF0066FF),
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: IconButton(
              icon: const Icon(Icons.search_rounded, color: Colors.white, size: 22),
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Active Filters",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0066FF),
                  padding: EdgeInsets.zero,
                ),
                child: const Text(
                  "Clear All",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildFilterChip(
                widget.name,
                Icons.location_on,
                const Color(0xFF0066FF),
              ),
              if (widget.propertyType != null)
                _buildFilterChip(
                  widget.propertyType!,
                  Icons.apartment,
                  const Color(0xFF10B981),
                ),
              if (widget.furnishingType != null)
                _buildFilterChip(
                  widget.furnishingType!,
                  Icons.chair,
                  const Color(0xFFF59E0B),
                ),
              if (widget.bhkType != null)
                _buildFilterChip(
                  "${widget.bhkType} BHK",
                  Icons.bed,
                  const Color(0xFFEF4444),
                ),
              if (widget.budgetRange != null)
                _buildFilterChip(
                  widget.budgetRange!,
                  Icons.currency_rupee,
                  const Color(0xFF8B5CF6),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "${filteredProperties.length} Properties Found",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Showing best matches in ${widget.name}",
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Sort Dropdown
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                dropdownColor: Colors.white,
                value: selectedSort,
                icon: const Icon(Icons.expand_more_rounded, size: 20),
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF1E293B),
                  fontWeight: FontWeight.w500,
                ),
                items: sortOptions.map((String option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedSort = newValue;
                      _applyFiltersAndSorting();
                    });
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    final price = double.parse((property['price'] ?? 0.0).toString());
    final isForRent = property['listing_type'].toString().toLowerCase() == 'rent';
    final priceText = isForRent
        ? "₹${(price / 1000).toStringAsFixed(0)}K/mo"
        : "₹${(price / 10000000).toStringAsFixed(1)}Cr";

    final images = property['images'] != null ? List<String>.from(property['images']) : [];
    final imgUrl = images.isNotEmpty ? images[0] : "https://images.unsplash.com/photo-1568605114967-8130f3a36994";
    final ratingVal = property['rating'] != null ? property['rating'].toDouble() : 4.5;
    final propertyId = property['property_id'] ?? 1;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => PropertyDetailsPage(propertyId: propertyId)),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                // Property Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.network(
                    imgUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // Property Type Badge
                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
                      property['property_type'] ?? 'Apartment',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0066FF),
                      ),
                    ),
                  ),
                ),

                // Price Tag
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
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
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0066FF),
                      ),
                    ),
                  ),
                ),

                // Verified Badge
                if (property['is_available'] == true || property['is_available'] == 1)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.verified, size: 14, color: Colors.white),
                          SizedBox(width: 4),
                          Text(
                            "Verified",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Details Section
            Padding(
              padding: const EdgeInsets.all(20),
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
                              property['title'] ?? 'Premium Listing',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on_outlined,
                                  size: 16,
                                  color: Color(0xFF94A3B8),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    property['full_address'] ?? 'Surat, Gujarat',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.star, size: 16, color: Colors.orange),
                            const SizedBox(width: 4),
                            Text(
                              ratingVal.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.orange,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Property Features
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildFeatureItem(
                          Icons.bed_rounded,
                          "${property['bedrooms'] ?? 2} Beds",
                        ),
                        _buildFeatureItem(
                          Icons.bathtub_rounded,
                          "${property['bathrooms'] ?? 2} Baths",
                        ),
                        _buildFeatureItem(
                          Icons.square_foot_rounded,
                          "${(property['area'] ?? 1200).toString().split('.')[0]} Sq Ft",
                        ),
                        _buildFeatureItem(
                          Icons.chair_rounded,
                          property['furnishing'] ?? 'Furnished',
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Call to Action
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PropertyDetailsPage(propertyId: propertyId),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF0066FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "View Details",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: IconButton(
                          icon: Icon(
                            _favoritePropertyIds.contains(propertyId) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            size: 22,
                            color: _favoritePropertyIds.contains(propertyId) ? const Color(0xFF0066FF) : const Color(0xFF94A3B8),
                          ),
                          onPressed: () => _toggleFavorite(propertyId),
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
    );
  }

  Future<void> _toggleFavorite(int propertyId) async {
    if (_userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please log in to save properties')),
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
      result = await SavedPropertyService.saveProperty(_userId!, propertyId);
    } else {
      result = await SavedPropertyService.unsaveProperty(_userId!, propertyId);
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
          SnackBar(content: Text(result['message'] ?? 'Failed to update saved property')),
        );
      }
    }

    _isTogglingFavorite = false;
  }

  Widget _buildFeatureItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(
          icon,
          size: 20,
          color: const Color(0xFF0066FF),
        ),
        const SizedBox(height: 6),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
      ],
    );
  }
}