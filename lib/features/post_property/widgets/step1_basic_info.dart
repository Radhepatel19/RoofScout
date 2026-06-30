import 'package:flutter/material.dart';
import 'common_widgets.dart';

class Step1BasicInfo extends StatelessWidget {
  final TextEditingController propertyNameController;
  final TextEditingController descriptionController;
  final TextEditingController addressController;
  final TextEditingController priceController;
  final TextEditingController areaController;

  final String? selectedState;
  final String? selectedCity;
  final String? selectedPropertyType;
  final String? selectedListingType;
  final String? selectedFurnishing;
  final String? selectedBedrooms;
  final String? selectedBathrooms;

  final List<String> states;
  final List<String> filteredCities;
  final List<String> propertyTypes;
  final List<String> listingTypes;
  final List<String> furnishingOptions;
  final List<String> bedroomOptions;
  final List<String> bathroomOptions;
  final List<String> furnitureOptions;
  final Map<String, bool> selectedFurniture;

  final Function(String?) onStateChanged;
  final Function(String?) onCityChanged;
  final Function(String?) onPropertyTypeChanged;
  final Function(String?) onListingTypeChanged;
  final Function(String?) onFurnishingChanged;
  final Function(String?) onBedroomsChanged;
  final Function(String?) onBathroomsChanged;
  final Function(String, bool) onFurnitureItemToggle;
  final VoidCallback onSelectAllFurniture;
  final VoidCallback onClearAllFurniture;

