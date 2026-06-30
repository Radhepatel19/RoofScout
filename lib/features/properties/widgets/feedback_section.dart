import 'package:flutter/material.dart';

class FeedbackSection extends StatefulWidget {
  const FeedbackSection({super.key});

  @override
  State<FeedbackSection> createState() => _FeedbackSectionState();
}

class _FeedbackSectionState extends State<FeedbackSection> {
  final TextEditingController _controller = TextEditingController();
  String selectedEmoji = '';

  void _onEmojiTap(String emoji, String label) {
    setState(() {
      selectedEmoji = emoji;
      _controller.text = "$emoji $label ";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Color(0xFFF8FAFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title

            const SizedBox(height: 10),

            // Emoji Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _emojiOption('😊', 'Yes', Colors.green),
                _emojiOption('😐', 'Neutral', Colors.orange),
                _emojiOption('😞', 'No', Colors.red),
              ],
            ),

            const SizedBox(height: 20),

            // Text field
            TextField(
              controller: _controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Tell us how we can improve...',
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.all(12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                  const BorderSide(color: Colors.blueAccent, width: 1.4),
                ),
              ),
            ),

            const SizedBox(height: 14),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  final feedback = _controller.text.trim();
                  if (feedback.isNotEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Thank you for your feedback!"),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Submit Feedback",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _emojiOption(String emoji, String label, Color color) {
    final bool isSelected = selectedEmoji == emoji;

    return GestureDetector(
      onTap: () => _onEmojiTap(emoji, label),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color:
              isSelected ? color.withOpacity(0.25) : color.withOpacity(0.12),
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected ? color : Colors.transparent,
                width: 2,
              ),
            ),
            child: Text(
              emoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
