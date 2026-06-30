import 'package:flutter/material.dart';

class PropertyCommonWidgets {
  static Widget buildInputField(
    String label,
    TextEditingController controller,
    String hintText,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(16),
              prefixIcon: Icon(icon, color: Color(0xFF94A3B8)),
            ),
            style: TextStyle(fontSize: 15),
            keyboardType: keyboardType,
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  static Widget buildDropdown(
    String label,
    String? value,
    List<String> items,
    IconData icon,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF475569),
          ),
        ),
        SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Color(0xFFE2E8F0)),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Container(
                  width: double.infinity,
                  child: Text(
                    item,
                    style: TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
              prefixIcon: Padding(
                padding: EdgeInsets.only(left: 16.0, right: 12.0),
                child: Icon(icon, color: Color(0xFF94A3B8)),
              ),
            ),
            isExpanded: true,
            hint: Text(
              "Select $label",
              style: TextStyle(fontSize: 15, color: Color(0xFF94A3B8)),
              overflow: TextOverflow.ellipsis,
            ),
            style: TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            icon: Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(
                Icons.arrow_drop_down_rounded,
                color: Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ],
    );
  }

  static Widget buildFurnitureActionButton(
    String text,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Expanded(
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18, color: color),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ).onTap(onTap),
    );
  }

  static IconData getFurnitureIcon(String furniture) {
    switch (furniture) {
      case "Bed":
        return Icons.bed_rounded;
      case "TV":
        return Icons.tv_rounded;
      case "Sofa":
        return Icons.chair_rounded;
      case "Fridge":
        return Icons.kitchen_rounded;
      case "Dining Table":
        return Icons.dining_rounded;
      case "Wardrobe":
        return Icons.warehouse_rounded;
      case "Washing Machine":
        return Icons.local_laundry_service_rounded;
      case "AC":
        return Icons.ac_unit_rounded;
      case "Microwave":
        return Icons.microwave_rounded;
      case "Study Table":
        return Icons.desktop_mac_rounded;
      case "Curtains":
        return Icons.curtains_rounded;
      case "Geyser":
        return Icons.water_damage_rounded;
      default:
        return Icons.checkroom_rounded;
    }
  }
}

// Extension for onTap functionality
extension OnTapExtension on Widget {
  Widget onTap(VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: this,
    );
  }
}
