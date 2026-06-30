import 'package:flutter/material.dart';
import 'package:roofscout/features/properties/screens/property_explore_page.dart';

class BhkChoiceWidget extends StatefulWidget {
  const BhkChoiceWidget({super.key});

  @override
  State<BhkChoiceWidget> createState() => _BhkChoiceWidgetState();
}

class _BhkChoiceWidgetState extends State<BhkChoiceWidget> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _bhkOptions = [
    {
      "label": "1 BHK",
      "icon": Icons.looks_one_rounded,
      "color": Color(0xFF0066FF),
      "description": "Compact living for singles/couples",
      "count": 1567,
      "avgPrice": "₹18K",
      "popularity": "High",
      "sizeRange": "400-800 sq ft",
    },
    {
      "label": "2 BHK",
      "icon": Icons.looks_two_rounded,
      "color": Color(0xFF00C853),
      "description": "Perfect for small families",
      "count": 2345,
      "avgPrice": "₹32K",
      "popularity": "Highest",
      "sizeRange": "800-1200 sq ft",
    },
    {
      "label": "3 BHK",
      "icon": Icons.looks_3_rounded,
      "color": Color(0xFFFF6B00),
      "description": "Spacious family homes",
      "count": 1876,
      "avgPrice": "₹48K",
      "popularity": "High",
      "sizeRange": "1200-1800 sq ft",
    },
    {
      "label": "4+ BHK",
      "icon": Icons.home_work_rounded,
      "color": Color(0xFF9C27B0),
      "description": "Luxury & large family homes",
      "count": 654,
      "avgPrice": "₹75K+",
      "popularity": "Medium",
      "sizeRange": "1800-3000+ sq ft",
    },
    {
      "label": "Studio",
      "icon": Icons.meeting_room_rounded,
      "color": Color(0xFF607D8B),
      "description": "Compact studio apartments",
      "count": 987,
      "avgPrice": "₹15K",
      "popularity": "Growing",
      "sizeRange": "300-600 sq ft",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),

        // BHK OPTIONS GRID
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 5,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.55,
          ),
          itemCount: _bhkOptions.length,
          itemBuilder: (context, index) {
            final bhk = _bhkOptions[index];
            final isSelected = _selectedIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() => _selectedIndex = index);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PropertyExploreViewPage(
                      name: bhk["label"],
                    ),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  color: isSelected
                      ? bhk['color'].withOpacity(0.1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? bhk['color'] as Color
                        : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: (bhk['color'] as Color).withOpacity(0.2),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ]
                      : [
                    BoxShadow(
                      color: Colors.grey[100]!,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // ICON
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                          colors: [
                            bhk['color'] as Color,
                            (bhk['color'] as Color).withOpacity(0.8),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                            : null,
                        color: !isSelected
                            ? (bhk['color'] as Color).withOpacity(0.1)
                            : null,
                        shape: BoxShape.circle,
                        border: isSelected
                            ? Border.all(
                          color: (bhk['color'] as Color).withOpacity(0.3),
                          width: 2,
                        )
                            : null,
                      ),
                      child: Icon(
                        bhk['icon'] as IconData,
                        size: 24,
                        color: isSelected
                            ? Colors.white
                            : bhk['color'] as Color,
                      ),
                    ),

                    const SizedBox(height: 12),

                    // LABEL
                    Text(
                      bhk['label'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? bhk['color'] as Color
                            : Colors.grey[800],
                      ),
                    ),

                    const SizedBox(height: 4),

                    // COUNT
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (bhk['color'] as Color).withOpacity(0.1)
                            : Colors.grey[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "${bhk['count']}",
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? bhk['color'] as Color
                              : Colors.grey[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // SELECTED BHK DETAILS
        if (_selectedIndex < _bhkOptions.length)
          _buildBhkDetails(_bhkOptions[_selectedIndex]),
      ],
    );
  }

  Widget _buildBhkDetails(Map<String, dynamic> bhk) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[100]!,
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // HEADER
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bhk['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  bhk['icon'] as IconData,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bhk['label'] as String,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: bhk['color'] as Color,
                      ),
                    ),
                    Text(
                      bhk['description'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PropertyExploreViewPage(
                        name: bhk["label"],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: bhk['color'] as Color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text("Explore"),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // STATS
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatItem(
                  Icons.home_work_outlined,
                  "Properties",
                  "${bhk['count']}",
                  bhk['color'] as Color,
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.grey[300],
                ),
                _buildStatItem(
                  Icons.currency_rupee_rounded,
                  "Avg. Rent",
                  bhk['avgPrice'] as String,
                  Colors.green,
                ),
                Container(
                  height: 30,
                  width: 1,
                  color: Colors.grey[300],
                ),
                _buildStatItem(
                  Icons.trending_up_rounded,
                  "Popularity",
                  bhk['popularity'] as String,
                  Colors.orange,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // SIZE RANGE
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (bhk['color'] as Color).withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: (bhk['color'] as Color).withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.square_foot_rounded,
                  size: 20,
                  color: bhk['color'] as Color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Typical size: ${bhk['sizeRange']}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 18,
          color: color,
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}