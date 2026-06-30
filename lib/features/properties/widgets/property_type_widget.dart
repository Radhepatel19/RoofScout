import 'package:flutter/material.dart';
import 'package:roofscout/features/properties/screens/property_explore_page.dart';

class PropertyTypeWidget extends StatefulWidget {
  const PropertyTypeWidget({super.key});

  @override
  State<PropertyTypeWidget> createState() => _PropertyTypeWidgetState();
}

class _PropertyTypeWidgetState extends State<PropertyTypeWidget> {
  int _selectedIndex = 0;
  final List<Map<String, dynamic>> _propertyTypes = [
    {
      "title": "Apartments",
      "icon": Icons.apartment_rounded,
      "color": const Color(0xFF0066FF),
      "count": 1245,
      "description": "Modern flats & apartments",
      "trend": "+12%",
    },
    {
      "title": "Villas",
      "icon": Icons.villa_rounded,
      "color": const Color(0xFF00C853),
      "count": 342,
      "description": "Luxury independent villas",
      "trend": "+18%",
    },
    {
      "title": "Independent Houses",
      "icon": Icons.house_rounded,
      "color": const Color(0xFFFF6B00),
      "count": 876,
      "description": "Standalone houses",
      "trend": "+8%",
    },
    {
      "title": "Studio Apartments",
      "icon": Icons.meeting_room_rounded,
      "color": const Color(0xFF9C27B0),
      "count": 567,
      "description": "Compact living spaces",
      "trend": "+25%",
    },
    {
      "title": "Penthouse",
      "icon": Icons.vertical_align_top_rounded,
      "color": const Color(0xFFF44336),
      "count": 89,
      "description": "Premium top-floor units",
      "trend": "+15%",
    },
    {
      "title": "Farmhouses",
      "icon": Icons.nature_people_rounded,
      "color": const Color(0xFF795548),
      "count": 67,
      "description": "Countryside retreats",
      "trend": "+32%",
    },
    {
      "title": "Builder Floors",
      "icon": Icons.layers_rounded,
      "color": const Color(0xFF607D8B),
      "count": 432,
      "description": "Complete floor units",
      "trend": "+5%",
    },
    {
      "title": "More Types",
      "icon": Icons.more_horiz_rounded,
      "color": Colors.grey[700]!,
      "count": null,
      "description": "View all categories",
      "trend": null,
    },
  ];


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // PROPERTY TYPES GRID
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(), // ← ADD THIS
          padding: const EdgeInsets.symmetric(horizontal: 4), // ← ADD PADDING
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 12, // ← INCREASED FOR BETTER SPACING
            crossAxisSpacing: 12,
            childAspectRatio: 0.6, // ← CHANGED TO 1.0 FOR SQUARE CARDS
          ),
          itemCount: _propertyTypes.length,
          itemBuilder: (context, index) {
            final propertyType = _propertyTypes[index];
            final isSelected = _selectedIndex == index;
            final isMoreOption = propertyType['title'] == "More Types";

            return Container(
                decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
            boxShadow: [
            if (isSelected)
            BoxShadow(
            color: (propertyType['color'] as Color).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
            ),
            ],
            ),
            child: GestureDetector(
            onTap: () {
            setState(() {
            _selectedIndex = index;
            });
            Navigator.push(
            context,
            MaterialPageRoute(
            builder: (context) => PropertyExploreViewPage(
            name: propertyType["title"],
            ),
            ),
            );
            },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected ? propertyType['color'].withOpacity(0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? propertyType['color'] as Color : Colors.grey[200]!,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: (propertyType['color'] as Color).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : [
                    BoxShadow(
                      color: Colors.grey[100]!,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    // CONTENT
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // ICON CONTAINER
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              gradient: isSelected && !isMoreOption
                                  ? LinearGradient(
                                colors: [
                                  propertyType['color'] as Color,
                                  (propertyType['color'] as Color).withOpacity(0.8),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                                  : null,
                              color: !isSelected ? (propertyType['color'] as Color).withOpacity(0.1) : null,
                              shape: BoxShape.circle,
                              border: isSelected && !isMoreOption
                                  ? Border.all(
                                color: (propertyType['color'] as Color).withOpacity(0.3),
                                width: 2,
                              )
                                  : null,
                            ),
                            child: Icon(
                              propertyType['icon'] as IconData,
                              size: 24,
                              color: isSelected && !isMoreOption
                                  ? Colors.white
                                  : propertyType['color'] as Color,
                            ),
                          ),

                          // TITLE AND INFO
                          Column(
                            children: [
                              Text(
                                propertyType['title'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: isSelected
                                      ? propertyType['color'] as Color
                                      : Colors.grey[800],
                                  letterSpacing: -0.2,
                                ),
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              if (propertyType['count'] != null && !isMoreOption) ...[
                                const SizedBox(height: 4),
                                Text(
                                  "${propertyType['count']} properties",
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // TREND BADGE
                    if (propertyType['trend'] != null && !isMoreOption)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: (propertyType['color'] as Color).withOpacity(0.9),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.trending_up_rounded,
                                size: 10,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                propertyType['trend'] as String,
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),);
          },
        ),

        const SizedBox(height: 8),

        // PROPERTY TYPE DETAILS PANEL
        if (_selectedIndex < _propertyTypes.length - 1)
          _buildPropertyTypeDetails(_propertyTypes[_selectedIndex]),
      ],
    );
  }

  Widget _buildPropertyTypeDetails(Map<String, dynamic> propertyType) {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: (propertyType['color'] as Color).withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: (propertyType['color'] as Color).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // ICON
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: propertyType['color'] as Color,
              shape: BoxShape.circle,
            ),
            child: Icon(
              propertyType['icon'] as IconData,
              color: Colors.white,
              size: 24,
            ),
          ),

          const SizedBox(width: 16),

          // DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  propertyType['title'] as String,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: propertyType['color'] as Color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  propertyType['description'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
                if (propertyType['count'] != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: (propertyType['color'] as Color).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.home_work_outlined,
                              size: 14,
                              color: propertyType['color'] as Color,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "${propertyType['count']} available",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: propertyType['color'] as Color,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (propertyType['trend'] != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.green.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.trending_up_rounded,
                                size: 14,
                                color: Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                propertyType['trend'] as String,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // EXPLORE BUTTON
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PropertyExploreViewPage(
                    name: propertyType["title"],
                  ),
                ),
              );
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: propertyType['color'] as Color,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}