import 'package:flutter/material.dart';
import 'package:roofscout/features/properties/screens/property_view_page.dart';

class ExplorePopularCities extends StatefulWidget {
  const ExplorePopularCities({super.key});

  @override
  State<ExplorePopularCities> createState() => _ExplorePopularCitiesState();
}

class _ExplorePopularCitiesState extends State<ExplorePopularCities> {
  int _selectedCityIndex = 0;

  final List<Map<String, dynamic>> _popularCities = [
    {
      "name": "Mumbai",
      "state": "Maharashtra",
      "image": "https://images.unsplash.com/photo-1529253355930-ddbe423a2ac7?w=600&auto=format&fit=crop",
      "color": Colors.blue,
      "icon": Icons.location_city_rounded,
      "propertyCount": 45678,
      "avgPrice": "₹2.8 Cr",
      "trend": "+12%",
      "description": "Financial capital with premium properties",
      "popularity": "Very High",
    },
    {
      "name": "Delhi NCR",
      "state": "Delhi/NCR",
      "image": "https://images.unsplash.com/photo-1587474260584-136574528ed5?w=600&auto=format&fit=crop",
      "color": Colors.orange,
      "icon": Icons.apartment_rounded,
      "propertyCount": 38945,
      "avgPrice": "₹2.1 Cr",
      "trend": "+8%",
      "description": "Capital city with modern infrastructure",
      "popularity": "Very High",
    },
    {
      "name": "Bengaluru",
      "state": "Karnataka",
      "image": "https://images.unsplash.com/photo-1596176530529-78163a4f7af2?w=600&auto=format&fit=crop",
      "color": Colors.green,
      "icon": Icons.computer_rounded,
      "propertyCount": 34567,
      "avgPrice": "₹1.8 Cr",
      "trend": "+15%",
      "description": "IT hub with tech-friendly properties",
      "popularity": "High",
    },
    {
      "name": "Hyderabad",
      "state": "Telangana",
      "image": "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&auto=format&fit=crop",
      "color": Colors.purple,
      "icon": Icons.business_center_rounded,
      "propertyCount": 29876,
      "avgPrice": "₹1.5 Cr",
      "trend": "+18%",
      "description": "Growing IT & business destination",
      "popularity": "High",
    },
    {
      "name": "Ahmedabad",
      "state": "Gujarat",
      "image": "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&auto=format&fit=crop",
      "color": Colors.red,
      "icon": Icons.business_center_rounded,
      "propertyCount": 23456,
      "avgPrice": "₹1.2 Cr",
      "trend": "+10%",
      "description": "Industrial hub with affordable luxury",
      "popularity": "Medium",
    },
    {
      "name": "Chennai",
      "state": "Tamil Nadu",
      "image": "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&auto=format&fit=crop",
      "color": Colors.teal,
      "icon": Icons.auto_awesome_rounded,
      "propertyCount": 28765,
      "avgPrice": "₹1.6 Cr",
      "trend": "+9%",
      "description": "Cultural capital with heritage properties",
      "popularity": "Medium",
    },
    {
      "name": "Pune",
      "state": "Maharashtra",
      "image": "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&auto=format&fit=crop",
      "color": Colors.indigo,
      "icon": Icons.school_rounded,
      "propertyCount": 31234,
      "avgPrice": "₹1.4 Cr",
      "trend": "+14%",
      "description": "Education hub with modern living",
      "popularity": "High",
    },
    {
      "name": "Kolkata",
      "state": "West Bengal",
      "image": "https://images.unsplash.com/photo-1548013146-72479768bada?w=600&auto=format&fit=crop",
      "color": Colors.amber,
      "icon": Icons.history_edu_rounded,
      "propertyCount": 26789,
      "avgPrice": "₹1.3 Cr",
      "trend": "+7%",
      "description": "Cultural city with heritage homes",
      "popularity": "Medium",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 4),

        // CITIES GRID
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            mainAxisSpacing: 10,
            crossAxisSpacing: 6,
            childAspectRatio: 0.6,
          ),
          itemCount: _popularCities.length,
          itemBuilder: (context, index) {
            final city = _popularCities[index];
            final isSelected = _selectedCityIndex == index;

            return GestureDetector(
              onTap: () {
                setState(() => _selectedCityIndex = index);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RoofHomePage(),
                  ),
                );
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected
                        ? city['color'] as Color
                        : Colors.grey[200]!,
                    width: isSelected ? 2 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                    BoxShadow(
                      color: (city['color'] as Color).withOpacity(0.2),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                      : [
                    BoxShadow(
                      color: Colors.grey[100]!,
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      // CITY IMAGE
                      Image.network(
                        city['image'] as String,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: double.infinity,
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
                                color: city['color'] as Color,
                              ),
                            ),
                          );
                        },
                      ),

                      // GRADIENT OVERLAY
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.transparent,
                              Colors.black.withOpacity(0.7),
                            ],
                          ),
                        ),
                      ),

                      // CITY INFO
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // TREND BADGE
                            if (city['trend'] != null)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.green,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.trending_up_rounded,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      city['trend'] as String,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                            // CITY NAME
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  city['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: -0.3,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  city['state'] as String,
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: Colors.white.withOpacity(0.8),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 20),

        // SELECTED CITY DETAILS
        if (_selectedCityIndex < _popularCities.length)
          _buildCityDetails(_popularCities[_selectedCityIndex]),
      ],
    );
  }

  Widget _buildCityDetails(Map<String, dynamic> city) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey[100]!,
            blurRadius: 15,
            offset: const Offset(0, 6),
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
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: city['color'] as Color,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  city['icon'] as IconData,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      city['name'] as String,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: city['color'] as Color,
                      ),
                    ),
                    Text(
                      city['state'] as String,
                      style: TextStyle(
                        fontSize: 14,
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
                      builder: (context) => RoofHomePage(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: city['color'] as Color,
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
                child: const Text("Explore Properties"),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // CITY DESCRIPTION
          Text(
            city['description'] as String,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.5,
            ),
          ),

          const SizedBox(height: 20),

          // STATS
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCityStat(
                  Icons.home_work_outlined,
                  "Properties",
                  "${city['propertyCount']}",
                  city['color'] as Color,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey[300],
                ),
                _buildCityStat(
                  Icons.currency_rupee_rounded,
                  "Avg. Price",
                  city['avgPrice'] as String,
                  Colors.green,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey[300],
                ),
                _buildCityStat(
                  Icons.trending_up_rounded,
                  "Trend",
                  city['trend'] as String,
                  Colors.orange,
                ),
                Container(
                  height: 40,
                  width: 1,
                  color: Colors.grey[300],
                ),
                _buildCityStat(
                  Icons.star_rounded,
                  "Popularity",
                  city['popularity'] as String,
                  Colors.purple,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityStat(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          size: 24,
          color: color,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }
}