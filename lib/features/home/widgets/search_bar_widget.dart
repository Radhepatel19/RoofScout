import 'package:flutter/material.dart';

class SearchBarWidget extends StatefulWidget {
  final TextEditingController? controller;
  final Function(String)? onChanged;
  final VoidCallback? onFilterTap;

  const SearchBarWidget({
    super.key,
    this.controller,
    this.onChanged,
    this.onFilterTap,
  });

  @override
  State<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends State<SearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.black54),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: widget.controller,
              decoration: const InputDecoration(
                hintText: 'Address, city, zip',
                border: InputBorder.none,
              ),
              onChanged: widget.onChanged,
            ),
          ),
          IconButton(
            onPressed: widget.onFilterTap,
            icon: const Icon(Icons.tune, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}
