import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';
import 'package:roofscout/features/properties/screens/property_view_page.dart';

class IndiaLocationPage extends StatefulWidget {
  String cityName;
  IndiaLocationPage({super.key, required this.cityName});

  @override
  State<IndiaLocationPage> createState() => _IndiaLocationPageState();
}

class _IndiaLocationPageState extends State<IndiaLocationPage> {
  GoogleMapController? mapController;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    searchController.text = widget.cityName; // widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tap the search icon to find the location 🔍"),
          duration: Duration(seconds: 3),
        ),
      );
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  LatLng selectedPosition = const LatLng(22.9734, 78.6569); // Center of India
  String selectedArea = "";

  Future<void> searchLocation(String query) async {
    try {
      List<Location> locations = await locationFromAddress("$query, India");

      if (locations.isNotEmpty) {
        final loc = locations.first;

        setState(() {
          selectedArea = query;
          selectedPosition = LatLng(loc.latitude, loc.longitude);
        });

        mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(selectedPosition, 14),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location not found in India")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "What is your landmark buy the home?",
          style: TextStyle(fontSize: 20),
        ),
        backgroundColor: Colors.blue,
      ),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: selectedPosition,
              zoom: 5,
            ),
            onMapCreated: (controller) => mapController = controller,
            markers: {
              Marker(
                markerId: const MarkerId("pick-point"),
                position: selectedPosition,
              ),
            },
          ),

          // Search box
          Positioned(
            top: 15,
            left: 15,
            right: 15,
            child: Material(
              elevation: 5,
              borderRadius: BorderRadius.circular(10),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search city/area in India (e.g., Pune, Delhi)",
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(12),
                  suffixIcon: IconButton(
                    tooltip: "Tap to search",
                    highlightColor: Colors.blue,
                    icon: const Icon(Icons.search),
                    onPressed: () =>
                        searchLocation(searchController.text.trim()),
                  ),
                ),
                onSubmitted: (value) => searchLocation(value),
              ),
            ),
          ),

          // Continue Button
          Positioned(
            bottom: 15,
            left: 15,
            right: 15,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.all(15),
              ),
              onPressed: selectedArea.isEmpty
                  ? null
                  : () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RoofHomePage(),
                        ),
                      );
                    },
              child: const Text("Continue", style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}
