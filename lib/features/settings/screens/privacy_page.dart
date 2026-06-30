import 'package:flutter/material.dart';

class PrivacyPage extends StatefulWidget {
  const PrivacyPage({super.key});

  @override
  State<PrivacyPage> createState() => _PrivacyPageState();
}

class _PrivacyPageState extends State<PrivacyPage> {
  bool _enableDataCollection = true;
  bool _enablePersonalizedAds = false;
  bool _enableLocationTracking = true;
  bool _enableAnalytics = true;
  bool _shareDataWithPartners = false;

  int _dataRetentionPeriod = 12; // months
  bool _autoDeleteInactiveData = true;

  List<Map<String, dynamic>> _privacySections = [
    {
      "title": "Information We Collect",
      "content": [
        "Personal Information: Name, email, phone number, location",
        "Property Preferences: Search history, saved properties, viewing patterns",
        "Device Information: IP address, device type, operating system",
        "Usage Data: Interaction with app features, time spent on properties"
      ],
      "icon": Icons.collections_bookmark_rounded,
    },
    {
      "title": "How We Use Your Information",
      "content": [
        "To provide personalized property recommendations",
        "To connect you with verified property agents",
        "To improve our services and user experience",
        "To send important updates and notifications",
        "To ensure platform security and prevent fraud"
      ],
      "icon": Icons.settings_rounded,
    },
    {
      "title": "Data Sharing",
      "content": [
        "With Verified Partners: Property agents, builders, and developers",
        "Service Providers: Cloud storage, analytics, and customer support",
        "Legal Requirements: When required by law or legal process",
        "Business Transfers: In case of merger, acquisition, or sale"
      ],
      "icon": Icons.share_rounded,
    },
    {
      "title": "Your Rights",
      "content": [
        "Access your personal data",
        "Correct inaccurate information",
        "Delete your account and data",
        "Opt-out of marketing communications",
        "Export your data in readable format"
      ],
      "icon": Icons.gpp_good_rounded,
    },
  ];

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
            elevation: 1,
            titleSpacing: 0,
            pinned: true,
            title: Text(
              "Privacy & Security",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                width: 40,
                height: 40,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.black87,
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
                  // Privacy Score
                  _buildPrivacyScoreCard(),

                  SizedBox(height: 24),

                  // Privacy Controls
                  Text(
                    "Privacy Controls",
                    style: TextStyle(
                      fontSize: 20,
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
                        // Data Collection
                        _buildPrivacySetting(
                          Icons.data_usage_rounded,
                          "Data Collection",
                          "Allow RoofScout to collect usage data",
                          "Improves app experience and recommendations",
                          _enableDataCollection,
                              (value) {
                            setState(() {
                              _enableDataCollection = value;
                            });
                          },
                        ),

                        Divider(height: 1, color: Color(0xFFE2E8F0)),

                        // Personalized Ads
                        _buildPrivacySetting(
                          Icons.ads_click_rounded,
                          "Personalized Ads",
                          "Show personalized property recommendations",
                          "Based on your search history and preferences",
                          _enablePersonalizedAds,
                              (value) {
                            setState(() {
                              _enablePersonalizedAds = value;
                            });
                          },
                        ),

                        Divider(height: 1, color: Color(0xFFE2E8F0)),

                        // Location Tracking
                        _buildPrivacySetting(
                          Icons.location_on_rounded,
                          "Location Services",
                          "Use your location for property suggestions",
                          "Required for accurate property recommendations",
                          _enableLocationTracking,
                              (value) {
                            setState(() {
                              _enableLocationTracking = value;
                            });
                          },
                        ),

                        Divider(height: 1, color: Color(0xFFE2E8F0)),

                        // Analytics
                        _buildPrivacySetting(
                          Icons.analytics_rounded,
                          "Analytics",
                          "Share anonymous usage data",
                          "Helps us improve the app experience",
                          _enableAnalytics,
                              (value) {
                            setState(() {
                              _enableAnalytics = value;
                            });
                          },
                        ),

                        Divider(height: 1, color: Color(0xFFE2E8F0)),

                        // Share with Partners
                        _buildPrivacySetting(
                          Icons.handshake_rounded,
                          "Share with Partners",
                          "Share data with verified property partners",
                          "Enables better property recommendations",
                          _shareDataWithPartners,
                              (value) {
                            setState(() {
                              _shareDataWithPartners = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Data Retention
                  Text(
                    "Data Management",
                    style: TextStyle(
                      fontSize: 20,
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
                        // Data Retention Period
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xFF0066FF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.schedule_rounded,
                                  size: 20,
                                  color: Color(0xFF0066FF),
                                ),
                              ),

                              SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Data Retention Period",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "How long we keep your data",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Text(
                                "$_dataRetentionPeriod months",
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF0066FF),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                          child: Slider(
                            value: _dataRetentionPeriod.toDouble(),
                            min: 1,
                            max: 36,
                            divisions: 35,
                            label: "$_dataRetentionPeriod months",
                            activeColor: Color(0xFF0066FF),
                            inactiveColor: Color(0xFFE2E8F0),
                            onChanged: (value) {
                              setState(() {
                                _dataRetentionPeriod = value.toInt();
                              });
                            },
                          ),
                        ),

                        Divider(height: 1, color: Color(0xFFE2E8F0)),

                        // Auto Delete Inactive Data
                        Padding(
                          padding: EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: Color(0xFF0066FF).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.delete_outline_rounded,
                                  size: 20,
                                  color: Color(0xFF0066FF),
                                ),
                              ),

                              SizedBox(width: 16),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Auto-Delete Inactive Data",
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Automatically delete data after 6 months of inactivity",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Switch.adaptive(
                                value: _autoDeleteInactiveData,
                                onChanged: (value) {
                                  setState(() {
                                    _autoDeleteInactiveData = value;
                                  });
                                },
                                activeColor: Color(0xFF0066FF),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Privacy Policy Sections
                  Text(
                    "Privacy Policy",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  SizedBox(height: 16),

                  Column(
                    children: _privacySections.map((section) {
                      return _buildPrivacySection(section);
                    }).toList(),
                  ),

                  SizedBox(height: 24),

                  // Action Buttons
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
                        // Download Data
                        ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.download_rounded,
                              size: 20,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          title: Text(
                            "Download My Data",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          subtitle: Text(
                            "Get a copy of all your personal data",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                          onTap: () {
                            // Download data
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Preparing your data download..."),
                                backgroundColor: Color(0xFF10B981),
                              ),
                            );
                          },
                        ),

                        Divider(height: 1, color: Color(0xFFE2E8F0)),

                        // Delete Account
                        ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFFEF4444).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.delete_forever_rounded,
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
                          subtitle: Text(
                            "Permanently delete your account and all data",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFFEF4444),
                          ),
                          onTap: () {
                            _showDeleteAccountDialog();
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Footer
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Last Updated: December 1, 2024",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          "RoofScout is committed to protecting your privacy. We follow industry best practices and comply with applicable data protection regulations.",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            height: 1.5,
                          ),
                        ),

                        SizedBox(height: 12),

                        Row(
                          children: [
                            Icon(Icons.shield_rounded, size: 16, color: Color(0xFF10B981)),
                            SizedBox(width: 6),
                            Text(
                              "GDPR Compliant",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            SizedBox(width: 16),
                            Icon(Icons.verified_user_rounded, size: 16, color: Color(0xFF0066FF)),
                            SizedBox(width: 6),
                            Text(
                              "Data Encrypted",
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF0066FF),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyScoreCard() {
    int score = 85; // Calculate based on privacy settings

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
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFF0066FF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  Icons.privacy_tip_rounded,
                  size: 28,
                  color: Color(0xFF0066FF),
                ),
              ),

              SizedBox(width: 16),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Your Privacy Score",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Based on your current privacy settings",
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),

              Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getScoreColor(score).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$score/100",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: _getScoreColor(score),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          LinearProgressIndicator(
            value: score / 100,
            backgroundColor: Color(0xFFE2E8F0),
            color: _getScoreColor(score),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),

          SizedBox(height: 8),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Low Privacy",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFFEF4444),
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                score >= 80 ? "Excellent" : score >= 60 ? "Good" : "Needs Improvement",
                style: TextStyle(
                  fontSize: 12,
                  color: _getScoreColor(score),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                "Maximum Privacy",
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF10B981),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 80) return Color(0xFF10B981);
    if (score >= 60) return Color(0xFFF59E0B);
    return Color(0xFFEF4444);
  }

  Widget _buildPrivacySetting(
      IconData icon,
      String title,
      String subtitle,
      String description,
      bool value,
      Function(bool) onChanged,
      ) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFF0066FF).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              size: 20,
              color: Color(0xFF0066FF),
            ),
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Color(0xFF94A3B8),
                  ),
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

  Widget _buildPrivacySection(Map<String, dynamic> section) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Color(0xFF0066FF).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            section["icon"],
            size: 20,
            color: Color(0xFF0066FF),
          ),
        ),
        title: Text(
          section["title"],
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: (section["content"] as List<String>).map((item) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.circle,
                        size: 6,
                        color: Color(0xFF0066FF),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item,
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        tilePadding: EdgeInsets.symmetric(horizontal: 20),
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Delete Account",
          style: TextStyle(
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Are you sure you want to delete your account?",
              style: TextStyle(
                fontSize: 15,
                color: Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFEE2E2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Color(0xFFDC2626), size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "This action cannot be undone. All your data will be permanently deleted.",
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFFDC2626),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "Cancel",
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAccount();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFFEF4444),
              foregroundColor: Colors.white,
            ),
            child: Text("Delete Account"),
          ),
        ],
      ),
    );
  }

  void _deleteAccount() {
    // Delete account logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Account deletion request submitted. You'll receive a confirmation email."),
        backgroundColor: Color(0xFFEF4444),
      ),
    );
  }
}