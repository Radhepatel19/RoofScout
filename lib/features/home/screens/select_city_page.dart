import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:roofscout/features/properties/screens/property_filter_page.dart';
import 'package:roofscout/features/home/services/city_service.dart';

class SelectCityPage extends StatefulWidget {
  final bool returnResult;
  const SelectCityPage({super.key, this.returnResult = false});

  @override
  State<SelectCityPage> createState() => _SelectCityPageState();
}

class _SelectCityPageState extends State<SelectCityPage> {
  List<dynamic> _cities = [];
  List<dynamic> _filteredCities = [];
  List<String> _letters = [];
  String _selectedLetter = 'A';
  TextEditingController searchController = TextEditingController();
  final ScrollController _alphabetScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadCities();
  }

  Future<void> _loadCities() async {
    try {
      debugPrint("Starting to load cities.json from assets...");
      final String response = await rootBundle.loadString(
        'assets/json/cities.json',
      );
      final List<dynamic> data = json.decode(response);
      debugPrint("Successfully loaded ${data.length} cities from cities.json!");

      data.sort((a, b) => a['name'].toString().compareTo(b['name'].toString()));

      Set<String> letters = {};
      for (var city in data) {
        if (city['name'] != null && city['name'].toString().isNotEmpty) {
          letters.add(city['name'][0].toUpperCase());
        }
      }

      final sortedLetters = letters.toList()..sort();
      final initialLetter = sortedLetters.isNotEmpty ? sortedLetters.first : 'A';

      setState(() {
        _cities = data;
        _letters = sortedLetters;
        _selectedLetter = initialLetter;
        _filteredCities = _getFilteredCities();
      });
      debugPrint("SelectCityPage initialized: Selected letter = $_selectedLetter, filtered items = ${_filteredCities.length}");
    } catch (e, stackTrace) {
      debugPrint("❌ Error loading cities.json from assets: $e");
      debugPrint(stackTrace.toString());
    }
  }

  List<dynamic> _getFilteredCities() {
    String query = searchController.text.trim().toLowerCase();
    return _cities.where((city) {
      final name = city['name']?.toString().toLowerCase() ?? '';
      final state = city['state']?.toString().toLowerCase() ?? '';
      bool matchesSearch = query.isEmpty || name.contains(query) || state.contains(query);
      
      // If query is active, ignore letter constraint to search globally across all cities!
      bool matchesLetter = query.isNotEmpty || 
          (city['name'] != null && city['name'].toString().toUpperCase().startsWith(_selectedLetter));
          
      return matchesSearch && matchesLetter;
    }).toList();
  }

  void _onLetterSelected(String letter) {
    setState(() {
      _selectedLetter = letter;
      _filteredCities = _getFilteredCities();
    });
  }

  void _onSearchChanged(String value) {
    if (value.isNotEmpty) {
      final firstLetter = value[0].toUpperCase();
      if (_letters.contains(firstLetter)) {
        setState(() {
          _selectedLetter = firstLetter;
        });
        _scrollToLetter(firstLetter);
      }
    }
    setState(() {
      _filteredCities = _getFilteredCities();
    });
  }

  void _scrollToLetter(String letter) {
    final index = _letters.indexOf(letter);
    if (index != -1) {
      _alphabetScrollController.animateTo(
        index * 55, // approximate width of each letter widget
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        title: const Text(
          "Where do you want to buy?",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 🔍 Search Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: TextField(
              controller: searchController,
              onChanged: _onSearchChanged,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                prefixIcon: const Icon(
                  Icons.search,
                  color: Colors.blueAccent,
                  size: 24,
                ),
                hintText: "Search city or state...",
                hintStyle: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 0),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: const BorderSide(
                    color: Color(0xFF0066FF),
                    width: 1.2,
                  ),
                ),
              ),
            ),
          ),

          // 🔠 Horizontal A-Z Selector
          Container(
            height: 60,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            child: ListView.builder(
              controller: _alphabetScrollController,
              scrollDirection: Axis.horizontal,
              itemCount: _letters.length,
              itemBuilder: (context, index) {
                final letter = _letters[index];
                final isSelected = letter == _selectedLetter;
                return GestureDetector(
                  onTap: () => _onLetterSelected(letter),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    width: 45,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue.shade700 : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF000000).withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        letter,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade300, thickness: 1),

          // 🏙️ City List
          Expanded(
            child: _filteredCities.isEmpty
                ? const Center(
              child: Text(
                "No cities found",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            )
                : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _filteredCities.length,
              itemBuilder: (context, index) {
                final city = _filteredCities[index];
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeInOut,
                  child: Card(
                    color: Colors.white,
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade700,
                        child: const Icon(
                          Icons.location_city,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        city['name'],
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        city['state'],
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                      onTap: () async {
                        await CityService.updateCity(city['name'], city['state']);

                        if (widget.returnResult) {
                          // ignore: use_build_context_synchronously
                          Navigator.pop(context, {
                            'name': city['name'],
                            'state': city['state'],
                          });
                          return;
                        }

                        // Navigate to property filter page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PropertyFilterPage(cityName: city['name']),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
