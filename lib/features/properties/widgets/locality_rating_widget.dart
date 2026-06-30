import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class LocalityRatingWidget extends StatefulWidget {
  const LocalityRatingWidget({super.key});

  @override
  State<LocalityRatingWidget> createState() => _LocalityRatingWidgetState();
}

class _LocalityRatingWidgetState extends State<LocalityRatingWidget> {
  int _selectedCategoryIndex = 0;
  double _overallRating = 4.3;

  final List<Map<String, dynamic>> _ratingCategories = [
    {
      'title': 'Overall',
      'rating': 4.3,
      'icon': Icons.star_rounded,
      'color': Colors.amber,
      'trend': '+0.2',
    },
    {
      'title': 'Safety',
      'rating': 4.7,
      'icon': Icons.security_rounded,
      'color': Colors.green,
      'trend': '+0.3',
    },
    {
      'title': 'Connectivity',
      'rating': 4.5,
      'icon': Icons.directions_bus_rounded,
      'color': Colors.blue,
      'trend': '+0.1',
    },
    {
      'title': 'Amenities',
      'rating': 4.2,
      'icon': Icons.local_grocery_store_rounded,
      'color': Colors.purple,
      'trend': '+0.4',
    },
    {
      'title': 'Cleanliness',
      'rating': 4.4,
      'icon': Icons.cleaning_services_rounded,
      'color': Colors.teal,
      'trend': '+0.2',
    },
  ];

  final List<Map<String, dynamic>> _localityTags = [
    {
      'title': 'Safe Area',
      'icon': Icons.security_rounded,
      'color': Colors.green,
      'strength': 'High',
    },
    {
      'title': 'Good Connectivity',
      'icon': Icons.directions_subway_rounded,
      'color': Colors.blue,
      'strength': 'Very High',
    },
    {
      'title': 'Family Friendly',
      'icon': Icons.family_restroom_rounded,
      'color': Colors.purple,
      'strength': 'High',
    },
    {
      'title': 'Near Schools',
      'icon': Icons.school_rounded,
      'color': Colors.orange,
      'strength': 'Medium',
    },
    {
      'title': 'Clean Roads',
      'icon': Icons.cleaning_services_rounded,
      'color': Colors.teal,
      'strength': 'High',
    },
    {
      'title': 'Shopping Hub',
      'icon': Icons.shopping_bag_rounded,
      'color': Colors.red,
      'strength': 'Very High',
    },
    {
      'title': 'Medical Facilities',
      'icon': Icons.local_hospital_rounded,
      'color': Colors.pink,
      'strength': 'Medium',
    },
    {
      'title': 'Green Spaces',
      'icon': Icons.park_rounded,
      'color': Colors.lightGreen,
      'strength': 'Low',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        const SizedBox(height: 4),

        // RATING OVERVIEW CARD
        Container(
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
              // OVERALL RATING HEADER
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Overall Rating",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey[900],
                        ),
                      ),
                      Text(
                        "Based on 1,234 reviews",
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.trending_up_rounded,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Trending",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // MAIN RATING DISPLAY
              Row(
                children: [
                  // RATING NUMBER
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF0066FF), Color(0xFF0052CC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0066FF).withOpacity(0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _overallRating.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                          const Text(
                            "out of 5",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(width: 20),

                  // RATING DETAILS
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        RatingBarIndicator(
                          rating: _overallRating,
                          itemBuilder: (context, index) => const Icon(
                            Icons.star_rounded,
                            color: Colors.amber,
                          ),
                          itemCount: 5,
                          itemSize: 24,
                          unratedColor: Colors.grey[300],
                        ),

                        const SizedBox(height: 12),

                        // RATING BARS
                        ..._buildRatingBars(),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // RATING CATEGORIES
              Text(
                "Category Ratings",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 12),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(
                    _ratingCategories.length,
                        (index) {
                      final category = _ratingCategories[index];
                      final isSelected = _selectedCategoryIndex == index;

                      return Padding(
                        padding: EdgeInsets.only(
                          right: index == _ratingCategories.length - 1 ? 0 : 12,
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() => _selectedCategoryIndex = index);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (category['color'] as Color).withOpacity(0.1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? category['color'] as Color
                                    : Colors.grey[200]!,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                BoxShadow(
                                  color: (category['color'] as Color)
                                      .withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ]
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  category['icon'] as IconData,
                                  size: 20,
                                  color: category['color'] as Color,
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      category['title'] as String,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: category['color'] as Color,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Text(
                                          category['rating'].toString(),
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w800,
                                            color: Colors.grey[900],
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Icon(
                                          Icons.star_rounded,
                                          size: 16,
                                          color: Colors.amber,
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: Colors.green.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            category['trend'] as String,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: Colors.green,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // LOCALITY TAGS
        Container(
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
              Text(
                "Locality Highlights",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[900],
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "What residents love about this area",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: _localityTags.map((tag) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: (tag['color'] as Color).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (tag['color'] as Color).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          tag['icon'] as IconData,
                          size: 18,
                          color: tag['color'] as Color,
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tag['title'] as String,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: tag['color'] as Color,
                              ),
                            ),
                            Text(
                              tag['strength'] as String,
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _buildRatingBars() {
    final Map<int, int> ratingDistribution = {
      5: 450,
      4: 380,
      3: 250,
      2: 100,
      1: 54,
    };
    final totalReviews = ratingDistribution.values.reduce((a, b) => a + b);

    return List.generate(5, (index) {
      final stars = 5 - index;
      final count = ratingDistribution[stars] ?? 0;
      final percentage = (count / totalReviews) * 100;

      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          children: [
            Text(
              '$stars',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.star_rounded, size: 16, color: Colors.amber),
            const SizedBox(width: 12),
            Expanded(
              child: LinearProgressIndicator(
                value: percentage / 100,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressColor(percentage),
                ),
                borderRadius: BorderRadius.circular(4),
                minHeight: 8,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
      );
    });
  }

  Color _getProgressColor(double percentage) {
    if (percentage >= 70) return Colors.green;
    if (percentage >= 40) return Colors.orange;
    return Colors.red;
  }
}