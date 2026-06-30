import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:roofscout/features/settings/screens/help_support_page.dart';
import 'package:roofscout/core/models/property_model.dart';
import 'package:roofscout/features/post_property/screens/property_see_pages.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:roofscout/features/properties/services/property_service.dart';
import 'package:roofscout/features/properties/services/property_image_service.dart';
import 'package:roofscout/features/post_property/services/owner_documents_service.dart';
import 'package:roofscout/features/post_property/widgets/common_widgets.dart';
import 'package:roofscout/features/post_property/widgets/step1_basic_info.dart';
import 'package:roofscout/features/post_property/widgets/step2_property_details.dart';
import 'package:roofscout/features/post_property/widgets/step3_verification.dart';

import 'package:roofscout/features/post_property/services/owner_service.dart';

class PropertyStepsPages extends StatefulWidget {
  final PropertyModel? property; // Optional property for editing

  const PropertyStepsPages({super.key,this.property});

  @override
  State<PropertyStepsPages> createState() => _PropertyStepsModernState();
}

class _PropertyStepsModernState extends State<PropertyStepsPages> {
  final PageController _pageController = PageController();
  int currentStep = 0;

  List<dynamic> allCities = [];
  List<String> states = [];
  List<String> filteredCities = [];

  XFile? aadhaarFront;
  XFile? aadhaarBack;
  XFile? panFront;
  List<XFile> propertyImages = [];
  final ImagePicker picker = ImagePicker();

  // Form Controllers
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _propertyNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _contactNameController = TextEditingController();
  final TextEditingController _contactPhoneController = TextEditingController();
  final TextEditingController _contactEmailController = TextEditingController();

  // Dropdown Values
  String? selectedState;
  String? selectedCity;
  String? selectedPropertyType;
  String? selectedFurnishing;
  String? selectedListingType;
  String? selectedAvailableFrom;
  String? selectedBedrooms;
  String? selectedBathrooms;
  String? selectedFloor;
  String? selectedTotalFloors;
  String? selectedAge;
  String? selectedFacing;
  List<String> selectedImageUrls = [
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&auto=format&fit=crop',
  ];
  final List<String> furnitureOptions = [
    "Bed",
    "TV",
    "Sofa",
    "Fridge",
    "Dining Table",
    "Wardrobe",
    "Washing Machine",
    "AC",
    "Microwave",
    "Study Table",
    "Curtains",
    "Geyser",
  ];
  // Lists
  final List<String> propertyTypes = [
    "Apartment",
    "Villa",
    "Independent House",
    "Plot / Land",
    "Studio",
    "Office Space",
    "Shop",
    "Penthouse",
    "Farm House",
  ];

  final List<String> furnishingOptions = [
    "Fully Furnished",
    "Semi Furnished",
    "Unfurnished",
  ];

  final List<String> listingTypes = ["For Rent", "For Sale"];
  final List<String> availableFromOptions = [
    "Immediately",
    "Within 5 days",
    "Next Week",
    "Next Month",
    "Anytime",
  ];

