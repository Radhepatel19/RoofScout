import 'package:flutter/material.dart';
import 'package:roofscout/features/auth/screens/login_page.dart';

import 'package:roofscout/features/post_property/screens/property_login_page.dart';

// NOTE: You must define and import this page for 'Buy', 'Rent', 'Commercial', and 'Broker'
// Placeholder for the main search/explore screen
class SearchPage extends StatelessWidget {
  final String title;
  const SearchPage({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(child: Text("Exploring: $title")),
    );
  }
}

class LookingForPage extends StatefulWidget {
  const LookingForPage({Key? key}) : super(key: key);

  @override
  State<LookingForPage> createState() => _LookingForPageState();
}

class _LookingForPageState extends State<LookingForPage> {
  String? selectedOption;

  final List<Map<String, dynamic>> options = [
    {"icon": Icons.home_rounded, "title": "Buy a Home"},
    {"icon": Icons.house_outlined, "title": "Rent as a Tenant"},
    {"icon": Icons.sell_rounded, "title": "Sell / Rent My Property"},
    {"icon": Icons.business_rounded, "title": "Explore Commercial Spaces"},
    {"icon": Icons.person_search_rounded, "title": "Find a Broker"},
  ];

  // ➡️ New function to handle navigation
  void _handleContinue(BuildContext context) {
    if (selectedOption == null) {
      // Show an alert if nothing is selected
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select an option to continue."),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Widget nextPage;

    switch (selectedOption) {
      case "Buy a Home":
        nextPage = const LoginPage();
        break;
      case "Rent as a Tenant":
        nextPage = const LoginPage();
        break;
      case "Sell / Rent My Property":
        // This is typically for property owners, leading to a property management/login page
        nextPage = const PropertyLoginPage();
        break;
      case "Explore Commercial Spaces":
      case "Find a Broker":
        // These options usually lead to a main search/explore interface
        nextPage = SearchPage(title: selectedOption!);
        // NOTE: If you need these to go to the general 'login_page.dart', change 'SearchPage' to 'LoginPage()'.
        // nextPage = const LoginPage();
        break;

      default:
        // Fallback for unexpected selection
        nextPage = const LoginPage();
        break;
    }

    // Navigate to the determined page
    Navigator.push(context, MaterialPageRoute(builder: (context) => nextPage));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Text(
          "What are you looking for?",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final item = options[index];
                  final isSelected = selectedOption == item["title"];

                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedOption = item["title"];
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue.shade700 : Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12.withOpacity(0.08),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                        border: Border.all(
                          color: isSelected
                              ? Colors.blue.shade700
                              : Colors.grey.shade300,
                          width: 1.5,
                        ),
                      ),
                      child: ListTile(
                        leading: Icon(
                          item["icon"],
                          color: isSelected ? Colors.white : Colors.blue.shade700,
                          size: 30,
                        ),
                        title: Text(
                          item["title"],
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black87,
                            fontSize: 17,
                            fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                          ),
                        ),
                        trailing: isSelected
                            ? const Icon(Icons.check_circle, color: Colors.white)
                            : const Icon(Icons.chevron_right_rounded,
                            color: Colors.grey),
                      ),
                    ),
                  );
                },
              ),
            ),

            // 🔹 Continue Button
            Center(
              child: ElevatedButton(
                // 📞 Call the new navigation function
                onPressed: selectedOption == null
                    ? null // Disable button if no option is selected
                    : () => _handleContinue(context),

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  padding:
                  const EdgeInsets.symmetric(horizontal: 100, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 5,
                ),
                child: const Text(
                  "Continue",
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}