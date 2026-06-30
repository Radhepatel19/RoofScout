import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  final Function(int) onNavigateToTab;
  const NotificationPage({super.key,required this.onNavigateToTab});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  bool _showUnreadOnly = false;
  int _selectedTab = 0; // 0: All, 1: Important, 2: Updates

  final List<Map<String, dynamic>> _allNotifications = [
    {
      "id": "1",
      "title": "New Property Match!",
      "message": "A 3BHK apartment in Vesu matches your preferences.",
      "time": "Just now",
      "type": "property_match",
      "isRead": false,
      "icon": Icons.home_work_rounded,
      "color": Color(0xFF0066FF),
      "action": "View Property",
    },
    {
      "id": "2",
      "title": "Price Drop Alert",
      "message": "The villa in Adajan you saved has reduced price by ₹5L.",
      "time": "10 min ago",
      "type": "price_drop",
      "isRead": false,
      "icon": Icons.arrow_downward_rounded,
      "color": Color(0xFF10B981),
      "action": "Check Price",
    },
    {
      "id": "3",
      "title": "Your Viewing is Confirmed",
      "message": "Your property viewing for tomorrow at 4 PM is confirmed.",
      "time": "1 hour ago",
      "type": "booking",
      "isRead": true,
      "icon": Icons.calendar_today_rounded,
      "color": Color(0xFF8B5CF6),
      "action": "View Details",
    },
    {
      "id": "4",
      "title": "New Message from Agent",
      "message": "Raj Mehta sent you a message about your inquiry.",
      "time": "2 hours ago",
      "type": "message",
      "isRead": true,
      "icon": Icons.message_rounded,
      "color": Color(0xFFF59E0B),
      "action": "Reply",
    },
    {
      "id": "5",
      "title": "Trending in Vesu",
      "message": "Check out the top trending properties in Vesu locality.",
      "time": "5 hours ago",
      "type": "trending",
      "isRead": true,
      "icon": Icons.trending_up_rounded,
      "color": Color(0xFFEF4444),
      "action": "Explore",
    },
    {
      "id": "6",
      "title": "Document Verification Complete",
      "message": "Your KYC documents have been successfully verified.",
      "time": "1 day ago",
      "type": "verification",
      "isRead": true,
      "icon": Icons.verified_rounded,
      "color": Color(0xFF10B981),
      "action": "View Status",
    },
    {
      "id": "7",
      "title": "Rent Payment Reminder",
      "message": "Your rent payment for March is due in 3 days.",
      "time": "2 days ago",
      "type": "payment",
      "isRead": true,
      "icon": Icons.payment_rounded,
      "color": Color(0xFF6366F1),
      "action": "Pay Now",
    },
    {
      "id": "8",
      "title": "New Properties Added",
      "message": "12 new properties added in your saved localities.",
      "time": "3 days ago",
      "type": "new_listing",
      "isRead": true,
      "icon": Icons.add_home_work_rounded,
      "color": Color(0xFFEC4899),
      "action": "Browse Now",
    },
  ];

  List<Map<String, dynamic>> get _filteredNotifications {
    List<Map<String, dynamic>> filtered = _allNotifications;

    if (_showUnreadOnly) {
      filtered = filtered.where((n) => !n["isRead"]).toList();
    }

    if (_selectedTab == 1) { // Important
      filtered = filtered.where((n) =>
          ["property_match", "price_drop", "booking"].contains(n["type"])
      ).toList();
    } else if (_selectedTab == 2) { // Updates
      filtered = filtered.where((n) =>
          ["trending", "new_listing", "verification"].contains(n["type"])
      ).toList();
    }

    return filtered;
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _allNotifications) {
        notification["isRead"] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("All notifications marked as read"),
        backgroundColor: Color(0xFF10B981),
      ),
    );
  }

  void _clearAllNotifications() {
    setState(() {
      _allNotifications.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("All notifications cleared"),
        backgroundColor: Color(0xFFEF4444),
      ),
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
            floating: true,
            automaticallyImplyLeading: false,
            snap: true,
            title: Text(
              "Notifications",
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
                    icon: Icon(Icons.settings_outlined, size: 20),
                    onPressed: () {
                      widget.onNavigateToTab(3);
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
                  // Header Stats
                  _buildHeaderStats(),

                  SizedBox(height: 20),

                  // Filter Tabs
                  _buildFilterTabs(),

                  SizedBox(height: 20),

                  // Action Buttons
                  _buildActionButtons(),

                  SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Notifications List
          if (_filteredNotifications.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  final notification = _filteredNotifications[index];
                  return _buildNotificationCard(notification, index);
                },
                childCount: _filteredNotifications.length,
              ),
            )
          else
            SliverToBoxAdapter(
              child: Container(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_rounded,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                      SizedBox(height: 16),
                      Text(
                        _showUnreadOnly ? "No unread notifications" : "No notifications",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "You're all caught up!",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
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

  Widget _buildHeaderStats() {
    final unreadCount = _allNotifications.where((n) => !n["isRead"]).length;

    return Container(
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Notifications",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "${_allNotifications.length} Total",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1E293B),
                ),
              ),
            ],
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                "Unread",
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 4),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Color(0xFFEF4444),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "$unreadCount",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
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
          // All Tab
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
                  color: _selectedTab == 0 ? Color(0xFF0066FF) : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Text(
                    "All",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedTab == 0 ? Colors.white : Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Important Tab
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
                  color: _selectedTab == 1 ? Color(0xFF0066FF) : Colors.transparent,
                  border: Border.symmetric(
                    vertical: BorderSide(
                      color: Color(0xFFE2E8F0),
                      width: 1,
                    ),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Important",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedTab == 1 ? Colors.white : Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Updates Tab
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedTab = 2;
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: _selectedTab == 2 ? Color(0xFF0066FF) : Colors.transparent,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),
                child: Center(
                  child: Text(
                    "Updates",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _selectedTab == 2 ? Colors.white : Color(0xFF64748B),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Show Unread Only Toggle
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _showUnreadOnly = !_showUnreadOnly;
              });
            },
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _showUnreadOnly ? Color(0xFF0066FF) : Color(0xFFE2E8F0),
                  width: _showUnreadOnly ? 2 : 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _showUnreadOnly ? Color(0xFF0066FF) : Colors.transparent,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _showUnreadOnly ? Color(0xFF0066FF) : Color(0xFF94A3B8),
                      ),
                    ),
                    child: _showUnreadOnly
                        ? Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  SizedBox(width: 12),
                  Text(
                    "Show Unread Only",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        SizedBox(width: 12),

        // Mark All as Read Button
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE2E8F0)),
          ),
          child: IconButton(
            icon: Icon(Icons.done_all_rounded, size: 20, color: Color(0xFF0066FF)),
            onPressed: _markAllAsRead,
          ),
        ),

        SizedBox(width: 12),

        // Clear All Button
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE2E8F0)),
          ),
          child: IconButton(
            icon: Icon(Icons.delete_outline_rounded, size: 20, color: Color(0xFFEF4444)),
            onPressed: _clearAllNotifications,
          ),
        ),
      ],
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification, int index) {
    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: index == _filteredNotifications.length - 1 ? 20 : 12,
      ),
      child: Container(
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
        child: Stack(
          children: [
            // Main Content
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Icon
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: notification["color"].withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      notification["icon"],
                      size: 24,
                      color: notification["color"],
                    ),
                  ),

                  SizedBox(width: 16),

                  // Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                notification["title"],
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: notification["isRead"]
                                      ? FontWeight.w500
                                      : FontWeight.w700,
                                  color: notification["isRead"]
                                      ? Color(0xFF1E293B)
                                      : Color(0xFF0066FF),
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              notification["time"],
                              style: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 8),

                        Text(
                          notification["message"],
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            height: 1.4,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),

                        SizedBox(height: 12),

                        // Action Button
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: notification["color"].withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            notification["action"],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: notification["color"],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Unread Indicator
            if (!notification["isRead"])
              Positioned(
                top: 16,
                right: 16,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Color(0xFFEF4444),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}