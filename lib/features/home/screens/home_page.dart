import 'package:flutter/material.dart';
import 'package:roofscout/features/auth/screens/login_page.dart';
import 'package:roofscout/features/home/screens/select_city_page.dart';
import 'package:roofscout/features/properties/screens/property_filter_page.dart';
import 'package:roofscout/features/properties/screens/property_view_page.dart';
import 'package:roofscout/features/properties/screens/review_property_page.dart';
import 'package:roofscout/features/home/services/city_service.dart';
import 'package:roofscout/features/properties/services/property_service.dart';
import 'package:roofscout/features/properties/widgets/bhk_choice_widget.dart';
import 'package:roofscout/features/home/widgets/explore_popular_cities.dart';
import 'package:roofscout/features/home/widgets/home_by_furnishing_widget.dart';
import 'package:roofscout/features/properties/widgets/locality_rating_widget.dart';
import 'package:roofscout/features/properties/widgets/property_type_widget.dart';
import 'package:roofscout/features/home/widgets/recently_posted_widget.dart';
import 'package:roofscout/features/home/widgets/recommended_properties_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:roofscout/features/auth/services/user_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _showElevatedAppBar = false;
  String _city = "Select City";
  bool _isLoadingProperties = true;
  List<Map<String, dynamic>> _filteredProperties = [];


  Future<void> _loadProperties() async {
    setState(() {
      _isLoadingProperties = true;
    });
    try {
      final city = await CityService.getMyCity();
      if (city != null) {
        setState(() {
          _city = city;
        });
      }

      final allProperties = await PropertyService.getProperties();
      
      setState(() {
        
        final targetCity = _city.split(',')[0].trim().toLowerCase();
        _filteredProperties = allProperties.where((p) {
          final pCity = (p['city'] ?? '').toString().trim().toLowerCase();
          return pCity == targetCity;
        }).toList();
        
        _isLoadingProperties = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingProperties = false;
      });
    }
  }

  String? _profileImageUrl;

  Future<void> _initApp() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("token");
    final userId = prefs.getInt("user_id");

    if (token == null || token.isEmpty) {
      // Not logged in
      Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
      return;
    }

    if (userId != null) {
      try {
        final result = await UserService.getUserProfile(userId);
        if (result["success"] && result["data"] != null) {
          setState(() {
            _profileImageUrl = result["data"]["profile_picture"];
          });
        }
      } catch (e) {
        print("Error fetching profile on home: $e");
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_scrollListener);
    _initApp();
    _loadProperties();
  }

  void _scrollListener() {
    if (_scrollController.offset > 100 && !_showElevatedAppBar) {
      setState(() => _showElevatedAppBar = true);
    } else if (_scrollController.offset <= 100 && _showElevatedAppBar) {
      setState(() => _showElevatedAppBar = false);
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: _showElevatedAppBar ? 4 : 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        toolbarHeight: 80,

        // LEFT SIDE 🎯 (Profile & Location)
        title: Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Row(
            children: [
              // Profile Avatar with Badge
              Stack(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF0066FF).withOpacity(0.2),
                        width: 2,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.grey[100],
                      backgroundImage: _profileImageUrl != null && _profileImageUrl!.isNotEmpty
                          ? NetworkImage(_profileImageUrl!)
                          : const NetworkImage(
                              "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100",
                            ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: Colors.green,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 16),

              // Location and Greeting
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Welcome back!",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    GestureDetector(
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const SelectCityPage(returnResult: true),
                          ),
                        );
                        _loadProperties();
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.location_on_rounded,
                            size: 18,
                            color: const Color(0xFF0066FF),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _city,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[900],
                            ),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 20,
                            color: Colors.grey[600],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // RIGHT SIDE 🎯 (Notifications & Chat)
        actions: [
          // Notification Icon

          // Chat Icon
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Stack(
              children: [
                IconButton(
                  onPressed: () {
                    // Navigate to chat page
                  },
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey[200]!, width: 1.5),
                    ),
                    child: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 22,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Positioned(
                  right: 10,
                  top: 10,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Color(0xFF0066FF),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),

      body: CustomScrollView(
        controller: _scrollController,
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 🔍 SEARCH BAR
                  _buildProfessionalSearchBar(),

                  const SizedBox(height: 24),

                  // 🏠 CATEGORIES SECTION
                  _buildCategoriesHeader(),

                  const SizedBox(height: 16),

                  // 🔵 CATEGORY GRID
                  _buildCategoryGrid(),

                  const SizedBox(height: 32),

                  // 📍 RECOMMENDED PROPERTIES
                  _buildSectionHeader(
                    title: "Recommended for you",
                    subtitle: "Based on your preferences",
                    onViewAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoofHomePage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  _isLoadingProperties
                      ? const SizedBox(
                          height: 180,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF0066FF),
                            ),
                          ),
                        )
                      : RecommendedPropertiesWidget(properties: _filteredProperties),

                  const SizedBox(height: 32),

                  // 🆕 RECENTLY POSTED
                  _buildSectionHeader(
                    title: "Recently Posted",
                    subtitle: "Fresh listings in your area",
                    onViewAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoofHomePage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  _isLoadingProperties
                      ? const SizedBox(
                          height: 180,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF0066FF),
                            ),
                          ),
                        )
                      : RecentlyPostedWidget(properties: _filteredProperties),

                  const SizedBox(height: 32),

                  // 🏘️ PROPERTY TYPES
                  _buildSectionHeader(
                    title: "Explore by Property Type",
                    subtitle: "Find your perfect match",
                  ),

                  const SizedBox(height: 16),
                  const PropertyTypeWidget(),

                  const SizedBox(height: 32),

                  // 🛋️ FURNISHING TYPES
                  _buildSectionHeader(
                    title: "Homes by Furnishing",
                    subtitle: "Choose your comfort level",
                  ),

                  const SizedBox(height: 16),
                  const HomeByFurnishingWidget(),

                  const SizedBox(height: 32),

                  // 🛏️ BHK CHOICES
                  _buildSectionHeader(
                    title: "Popular BHK Choices",
                    subtitle: "Most searched configurations",
                  ),

                  const SizedBox(height: 16),
                  const BhkChoiceWidget(),

                  const SizedBox(height: 32),

                  // ⭐ LOCALITY RATINGS
                  _buildSectionHeader(
                    title: "Locality Ratings & Reviews",
                    subtitle: "Based on resident reviews",
                    onViewAll: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ReviewPropertyPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 16),
                  const LocalityRatingWidget(),

                  const SizedBox(height: 32),

                  // 🏙️ POPULAR CITIES
                  _buildSectionHeader(
                    title: "Explore Popular Cities",
                    subtitle: "Properties across India",
                  ),

                  const SizedBox(height: 16),
                  const ExplorePopularCities(),

                  const SizedBox(height: 32),

                  // 📝 FEEDBACK SECTION
                  _buildFeedbackSection(),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Professional Search Bar
  Widget _buildProfessionalSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[100]!,
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        decoration: InputDecoration(
          hintText: "Search properties, localities, builders...",
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 15),
          prefixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.search_rounded,
              size: 24,
              color: const Color(0xFF0066FF),
            ),
          ),
          suffixIcon: Container(
            padding: const EdgeInsets.all(12),
            child: GestureDetector(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PropertyFilterPage(cityName: "Surat"),
                  ),
                  (route) => false,
                );
              },
              child: Icon(Icons.tune, size: 20, color: Colors.grey[500]),
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        onChanged: (text) {
          // Handle search
        },
      ),
    );
  }

  // Categories Header
  Widget _buildCategoriesHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Categories",
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: Colors.grey[900],
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  // Category Grid
  Widget _buildCategoryGrid() {
    final categories = [
      {
        'icon': Icons.home_work_outlined,
        'label': 'Buy',
        'color': const Color(0xFF0066FF),
        'bgColor': const Color(0xFF0066FF).withOpacity(0.1),
      },
      {
        'icon': Icons.key_outlined,
        'label': 'Rent',
        'color': const Color(0xFF00C853),
        'bgColor': const Color(0xFF00C853).withOpacity(0.1),
      },
      {
        'icon': Icons.business_outlined,
        'label': 'PG/Hostel',
        'color': const Color(0xFFFF6B00),
        'bgColor': const Color(0xFFFF6B00).withOpacity(0.1),
      },
      {
        'icon': Icons.store_mall_directory_outlined,
        'label': 'Commercial',
        'color': const Color(0xFF9C27B0),
        'bgColor': const Color(0xFF9C27B0).withOpacity(0.1),
      },
      {
        'icon': Icons.landscape_outlined,
        'label': 'Plots/Land',
        'color': const Color(0xFF795548),
        'bgColor': const Color(0xFF795548).withOpacity(0.1),
      },
      {
        'icon': Icons.account_balance_outlined,
        'label': 'Home Loan',
        'color': const Color(0xFFF44336),
        'bgColor': const Color(0xFFF44336).withOpacity(0.1),
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.1,
      ),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => RoofHomePage()),
            );
          },
          child: Container(
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
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: category['bgColor'] as Color,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    size: 28,
                    color: category['color'] as Color,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  category['label'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[800],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Section Header
  Widget _buildSectionHeader({
    required String title,
    String? subtitle,
    VoidCallback? onViewAll,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: Colors.grey[900],
                      letterSpacing: -0.3,
                    ),
                  ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (onViewAll != null)
              TextButton(
                onPressed: onViewAll,
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF0066FF),
                  padding: EdgeInsets.zero,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "View all",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0066FF),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 14,
                      color: const Color(0xFF0066FF),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 4,
          width: 60,
          decoration: BoxDecoration(
            color: const Color(0xFF0066FF),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }

  // Feedback Section
  Widget _buildFeedbackSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0066FF), Color(0xFF0052CC)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0066FF).withOpacity(0.3),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Are you finding us helpful?",
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Your feedback helps us improve your experience",
            style: TextStyle(
              fontSize: 15,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0066FF),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Rate Us",
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white,
                  side: const BorderSide(color: Colors.white),
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 24,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "Give Feedback",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
