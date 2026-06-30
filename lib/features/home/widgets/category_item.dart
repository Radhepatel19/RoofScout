import 'package:flutter/material.dart';

Widget categoryItem(BuildContext context, Widget page,IconData icon, String title) {
  return InkWell(
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => page, // Next Page
        ),
      );
    },
    child: Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        margin: EdgeInsets.only(bottom: 2),
        width: 90,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: Colors.blueAccent),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    ),
  );
}
