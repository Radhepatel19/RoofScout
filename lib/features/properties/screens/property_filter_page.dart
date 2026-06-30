import 'package:flutter/material.dart';
import 'package:roofscout/features/home/screens/menu_handler.dart';

import 'package:roofscout/features/properties/screens/property_view_page.dart';
import 'package:roofscout/features/properties/services/property_filter_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyFilterPage extends StatefulWidget {
  final String cityName;
  const PropertyFilterPage({super.key, required this.cityName});

  @override
  State<PropertyFilterPage> createState() => _PropertyFilterPageState();
}

class _PropertyFilterPageState extends State<PropertyFilterPage> {
  double minBudget = 5000;
  double maxBudget = 50000;
  int bedrooms = 1;
  String furnishing = "Fully Furnished";
  String propertyType = "Apartment";
  bool showAdvancedFilters = false;
  bool _isLoading = false;

  // Advanced Filters
  String postedBy = "Owner";
  String availableFor = "For Rent";
  String availableFrom = "Immediately";
  String selectedArea = "1000+";
  String selectedBathroom = "1";

  List<String> amenities = [
    "Parking",
    "Power Backup",
    "Lift",
    "Swimming Pool",
    "Gym",
    "Club House",
    "24x7 Security",
    "Children's Play Area",
    "Garden/Park",
    "Water Supply",
    "Wifi",
    "CCTV",
    "Maintenance Staff",
    "Pet Friendly"
  ];
  List<String> selectedAmenities = [];

  void _toggleAmenity(String amenity) {
    setState(() {
      if (selectedAmenities.contains(amenity)) {
        selectedAmenities.remove(amenity);
      } else {
        selectedAmenities.add(amenity);
      }
    });
  }

