import 'package:flutter/material.dart';
import 'package:roofscout/features/properties/screens/property_details_page.dart';
import 'package:roofscout/features/properties/screens/property_filter_page.dart';
import 'package:roofscout/features/properties/screens/property_view_page.dart';
import 'package:roofscout/features/properties/services/saved_property_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
class FavoritePage extends StatefulWidget {
  const FavoritePage({super.key});

  @override
  State<FavoritePage> createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  String _selectedCategory = "All";
  bool _isGridView = false;
  bool _isLoading = true;
  int? _userId;
  List<Map<String, dynamic>> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadSavedProperties();
  }

  Future<void> _loadSavedProperties() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    
    if (userId != null) {
      _userId = userId;
      final result = await SavedPropertyService.getSavedProperties(userId);
      if (mounted) {
        if (result['success']) {
          setState(() {
            _favorites = List<Map<String, dynamic>>.from(result['data']);
            _isLoading = false;
          });
        } else {
          setState(() => _isLoading = false);
        }
      }
    } else {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  final List<String> _categories = [
    "All",
    "Apartments",
    "Villas",
    "Plots",
    "Commercial",
    "For Rent"
  ];

  @override
  Widget build(BuildContext context) {
    final filteredProperties = _filterProperties();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            pinned: true,
            floating: true,
            automaticallyImplyLeading: false,
            snap: true,
            title: Text(
              "My Shortlists",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.grey[900],
                letterSpacing: -0.5,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () => _toggleViewMode(),
                icon: Icon(
                  _isGridView ? Icons.view_stream : Icons.grid_view,
                  color: Colors.grey[700],
                  size: 24,
                ),
              ),
              IconButton(
                onPressed: () => {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PropertyFilterPage(cityName: "Surat")))
                  },
                icon: Icon(
                  Icons.filter_list,
                  color: Colors.grey[700],
                  size: 24,
                ),
              ),
            ],
          ),

          // Category Filter Chips
          SliverToBoxAdapter(
            child: _buildCategoryFilter(),
          ),

          // Stats Bar
          SliverToBoxAdapter(
            child: _buildStatsBar(filteredProperties.length),
          ),

          // Property List/Grid
          // Property List/Grid OR Empty State
          if (filteredProperties.isEmpty)
            SliverFillRemaining(
              child: _buildEmptyState(),
            )
          else if (_isGridView)
            SliverPadding(
              padding: const EdgeInsets.all(16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.75,
                ),
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return PremiumPropertyCardGrid(
                      property: filteredProperties[index],
                      onTap: () => _navigateToDetail(filteredProperties[index]),
                        onRemove: () => _removeFromFavorites(filteredProperties[index]['property_id']),
                    );
                  },
                  childCount: filteredProperties.length,
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                      (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PremiumPropertyCard(
                        property: filteredProperties[index],
                        onTap: () => _navigateToDetail(filteredProperties[index]),
                        onRemove: () => _removeFromFavorites(filteredProperties[index]['property_id']),
                      ),
                    );
                  },
                  childCount: filteredProperties.length,
                ),
              ),
            ),
        ],
      ),

      // Floating Action Button for Bulk Actions
      floatingActionButton: filteredProperties.isNotEmpty
          ? FloatingActionButton.extended(
        onPressed: () => _showBulkActions(context),
        backgroundColor: const Color(0xFF0066CC),
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        icon: const Icon(Icons.send),
        label: const Text("Contact All"),
      )
          : null,
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = _selectedCategory == category;

          return FilterChip(
            label: Text(
              category,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                fontSize: 14,
              ),
            ),
            selected: isSelected,
            onSelected: (_) => setState(() => _selectedCategory = category),
            backgroundColor: Colors.grey[100],
            selectedColor: const Color(0xFF0066CC),
            checkmarkColor: Colors.white,
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? const Color(0xFF0066CC) : Colors.grey[300]!,
                width: isSelected ? 0 : 1,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            showCheckmark: true,
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_rounded,
                size: 60,
                color: Colors.grey[400],
              ),
            ),

            const SizedBox(height: 24),

            // Title
            Text(
              "No Favorites Yet",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.grey[800],
              ),
            ),

            const SizedBox(height: 12),

            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                "Properties you mark as favorite will appear here. Start exploring and save your dream homes!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  height: 1.5,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Browse Button
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=> const RoofHomePage()));
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0066CC),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.explore, size: 20),
                  SizedBox(width: 8),
                  Text(
                    "Browse Properties",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  Widget _buildStatsBar(int count) {
    if (count == 0) {
      return Container(); // Return empty container when no properties
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[200]!,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "$count Properties",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "Total estimated value",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              Text(
                "₹${_calculateTotalValue().toStringAsFixed(2)} Cr",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0066CC),
                ),
              ),
            ],
          ),

          // Quick Stats
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF0066CC), Color(0xFF004D99)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.star,
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(height: 4),
                Text(
                  "${_calculateAverageRating().toStringAsFixed(1)}",
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  "Avg. Rating",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filterProperties() {
    if (_selectedCategory == "All") return _favorites;

    return _favorites.where((property) {
      final type = property['property_type'] ?? '';
      final status = property['listing_type'] ?? '';
      if (_selectedCategory == "Apartments") return type == 'Apartment';
      if (_selectedCategory == "Villas") return type == 'Villa';
      if (_selectedCategory == "Plots") return type == 'Plot';
      if (_selectedCategory == "Commercial") return type == 'Commercial';
      if (_selectedCategory == "For Rent") return status == 'For Rent';
      return true;
    }).toList();
  }

  double _calculateTotalValue() {
    final props = _filterProperties();
    if (props.isEmpty) return 0.0;

    double total = 0.0;
    for (var p in props) {
      if (p['price'] != null) {
        total += (p['price'] is num) ? (p['price'] as num).toDouble() : double.tryParse(p['price'].toString()) ?? 0.0;
      }
    }
    return total / 10000000;
  }

  double _calculateAverageRating() {
    final props = _filterProperties();
    if (props.isEmpty) return 0.0;

    double totalRating = 0.0;
    for (var p in props) {
      if (p['rating'] != null) {
        totalRating += (p['rating'] is num) ? (p['rating'] as num).toDouble() : double.tryParse(p['rating'].toString()) ?? 4.5;
      } else {
        totalRating += 4.5; // Default rating if none
      }
    }
    return totalRating / props.length;
  }

  void _toggleViewMode() {
    setState(() => _isGridView = !_isGridView);
  }


  void _navigateToDetail(Map<String, dynamic> property) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyDetailsPage(),
      ),
    );
  }

  Future<void> _removeFromFavorites(int id) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Remove from favorites?"),
        content: const Text("This property will be removed from your shortlist."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (_userId != null) {
                final previousFavorites = List<Map<String, dynamic>>.from(_favorites);
                setState(() {
                  _favorites.removeWhere((prop) => prop['property_id'] == id);
                });
                
                final result = await SavedPropertyService.unsaveProperty(_userId!, id);
                if (!result['success']) {
                  setState(() {
                    _favorites = previousFavorites;
                  });
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result['message'] ?? 'Failed to remove')),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Property removed from favorites"),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Remove", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showBulkActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Bulk Actions",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.email, color: Color(0xFF0066CC)),
                title: const Text("Email all property details"),
                onTap: () {
                  Navigator.pop(context);
                  // Implement email logic
                },
              ),
              ListTile(
                leading: const Icon(Icons.print, color: Color(0xFF0066CC)),
                title: const Text("Print shortlist"),
                onTap: () {
                  Navigator.pop(context);
                  // Implement print logic
                },
              ),
              ListTile(
                leading: const Icon(Icons.share, color: Color(0xFF0066CC)),
                title: const Text("Share shortlist"),
                onTap: () {
                  Navigator.pop(context);
                  // Implement share logic
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text("Clear all favorites", style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context);
                  _clearAllFavorites();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _clearAllFavorites() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Clear all favorites?"),
        content: const Text("This will remove all properties from your shortlist."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _favorites.clear());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("All favorites cleared"),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text("Clear All", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Premium Property Card (List View)
class PremiumPropertyCard extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const PremiumPropertyCard({
    super.key,
    required this.property,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final price = property['price'] ?? 0;
    final isForRent = property['listing_type'] == 'For Rent';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200]!,
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            Stack(
              children: [
                // Main Image
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Image.network(
                    (property['images'] != null && property['images'] is List && property['images'].isNotEmpty) ? property['images'][0] : 'https://images.unsplash.com/photo-1568605114967-8130f3a36994',
                    height: 220,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 220,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation(Colors.blue[800]!),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Gradient Overlay
                Container(
                  height: 220,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.5),
                      ],
                    ),
                  ),
                ),

                // Badges
                Positioned(
                  top: 16,
                  left: 16,
                  child: Row(
                    children: [
                      if (property['isPremium'] == true)
                        _buildBadge("PREMIUM", const Color(0xFFFFD700)),
                      if (property['isVerified'] == true)
                        _buildBadge("VERIFIED", const Color(0xFF00B894)),
                      _buildBadge(
                        property['listing_type'] ?? 'For Rent',
                        const Color(0xFF0066CC),
                      ),
                    ],
                  ),
                ),

                // Price Tag
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Text(
                          isForRent
                              ? "₹${(double.tryParse(price.toString()) ?? 0) ~/ 1000}K/mo"
                              : "₹${((double.tryParse(price.toString()) ?? 0) / 100000).toStringAsFixed(1)}L",
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF0066CC),
                          ),
                        ),
                        if (property['pricePerSqft'] != null)
                          Padding(
                            padding: const EdgeInsets.only(left: 8),
                            child: Text(
                              "₹${property['pricePerSqft']}/sq ft",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),

                // Image Counter
                if (property['images'] != null && property['images'] is List && (property['images'] as List).length > 1)
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.photo_library,
                            size: 14,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${(property['images'] as List).length}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),

            // Content Section
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Rating
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property['title'] ?? 'Property',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              property['property_type'] ?? property['subtitle'] ?? '',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Rating
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066CC).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 16,
                              color: Color(0xFF0066CC),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              (property['rating'] ?? 4.5).toString(),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF0066CC),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Location
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          property['city'] ?? 'Surat',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        property['created_at'] != null
                            ? property['created_at'].toString().substring(0, 10)
                            : '',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Property Features
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildFeature(
                          Icons.bed,
                          "${property['bedrooms']} Beds",
                        ),
                        _buildFeature(
                          Icons.bathtub,
                          "${property['bathrooms']} Baths",
                        ),
                        _buildFeature(
                          Icons.square_foot,
                          "${property['area'] ?? '-'} sq.ft",
                        ),
                        _buildFeature(
                          Icons.access_time,
                          "Ready to Move",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Actions Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Remove Button
                      OutlinedButton.icon(
                        onPressed: onRemove,
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text("Remove"),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),

                      // Contact Button
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.message, size: 18),
                        label: const Text("Contact Agent"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066CC),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
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

  Widget _buildBadge(String text, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildFeature(IconData icon, String text) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.grey[200]!,
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(
            icon,
            size: 20,
            color: const Color(0xFF0066CC),
          ),
        ),
        const SizedBox(height: 8),
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

