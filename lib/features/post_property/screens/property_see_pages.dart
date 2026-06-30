import 'package:flutter/material.dart';
import 'package:roofscout/features/home/screens/menu_handler.dart';
import 'package:roofscout/features/post_property/screens/property_steps_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:roofscout/features/properties/services/property_service.dart';
import 'package:roofscout/core/models/property_model.dart';

class PropertySeePages extends StatefulWidget {
  const PropertySeePages({super.key});

  @override
  State<PropertySeePages> createState() => _PropertySeePagesState();
}

class _PropertySeePagesState extends State<PropertySeePages> {
  List<PropertyModel> properties = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchProperties();
  }

  Future<void> _fetchProperties() async {
    try {
      final data = await PropertyService.getMyProperties();
      setState(() {
        properties = data.map((json) => PropertyModel.fromJson(json)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = e.toString();
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading properties: $e'), backgroundColor: Colors.red),
      );
    }
  }

  bool isOlderThan24h(DateTime uploadedAt) {
    final cutoff = DateTime.now().subtract(const Duration(hours: 24));
    return uploadedAt.isBefore(cutoff);
  }

  String getTimeAgo(DateTime uploadedAt) {
    final difference = DateTime.now().difference(uploadedAt);

    if (difference.inHours < 1) {
      return "${difference.inMinutes} min ago";
    } else if (difference.inHours < 24) {
      return "${difference.inHours} hours ago";
    } else {
      return "${difference.inDays} days ago";
    }
  }

  void _showDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Property"),
        content: const Text("Are you sure you want to delete this property listing?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () async {
              try {
                await PropertyService.deleteProperty(properties[index].id);
                setState(() {
                  properties.removeAt(index);
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Property deleted successfully"),
                    backgroundColor: Colors.red,
                  ),
                );
              } catch (e) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Delete", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showEditOptions(int index) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.blue),
              title: const Text("Edit Property Details"),
              onTap: () {
                Navigator.pop(context);
                _navigateToEditPage(index);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library, color: Colors.green),
              title: const Text("Change Photos"),
              onTap: () {
                Navigator.pop(context);
                // Implement photo change logic
              },
            ),
            ListTile(
              leading: const Icon(Icons.price_change, color: Colors.orange),
              title: const Text("Update Price"),
              onTap: () {
                Navigator.pop(context);
                _showPriceUpdateDialog(index);
              },
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEditPage(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PropertyStepsPages(property: properties[index]),
      ),
    );
  }

  void _showPriceUpdateDialog(int index) {
    final priceController = TextEditingController(
        text: properties[index].price.toStringAsFixed(0)
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Update Price"),
        content: TextField(
          controller: priceController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "New Price",
            prefixText: "₹ ",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final newPrice = double.tryParse(priceController.text);
              if (newPrice != null && newPrice > 0) {
                setState(() {
                  properties[index].price = newPrice;
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Price updated successfully"),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  void _approveProperty(int index) async {
    try {
      await PropertyService.updatePropertyStatus(properties[index].id, true);
      setState(() {
        properties[index].isPendingApproval = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Property approved and published!"),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e"), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        titleSpacing: 0,
        elevation: 0,
        scrolledUnderElevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => MenuHandler()));
          },
        ),
        title: const Text(
          "My Properties",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            letterSpacing: 0.3,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline, color: Colors.blue),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context)=> const PropertyStepsPages()));
              },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : properties.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.home_work_outlined, size: 60, color: Colors.grey),
                      SizedBox(height: 16),
                      Text("No properties found", style: TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Status Tabs
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildStatusTab("All", properties.length),
                          _buildStatusTab("Pending", properties.where((p) => p.isPendingApproval).length),
                          _buildStatusTab("Approved", properties.where((p) => !p.isPendingApproval).length),
                        ],
                      ),
                    ),

                    Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: properties.length,
              itemBuilder: (context, index) {
                final property = properties[index];
                final PageController _controller = PageController();
                final timeAgo = getTimeAgo(property.uploadedAt);
                final isPending = property.isPendingApproval;
                final show24hBadge = !isOlderThan24h(property.uploadedAt) && isPending;

                return Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Image Slider
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: SizedBox(
                              height: 200,
                              child: Stack(
                                alignment: Alignment.bottomCenter,
                                children: [
                                  PageView.builder(
                                    controller: _controller,
                                    itemCount: property.images.length,
                                    itemBuilder: (context, pageIndex) {
                                      return Image.network(
                                        property.images[pageIndex],
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                      );
                                    },
                                  ),

                                  Positioned(
                                    bottom: 10,
                                    child: SmoothPageIndicator(
                                      controller: _controller,
                                      count: property.images.length,
                                      effect: WormEffect(
                                        dotHeight: 8,
                                        dotWidth: 8,
                                        activeDotColor: Colors.white,
                                        dotColor: Colors.white54,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  property.name,  // Show property name
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  property.description.length > 100
                                      ? "${property.description.substring(0, 100)}..."
                                      : property.description,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: 8),

                                // Price and Status Row
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      property.availableFor == "For Sale"
                                          ? "₹ ${property.price.toStringAsFixed(0)}"
                                          : "₹ ${property.price.toStringAsFixed(0)}/month",
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                                      decoration: BoxDecoration(
                                        color: isPending ? Colors.orange : Colors.green,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isPending ? "Pending" : "Approved",
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),

                                // Location
                                Row(
                                  children: [
                                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        "${property.address}, ${property.district}",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF64748B),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Property Details
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    _detailItem(Icons.king_bed, "${property.bedrooms} BHK"),
                                    _detailItem(Icons.bathtub, "${property.bathrooms} Bath"),
                                    _detailItem(Icons.square_foot, "${property.area} sq.ft"),
                                    _detailItem(Icons.apartment, property.propertyType),
                                  ],
                                ),

                                const SizedBox(height: 12),

                                // Amenities
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: property.amenities.take(4).map((amenity) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        amenity,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),

                                /// 🛋️ FURNITURE SECTION
                                if (property.furnishing != "Unfurnished" && property.furniture.isNotEmpty)
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Text(
                                        "Furniture Included:",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: property.furniture.map((furniture) {
                                          return Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                            decoration: BoxDecoration(
                                              color: Color(0xFFECFDF5),
                                              borderRadius: BorderRadius.circular(8),
                                              border: Border.all(color: Color(0xFF10B981).withOpacity(0.3)),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  _getFurnitureIcon(furniture),
                                                  size: 14,
                                                  color: Color(0xFF10B981),
                                                ),
                                                const SizedBox(width: 4),
                                                Text(
                                                  furniture,
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    color: Color(0xFF065F46),
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  ),
                                const SizedBox(height: 16),
                                // Action Buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.edit, size: 18),
                                        label: const Text("Edit"),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          side: BorderSide(color: Colors.blue.shade300),
                                        ),
                                        onPressed: () => _showEditOptions(index),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        icon: const Icon(Icons.delete_outline, size: 18),
                                        label: const Text("Delete"),
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 12),
                                          side: BorderSide(color: Colors.red.shade300),
                                        ),
                                        onPressed: () => _showDeleteDialog(index),
                                      ),
                                    ),
                                  ],
                                ),

                                // Approve Button (only for pending properties)
                                if (isPending && show24hBadge)
                                  const SizedBox(height: 12),

                                if (isPending && show24hBadge)
                                  Container(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      icon: const Icon(Icons.check_circle, size: 18),
                                      label: const Text("Approve & Publish Now"),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.green,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                      ),
                                      onPressed: () => _approveProperty(index),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // 24h Pending Badge
                      if (show24hBadge)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.timer, size: 14, color: Colors.white),
                                const SizedBox(width: 4),
                                Text(
                                  "Posted $timeAgo",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                      // Property Type Badge
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.blue.shade700,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            property.availableFor,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
  IconData _getFurnitureIcon(String furniture) {
    switch (furniture.toLowerCase()) {
      case "bed":
        return Icons.bed_rounded;
      case "tv":
        return Icons.tv_rounded;
      case "sofa":
        return Icons.chair_rounded;
      case "fridge":
        return Icons.kitchen_rounded;
      case "dining table":
        return Icons.dining_rounded;
      case "wardrobe":
        return Icons.warehouse_rounded;
      case "washing machine":
        return Icons.local_laundry_service_rounded;
      case "ac":
        return Icons.ac_unit_rounded;
      case "microwave":
        return Icons.microwave_rounded;
      case "study table":
        return Icons.desktop_mac_rounded;
      case "curtains":
        return Icons.curtains_rounded;
      case "geyser":
        return Icons.water_damage_rounded;
      default:
        return Icons.checkroom_rounded;
    }
  }
  Widget _buildStatusTab(String title, int count) {
    return Column(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            color: Color(0xFF64748B),
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E293B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _detailItem(IconData icon, String text) {
    return Column(
      children: [
        Icon(icon, size: 20, color: const Color(0xFF475569)),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF64748B),
          ),
        ),
      ],
    );
  }
}