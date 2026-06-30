import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // For XFile
import 'common_widgets.dart';

class Step2PropertyDetails extends StatefulWidget {
  final String? selectedFloor;
  final String? selectedTotalFloors;
  final String? selectedAge;
  final String? selectedFacing;
  final String? selectedAvailableFrom;

  final List<String> floorOptions;
  final List<String> totalFloorOptions;
  final List<String> propertyAgeOptions;
  final List<String> facingOptions;
  final List<String> availableFromOptions;

  final Map<String, bool> amenities;
  final List<XFile> propertyImages;
  final List<String> existingImages; // Added for edit flow

  final Function(String?) onFloorChanged;
  final Function(String?) onTotalFloorsChanged;
  final Function(String?) onAgeChanged;
  final Function(String?) onFacingChanged;
  final Function(String?) onAvailableFromChanged;
  final Function(String, bool) onAmenityToggle;
  final VoidCallback onPickPropertyImages;
  final Function(int) onRemovePropertyImage;
  final Function(int) onRemoveExistingImage; // Added for edit flow

  const Step2PropertyDetails({
    super.key,
    required this.selectedFloor,
    required this.selectedTotalFloors,
    required this.selectedAge,
    required this.selectedFacing,
    required this.selectedAvailableFrom,
    required this.floorOptions,
    required this.totalFloorOptions,
    required this.propertyAgeOptions,
    required this.facingOptions,
    required this.availableFromOptions,
    required this.amenities,
    required this.propertyImages,
    this.existingImages = const [], // Default to empty
    required this.onFloorChanged,
    required this.onTotalFloorsChanged,
    required this.onAgeChanged,
    required this.onFacingChanged,
    required this.onAvailableFromChanged,
    required this.onAmenityToggle,
    required this.onPickPropertyImages,
    required this.onRemovePropertyImage,
    required this.onRemoveExistingImage, // Required callback
  });

  @override
  State<Step2PropertyDetails> createState() => _Step2PropertyDetailsState();
}

class _Step2PropertyDetailsState extends State<Step2PropertyDetails> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Property Details & Images",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),

          SizedBox(height: 8),

          Text(
            "Add detailed information and photos",
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),

          SizedBox(height: 24),

          // Additional Specifications
          Container(
            padding: EdgeInsets.all(20),
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
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: PropertyCommonWidgets.buildDropdown(
                        "Floor Number",
                        widget.selectedFloor,
                        widget.floorOptions,
                        Icons.stairs_rounded,
                        widget.onFloorChanged,
                      ),
                    ),

                    SizedBox(width: 16),

                    Expanded(
                      child: PropertyCommonWidgets.buildDropdown(
                        "Total Floors",
                        widget.selectedTotalFloors,
                        widget.totalFloorOptions,
                        Icons.vertical_align_top_rounded,
                        widget.onTotalFloorsChanged,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: PropertyCommonWidgets.buildDropdown(
                        "Property Age",
                        widget.selectedAge,
                        widget.propertyAgeOptions,
                        Icons.calendar_today_rounded,
                        widget.onAgeChanged,
                      ),
                    ),

                    SizedBox(width: 16),

                    Expanded(
                      child: PropertyCommonWidgets.buildDropdown(
                        "Facing",
                        widget.selectedFacing,
                        widget.facingOptions,
                        Icons.wb_sunny_rounded,
                        widget.onFacingChanged,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                PropertyCommonWidgets.buildDropdown(
                  "Available From",
                  widget.selectedAvailableFrom,
                  widget.availableFromOptions,
                  Icons.date_range_rounded,
                  widget.onAvailableFromChanged,
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Amenities Section
          Text(
            "✨ Amenities",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),

          SizedBox(height: 12),

          Container(
            padding: EdgeInsets.all(20),
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
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: widget.amenities.keys.map((amenity) {
                return GestureDetector(
                  onTap: () {
                    widget.onAmenityToggle(amenity, !widget.amenities[amenity]!);
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: widget.amenities[amenity]!
                          ? Color(0xFF0066FF).withOpacity(0.1)
                          : Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: widget.amenities[amenity]!
                            ? Color(0xFF0066FF)
                            : Color(0xFFE2E8F0),
                        width: widget.amenities[amenity]! ? 1.5 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        widget.amenities[amenity]!
                            ? Icon(
                                Icons.check_circle_rounded,
                                size: 16,
                                color: Color(0xFF0066FF),
                              )
                            : Icon(
                                Icons.circle_outlined,
                                size: 16,
                                color: Color(0xFF94A3B8),
                              ),
                        SizedBox(width: 8),
                        Text(
                          amenity,
                          style: TextStyle(
                            fontSize: 14,
                            color: widget.amenities[amenity]!
                                ? Color(0xFF0066FF)
                                : Color(0xFF475569),
                            fontWeight: widget.amenities[amenity]!
                                ? FontWeight.w600
                                : FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 24),

          // Property Images
          Text(
            "📷 Property Images",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),

          SizedBox(height: 8),

          Text(
            "Upload clear photos of all rooms, exterior, and amenities",
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),

          SizedBox(height: 12),

          // Image Upload Button
          Container(
            width: double.infinity,
            height: 150,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: (widget.propertyImages.isEmpty && widget.existingImages.isEmpty)
                    ? Color(0xFFE2E8F0)
                    : Color(0xFF10B981),
                width: 2,
                style: BorderStyle.solid,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 12,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.cloud_upload_rounded,
                  size: 40,
                  color: (widget.propertyImages.isEmpty && widget.existingImages.isEmpty)
                      ? Color(0xFF94A3B8)
                      : Color(0xFF10B981),
                ),
                SizedBox(height: 12),
                Text(
                  (widget.propertyImages.isEmpty && widget.existingImages.isEmpty)
                      ? "Tap to upload property images"
                      : "${widget.propertyImages.length + widget.existingImages.length} images selected",
                  style: TextStyle(
                    fontSize: 14,
                    color: (widget.propertyImages.isEmpty && widget.existingImages.isEmpty)
                        ? Color(0xFF64748B)
                        : Color(0xFF10B981),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Minimum 1, Maximum 10 images",
                  style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ).onTap(widget.onPickPropertyImages),

          SizedBox(height: 16),

          // Selected Images Grid
          if (widget.propertyImages.isNotEmpty || widget.existingImages.isNotEmpty)
            GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1,
              ),
              itemCount: widget.propertyImages.length + widget.existingImages.length,
              itemBuilder: (context, index) {
                // Determine if this is an existing image or a new one
                bool isExisting = index < widget.existingImages.length;
                
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: isExisting 
                              ? NetworkImage(widget.existingImages[index]) 
                              : FileImage(File(widget.propertyImages[index - widget.existingImages.length].path)) as ImageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          if (isExisting) {
                            widget.onRemoveExistingImage(index);
                          } else {
                            widget.onRemovePropertyImage(index - widget.existingImages.length);
                          }
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

          SizedBox(height: 40),
        ],
      ),
    );
  }
}
