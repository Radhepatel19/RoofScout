import 'package:flutter/material.dart';
import 'package:roofscout/features/settings/screens/about_version_page.dart';
import 'package:roofscout/features/profile/screens/edit_profile_page.dart';
import 'package:roofscout/features/settings/screens/help_support_page.dart';
import 'package:roofscout/features/settings/screens/privacy_page.dart';
import 'package:roofscout/features/home/screens/selection_page.dart';
import 'package:roofscout/features/post_property/screens/property_see_pages.dart';
import 'package:roofscout/features/post_property/screens/property_steps_page.dart';
import 'package:roofscout/features/post_property/screens/property_login_page.dart';

import 'package:roofscout/features/properties/services/property_service.dart';
import 'package:roofscout/features/auth/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ProfilePage extends StatefulWidget {
  final Function(int) onNavigateToTab;
  const ProfilePage({super.key, required this.onNavigateToTab});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isNotificationsEnabled = true;
  bool _isBiometricEnabled = false;
  int _selectedTab = 0; // 0: Profile, 1: Settings

  List<Map<String, dynamic>> _postedProperties = [];
  final Map<String, dynamic> _userProfile = {
    "name": "Loading...",
    "email": "Loading...",
    "phone": "Loading...",
    "location": "Loading...",
    "memberSince": "",
    "profileImage": "",
    "propertiesSaved": 0,
    "propertiesViewed": 0,
    "inquiriesSent": 0,
    "isVerified": false,
    "userType": "Loading...", // Added this field
  };

  List<Map<String, dynamic>> _savedProperties = [];

  List<Map<String, dynamic>> _recentActivities = [];
  @override
  void initState() {
    super.initState();
    _fetchInitialData();
  }

  Future<void> _fetchInitialData() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id");
    final role = prefs.getString("user_role");

    if (userId != null) {
      final profileResponse = await UserService.getUserProfile(userId);
      if (profileResponse["success"] == true) {
        final data = profileResponse["data"];
        setState(() {
          _userProfile["name"] = data["full_name"] ?? _userProfile["name"];
          _userProfile["email"] = data["email"] ?? _userProfile["email"];
          _userProfile["phone"] = data["phone"] ?? _userProfile["phone"];
          _userProfile["location"] = data["city"] ?? _userProfile["location"];
          _userProfile["userType"] = role == "owner" ? "Property Owner" : "Broker";
          _userProfile["profileImage"] = data["profile_picture"] ?? _userProfile["profileImage"];
        });
      }
    }

    if (role == "owner") {
      try {
        final properties = await PropertyService.getMyProperties();
        setState(() {
          _postedProperties = properties.map((p) => {
            "id": p["property_id"].toString(),
            "title": p["title"],
            "location": "${p["city"]}, ${p["state"]}",
            "price": "₹${p["price"]}",
            "status": p["is_available"] ? "Active" : "Pending",
            "views": p["views_count"] ?? 0,
            "inquiries": p["enquiries_count"] ?? 0,
            "image": (p["images"] != null && p["images"].isNotEmpty) 
                ? p["images"][0] 
                : "https://images.unsplash.com/photo-1613490493576-7fde63acd811",
            "postedDate": p["created_at"].toString().split('T')[0],
            "isVerified": p["is_verified"] ?? false,
          }).toList();
        });
      } catch (e) {
        debugPrint("Error fetching properties: $e");
      }
    }
  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();

    // Clear user session data
    await prefs.clear();
    // OR if you want to keep other values:
    // await prefs.remove('isLoggedIn');

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const SelectionScreen()),
      (route) => false, // 🔥 clears all previous screens
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            pinned: true,
            automaticallyImplyLeading: false,
            title: Text(
              "My Profile",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.grey[900],
                letterSpacing: -0.5,
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
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: IconButton(
                    icon: Icon(Icons.edit_rounded, size: 20),
                    onPressed: () async {
                      // Edit profile
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      );
                      _fetchInitialData();
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
                children: [
                  // Profile Header Card
                  _buildProfileHeader(),

                  SizedBox(height: 24),

                  // Tab Selection
                  _buildTabSelector(),

                  SizedBox(height: 24),

                  // Content based on selected tab
                  if (_selectedTab == 0)
                    _buildProfileContent(widget.onNavigateToTab),
                  if (_selectedTab == 1) _buildSettingsContent(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Container(
      padding: EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image & Info
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Image
              Stack(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(40),
                      border: Border.all(color: Color(0xFF0066FF), width: 3),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(37),
                      child: Image.network(
                        _userProfile["profileImage"],
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Color(0xFF0066FF).withOpacity(0.1),
                            child: Icon(
                              Icons.person,
                              size: 40,
                              color: Color(0xFF0066FF),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(width: 20),

              // User Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          _userProfile["name"],
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 8),

                    Row(
                      children: [
                        Icon(
                          Icons.email_outlined,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        SizedBox(width: 8),
                        Text(
                          _userProfile["email"],
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        SizedBox(width: 8),
                        Text(
                          _userProfile["phone"],
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),

                    SizedBox(height: 4),

                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 16,
                          color: Color(0xFF94A3B8),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "Member since ${_userProfile["memberSince"]}",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24),

          // Stats Grid
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  "Properties Saved",
                  _userProfile["propertiesSaved"].toString(),
                  Icons.bookmark_rounded,
                ),
                _buildStatItem(
                  "Properties Viewed",
                  _userProfile["propertiesViewed"].toString(),
                  Icons.remove_red_eye_rounded,
                ),
                _buildStatItem(
                  "Inquiries Sent",
                  _userProfile["inquiriesSent"].toString(),
                  Icons.message_rounded,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFF0066FF).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 24, color: Color(0xFF0066FF)),
        ),
        SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTabSelector() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 0;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _selectedTab == 0
                      ? Color(0xFF0066FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_outline_rounded,
                      size: 20,
                      color: _selectedTab == 0
                          ? Colors.white
                          : Color(0xFF94A3B8),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Profile",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _selectedTab == 0
                            ? Colors.white
                            : Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Settings Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 1;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _selectedTab == 1
                      ? Color(0xFF0066FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.settings_outlined,
                      size: 20,
                      color: _selectedTab == 1
                          ? Colors.white
                          : Color(0xFF94A3B8),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "Settings",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _selectedTab == 1
                            ? Colors.white
                            : Color(0xFF64748B),
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

  Widget _buildProfileContent(Function(int) onNavigateToTab) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Saved Properties
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Saved Properties",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            TextButton(
              onPressed: () {
                onNavigateToTab(2); // 👉 Favorite tab
              },
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF0066FF),
                padding: EdgeInsets.zero,
              ),
              child: Text(
                "View All",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),

        SizedBox(height: 12),

        // Saved Properties List
        if (_savedProperties.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.bookmark_border_rounded, size: 48, color: Colors.grey[300]),
                SizedBox(height: 12),
                Text(
                  "No Saved Properties",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                ),
                SizedBox(height: 4),
                Text(
                  "Properties you save will appear here.",
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 195,
            child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _savedProperties.length,
            itemBuilder: (context, index) {
              final property = _savedProperties[index];
              return GestureDetector(
                onTap: () {
                  onNavigateToTab(2);
                },
                child: Container(
                  width: 160,
                  margin: EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Property Image
                      ClipRRect(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                        child: Image.network(
                          property["image"],
                          height: 100,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),

                      // Property Details
                      Padding(
                        padding: EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property["title"],
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF1E293B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: 4),

                            Text(
                              property["location"],
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),

                            SizedBox(height: 6),

                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  property["price"],
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0066FF),
                                  ),
                                ),
                                Icon(
                                  Icons.bookmark_rounded,
                                  size: 16,
                                  color: Color(0xFFEF4444),
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

        SizedBox(height: 24),

        // Post Property Section
        Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Post Your Property",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Color(0xFF10B981),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      "OWNER",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              Text(
                "List your property for sale or rent on RoofScout",
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),

              SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PropertyLoginPage(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF10B981),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_home_work_rounded, size: 20),
                          SizedBox(width: 8),
                          Text(
                            "Post New Property",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        // Add this in _buildProfileContent() after Recent Activities section
        SizedBox(height: 24),

        // My Listed Properties Section
        if (_userProfile["userType"] == "Property Owner" ||
            _postedProperties.isNotEmpty)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "My Listed Properties",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  Row(
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PropertySeePages(),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Color(0xFF0066FF),
                          padding: EdgeInsets.zero,
                        ),
                        child: Text(
                          "View All",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.add, size: 18, color: Colors.white),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const PropertyStepsPages(),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              SizedBox(height: 12),

              if (_postedProperties.isEmpty)
                Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.home_work_outlined,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 12),
                      Text(
                        "No Properties Listed",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "List your first property to start earning",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PropertySeePages(),
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Color(0xFF10B981),
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_home_work_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                "Post Your First Property",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 16,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    children: _postedProperties.take(2).map((property) {
                      return Column(
                        children: [
                          _buildMyPropertyItem(property),
                          if (_postedProperties.indexOf(property) < 1 &&
                              _postedProperties.length > 1)
                            Divider(height: 1, color: Color(0xFFE2E8F0)),
                        ],
                      );
                    }).toList(),
                  ),
                ),
            ],
          ),

        SizedBox(height: 24),

        // Recent Activities
        Text(
          "Recent Activities",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 24),

        // Activities List
        if (_recentActivities.isEmpty)
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(Icons.history_rounded, size: 48, color: Colors.grey[300]),
                SizedBox(height: 12),
                Text(
                  "No Recent Activities",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E293B)),
                ),
                SizedBox(height: 4),
                Text(
                  "Your recent activities will appear here.",
                  style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: List.generate(_recentActivities.length, (index) {
              final activity = _recentActivities[index];
              return Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: activity["color"].withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        activity["icon"],
                        size: 20,
                        color: activity["color"],
                      ),
                    ),

                    SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activity["title"],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            activity["description"],
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),

                    Text(
                      activity["time"],
                      style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    ),
                  ],
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildMyPropertyItem(Map<String, dynamic> property) {
    Color statusColor = property["status"] == "Active"
        ? Color(0xFF10B981)
        : property["status"] == "Pending"
        ? Color(0xFFF59E0B)
        : Color(0xFFEF4444);

    return Padding(
      padding: EdgeInsets.all(16),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PropertySeePages()),
          );
        },
        child: Row(
          children: [
            // Property Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                image: DecorationImage(
                  image: NetworkImage(property["image"]),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(width: 16),

            // Property Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        property["title"],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E293B),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: statusColor.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          property["status"],
                          style: TextStyle(
                            fontSize: 11,
                            color: statusColor,
                            fontWeight: FontWeight.w700,
                          ),
                        )
                      ),
                    ],
                  ),

                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property["location"],
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF64748B),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4),

                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12,
                        color: Color(0xFF94A3B8),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "Posted on: ${property["postedDate"]}",
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        property["price"],
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0066FF),
                        ),
                      ),
                      Row(
                        children: [
                          Column(
                            children: [
                              Icon(
                                Icons.remove_red_eye_outlined,
                                size: 14,
                                color: Color(0xFF94A3B8),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "${property["views"]}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(width: 12),
                          Column(
                            children: [
                              Icon(
                                Icons.message_outlined,
                                size: 14,
                                color: Color(0xFF94A3B8),
                              ),
                              SizedBox(height: 2),
                              Text(
                                "${property["inquiries"]}",
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF64748B),
                                ),
                              ),
                            ],
                          ),
                        ],
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

  Widget _buildSettingsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Account Settings",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),

        SizedBox(height: 16),

        // Settings List
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Notification Settings
              _buildSettingsItem(
                Icons.notifications_active_rounded,
                "Notifications",
                "Manage your notification preferences",
                _isNotificationsEnabled,
                (value) {
                  setState(() {
                    _isNotificationsEnabled = value;
                  });
                },
              ),

              Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Biometric Login
              _buildSettingsItem(
                Icons.fingerprint_rounded,
                "Biometric Login",
                "Use fingerprint or face ID",
                _isBiometricEnabled,
                (value) {
                  setState(() {
                    _isBiometricEnabled = value;
                  });
                },
              ),

              Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Privacy Settings
              _buildSettingsTile(
                Icons.privacy_tip_rounded,
                "Privacy Settings",
                "Manage your data and privacy",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PrivacyPage(),
                    ),
                  );
                },
              ),

              Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Help & Support
              _buildSettingsTile(
                Icons.help_outline_rounded,
                "Help & Support",
                "Get help or contact support",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const HelpSupportPage(),
                    ),
                  );
                },
              ),

              Divider(height: 1, color: Color(0xFFE2E8F0)),

              // About
              _buildSettingsTile(
                Icons.info_outline_rounded,
                "About",
                "App version 2.1.0",
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AboutVersionPage(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),

        SizedBox(height: 24),

        // Account Actions
        Text(
          "Account Actions",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),

        SizedBox(height: 16),

        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // Logout Button
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFF0066FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    size: 20,
                    color: Color(0xFF0066FF),
                  ),
                ),
                title: Text(
                  "Logout",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                onTap: () {
                  logout(context);
                },
              ),

              Divider(height: 1, color: Color(0xFFE2E8F0)),

              // Delete Account Button
              ListTile(
                leading: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Color(0xFFEF4444).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: Color(0xFFEF4444),
                  ),
                ),
                title: Text(
                  "Delete Account",
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFEF4444),
                  ),
                ),
                onTap: () {
                  _showDeleteAccountDialog(context);
                },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsItem(
    IconData icon,
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF0066FF).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Color(0xFF0066FF)),
          ),

          SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E293B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ),

          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: Color(0xFF0066FF),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            "Delete Account",
            style: TextStyle(fontWeight: FontWeight.w800),
          ),
          content: const Text(
            "Are you sure you want to delete your account?\nThis action cannot be undone.",
            style: TextStyle(height: 1.4),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF4444),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                logout(context);
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSettingsTile(
    IconData icon,
    String title,
    String subtitle,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Color(0xFF0066FF).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 20, color: Color(0xFF0066FF)),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1E293B),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
      ),
      trailing: Icon(
        Icons.chevron_right_rounded,
        size: 20,
        color: Color(0xFF94A3B8),
      ),
      onTap: onTap,
    );
  }
}
