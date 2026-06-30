import 'package:flutter/material.dart';
import 'package:roofscout/core/widgets/action_circle_icon.dart';

class PropertyCardSelected extends StatefulWidget {
  final BuildContext context;
  final List<String> imageList;
  final String title;
  final String location;
  final String price;
  final int bedrooms;
  final int bathrooms;
  final String area;
  final VoidCallback onTap;

  const PropertyCardSelected({
    super.key,
    required this.context,
    required this.imageList,
    required this.title,
    required this.location,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.area,
    required this.onTap,
  });

  @override
  State<PropertyCardSelected> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCardSelected> {
  int currentImageIndex = 0;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE + ICONS STACK
            Stack(
              children: [
                // IMAGE SLIDER
                SizedBox(
                  height: 200,
                  child: PageView.builder(
                    itemCount: widget.imageList.length,
                    onPageChanged: (index) {
                      setState(() => currentImageIndex = index);
                    },
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: Image.network(
                          widget.imageList[index],
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                ),

                // PRICE TAG
                Positioned(
                  right: 14,
                  top: 14,
                  child: Container(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.orange[700],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      widget.price,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),

                // DOT INDICATOR
                Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      widget.imageList.length,
                          (dotIndex) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 3),
                        width: currentImageIndex == dotIndex ? 10 : 6,
                        height: currentImageIndex == dotIndex ? 10 : 6,
                        decoration: BoxDecoration(
                          color: currentImageIndex == dotIndex
                              ? Colors.white
                              : Colors.white54,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ),
                ),

                // ACTION BUTTONS (BOTTOM RIGHT)
                Positioned(
                  right: 14,
                  bottom: 14,
                  child: Row(
                    children: [
                      ActionCircleIcon(
                        icon: Icons.favorite_border,
                        isLikeButton: true,
                        onTap: () {
                          // Optional additional logic
                        },
                      ),
                      const SizedBox(width: 10),
                      ActionCircleIcon(
                        icon: Icons.share,
                        onTap: () {
                          // Share logic
                        },
                      ),
                      const SizedBox(width: 10),
                      ActionCircleIcon(
                        icon: Icons.location_on_outlined,
                        onTap: () {
                          // Location logic
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // TEXT INFORMATION SECTION
            Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.blue[900],
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  Row(
                    children: [
                      const Icon(Icons.location_on,
                          size: 18, color: Colors.orange),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.location,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _propIcon(Icons.bed, "${widget.bedrooms} Beds"),
                      _propIcon(Icons.bathtub, "${widget.bathrooms} Baths"),
                      _propIcon(Icons.square_foot, widget.area),
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


  // PROPERTY ICON TEXT ROW
  Widget _propIcon(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.blue[800]),
        const SizedBox(width: 5),
        Text(
          text,
          style: TextStyle(color: Colors.grey[700], fontSize: 14),
        ),
      ],
    );
  }
}
