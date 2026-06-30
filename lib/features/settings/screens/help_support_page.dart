import 'package:flutter/material.dart';
import 'package:roofscout/features/settings/screens/privacy_page.dart';

class HelpSupportPage extends StatefulWidget {
  const HelpSupportPage({super.key});

  @override
  State<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends State<HelpSupportPage> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  String _selectedCategory = "General Inquiry";
  final List<String> _categories = [
    "General Inquiry",
    "Property Listing",
    "Account Issues",
    "Payment Problems",
    "Technical Support",
    "Property Viewing",
    "Agent Contact",
    "Report Issue"
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      "question": "How do I list my property for sale/rent?",
      "answer": "You can list your property by navigating to your profile page and clicking on 'Post New Property'. Fill in the required details including property type, location, price, and upload images. Your property will be verified within 24 hours.",
      "category": "Property Listing",
      "isExpanded": false,
    },
    {
      "question": "How long does property verification take?",
      "answer": "Property verification usually takes 24-48 hours. Our team manually verifies all property details, images, and ownership documents to ensure authenticity. You'll receive a notification once verification is complete.",
      "category": "Property Listing",
      "isExpanded": false,
    },
    {
      "question": "How do I contact a property owner/agent?",
      "answer": "Click on the 'Contact Owner/Agent' button on any property listing page. You can either call them directly, send a WhatsApp message, or request a callback. Ensure you have clear questions prepared.",
      "category": "Agent Contact",
      "isExpanded": false,
    },
    {
      "question": "Is my personal information secure?",
      "answer": "Yes, we use bank-level encryption to protect your personal information. Your contact details are only shared with property owners/agents when you initiate contact. View our Privacy Policy for detailed information.",
      "category": "Account Issues",
      "isExpanded": false,
    },
    {
      "question": "How do I schedule a property viewing?",
      "answer": "After contacting the owner/agent, you can schedule a viewing through the chat feature. We recommend scheduling viewings during daylight hours and bringing a companion for safety.",
      "category": "Property Viewing",
      "isExpanded": false,
    },
    {
      "question": "What should I check during property viewing?",
      "answer": "Check water pressure, electricity connections, plumbing, ventilation, parking availability, neighborhood security, and amenities. Take photos and notes for comparison with other properties.",
      "category": "Property Viewing",
      "isExpanded": false,
    },
    {
      "question": "How do I update my profile information?",
      "answer": "Go to your profile page, click on 'Edit Profile', and update your details. Changes are saved automatically. For email or phone number changes, verification is required.",
      "category": "Account Issues",
      "isExpanded": false,
    },
  ];

  final List<Map<String, dynamic>> _contactOptions = [
    {
      "title": "Call Support",
      "description": "Speak directly with our support team",
      "icon": Icons.phone_in_talk_rounded,
      "color": Color(0xFF10B981),
      "action": "+91 1800-123-4567",
      "type": "call",
    },
    {
      "title": "Email Support",
      "description": "Send us an email for detailed queries",
      "icon": Icons.email_rounded,
      "color": Color(0xFF0066FF),
      "action": "support@roofscout.com",
      "type": "email",
    },
    {
      "title": "Live Chat",
      "description": "24/7 chat support with instant responses",
      "icon": Icons.chat_rounded,
      "color": Color(0xFF8B5CF6),
      "action": "Start Chat",
      "type": "chat",
    },
    {
      "title": "WhatsApp Business",
      "description": "Quick support via WhatsApp",
      "icon": Icons.message_rounded,
      "color": Color(0xFF25D366),
      "action": "+91 98765 43210",
      "type": "whatsapp",
    },
  ];

  @override
  void initState() {
    super.initState();
    // Load user data if available
    _nameController.text = "Raj Sharma";
    _emailController.text = "raj.sharma@email.com";
  }

  void _submitSupportRequest() {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _messageController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please fill all required fields"),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Support request submitted successfully!"),
        backgroundColor: Color(0xFF10B981),
      ),
    );

    // Clear form
    _messageController.clear();
    setState(() {
      _selectedCategory = "General Inquiry";
    });
  }

  void _toggleFAQ(int index) {
    setState(() {
      _faqs[index]["isExpanded"] = !_faqs[index]["isExpanded"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 1,
            titleSpacing: 0,
            pinned: true,
            title: Text(
              "Help & Support",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color(0xFF1E293B),
              ),
            ),
            leading: Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Container(
                width: 40,
                height: 40,
                child: IconButton(
                  icon: Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  color: Colors.black87,
                ),
              ),
            ),
          ),

          // Main Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Quick Help Cards
                  Text(
                    "Quick Help",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.0,
                    ),
                    itemCount: _contactOptions.length,
                    itemBuilder: (context, index) {
                      final option = _contactOptions[index];
                      return _buildQuickHelpCard(option);
                    },
                  ),

                  SizedBox(height: 16),

                  // Frequently Asked Questions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Frequently Asked Questions",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        "${_faqs.length} FAQs",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 16),

                  // FAQs List
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: _faqs.map((faq) {
                        final index = _faqs.indexOf(faq);
                        return _buildFAQItem(faq, index);
                      }).toList(),
                    ),
                  ),

                  SizedBox(height: 24),

                  // Contact Support Form
                  Container(
                    padding: EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                color: Color(0xFF0066FF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(25),
                              ),
                              child: Icon(
                                Icons.support_agent_rounded,
                                size: 28,
                                color: Color(0xFF0066FF),
                              ),
                            ),

                            SizedBox(width: 16),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Need More Help?",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Contact our support team directly",
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 24),

                        // Name Field
                        Text(
                          "Your Name",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            hintText: "Enter your full name",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF0066FF)),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Email Field
                        Text(
                          "Email Address",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Enter your email address",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF0066FF)),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Category Dropdown
                        Text(
                          "Issue Category",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Color(0xFFE2E8F0)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: _selectedCategory,
                              isExpanded: true,
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              style: TextStyle(
                                fontSize: 15,
                                color: Color(0xFF1E293B),
                              ),
                              items: _categories.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCategory = newValue!;
                                });
                              },
                              dropdownColor: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Message Field
                        Text(
                          "Describe Your Issue",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        SizedBox(height: 8),
                        TextField(
                          controller: _messageController,
                          maxLines: 4,
                          decoration: InputDecoration(
                            hintText: "Please provide details about your issue...",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(color: Color(0xFF0066FF)),
                            ),
                          ),
                        ),

                        SizedBox(height: 24),

                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _submitSupportRequest,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF0066FF),
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              "Submit Support Request",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 16),

                        // Support Hours
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 20,
                                color: Color(0xFF0066FF),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Support Hours",
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Monday - Saturday: 9 AM - 9 PM\nSunday: 10 AM - 6 PM",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 24),

                  // Additional Resources
                  Text(
                    "Additional Resources",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1E293B),
                    ),
                  ),

                  SizedBox(height: 16),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 16,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF0066FF).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.book_rounded,
                              size: 20,
                              color: Color(0xFF0066FF),
                            ),
                          ),
                          title: Text(
                            "User Guides & Tutorials",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          subtitle: Text(
                            "Step-by-step guides for using RoofScout",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                          onTap: () {
                            // Navigate to guides
                          },
                        ),

                        Divider(height: 1, color: Color(0xFFE2E8F0)),

                        ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF10B981).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.gavel_rounded,
                              size: 20,
                              color: Color(0xFF10B981),
                            ),
                          ),
                          title: Text(
                            "Terms & Conditions",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          subtitle: Text(
                            "Legal terms for using RoofScout",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                          onTap: () {
                            // Navigate to terms
                          },
                        ),

                        Divider(height: 1, color: Color(0xFFE2E8F0)),

                        ListTile(
                          leading: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Color(0xFF8B5CF6).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.privacy_tip_rounded,
                              size: 20,
                              color: Color(0xFF8B5CF6),
                            ),
                          ),
                          title: Text(
                            "Privacy Policy",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          subtitle: Text(
                            "How we protect your data",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                            ),
                          ),
                          trailing: Icon(
                            Icons.chevron_right_rounded,
                            size: 20,
                            color: Color(0xFF94A3B8),
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PrivacyPage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickHelpCard(Map<String, dynamic> option) {
    return GestureDetector(
      onTap: () {
        // Handle action based on type
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Opening ${option["title"]}..."),
            backgroundColor: option["color"],
          ),
        );
      },
      child: Container(
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
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: option["color"].withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  option["icon"],
                  size: 22,
                  color: option["color"],
                ),
              ),

              SizedBox(height: 12),

              Text(
                option["title"],
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E293B),
                ),
              ),

              SizedBox(height: 4),

              Text(
                option["description"],
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF64748B),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),

              SizedBox(height: 8),

              Text(
                option["action"],
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: option["color"],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq, int index) {
    return Column(
      children: [
        GestureDetector(
          onTap: () => _toggleFAQ(index),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        faq["question"],
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        faq["category"],
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF0066FF),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 12),
                Icon(
                  faq["isExpanded"]
                      ? Icons.expand_less_rounded
                      : Icons.expand_more_rounded,
                  size: 24,
                  color: Color(0xFF0066FF),
                ),
              ],
            ),
          ),
        ),

        if (faq["isExpanded"])
          Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Text(
              faq["answer"],
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.6,
              ),
            ),
          ),

        if (index < _faqs.length - 1)
          Divider(height: 1, color: Color(0xFFE2E8F0)),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }
}