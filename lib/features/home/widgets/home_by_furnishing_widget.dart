import 'package:flutter/material.dart';
import 'package:roofscout/features/properties/screens/property_explore_page.dart';

class HomeByFurnishingWidget extends StatefulWidget {
  const HomeByFurnishingWidget({super.key});

  @override
  State<HomeByFurnishingWidget> createState() => _HomeByFurnishingWidgetState();
}

class _HomeByFurnishingWidgetState extends State<HomeByFurnishingWidget> {
  int _selectedIndex = 0;

  final List<Map<String, dynamic>> _furnishingOptions = [
    {
      'title': 'Fully Furnished',
      'subtitle': 'Ready to move in',
      'image': 'https://images.unsplash.com/photo-1615529328331-f8917597711f?w=600&auto=format&fit=crop',
      'color': Color(0xFF0066FF),
      'icon': Icons.chair_alt_rounded,
      'count': 1245,
      'priceRange': '₹25K - ₹80K',
      'features': ['Furniture', 'Appliances', 'Decor'],
    },
    {
      'title': 'Semi Furnished',
      'subtitle': 'Basic amenities included',
      'image': 'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=600&auto=format&fit=crop',
      'color': Color(0xFF00C853),
      'icon': Icons.table_restaurant_rounded,
      'count': 876,
      'priceRange': '₹18K - ₹55K',
      'features': ['Basic Furniture', 'Kitchen Setup'],
    },
    {
      'title': 'Unfurnished',
      'subtitle': 'Blank canvas for you',
      'image': 'https://images.unsplash.com/photo-1600210492486-724fe5c67fb0?w=600&auto=format&fit=crop',
      'color': Color(0xFFFF6B00),
      'icon': Icons.home_work_outlined,
      'count': 654,
      'priceRange': '₹15K - ₹45K',
      'features': ['Empty Space', 'Custom Design'],
    },
    {
      'title': 'Premium Furnished',
      'subtitle': 'Luxury living experience',
      'image': 'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&auto=format&fit=crop',
      'color': Color(0xFF9C27B0),
      'icon': Icons.diamond_rounded,
      'count': 342,
      'priceRange': '₹60K - ₹2L',
      'features': ['Premium Furniture', 'Smart Home'],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.6, // ← LIMIT MAX HEIGHT
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ← IMPORTANT: Don't take more space than needed
        children: [

          SizedBox(
            height: 240, // ← REDUCED HEIGHT from 240
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4),
              itemCount: _furnishingOptions.length,
              itemBuilder: (context, index) {
                final option = _furnishingOptions[index];
                final isSelected = _selectedIndex == index;

                return Container(
                  width: 180, // ← REDUCED WIDTH from 200
                  margin: EdgeInsets.only(
                    right: index == _furnishingOptions.length - 1 ? 4 : 12,
                  ),
                  child: GestureDetector(
                    onTap: () {
                      setState(() => _selectedIndex = index);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PropertyExploreViewPage(
                            name: option['title'],
                          ),
                        ),
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16), // ← SMALLER RADIUS
                        color: Colors.white,
                        border: Border.all(
                          color: isSelected
                              ? option['color'] as Color
                              : Colors.grey[200]!,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: isSelected
                                ? (option['color'] as Color).withOpacity(0.2)
                                : Colors.grey[100]!,
                            blurRadius: 8, // ← REDUCED SHADOW
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // IMAGE SECTION
                          Expanded(
                            flex: 3,
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(16),
                                  ),
                                  child: Image.network(
                                    option['image'] as String,
                                    fit: BoxFit.cover,
                                    width: double.infinity,
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey[200],
                                        child: Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded /
                                                loadingProgress.expectedTotalBytes!
                                                : null,
                                            color: option['color'] as Color,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),

                                // Gradient Overlay
                                Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(16),
                                    ),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.transparent,
                                        Colors.black.withOpacity(0.2),
                                      ],
                                    ),
                                  ),
                                ),

                                // Count Badge
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 4,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      "${option['count']}",
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: option['color'] as Color,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // CONTENT SECTION
                          Expanded(
                            flex: 2,
                            child: Padding(
                              padding: const EdgeInsets.all(12), // ← REDUCED PADDING
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  // Title and Subtitle
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        option['title'] as String,
                                        style: TextStyle(
                                          fontSize: 14, // ← SMALLER FONT
                                          fontWeight: FontWeight.w700,
                                          color: option['color'] as Color,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2), // ← REDUCED SPACING
                                      Text(
                                        option['subtitle'] as String,
                                        style: TextStyle(
                                          fontSize: 11, // ← SMALLER FONT
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),

                                  // Price Range
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      option['priceRange'] as String,
                                      style: const TextStyle(
                                        fontSize: 10, // ← SMALLER FONT
                                        fontWeight: FontWeight.w600,
                                        color: Colors.green,
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
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16), // ← REDUCED SPACING

          // FEATURES FOR SELECTED OPTION
          if (_selectedIndex < _furnishingOptions.length)
            _buildFeaturesSection(_furnishingOptions[_selectedIndex]),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(Map<String, dynamic> option) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.all(12), // ← REDUCED PADDING
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12), // ← SMALLER RADIUS
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // ← IMPORTANT
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8), // ← REDUCED PADDING
                decoration: BoxDecoration(
                  color: option['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option['icon'] as IconData,
                  color: Colors.white,
                  size: 18, // ← SMALLER ICON
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option['title'] as String,
                      style: TextStyle(
                        fontSize: 14, // ← SMALLER FONT
                        fontWeight: FontWeight.w700,
                        color: option['color'] as Color,
                      ),
                    ),
                    Text(
                      option['subtitle'] as String,
                      style: TextStyle(
                        fontSize: 12, // ← SMALLER FONT
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
                        name: option['title'],
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: option['color'] as Color,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // ← REDUCED
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                  visualDensity: VisualDensity.compact, // ← COMPACT BUTTON
                ),
                child: const Text(
                  "Explore",
                  style: TextStyle(fontSize: 12), // ← SMALLER TEXT
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Features
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: (option['features'] as List<String>)
                .map((feature) => Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: Colors.grey[300]!,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 12, // ← SMALLER ICON
                    color: option['color'] as Color,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    feature,
                    style: TextStyle(
                      fontSize: 11, // ← SMALLER FONT
                      color: Colors.grey[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }

}