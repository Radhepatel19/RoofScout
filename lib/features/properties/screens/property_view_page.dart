import 'dart:async';
import 'package:flutter/material.dart';
import 'package:roofscout/features/home/screens/menu_handler.dart';
import 'package:roofscout/features/properties/screens/property_details_page.dart';
import 'package:roofscout/features/properties/screens/property_filter_page.dart';
import 'package:roofscout/features/properties/screens/property_explore_page.dart';
import 'package:roofscout/features/properties/services/property_service.dart';
import 'package:roofscout/features/home/services/city_service.dart';
import 'package:roofscout/features/properties/services/saved_property_service.dart';
import 'package:roofscout/features/home/screens/select_city_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoofHomePage extends StatefulWidget {
  const RoofHomePage({super.key});

  @override
  State<RoofHomePage> createState() => _RoofHomePageState();
}

class _RoofHomePageState extends State<RoofHomePage> {
  final List<String> bannerList = [
    "https://images.unsplash.com/photo-1568605114967-8130f3a36994",
    "https://images.unsplash.com/photo-1600585154340-be6161a56a0c",
    "https://images.unsplash.com/photo-1598928506311-c55ded91a20c"
  ];

  final PageController _pageController = PageController();
  int currentIndex = 0;
  String selectedFilter = "Rent";
  Timer? _timer;
  Set<int> _favoritePropertyIds = {};
  int? _userId;
  bool _isTogglingFavorite = false;

  bool _isLoading = true;
  String _errorMsg = "";
  List<Map<String, dynamic>> _properties = [];
  List<Map<String, dynamic>> _Topproperties = [];

  String _selectedCityName = "Surat, Gujarat";
  String _avgPriceText = "₹45L";
  String _avgRatingText = "4.7";

  @override
  void initState() {
    super.initState();
    autoScrollSlider();
    _loadProperties();
  }

  Future<void> _loadProperties() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMsg = "";
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

      // 1. Fetch Selected City from database
      final myCity = await CityService.getMyCity();
      if (myCity != null && myCity.isNotEmpty) {
        _selectedCityName = myCity;
      } else {
        _selectedCityName = "Surat, Gujarat";
      }

      // 2. Fetch all properties
      final allProperties = await PropertyService.getProperties();

