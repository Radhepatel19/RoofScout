import 'package:flutter/material.dart';
import 'package:roofscout/features/properties/services/property_report_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PropertyReportPage extends StatefulWidget {
  final int propertyId;
  const PropertyReportPage({super.key, required this.propertyId});

  @override
  State<PropertyReportPage> createState() => _PropertyReportPageState();
}

class _PropertyReportPageState extends State<PropertyReportPage> {
  List<dynamic> reports = [];
  bool isLoading = true;
  String? selectedReportType;
  final TextEditingController descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchReports();
  }

  Future<void> _fetchReports() async {
    setState(() => isLoading = true);
    final response = await PropertyReportService.getReportsByProperty(widget.propertyId);
    if (response['success'] == true) {
      setState(() {
        reports = response['data'];
        isLoading = false;
      });
    } else {
      setState(() => isLoading = false);
    }
  }

  Future<void> _submitReport() async {
    if (selectedReportType == null || descriptionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getInt("user_id") ?? 1;

    final response = await PropertyReportService.submitReport(
      propertyId: widget.propertyId,
      userId: userId,
      reportType: selectedReportType!,
      description: descriptionController.text,
    );

    if (response['success'] == true) {
      Navigator.pop(context);
      _fetchReports();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Report submitted successfully"), backgroundColor: Colors.green),
      );
      descriptionController.clear();
      selectedReportType = null;
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['message'] ?? "Failed to submit report")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Property Issues',
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
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reporting Center',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Track and manage reports for fake listings, spam, or scams.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: reports.isEmpty
                      ? const Center(child: Text("No reports yet"))
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          itemCount: reports.length,
                          itemBuilder: (context, index) {
                            final item = reports[index];
                            return _buildReportCard(item);
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: ElevatedButton.icon(
          onPressed: () => _showReportDialog(context),
          icon: const Icon(Icons.flag_rounded),
          label: const Text('Report a New Issue'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF4444),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 0,
          ),
        ),
      ),
    );
  }

  Widget _buildReportCard(Map<String, dynamic> item) {
    Color statusColor;
    switch (item['status']) {
      case 'resolved': statusColor = Colors.green; break;
      case 'reviewing': statusColor = Colors.orange; break;
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
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _formatType(item['report_type']),
                    style: const TextStyle(
                      color: Color(0xFF0066FF),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    item['status'].toString().toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              item['description'],
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: Color(0xFF94A3B8)),
                const SizedBox(width: 4),
                Text(
                  item['created_at'].toString().split('T')[0],
                  style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatType(String type) {
    return type.split('_').map((e) => e[0].toUpperCase() + e.substring(1)).join(' ');
  }

  void _showReportDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Report Issue'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'Issue Type'),
                value: selectedReportType,
                items: const [
                  DropdownMenuItem(value: 'fake_listing', child: Text('Fake Listing')),
                  DropdownMenuItem(value: 'spam', child: Text('Spam')),
                  DropdownMenuItem(value: 'scam', child: Text('Scam')),
                  DropdownMenuItem(value: 'wrong_info', child: Text('Wrong Information')),
                  DropdownMenuItem(value: 'other', child: Text('Other')),
                ],
                onChanged: (value) => setDialogState(() => selectedReportType = value),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  alignLabelWithHint: true,
                  labelText: 'Description',
                  hintText: 'Provide details about the issue...',
                ),
                maxLength: 100,
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: _submitReport,
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFEF4444)),
              child: const Text('Submit Report', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