  final List<String> bedroomOptions = ["1", "2", "3", "4", "5", "6+"];
  final List<String> bathroomOptions = ["1", "2", "3", "4", "5+"];
  final List<String> floorOptions = ["Ground", "1", "2", "3", "4", "5", "6+"];
  final List<String> totalFloorOptions = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "6",
    "7",
    "8",
    "9",
    "10+",
  ];
  final List<String> propertyAgeOptions = [
    "New Construction",
    "Under Construction",
    "0-1 Year",
    "1-5 Years",
    "5-10 Years",
    "10+ Years",
  ];
  final List<String> facingOptions = [
    "East",
    "West",
    "North",
    "South",
    "North-East",
    "North-West",
    "South-East",
    "South-West",
  ];

  // Amenities
  final Map<String, bool> amenities = {
    "Parking": false,
    "Power Backup": false,
    "Lift": false,
    "Swimming Pool": false,
    "Gym": false,
    "Club House": false,
    "24x7 Security": false,
    "Children's Play Area": false,
    "Garden/Park": false,
    "Water Supply": false,
    "Wifi": false,
    "CCTV": false,
    "Maintenance Staff": false,
    "Pet Friendly": false,
  };
  final String aadharFront =
      "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&auto=format&fit=crop"; // fixed URL

  final String panImage = "https://images.unsplash.com/photo-1600607687939-ce8a6c25118c?w=600&auto=format&fit=crop"; // fixed URL
  final Map<String, bool> selectedFurniture = {};
  List<String> existingImages = []; // Added for edit flow

  // Important: Validation flags for each step
  bool _step1Valid = false;
  bool _step2Valid = false;
  bool _step3Valid = false;

  @override
  void initState() {
    super.initState();

    for (var furniture in furnitureOptions) {
      selectedFurniture[furniture] = false;
    }

    if (widget.property != null) {
      final p = widget.property!;
      // Step 1: Basic Info
      _propertyNameController.text = p.name;
      _descriptionController.text = p.description;
      _addressController.text = p.address;
      _priceController.text = p.price.toStringAsFixed(0);
      _areaController.text = p.area.toString();
      
      selectedState = p.state;
      selectedCity = p.district;
      selectedPropertyType = p.propertyType;
      selectedListingType = p.availableFor; // "Rent" or "Sale"
      selectedAvailableFrom = p.availabilityTime;
      selectedBedrooms = p.bedrooms.toString();
      selectedBathrooms = p.bathrooms.toString();
      
      // Step 2: Details
      selectedFloor = p.floorNumber.toString();
      selectedTotalFloors = p.totalFloors.toString();
      selectedAge = p.propertyAge;
      selectedFacing = p.facing;
      
      // Existing Images
      existingImages = List.from(p.images);
      
      // Amenities
      for (var amenity in p.amenities) {
        if (amenities.containsKey(amenity)) {
          amenities[amenity] = true;
        }
      }

      // Furniture
      for (var furn in p.furniture) {
        for (var option in furnitureOptions) {
          if (furn.toLowerCase() == option.toLowerCase()) {
            selectedFurniture[option] = true;
          }
        }
      }
      
      if (p.furnishing == "Fully Furnished" || p.furnishing == "Semi Furnished") {
        selectedFurnishing = p.furnishing;
      } else {
        selectedFurnishing = "Unfurnished";
      }

      // Mark steps as valid for editing
      _step1Valid = true;
      _step2Valid = true; 
    }

    loadJsonData();
    _fetchOwnerData();

    // Add listeners for real-time validation
    _addressController.addListener(_validateStep1);
    _priceController.addListener(_validateStep1);
    _areaController.addListener(_validateStep1);
  }

  Future<void> _fetchOwnerData() async {
    try {
      final result = await OwnerService.getOwnerData();
      if (result["success"] && result["data"] != null) {
        final data = result["data"];
        setState(() {
          _contactNameController.text = data["full_name"] ?? "";
          _contactPhoneController.text = data["phone"] ?? "";
          _contactEmailController.text = data["email"] ?? "";
        });
      }
    } catch (e) {
      print("Error fetching owner data: $e");
    }
  }

  Future<void> loadJsonData() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/json/cities.json',
      );
      final data = json.decode(response);
      allCities = data;
      states = allCities.map((e) => e["state"].toString()).toSet().toList();
      
      // Handle pre-selection for edit mode
      if (selectedState != null) {
          filteredCities = allCities
              .where((element) => element["state"] == selectedState)
              .map((e) => e["name"].toString())
              .toList();
      }

      setState(() {});
    } catch (e) {
      print("Error loading cities: $e");
    }
  }

  void _validateStep1() {
    bool isValid =
        _addressController.text.isNotEmpty &&
        _priceController.text.isNotEmpty &&
        _areaController.text.isNotEmpty &&
        selectedState != null &&
        selectedCity != null &&
        selectedPropertyType != null &&
        selectedListingType != null &&
        selectedBedrooms != null;

    if (_step1Valid != isValid) {
      setState(() {
        _step1Valid = isValid;
      });
    }
  }

  void _validateStep2() {
    bool isValid =
        (propertyImages.length + existingImages.length) >= 1; // At least 1 property image required
    if (_step2Valid != isValid) {
      setState(() {
        _step2Valid = isValid;
      });
    }
  }

  void _validateStep3() {
    bool isValid =
        _contactNameController.text.isNotEmpty &&
        _contactPhoneController.text.length >= 10 &&
        aadhaarFront != null &&
        aadhaarBack != null &&
        panFront != null;

    if (_step3Valid != isValid) {
      setState(() {
        _step3Valid = isValid;
      });
    }
  }

  Future<void> _pickSingleImage(String type) async {
    final PermissionStatus status = await Permission.photos.request();

    if (status.isGranted || status.isLimited) {
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          if (type == "aadhaarFront") {
            aadhaarFront = image;
          } else if (type == "aadhaarBack") {
            aadhaarBack = image;
          } else if (type == "panFront") {
            panFront = image;
          }
        });
        _validateStep3();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permission denied to access photos"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickImages(List<XFile> list, int maxImages, String type) async {
    final PermissionStatus status = await Permission.photos.request();

    if (status.isGranted || status.isLimited) {
      final List<XFile>? images = await picker.pickMultiImage(
        maxWidth: 1200,
        maxHeight: 1200,
        imageQuality: 85,
      );

      if (images != null) {
        setState(() {
          if (list.length + images.length > maxImages) {
            int available = maxImages - list.length;
            if (available > 0) {
              list.addAll(images.take(available));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("Maximum $maxImages images allowed for $type"),
                  backgroundColor: Colors.red,
                ),
              );
            }
          } else {
            list.addAll(images);
          }
        });

        if (type == "property") _validateStep2();
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Permission denied to access photos"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _removeImage(List<XFile> list, int index, String type) {
    setState(() {
      list.removeAt(index);
    });
    if (type == "property") _validateStep2();
  }

  void _nextStep() {
    if (currentStep < 2) {
      // Validate current step before proceeding
      if (currentStep == 0 && !_step1Valid) {
        _showValidationError("Please fill all required basic details");
        return;
      }
      if (currentStep == 1 && !_step2Valid) {
        _showValidationError("Please add at least one property image");
        return;
      }

      setState(() {
        currentStep++;
        _pageController.animateToPage(
          currentStep,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
        _pageController.animateToPage(
          currentStep,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      });
    }
  }

  void _showValidationError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _submitProperty() async {
    if (!_step3Valid) {
      _showValidationError("Please complete all verification steps");
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // 1️⃣ Upload Owner Documents first
      final docResult = await OwnerDocumentsService.uploadDocuments(
        aadharFrontPath: aadhaarFront!.path,
        aadharBackPath: aadhaarBack?.path,
        panPath: panFront!.path,
      );

      if (docResult['success'] != true) {
        throw Exception("Failed to upload verification documents");
      }

      // 2️⃣ Create or Update property
      Map<String, dynamic> propertyResponse;
      if (widget.property != null) {
        propertyResponse = await _updateProperty();
      } else {
        propertyResponse = await _createPropertyInternal();
      }

      final int propertyId = propertyResponse['property_id'];

      // 3️⃣ Upload Property Images (Batch) if there are any new ones
      if (propertyImages.isNotEmpty) {
        await PropertyImagesService.addPropertyImagesBatch(
          propertyId: propertyId,
          imagePaths: propertyImages.map((e) => e.path).toList(),
        );
      }

      // Close loading dialog
      Navigator.pop(context);

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.property != null ? "Property updated successfully!" : "Property submitted for verification!"),
          backgroundColor: const Color(0xFF10B981),
          duration: const Duration(seconds: 2),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => PropertySeePages()),
      );
    } catch (e) {
      Navigator.pop(context); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Failed to submit property: $e"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<Map<String, dynamic>> _createPropertyInternal() async {
    final String furnitureForApi = selectedFurniture.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .join(', ');

    final List<String> selectedAmenities = amenities.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    return await PropertyService.addProperty(
      title: _propertyNameController.text,
      description: _descriptionController.text,
      propertyType: selectedPropertyType!,
      listingType: selectedListingType!,
      state: selectedState!,
      city: selectedCity!,
      fullAddress: _addressController.text,
      price: double.parse(_priceController.text),
      area: double.parse(_areaController.text),
      bedrooms: int.parse(selectedBedrooms!),
      bathrooms: int.parse(selectedBathrooms!),
      furnishing: selectedFurnishing!,
      furniture: furnitureForApi,
      floorNumber: int.parse(selectedFloor!),
      totalFloors: int.parse(selectedTotalFloors!),
      propertyAge: selectedAge!,
      facing: selectedFacing!,
      availableFrom: selectedAvailableFrom!,
      images: [], // Images will be uploaded via PropertyImagesService next
      amenities: selectedAmenities,
    );
  }

  Future<Map<String, dynamic>> _updateProperty() async {
    final String furnitureForApi = selectedFurniture.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .join(', ');

    final List<String> selectedAmenities = amenities.entries
        .where((e) => e.value)
        .map((e) => e.key)
        .toList();

    return await PropertyService.updateProperty(
      id: widget.property!.id,
      title: _propertyNameController.text,
      description: _descriptionController.text,
      propertyType: selectedPropertyType!,
      listingType: selectedListingType!,
      state: selectedState!,
      city: selectedCity!,
      fullAddress: _addressController.text,
      price: double.parse(_priceController.text),
      area: double.parse(_areaController.text),
      bedrooms: int.parse(selectedBedrooms!),
      bathrooms: int.parse(selectedBathrooms!),
      furnishing: selectedFurnishing!,
      furniture: furnitureForApi,
      floorNumber: int.parse(selectedFloor!),
      totalFloors: int.parse(selectedTotalFloors!),
      propertyAge: selectedAge!,
      facing: selectedFacing!,
      availableFrom: selectedAvailableFrom!,
      images: existingImages, // New images will be uploaded via PropertyImagesService batch
      amenities: selectedAmenities,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: Column(
        children: [
          // Custom App Bar
          _buildAppBar(),

          // Progress Bar
          _buildProgressBar(),

          // Page Content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildStep1(), _buildStep2(), _buildStep3()],
            ),
          ),

          // Bottom Navigation
          _buildBottomNavigation(),
        ],
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 12,
        left: 20,
        right: 20,
        bottom: 16,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                size: 18,
                color: Color(0xFF475569),
              ),
            ),
          ),

          Text(
            "List Your Property",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E293B),
            ),
          ),

          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HelpSupportPage(),
                  ),
                );
              },
              child: const Icon(
                Icons.help_outline_rounded,
                size: 20,
                color: Color(0xFF475569),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final steps = ["Basic Info", "Details", "Verification"];

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          // Steps Indicator
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: steps.asMap().entries.map((entry) {
              int index = entry.key;
              String step = entry.value;
              bool isActive = index <= currentStep;

              return Expanded(
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background Circle
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Color(0xFF0066FF)
                                : Color(0xFFE2E8F0),
                            shape: BoxShape.circle,
                          ),
                          child: isActive
                              ? Icon(Icons.check, size: 18, color: Colors.white)
                              : Center(
                                  child: Text(
                                    (index + 1).toString(),
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                        ),

                        // Success Check
                        if (index < currentStep)
                          Positioned(
                            right: 0,
                            top: 0,
                            child: Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Color(0xFF10B981),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                              ),
                              child: Icon(
                                Icons.check,
                                size: 8,
                                color: Colors.white,
                              ),
                            ),
                          ),
                      ],
                    ),

                    SizedBox(height: 8),

                    Text(
                      step,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isActive ? Color(0xFF0066FF) : Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),

          SizedBox(height: 12),

          // Progress Line
          Container(
            margin: EdgeInsets.symmetric(horizontal: 40),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Color(0xFF0066FF),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Container(width: 20, height: 4, color: Color(0xFF0066FF)),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: currentStep >= 1
                          ? Color(0xFF0066FF)
                          : Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Container(
                  width: 20,
                  height: 4,
                  color: currentStep >= 1
                      ? Color(0xFF0066FF)
                      : Color(0xFFE2E8F0),
                ),
                Expanded(
                  child: Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: currentStep >= 2
                          ? Color(0xFF0066FF)
                          : Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(2),
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

  Widget _buildStep1() {
    return Step1BasicInfo(
      propertyNameController: _propertyNameController,
      descriptionController: _descriptionController,
      addressController: _addressController,
      priceController: _priceController,
      areaController: _areaController,
      selectedState: selectedState,
      selectedCity: selectedCity,
      selectedPropertyType: selectedPropertyType,
      selectedListingType: selectedListingType,
      selectedFurnishing: selectedFurnishing,
      selectedBedrooms: selectedBedrooms,
      selectedBathrooms: selectedBathrooms,
      states: states,
      filteredCities: filteredCities,
      propertyTypes: propertyTypes,
      listingTypes: listingTypes,
      furnishingOptions: furnishingOptions,
      bedroomOptions: bedroomOptions,
      bathroomOptions: bathroomOptions,
      furnitureOptions: furnitureOptions,
      selectedFurniture: selectedFurniture,
      onStateChanged: (value) {
        setState(() {
          selectedState = value;
          selectedCity = null;
          filteredCities = allCities
              .where((c) => c["state"] == selectedState)
              .map<String>((c) => c["name"])
              .toList();
        });
      },
      onCityChanged: (value) {
        setState(() {
          selectedCity = value;
        });
        _validateStep1();
      },
      onPropertyTypeChanged: (value) {
        setState(() {
          selectedPropertyType = value;
        });
        _validateStep1();
      },
      onListingTypeChanged: (value) {
        setState(() {
          selectedListingType = value;
        });
        _validateStep1();
      },
      onFurnishingChanged: (value) {
        setState(() {
          selectedFurnishing = value;
          // If changing to "Unfurnished", clear all furniture selections
          if (value == "Unfurnished") {
            for (var furniture in furnitureOptions) {
              selectedFurniture[furniture] = false;
            }
          }
          // If changing to "Fully Furnished", select all furniture
          else if (value == "Fully Furnished") {
            for (var furniture in furnitureOptions) {
              selectedFurniture[furniture] = true;
            }
          }
        });
      },
      onBedroomsChanged: (value) {
        setState(() {
          selectedBedrooms = value;
        });
        _validateStep1();
      },
      onBathroomsChanged: (value) {
        setState(() {
          selectedBathrooms = value;
        });
      },
      onFurnitureItemToggle: (furniture, value) {
        setState(() {
          selectedFurniture[furniture] = value;
        });
      },
      onSelectAllFurniture: () {
        setState(() {
          for (var furniture in furnitureOptions) {
            selectedFurniture[furniture] = true;
          }
        });
      },
      onClearAllFurniture: () {
        setState(() {
          for (var furniture in furnitureOptions) {
            selectedFurniture[furniture] = false;
          }
        });
      },
    );
  }

  Widget _buildStep2() {
    return Step2PropertyDetails(
      selectedFloor: selectedFloor,
      selectedTotalFloors: selectedTotalFloors,
      selectedAge: selectedAge,
      selectedFacing: selectedFacing,
      selectedAvailableFrom: selectedAvailableFrom,
      floorOptions: floorOptions,
      totalFloorOptions: totalFloorOptions,
      propertyAgeOptions: propertyAgeOptions,
      facingOptions: facingOptions,
      availableFromOptions: availableFromOptions,
      amenities: amenities,
      propertyImages: propertyImages,
      existingImages: existingImages,
      onFloorChanged: (value) {
        setState(() {
          selectedFloor = value;
        });
      },
      onTotalFloorsChanged: (value) {
        setState(() {
          selectedTotalFloors = value;
        });
      },
      onAgeChanged: (value) {
        setState(() {
          selectedAge = value;
        });
      },
      onFacingChanged: (value) {
        setState(() {
          selectedFacing = value;
        });
      },
      onAvailableFromChanged: (value) {
        setState(() {
          selectedAvailableFrom = value;
        });
      },
      onAmenityToggle: (amenity, value) {
        setState(() {
          amenities[amenity] = value;
        });
      },
      onPickPropertyImages: () {
        _pickImages(propertyImages, 10, "property");
      },
      onRemovePropertyImage: (index) {
        _removeImage(propertyImages, index, "property");
      },
      onRemoveExistingImage: (index) {
        setState(() {
          existingImages.removeAt(index);
        });
        _validateStep2();
      },
    );
  }

  Widget _buildStep3() {
    return Step3Verification(
      contactNameController: _contactNameController,
      contactPhoneController: _contactPhoneController,
      contactEmailController: _contactEmailController,
      aadhaarFront: aadhaarFront,
      aadhaarBack: aadhaarBack,
      panFront: panFront,
      onPickAadhaarFront: () => _pickSingleImage("aadhaarFront"),
      onPickAadhaarBack: () => _pickSingleImage("aadhaarBack"),
      onPickPanFront: () => _pickSingleImage("panFront"),
    );
  }



  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Previous Button
          if (currentStep > 0)
            Expanded(
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    "Previous",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF475569),
                    ),
                  ),
                ),
              ).onTap(_previousStep),
            ),

          if (currentStep > 0) SizedBox(width: 12),

          // Next/Submit Button
          Expanded(
            flex: currentStep == 0 ? 2 : 1,
            child:
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: _getButtonColor(),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      currentStep < 2 ? "Next Step" : "Submit Property",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ).onTap(() {
                  if (currentStep < 2) {
                    _nextStep();
                  } else {
                    _submitProperty();
                  }
                }),
          ),
        ],
      ),
    );
  }

  Color _getButtonColor() {
    if (currentStep == 0 && !_step1Valid) return Color(0xFF94A3B8);
    if (currentStep == 1 && !_step2Valid) return Color(0xFF94A3B8);
    if (currentStep == 2 && !_step3Valid) return Color(0xFF94A3B8);
    return Color(0xFF0066FF);
  }
}


