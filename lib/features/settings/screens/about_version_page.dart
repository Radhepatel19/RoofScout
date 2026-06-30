import 'package:flutter/material.dart';
import 'package:roofscout/features/settings/screens/privacy_page.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutVersionPage extends StatefulWidget {
  const AboutVersionPage({super.key});

  @override
  State<AboutVersionPage> createState() => _AboutVersionPageState();
}

class _AboutVersionPageState extends State<AboutVersionPage> {
  final String _appVersion = "2.1.0";
  final String _buildNumber = "2024.12.01";

  final List<Map<String, dynamic>> _teamMembers = [
    {
      "name": "Radhe Patel",
      "role": "Founder & CEO",
      "image": "https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d",
    },
    {
      "name": "Priya Sharma",
      "role": "Product Lead",
      "image": "https://images.unsplash.com/photo-1494790108755-2616b786d4d2",
    },
    {
      "name": "Amit Kumar",
      "role": "Tech Lead",
      "image": "https://images.unsplash.com/photo-1500648767791-00dcc994a43e",
    },
    {
      "name": "Neha Singh",
      "role": "Design Head",
      "image": "https://images.unsplash.com/photo-1438761681033-6461ffad8d80",
    },
  ];

  final List<Map<String, dynamic>> _versionHistory = [
    {
      "version": "2.1.0",
      "date": "Dec 1, 2024",
      "changes": [
        "Added property price alerts",
        "Improved search filters",
        "Enhanced property verification",
        "Bug fixes and performance improvements"
      ],
    },
    {
      "version": "2.0.0",
      "date": "Nov 15, 2024",
      "changes": [
        "Redesigned user interface",
        "Added property owner dashboard",
        "Integrated payment gateway",
        "New notification system"
      ],
    },
    {
      "version": "1.5.0",
      "date": "Oct 20, 2024",
      "changes": [
        "Added video property tours",
        "Improved chat functionality",
        "Enhanced security features",
        "Location-based recommendations"
      ],
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
            titleSpacing: 0,
            elevation: 0,
            pinned: true,
            title: Text(
              "About RoofScout",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
              onPressed: () => Navigator.pop(context),
              color: Colors.black87,
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // App Logo & Version
                  Container(
                    padding: EdgeInsets.all(30),
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
                        Container(
                          width: 200,
                          height: 200,
                          child: Center(
                            child: IconButton(
                              onPressed: () {
                                // Your action
                              },
                              icon: Image.asset(
                                'assets/images/roof_scout.png',
                              ),
                            ),
                          ),
                        ),

                        Text(
                          "Find Your Perfect Home",
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF64748B),
                          ),
                        ),

                        SizedBox(height: 16),

                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            "Version $_appVersion",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0066FF),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // About Description
                  Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "About Us",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),

                        SizedBox(height: 12),

                        Text(
                          "RoofScout is India's fastest-growing property discovery platform, "
                              "helping millions find their dream homes. We connect buyers, sellers, "
                              "renters, and agents in a transparent and efficient marketplace.",
                          style: TextStyle(
                            fontSize: 15,
                            color: Color(0xFF64748B),
                            height: 1.6,
                          ),
                        ),

                        SizedBox(height: 16),

                        Row(
                          children: [
                            Icon(Icons.location_on_rounded, size: 18, color: Color(0xFF0066FF)),
                            SizedBox(width: 8),
                            Text(
                              "Headquarters: Surat, Gujarat",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(Icons.people_rounded, size: 18, color: Color(0xFF0066FF)),
                            SizedBox(width: 8),
                            Text(
                              "2M+ Users • 50K+ Properties",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF475569),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Team Section
                  Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Our Team",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "The passionate people behind RoofScout",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                          ),
                        ),

                        GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 1.2,
                          ),
                          itemCount: _teamMembers.length,
                          itemBuilder: (context, index) {
                            final member = _teamMembers[index];
                            return _buildTeamMemberCard(member);
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Version History
                  Container(
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
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Version History",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              "Build $_buildNumber",
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF64748B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 20),

                        Column(
                          children: _versionHistory.map((version) {
                            return _buildVersionCard(version);
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Links Section
                  Container(
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
                        ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.article_rounded,
                              size: 20,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          title: Text(
                            "Terms & Conditions",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                          onTap: () {
                            // Open terms page
                          },
                        ),

                        Divider(height: 1, color: Color(0xFFE2E8F0)),

                        ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF0066FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.privacy_tip_rounded,
                              size: 20,
                              color: Color(0xFF0066FF),
                            ),
                          ),
                          title: Text(
                            "Privacy Policy",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PrivacyPage(),
                              ),
                            );
                          },
                        ),

                        Divider(height: 1, color: Color(0xFFE2E8F0)),

                        ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF8B5CF6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.star_rounded,
                              size: 20,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                          title: Text(
                            "Rate Our App",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                          onTap: () async {
                            final url = Uri.parse(
                              'https://play.google.com/store/apps/details?id=com.roofscout.app',
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(url);
                            }
                          },
                        ),

                        Divider(height: 1, color: Color(0xFFE2E8F0)),

                        ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFFF59E0B).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.share_rounded,
                              size: 20,
                              color: Color(0xFFF59E0B),
                            ),
                          ),
                          title: Text(
                            "Share RoofScout",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                          onTap: () {
                            // Share app
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 32),

                  // Footer
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Color(0xFFE2E8F0)),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "© 2024 RoofScout Technologies Pvt. Ltd.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),

                        SizedBox(height: 8),

                        Text(
                          "All rights reserved",
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                          ),
                        ),

                        SizedBox(height: 16),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.facebook, size: 24),
                              color: Color(0xFF1877F2),
                              onPressed: () async {
                                final url = Uri.parse('https://facebook.com/roofscout');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                            ),

                            IconButton(
                              icon: Icon(Icons.camera_alt_rounded, size: 24),
                              color: Color(0xFFE4405F),
                              onPressed: () async {
                                final url = Uri.parse('https://instagram.com/roofscout');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                            ),

                            IconButton(
                              icon: Icon(Icons.link_rounded, size: 24),
                              color: Color(0xFF1DA1F2),
                              onPressed: () async {
                                final url = Uri.parse('https://twitter.com/roofscout');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
                            ),

                            IconButton(
                              icon: Icon(Icons.linked_camera_rounded, size: 24),
                              color: Color(0xFF0A66C2),
                              onPressed: () async {
                                final url = Uri.parse('https://linkedin.com/company/roofscout');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url);
                                }
                              },
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

  Widget _buildTeamMemberCard(Map<String, dynamic> member) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Color(0xFF0066FF), width: 2),
            image: DecorationImage(
              image: NetworkImage(member["image"]),
              fit: BoxFit.cover,
            ),
          ),
        ),

        SizedBox(height: 12),

        Text(
          member["name"],
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
          textAlign: TextAlign.center,
        ),

        SizedBox(height: 4),

        Text(
          member["role"],
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildVersionCard(Map<String, dynamic> version) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "v${version["version"]}",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
              Text(
                version["date"],
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          Column(
            children: (version["changes"] as List<String>).map((change) {
              return Padding(
                padding: EdgeInsets.only(bottom: 6),
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
                        change,
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}