      if (mounted) {
        setState(() {
          // 3. FILTER properties to only display selected city's properties!
          final targetCity = _selectedCityName.split(',')[0].trim().toLowerCase();
          
          _properties = allProperties.where((p) {
            final pCity = (p['city'] ?? '').toString().trim().toLowerCase();
            return pCity == targetCity;
          }).toList();

          // Filter top rated properties within the selected city (rating >= 4.0)
          _Topproperties = _properties.where((p) {
            final r = p['rating'];
            if (r == null) return false;
            final doubleRating = r is num ? r.toDouble() : double.tryParse(r.toString()) ?? 0.0;
            return doubleRating >= 4.0;
          }).toList();

          // Calculate Dynamic Stats
          double totalPr = 0;
          for (var p in _properties) {
            totalPr += double.tryParse((p['price'] ?? 0).toString()) ?? 0;
          }
          double avgPr = _properties.isNotEmpty ? totalPr / _properties.length : 0;
          if (avgPr >= 10000000) {
            _avgPriceText = "₹${(avgPr / 10000000).toStringAsFixed(1)}Cr";
          } else if (avgPr >= 100000) {
            _avgPriceText = "₹${(avgPr / 100000).toStringAsFixed(0)}L";
          } else if (avgPr >= 1000) {
            _avgPriceText = "₹${(avgPr / 1000).toStringAsFixed(0)}K";
          } else {
            _avgPriceText = "₹0";
          }

          double totalRa = 0;
          for (var p in _properties) {
            var r = p['rating'];
            double dRating = r is num ? r.toDouble() : double.tryParse(r.toString()) ?? 4.5;
            totalRa += dRating;
          }
          double avgRa = _properties.isNotEmpty ? totalRa / _properties.length : 4.5;
          _avgRatingText = avgRa.toStringAsFixed(1);

          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  Future<void> finish(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstVisit', false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MenuHandler()),
      (route) => false,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void autoScrollSlider() {
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (currentIndex < bannerList.length - 1) {
        currentIndex++;
      } else {
        currentIndex = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          currentIndex,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF)))
          : CustomScrollView(
              slivers: [
                // App Bar
                SliverAppBar(
                  backgroundColor: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  elevation: 0,
                  pinned: true,
                  floating: true,
                  automaticallyImplyLeading: false,
                  expandedHeight: 85,
                  flexibleSpace: FlexibleSpaceBar(
                    collapseMode: CollapseMode.pin,
                    background: Container(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: MediaQuery.of(context).padding.top + 20,
                          left: 20,
                          right: 20,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Logo
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        finish(context);
                                      },
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Icon(
                                          Icons.arrow_back_ios_new_rounded,
                                          size: 18,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        RichText(
                                          text: const TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "Roof",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFF0066FF),
                                                ),
                                              ),
                                              TextSpan(
                                                text: "Scout",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.w800,
                                                  color: Color(0xFFFF6B35),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        GestureDetector(
                                          onTap: () async {
                                            final result = await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) => const SelectCityPage(returnResult: true),
                                              ),
                                            );
                                            if (result != null) {
                                              _loadProperties();
                                            }
                                          },
                                          child: Row(
                                            children: [
                                              const Icon(
                                                Icons.location_on_rounded,
                                                size: 14,
                                                color: Color(0xFF0066FF),
                                              ),
                                              const SizedBox(width: 4),
                                              Text(
                                                _selectedCityName,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  color: Color(0xFF64748B),
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                                // Notification Icon
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF1F5F9),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Stack(
                                    children: [
                                      const Center(
                                        child: Icon(
                                          Icons.notifications_none_rounded,
                                          size: 22,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                      Positioned(
                                        right: 10,
                                        top: 10,
                                        child: Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFFFF4757),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                // Main Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Search Bar
                        _buildSearchBar(),

                        const SizedBox(height: 20),

                        // Filter Chips
                        _buildFilterChips(),

                        const SizedBox(height: 24),

                        // Banner Slider
                        _buildBannerSlider(),

                        const SizedBox(height: 32),

                        // Quick Stats
                        _buildQuickStats(),

                        const SizedBox(height: 32),

                        // Popular Localities
                        _buildTopRatedProperties(),

                        const SizedBox(height: 32),

                        // Recommended Properties Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Recommended Properties",
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
                                "View All",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),

                // Properties List
                _properties.isEmpty
                    ? const SliverToBoxAdapter(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(40.0),
                            child: Text("No properties found in this location."),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: 20,
                                right: 20,
                                bottom: 20,
                              ),
                              child: _buildPropertyCard(_properties[index]),
                            );
                          },
                          childCount: _properties.length,
                        ),
                      ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: () {
        // Navigate to search page
      },
      child: Container(
        height: 56,
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
        child: Row(
          children: [
            // Search Icon
            const Padding(
              padding: EdgeInsets.only(left: 16, right: 12),
              child: Icon(
                Icons.search_rounded,
                color: Color(0xFF0066FF),
                size: 22,
              ),
            ),

            // Centered Text
            Expanded(
              child: Text(
                "Search for properties in ${_selectedCityName.split(',')[0]}",
                style: const TextStyle(
                  color: Color(0xFF94A3B8),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Filter Button
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF0066FF), Color(0xFF0052CC)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.tune_rounded,
                  color: Colors.white,
                  size: 22,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PropertyFilterPage(cityName: 'Surat'),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChips() {
    final List<String> filters = ["Rent", "Buy", "PG", "Commercial", "Plot"];

    return SizedBox(
      height: 42,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final isSelected = selectedFilter == filter;

          return GestureDetector(
            onTap: () {
              setState(() => selectedFilter = filter);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF0066FF) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected ? const Color(0xFF0066FF) : const Color(0xFFE2E8F0),
                  width: 1.5,
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0066FF).withOpacity(0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isSelected ? Colors.white : const Color(0xFF475569),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBannerSlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Featured Properties",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _pageController,
            itemCount: bannerList.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemBuilder: (_, index) {
              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Stack(
                    children: [
                      // Image
                      Positioned.fill(
                        child: Image.network(
                          bannerList[index],
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Gradient Overlay
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20),
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.8),
                                Colors.transparent,
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Content
                      Positioned(
                        left: 20,
                        bottom: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Premium Properties",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Discover your dream home",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),

        // Dots Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            bannerList.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              height: 6,
              width: currentIndex == index ? 20 : 8,
              decoration: BoxDecoration(
                color: currentIndex == index ? const Color(0xFF0066FF) : const Color(0xFFCBD5E1),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickStats() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF000000).withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("${_properties.length}+", "${_selectedCityName.split(',')[0]} Listings"),
              _buildStatItem(_avgPriceText, "Avg. Price"),
              _buildStatItem(_avgRatingText, "Avg. Rating"),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            height: 1,
            color: const Color(0xFFF1F5F9),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatItem("100%", "Verified"),
              _buildStatItem("<1 hr", "Response Time"),
              _buildStatItem(_selectedCityName.split(',')[0], "Verified Localities"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Color(0xFF0066FF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTopRatedProperties() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Top-Rated Properties",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PropertyExploreViewPage(name: 'Top-Rated Properties'),
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF0066FF),
                padding: EdgeInsets.zero,
              ),
              child: const Text(
                "View All",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 300,
          child: _Topproperties.isEmpty
              ? const Center(child: Text("No high-rated properties yet."))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _Topproperties.length,
                  itemBuilder: (context, index) {
                    final property = _Topproperties[index];
                    final images = property['images'] != null ? List<String>.from(property['images']) : [];
                    final imgUrl = images.isNotEmpty ? images[0] : bannerList[0];
                    final ratingVal = property['rating'] != null ? property['rating'].toString() : "4.5";
                    final propertyId = property['property_id'] ?? 1;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PropertyDetailsPage(propertyId: propertyId),
                          ),
                        );
                      },
                      child: Container(
                        width: 240,
                        margin: EdgeInsets.only(
                          right: index == _Topproperties.length - 1 ? 0 : 16,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
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
                            // Property Image with Favorite Button
                            Stack(
                              children: [
                                Container(
                                  height: 120,
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topLeft: Radius.circular(16),
                                      topRight: Radius.circular(16),
                                    ),
                                    image: DecorationImage(
                                      image: NetworkImage(imgUrl),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: GestureDetector(
                                    onTap: () => _toggleFavorite(propertyId),
                                    child: Container(
                                      padding: const EdgeInsets.all(6),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        _favoritePropertyIds.contains(propertyId) 
                                            ? Icons.bookmark_rounded 
                                            : Icons.bookmark_border_rounded,
                                        size: 20,
                                        color: _favoritePropertyIds.contains(propertyId) 
                                            ? const Color(0xFF0066FF) 
                                            : const Color(0xFF94A3B8),
                                      ),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 8,
                                  left: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0066FF),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(
                                          Icons.star,
                                          size: 12,
                                          color: Colors.white,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          ratingVal,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Property Type & Price
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF1F5F9),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          property['property_type'] ?? 'Apartment',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                      Text(
                                        "₹${(double.parse((property['price'] ?? 0).toString()) / 1000).toStringAsFixed(0)}K",
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0066FF),
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Property Name
                                  Text(
                                    property['title'] ?? 'Luxury Apartment',
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: Color(0xFF1E293B),
                                      height: 1.3,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),

                                  const SizedBox(height: 8),

                                  // Location
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on_outlined,
                                        size: 14,
                                        color: Color(0xFF64748B),
                                      ),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          property['full_address'] ?? 'Surat, Gujarat',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Color(0xFF64748B),
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),

                                  const SizedBox(height: 8),

                                  // Property Features
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 4,
                                    children: [
                                      _buildPropertyFeature(
                                        icon: Icons.bed_outlined,
                                        text: "${property['bedrooms'] ?? 2} Beds",
                                      ),
                                      _buildPropertyFeature(
                                        icon: Icons.bathtub_outlined,
                                        text: "${property['bathrooms'] ?? 2} Baths",
                                      ),
                                      _buildPropertyFeature(
                                        icon: Icons.square_foot_outlined,
                                        text: "${(property['area'] ?? 1200).toString().split('.')[0]} Sq Ft",
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
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildPropertyFeature({required IconData icon, required String text}) {
    return Row(
      children: [
        Icon(
          icon,
          size: 14,
          color: const Color(0xFF64748B),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildPropertyCard(Map<String, dynamic> property) {
    final price = double.parse((property['price'] ?? 0.0).toString());
    final isForRent = property['listing_type'].toString().toLowerCase() == 'rent';
    final priceText = isForRent
        ? "₹${(price / 1000).toStringAsFixed(0)}K/month"
        : "₹${(price / 1000000).toStringAsFixed(1)}Cr";

    final images = property['images'] != null ? List<String>.from(property['images']) : [];
    final imgUrl = images.isNotEmpty ? images[0] : bannerList[0];
    final ratingVal = property['rating'] != null ? property['rating'].toDouble() : 4.5;
    final amenities = property['amenities'] != null ? List<String>.from(property['amenities']) : <String>[];
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
              color: const Color(0xFF000000).withOpacity(0.05),
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

                // Favorite Button
                Positioned(
                  top: 16,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => _toggleFavorite(propertyId),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration:  BoxDecoration(
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
                        _favoritePropertyIds.contains(propertyId) ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                        size: 22,
                        color: _favoritePropertyIds.contains(propertyId) ? const Color(0xFF0066FF) : const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ),

                // Price Tag
                Positioned(
                  bottom: 16,
                  left: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
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
                if (property['is_available'] == true || property['is_available'] == 1)
                  Positioned(
                    top: 16,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF00B894),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Icon(
                            Icons.verified,
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
                              property['title'] ?? 'Premium Apartment',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "${property['bedrooms'] ?? 2} BHK ${property['furnishing'] ?? 'Furnished'}",
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
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

                  // Location
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Color(0xFF94A3B8),
                      ),
                      const SizedBox(width: 8),
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

                  const SizedBox(height: 20),

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
                          Icons.bed,
                          "${property['bedrooms'] ?? 2} Beds",
                        ),
                        _buildFeatureItem(
                          Icons.bathtub,
                          "${property['bathrooms'] ?? 2} Baths",
                        ),
                        _buildFeatureItem(
                          Icons.square_foot,
                          "${(property['area'] ?? 1200).toString().split('.')[0]} Sq Ft",
                        ),
                        _buildFeatureItem(
                          Icons.verified_user,
                          isForRent ? "For Rent" : "For Sale",
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Amenities
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: (amenities.isEmpty ? <String>['Prime Location', '24x7 Security'] : amenities)
                        .take(3)
                        .map((amenity) => Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0066FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                amenity,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0066FF),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ),

                  const SizedBox(height: 20),

                  // View Button
                  SizedBox(
                    width: double.infinity,
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
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "View Details",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 18),
                        ],
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
          size: 20,
          color: const Color(0xFF0066FF),
        ),
        const SizedBox(height: 8),
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