// Premium Property Card (Grid View)
class PremiumPropertyCardGrid extends StatelessWidget {
  final Map<String, dynamic> property;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const PremiumPropertyCardGrid({
    super.key,
    required this.property,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final isForRent = property['listing_type'] == 'For Rent';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200]!,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Stack
            Stack(
              children: [
                // Property Image
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Image.network(
                    (property['images'] != null && property['images'] is List && property['images'].isNotEmpty) ? property['images'][0] : 'https://images.unsplash.com/photo-1568605114967-8130f3a36994',
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),

                // Gradient Overlay
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                ),

                // Price Tag
                Positioned(
                  bottom: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      isForRent 
                          ? "₹${(double.parse((property['price'] ?? 0).toString()) / 1000).toStringAsFixed(0)}K" 
                          : "₹${(double.parse((property['price'] ?? 0).toString()) / 100000).toStringAsFixed(1)}L",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF0066CC),
                      ),
                    ),
                  ),
                ),

                // Favorite Button
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: onRemove,
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
                      child: const Icon(
                        Icons.favorite,
                        size: 18,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Title
                    Text(
                      property['title'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    // Location
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 14,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            property['city'] ?? 'Surat',
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

                    // Features
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildMiniFeature(
                          Icons.bed,
                          "${property['bedrooms']}",
                        ),
                        _buildMiniFeature(
                          Icons.bathtub,
                          "${property['bathrooms']}",
                        ),
                        _buildMiniFeature(
                          Icons.square_foot,
                          "${property['area']}",
                        ),
                      ],
                    ),

                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0066CC).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        property['listing_type'] ?? 'For Rent',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF0066CC),
                        ),
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

  Widget _buildMiniFeature(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xFF0066CC),
        ),
        const SizedBox(width: 2),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}