  const Step1BasicInfo({
    super.key,
    required this.propertyNameController,
    required this.descriptionController,
    required this.addressController,
    required this.priceController,
    required this.areaController,
    required this.selectedState,
    required this.selectedCity,
    required this.selectedPropertyType,
    required this.selectedListingType,
    required this.selectedFurnishing,
    required this.selectedBedrooms,
    required this.selectedBathrooms,
    required this.states,
    required this.filteredCities,
    required this.propertyTypes,
    required this.listingTypes,
    required this.furnishingOptions,
    required this.bedroomOptions,
    required this.bathroomOptions,
    required this.furnitureOptions,
    required this.selectedFurniture,
    required this.onStateChanged,
    required this.onCityChanged,
    required this.onPropertyTypeChanged,
    required this.onListingTypeChanged,
    required this.onFurnishingChanged,
    required this.onBedroomsChanged,
    required this.onBathroomsChanged,
    required this.onFurnitureItemToggle,
    required this.onSelectAllFurniture,
    required this.onClearAllFurniture,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Basic Property Information",
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),

          SizedBox(height: 8),

          Text(
            "Fill in the basic details of your property",
            style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
          ),

          SizedBox(height: 24),

          // Property Name
          PropertyCommonWidgets.buildInputField(
            "Property Name / Title",
            propertyNameController,
            "e.g., Luxury 3BHK Apartment in Vesu",
            Icons.home_work_outlined,
          ),

          SizedBox(height: 16),

          // Property Description
          Text(
            "Description",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF475569),
            ),
          ),

          SizedBox(height: 8),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Color(0xFFE2E8F0)),
            ),
            child: TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: "Describe your property in detail...",
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(16),
              ),
              style: TextStyle(fontSize: 15),
            ),
          ),

          SizedBox(height: 24),

          // Location Section
          Text(
            "📍 Location Details",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),

          SizedBox(height: 16),

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
                PropertyCommonWidgets.buildDropdown(
                  "State",
                  selectedState,
                  states,
                  Icons.location_city_rounded,
                  onStateChanged,
                ),

                SizedBox(height: 16),

                PropertyCommonWidgets.buildDropdown(
                  "City / District",
                  selectedCity,
                  filteredCities,
                  Icons.location_on_rounded,
                  onCityChanged,
                ),

                SizedBox(height: 16),

                PropertyCommonWidgets.buildInputField(
                  "Full Address",
                  addressController,
                  "Enter complete address with landmark",
                  Icons.maps_home_work_rounded,
                ),
              ],
            ),
          ),

          SizedBox(height: 24),

          // Property Specifications
          Text(
            "🏠 Property Specifications",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),

          SizedBox(height: 16),

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
                PropertyCommonWidgets.buildDropdown(
                  "Property Type",
                  selectedPropertyType,
                  propertyTypes,
                  Icons.apartment_rounded,
                  onPropertyTypeChanged,
                ),

                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: PropertyCommonWidgets.buildDropdown(
                        "Listing Type",
                        selectedListingType,
                        listingTypes,
                        Icons.sell_rounded,
                        onListingTypeChanged,
                      ),
                    ),

                    SizedBox(width: 16),

                    Expanded(
                      child: PropertyCommonWidgets.buildDropdown(
                        "Furnishing",
                        selectedFurnishing,
                        furnishingOptions,
                        Icons.chair_rounded,
                        onFurnishingChanged,
                      ),
                    ),
                  ],
                ),

                // Show furniture selection only when Furnishing is selected and not "Unfurnished"
                if (selectedFurnishing != null &&
                    selectedFurnishing != "Unfurnished")
                  _buildFurnitureSelection(),

                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: PropertyCommonWidgets.buildInputField(
                        "Price (₹)",
                        priceController,
                        "e.g., 2500000",
                        Icons.currency_rupee_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),

                    SizedBox(width: 16),

                    Expanded(
                      child: PropertyCommonWidgets.buildInputField(
                        "Area (sq. ft)",
                        areaController,
                        "e.g., 1250",
                        Icons.square_foot_rounded,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: PropertyCommonWidgets.buildDropdown(
                        "Bedrooms",
                        selectedBedrooms,
                        bedroomOptions,
                        Icons.bed_rounded,
                        onBedroomsChanged,
                      ),
                    ),

                    SizedBox(width: 16),

                    Expanded(
                      child: PropertyCommonWidgets.buildDropdown(
                        "Bathrooms",
                        selectedBathrooms,
                        bathroomOptions,
                        Icons.bathtub_rounded,
                        onBathroomsChanged,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildFurnitureSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 16),
        Text(
          "Select Available Furniture",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        SizedBox(height: 8),
        Text(
          selectedFurnishing == "Fully Furnished"
              ? "All furniture should be selected for fully furnished"
              : "Select which furniture items are included",
          style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
        ),
        SizedBox(height: 16),
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
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: furnitureOptions.length,
                itemBuilder: (context, index) {
                  return _buildFurnitureGridItem(furnitureOptions[index]);
                },
              ),

              if (selectedFurnishing == "Fully Furnished")
                Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Row(
                    children: [
                      PropertyCommonWidgets.buildFurnitureActionButton(
                        "Select All",
                        Color(0xFF10B981),
                        Icons.check_circle_outline_rounded,
                        onSelectAllFurniture,
                      ),
                      SizedBox(width: 12),
                      PropertyCommonWidgets.buildFurnitureActionButton(
                        "Clear All",
                        Color(0xFFEF4444),
                        Icons.highlight_off_rounded,
                        onClearAllFurniture,
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFurnitureGridItem(String furniture) {
    return GestureDetector(
      onTap: () {
        // Don't allow deselection if Fully Furnished is selected
        if (selectedFurnishing == "Fully Furnished" &&
            selectedFurniture[furniture] == false) {
          return;
        }

        onFurnitureItemToggle(furniture, !selectedFurniture[furniture]!);
      },
      child: Container(
        decoration: BoxDecoration(
          color: selectedFurniture[furniture]!
              ? Color(0xFF0066FF).withOpacity(0.1)
              : Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selectedFurniture[furniture]!
                ? Color(0xFF0066FF)
                : Color(0xFFE2E8F0),
            width: selectedFurniture[furniture]! ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: selectedFurniture[furniture]!
                    ? Color(0xFF0066FF).withOpacity(0.2)
                    : Color(0xFFE2E8F0),
                shape: BoxShape.circle,
              ),
              child: Icon(
                PropertyCommonWidgets.getFurnitureIcon(furniture),
                size: 18,
                color: selectedFurniture[furniture]!
                    ? Color(0xFF0066FF)
                    : Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                furniture,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  color: selectedFurniture[furniture]!
                      ? Color(0xFF0066FF)
                      : Color(0xFF475569),
                  fontWeight: selectedFurniture[furniture]!
                      ? FontWeight.w600
                      : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
