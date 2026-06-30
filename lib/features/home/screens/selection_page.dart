import 'package:flutter/material.dart';

import 'package:roofscout/features/home/screens/looking_for_page.dart';
import 'package:roofscout/features/post_property/screens/property_login_page.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({Key? key}) : super(key: key);

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  String? selectedCategory;
  String? selectedRole;

  final List<String> categories = ["Home", "Commercial", "Office"];
  final List<String> roles = ["Owner", "Broker"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  // 🔹 Row for Back Arrow + Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left:16.0),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Roof",
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextSpan(
                                text: "Scout",
                                style: TextStyle(
                                  color: Colors.orange.shade600,
                                  fontSize: 25,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      )

                    ],
                  ),

                  Positioned(
                    right: 0,
                    top: 0,
                    child: TextButton(
                      onPressed: () => {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LookingForPage()))
                      },
                      child: const Text(
                        "Skip",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    // 🔹 Select Category
                    const Text(
                      "Select Your Category",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: categories.map((category) {
                        bool isSelected = selectedCategory == category;
                        return GestureDetector(
                          onTap: () => setState(() => selectedCategory = category),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            padding: const EdgeInsets.symmetric(
                                vertical: 14, horizontal: 22),
                            decoration: BoxDecoration(
                              color:
                              isSelected ? Colors.blue.shade600 : Colors.white,
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 6,
                                  offset: const Offset(0, 3),
                                )
                              ],
                              border: Border.all(
                                  color: isSelected
                                      ? Colors.blue
                                      : Colors.grey.shade300,
                                  width: 1.5),
                            ),
                            child: Text(
                              category,
                              style: TextStyle(
                                fontSize: 16,
                                color: isSelected ? Colors.white : Colors.black87,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 30),

                    // 🔹 Select Role
                    const Text(
                      "Select Your Role",
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: roles.map((role) {
                        bool isSelected = selectedRole == role;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => selectedRole = role),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              margin: const EdgeInsets.only(right: 6),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              decoration: BoxDecoration(
                                color:
                                isSelected ? Colors.blue.shade600 : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                    color: isSelected
                                        ? Colors.blue
                                        : Colors.grey.shade300,
                                    width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  )
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  role,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color:
                                    isSelected ? Colors.white : Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 40),

                    GestureDetector(
                      onTap: () {
                        if (selectedCategory != null && selectedRole != null) {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => PropertyLoginPage()));
                          // Navigate to next screen
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Please select both Category and Role")),
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,

                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          gradient: LinearGradient(
                            colors: [Colors.blue.shade600, Colors.blueAccent.shade100],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: const Text(
                              "Next",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ),
                    ),

                    const SizedBox(height: 30),

                    // 🔹 How It Works Section
                    const Text(
                      "How this app works?",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black12,
                                blurRadius: 6,
                                offset: Offset(0, 3))
                          ],
                        ),
                        child: const Text(
                          "1️⃣ Choose your role (Owner or Broker).\n"
                              "2️⃣ Select a category to continue.\n"
                              "3️⃣ Post or browse listings easily.\n"
                              "4️⃣ Connect with others directly in the app.\n"
                              "5️⃣ Manage your deals and chats effortlessly.",
                          style: TextStyle(fontSize: 15, height: 1.6),
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 🔹 FAQ Section
                    const Text(
                      "Frequently Asked Questions",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    ExpansionTile(
                      title: const Text("How do I post my property?"),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              "Select your role as Owner, then click on 'Add Property' on the next screen."),
                        ),
                      ],
                    ),
                      ExpansionTile(
                        title: const Text("Is there a fee to list?"),
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("No, listing your property is completely free!"),
                          ),
                        ],
                      ),

                    ExpansionTile(
                      title: const Text("Can I contact brokers directly?"),
                      children: const [
                        Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text(
                              "Yes! You can directly chat with owners or brokers using our in-app chat feature."),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
