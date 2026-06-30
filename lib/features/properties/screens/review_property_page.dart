import 'package:flutter/material.dart';
import 'package:roofscout/features/properties/services/property_service.dart';

class ReviewPropertyPage extends StatefulWidget {
  final int? propertyId;
  const ReviewPropertyPage({super.key, this.propertyId});

  @override
  State<ReviewPropertyPage> createState() => _ReviewPropertyPageState();
}

class _ReviewPropertyPageState extends State<ReviewPropertyPage> {
  List<Map<String, dynamic>> _reviews = [];
  bool _isLoading = true;
  String _errorMsg = "";

  @override
  void initState() {
    super.initState();
    _fetchReviews();
  }

  Future<void> _fetchReviews() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMsg = "";
    });
    try {
      final propertyId = widget.propertyId ?? 1;
      final fetched = await PropertyService.getPropertyReviews(propertyId);
      if (mounted) {
        setState(() {
          _reviews = fetched;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _reviews = [];
          _isLoading = false;
          _errorMsg = e.toString();
        });
      }
    }
  }

  String _formatDate(dynamic dateString) {
    if (dateString == null) return "Recent";
    try {
      final dt = DateTime.parse(dateString.toString());
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      return "${dt.day} ${months[dt.month - 1]} ${dt.year}";
    } catch (_) {
      return dateString.toString().split('T')[0];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          "Property Reviews",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF)))
          : _reviews.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0066FF).withOpacity(0.05),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.rate_review_outlined,
                          size: 64,
                          color: Color(0xFF0066FF),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "No Reviews Yet",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          "There are no reviews posted for this property yet.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[500],
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _reviews.length,
                  itemBuilder: (context, index) {
                    final review = _reviews[index];
                    final rawRating = review['rating'];
                    final intRating = rawRating is num ? rawRating.toInt() : (int.tryParse(rawRating.toString()) ?? 5);

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _reviewCard(
                        name: review['user_name'] ?? 'Verified Resident',
                        reviewText: review['review_text'] ?? '',
                        rating: intRating,
                        date: _formatDate(review['created_at']),
                        avatarLetter: (review['user_name'] ?? 'V').toString()[0].toUpperCase(),
                      ),
                    );
                  },
                ),
    );
  }

  // Review Card Widget
  Widget _reviewCard({
    required String name,
    required String reviewText,
    required int rating,
    required String date,
    required String avatarLetter,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar and name
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: const Color(0xFF0066FF),
                child: Text(
                  avatarLetter,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Stars & Date
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < rating ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
              Text(
                "Reviewed on $date",
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF94A3B8),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Review text
          Text(
            reviewText,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF475569),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
