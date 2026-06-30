class PropertyModel {
  int id;
  String name;
  String description;
  List<String> images;
  String address;
  String state;
  String district;
  double price;
  int bedrooms;
  int bathrooms;
  String propertyType;
  String furnishing;
  List<String> furniture;
  String availableFor;
  String availabilityTime;
  double area;
  List<String> amenities;
  String propertyAge;
  DateTime uploadedAt;
  bool isPendingApproval;
  int floorNumber;
  int totalFloors;
  String facing;

  PropertyModel({
    required this.id,
    required this.name,
    required this.description,
    required this.images,
    required this.address,
    required this.state,
    required this.district,
    required this.price,
    required this.bedrooms,
    required this.bathrooms,
    required this.propertyType,
    required this.furnishing,
    required this.furniture,
    required this.availableFor,
    required this.availabilityTime,
    required this.area,
    required this.amenities,
    required this.propertyAge,
    required this.uploadedAt,
    this.isPendingApproval = true,
    this.floorNumber = 0,
    this.totalFloors = 0,
    this.facing = '',
  });

  factory PropertyModel.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse lists
    List<String> parseList(dynamic input) {
      if (input == null) return [];
      if (input is List) {
        return input.map((e) => e.toString()).toList();
      }
      return [];
    }

    return PropertyModel(
      id: json['property_id'] is int ? json['property_id'] : int.tryParse(json['property_id'].toString()) ?? 0,
      name: json['title'] ?? 'No Title',
      description: json['description'] ?? '',
      images: parseList(json['images']),
      address: json['full_address'] ?? '',
      state: json['state'] ?? '',
      district: json['city'] ?? '',
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      bedrooms: int.tryParse(json['bedrooms'].toString()) ?? 0,
      bathrooms: int.tryParse(json['bathrooms'].toString()) ?? 0,
      propertyType: json['property_type'] ?? 'Apartment',
      furnishing: json['furnishing'] ?? 'Unfurnished',
      furniture: parseList(json['furniture']),
      availableFor: json['listing_type'] ?? 'Rent',
      // Directly using available_from as String, or default to "Immediate"
      availabilityTime: json['available_from']?.toString() ?? "Immediate",
      area: double.tryParse(json['area'].toString()) ?? 0.0,
      amenities: parseList(json['amenities']),
      propertyAge: json['property_age']?.toString() ?? '0',
      uploadedAt: DateTime.tryParse(json['created_at'].toString()) ?? DateTime.now(),
      isPendingApproval: json['is_available'] == false,
      floorNumber: int.tryParse(json['floor_number'].toString()) ?? 0,
      totalFloors: int.tryParse(json['total_floors'].toString()) ?? 0,
      facing: json['facing'] ?? '',
    );
  }
}
