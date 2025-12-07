import 'package:flutter/material.dart';

class LocationSelector extends StatelessWidget {
  final String pickupLocation;
  final String destinationLocation;
  final bool isEditingPickup;
  final bool isLoadingAddress;
  final VoidCallback onPickupTap;
  final VoidCallback onDestinationTap;
  final VoidCallback onSearchTap;
  final VoidCallback onConfirmTap;

  const LocationSelector({
    Key? key,
    required this.pickupLocation,
    required this.destinationLocation,
    required this.isEditingPickup,
    required this.isLoadingAddress,
    required this.onPickupTap,
    required this.onDestinationTap,
    required this.onSearchTap,
    required this.onConfirmTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("حدد مسارك",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 15),
        InkWell(
          onTap: onPickupTap,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isEditingPickup ? Color(0xFF7F00FF) : Colors.grey[300]!,
                width: isEditingPickup ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.my_location, color: Color(0xFF7F00FF)),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("من أين؟",
                          style: TextStyle(color: Colors.grey, fontSize: 10)),
                      isEditingPickup && isLoadingAddress
                          ? Text("جاري التحديث...",
                              style: TextStyle(color: Colors.grey))
                          : Text(pickupLocation,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (isEditingPickup)
                  Icon(Icons.edit, size: 16, color: Color(0xFF7F00FF)),
                IconButton(icon: Icon(Icons.search), onPressed: onSearchTap),
              ],
            ),
          ),
        ),
        SizedBox(height: 15),
        InkWell(
          onTap: onDestinationTap,
          child: AnimatedContainer(
            duration: Duration(milliseconds: 200),
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: !isEditingPickup ? Colors.red : Colors.grey[300]!,
                width: !isEditingPickup ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.location_on, color: Colors.red),
                SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("إلى أين؟",
                          style: TextStyle(color: Colors.grey, fontSize: 10)),
                      !isEditingPickup && isLoadingAddress
                          ? Text("جاري التحديث...",
                              style: TextStyle(color: Colors.grey))
                          : Text(destinationLocation,
                              style: TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (!isEditingPickup)
                  Icon(Icons.edit, size: 16, color: Colors.red),
                IconButton(icon: Icon(Icons.search), onPressed: onSearchTap),
              ],
            ),
          ),
        ),
        SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: onConfirmTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text("اختيار السيارة",
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