  Future<void> goHome(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstVisit', false);

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MenuHandler()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // block default back
      onPopInvoked: (didPop) async {
        if (!didPop) {
          await goHome(context); // system back pressed
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey[100],
        appBar: AppBar(
          title: Text(
            "Filters - ${widget.cityName}",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blue.shade700,
          scrolledUnderElevation: 0,
          elevation: 0,
          automaticallyImplyLeading: false,
          foregroundColor: Colors.white,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _sectionTitle("💰 Budget (₹)"),
              _budgetSlider(),

              _sectionTitle("🛏️ Bedrooms"),
              _bedroomSelector(),

              _sectionTitle("🏢 Property Type"),
              _dropdownSelector(
                [
                  "Apartment",
                  "Villa",
                  "Independent House",
                  "Plot / Land",
                  "Studio",
                  "Office Space",
                  "Shop",
                  "Penthouse",
                  "Farm House",
                ],
                propertyType,
                (val) => setState(() => propertyType = val!),
              ),

              _sectionTitle("🪑 Furnishing Status"),
              _dropdownSelector(
                [ "Fully Furnished","Semi Furnished","Unfurnished",],
                furnishing,
                (val) => setState(() => furnishing = val!),
              ),

              const SizedBox(height: 18),

              // 🔹 Advanced Filters Header (Toggle)
              GestureDetector(
                onTap: () {
                  setState(() {
                    showAdvancedFilters = !showAdvancedFilters;
                  });
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(Icons.tune, color: Colors.blue.shade700),
                      const SizedBox(width: 10),
                      Text(
                        showAdvancedFilters
                            ? "Hide Advanced Filters"
                            : "Show Advanced Filters",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        showAdvancedFilters
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                        color: Colors.blue.shade700,
                      ),
                    ],
                  ),
                ),
              ),

              // 🔹 Conditional Advanced Filters
              AnimatedCrossFade(
                firstChild: const SizedBox.shrink(),
                secondChild: _advancedFiltersSection(),
                crossFadeState: showAdvancedFilters
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                duration: const Duration(milliseconds: 300),
              ),

              const SizedBox(height: 30),

              // 🟦 View Homes Button
              Center(
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () async {
                          setState(() => _isLoading = true);

                          try {
                            // Extract area value as int (e.g. "1000+" -> 1000)
                            int? area = int.tryParse(
                                selectedArea.replaceAll('+', ''));
                            int? bathrooms = int.tryParse(
                                selectedBathroom.replaceAll('+', ''));

                            final result =
                                await PropertyFilterService.saveFilter(
                              city: widget.cityName,
                              availableFor: availableFor,
                              minBudget: minBudget.toInt(),
                              maxBudget: maxBudget.toInt(),
                              bedrooms: bedrooms,
                              propertyType: propertyType,
                              furnishingStatus: furnishing,
                              postedBy: postedBy,
                              minAreaSqft: area,
                              availableFrom: availableFrom,
                              bathrooms: bathrooms,
                              amenities: selectedAmenities,
                            );

                            if (mounted) {
                              setState(() => _isLoading = false);
                              if (result["success"]) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => RoofHomePage()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(result["message"] ??
                                        "Failed to save filters"),
                                    backgroundColor: Colors.red,
                                  ),
                                );
                              }
                            }
                          } catch (e) {
                            if (mounted) {
                              setState(() => _isLoading = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Error: ${e.toString()}"),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 14,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 5,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          "🔍 View Homes",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // 🔹 Basic Section Title
  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 17,
        color: Colors.black87,
      ),
    ),
  );

  // 🔹 Budget Slider
  Widget _budgetSlider() => Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text("₹${minBudget.toInt()}"),
          Text("₹${maxBudget.toInt()}"),
        ],
      ),
      RangeSlider(
        values: RangeValues(minBudget, maxBudget),
        min: 0,
        max: 100000,
        divisions: 50,
        activeColor: Colors.blue.shade700,
        inactiveColor: Colors.blue.shade100,
        labels: RangeLabels("₹${minBudget.toInt()}", "₹${maxBudget.toInt()}"),
        onChanged: (values) {
          setState(() {
            minBudget = values.start;
            maxBudget = values.end;
          });
        },
      ),
    ],
  );

  // 🔹 Bedrooms
  Widget _bedroomSelector() {
    return Wrap(
      spacing: 8,
      children: List.generate(6, (i) {
        final label = i == 5 ? "5+" : "$i";
        final selected = bedrooms == i;
        return ChoiceChip(
          label: Text(label),
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black87,
          ),
          selected: selected,
          onSelected: (_) => setState(() => bedrooms = i),
          selectedColor: Colors.blue.shade700,
          backgroundColor: Colors.grey.shade200,
        );
      }),
    );
  }

  // 🔹 Dropdowns
  Widget _dropdownSelector(
    List<String> options,
    String currentValue,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButton<String>(
        value: currentValue,
        isExpanded: true,
        underline: const SizedBox(),
        dropdownColor: Colors.white,
        icon: const Icon(Icons.arrow_drop_down),
        items: options
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  // 🔹 Advanced Filters Section
  Widget _advancedFiltersSection() => Padding(
    padding: const EdgeInsets.only(top: 10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle("👤 Posted By"),
        _chipSelector(
          ["Owner", "Dealer", "Builder"],
          postedBy,
          (val) => setState(() => postedBy = val),
        ),

        _sectionTitle("📜 Available For"),
        _chipSelector(
          ["For Rent", "For Sale"],
          availableFor,
          (val) => setState(() => availableFor = val),
        ),

        _sectionTitle("🏗️ Amenities"),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: amenities.map((amenity) {
            final selected = selectedAmenities.contains(amenity);
            return FilterChip(
              label: Text(amenity),
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black87,
              ),
              selected: selected,
              onSelected: (_) => _toggleAmenity(amenity),
              selectedColor: Colors.blue.shade700,
              backgroundColor: Colors.grey.shade200,
            );
          }).toList(),
        ),

        _sectionTitle("📏 Area (sq.ft)"),
        _dropdownSelector(
          ["500+", "1000+", "1500+", "2000+", "2500+", "3000+"],
          selectedArea,
          (val) => setState(() => selectedArea = val!),
        ),

        _sectionTitle("🛁 Bathrooms"),
        _chipSelector(
          ["0", "1", "2", "3", "4","5+"],
          selectedBathroom,
          (val) => setState(() => selectedBathroom = val),
        ),

        _sectionTitle("📅 Available From"),
        _chipSelector(
          [ "Immediately","Within 5 days","Next Week","Next Month","Anytime",],
          availableFrom,
          (val) => setState(() => availableFrom = val),
        ),
      ],
    ),
  );

  // 🔹 Chips
  Widget _chipSelector(
    List<String> options,
    String selected,
    ValueChanged<String> onSelected,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((option) {
        final bool isSelected = selected == option;
        return ChoiceChip(
          label: Text(option),
          labelStyle: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w500,
          ),
          selected: isSelected,
          onSelected: (_) => onSelected(option),
          selectedColor: Colors.blue.shade700,
          backgroundColor: Colors.grey.shade200,
        );
      }).toList(),
    );
  }
}
