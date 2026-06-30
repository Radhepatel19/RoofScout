import 'package:flutter/material.dart';
import 'package:roofscout/features/properties/screens/property_details_page.dart' show PropertyDetailsPage;

class PropertyCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String location;
  final int bedrooms;
  final int bathrooms;
  final String area;
  final bool isLiked;
  final VoidCallback onLikeToggle;

  const PropertyCard({
    super.key,
    required this.imageUrl,
    required this.title,
    required this.location,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.isLiked,
    required this.onLikeToggle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const PropertyDetailsPage()),
        );
      },
      child: Container(
        width: 180, // smaller width for horizontal layout
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(blurRadius: 4, color: Colors.black12),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Like Button
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 110,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  right: 8,
                  top: 8,
                  child: GestureDetector(
                    onTap: onLikeToggle,
                    child: AnimatedScale(
                      scale: isLiked ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: isLiked ? Colors.red : Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            // Title
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 8),
              child: Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Location
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                location,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),

            const Divider(height: 10),

            // Details Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.bed_outlined, size: 14, color: Colors.blue),
                      const SizedBox(width: 3),
                      Text("$bedrooms", style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.bathtub_outlined, size: 14, color: Colors.blue),
                      const SizedBox(width: 3),
                      Text("$bathrooms", style: const TextStyle(fontSize: 11)),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.square_foot, size: 14, color: Colors.blue),
                      const SizedBox(width: 3),
                      Text(area, style: const TextStyle(fontSize: 11)),
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
}
