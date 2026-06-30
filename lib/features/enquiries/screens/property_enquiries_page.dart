import 'package:flutter/material.dart';
import 'package:roofscout/features/enquiries/services/enquiry_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyEnquiriesPage extends StatefulWidget {
  final int propertyId;
  const PropertyEnquiriesPage({super.key, required this.propertyId});

  @override
  State<PropertyEnquiriesPage> createState() => _PropertyEnquiriesPageState();
}

class _PropertyEnquiriesPageState extends State<PropertyEnquiriesPage> {
  List<dynamic> enquiries = [];
  bool isLoading = true;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchEnquiries();
  }

  Future<void> _fetchEnquiries() async {
    setState(() => isLoading = true);
    final prefs = await SharedPreferences.getInstance();
    final ownerId = prefs.getInt("user_id") ?? 1;

    final response = await EnquiryService.getEnquiriesByOwner(ownerId);
    if (response['success'] == true) {
      setState(() {
        enquiries = response['data'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitEnquiry() async {
    if (messageController.text.isEmpty || nameController.text.isEmpty || phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id") ?? 1;

    final response = await EnquiryService.sendEnquiry(
      propertyId: widget.propertyId,
      userId: userId,
      message: messageController.text,
      contactPhone: phoneController.text,
      contactEmail: 'user@example.com', // Dummy email for now
    );

    if (response['success'] == true) {
      Navigator.pop(context);
      _fetchEnquiries();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Enquiry sent successfully"), backgroundColor: Colors.green),
      );
      messageController.clear();
      nameController.clear();
      phoneController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Failed to send enquiry")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Enquiries',
          style: TextStyle(
            color: Color(0xFF1E293B),
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatItem('Total', enquiries.length.toString()),
                      _buildStatItem('New', enquiries.where((e) => e['enquiry_status'] == 'unread').length.toString()),
                      _buildStatItem('Resolved', enquiries.where((e) => e['enquiry_status'] == 'responded').length.toString()),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: enquiries.isEmpty
                      ? const Center(child: Text("No enquiries yet"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: enquiries.length,
                          itemBuilder: (context, index) {
                            final item = enquiries[index];
                            return _buildEnquiryCard(item);
                          },
                        ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showWriteEnquirySheet(context),
        backgroundColor: const Color(0xFF0066FF),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildEnquiryCard(Map<String, dynamic> item) {
    Color statusColor;
    switch (item['enquiry_status']) {
      case 'read': statusColor = Colors.orange; break;
      case 'responded': statusColor = Colors.green; break;
      default: statusColor = Colors.blue;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF0066FF).withOpacity(0.1),
                  child: Text(
                    (item['user_name'] ?? 'U')[0].toUpperCase(),
                    style: const TextStyle(color: Color(0xFF0066FF), fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['user_name'] ?? 'Unknown User',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: Color(0xFF1E293B)),
                      ),
                      Text(
                        item['created_at'].toString().split('T')[0],
                        style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['enquiry_status'].toString().toUpperCase(),
                    style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item['message'],
              style: const TextStyle(color: Color(0xFF475569), fontSize: 14, height: 1.5),
            ),
            if (item['contact_phone'] != null || item['contact_email'] != null) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  if (item['contact_phone'] != null) ...[
                    const Icon(Icons.phone_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(item['contact_phone'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                  if (item['contact_email'] != null) ...[
                    const SizedBox(width: 12),
                    const Icon(Icons.email_outlined, size: 14, color: Color(0xFF64748B)),
                    const SizedBox(width: 4),
                    Text(item['contact_email'], style: const TextStyle(fontSize: 12, color: Color(0xFF64748B))),
                  ],
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.reply_rounded, size: 18),
                  label: const Text('Reply'),
                  style: TextButton.styleFrom(foregroundColor: const Color(0xFF0066FF)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showWriteEnquirySheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.75,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Write Enquiry', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded)),
                ],
              ),
              const SizedBox(height: 12),
              Text('Express your interest or ask questions about this property.', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              const SizedBox(height: 24),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(labelText: 'Phone Number', border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: messageController,
                maxLines: 4,
                decoration: InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'Message',
                  hintText: 'I would like to know more about...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitEnquiry,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: const Text('Submit Enquiry', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF1E293B))),
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
      ],
    );
  }
}
