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
        const Text("Set Your Route",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        InkWell(
          onTap: onPickupTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: isEditingPickup ? const Color(0xFF6A1B9A) : Colors.grey[300]!,
                width: isEditingPickup ? 2 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.my_location, color: Color(0xFF6A1B9A)),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("From?",
                          style: TextStyle(color: Colors.grey, fontSize: 10)),
                      isEditingPickup && isLoadingAddress
                          ? const Text("Updating...",
                              style: TextStyle(color: Colors.grey))
                          : Text(pickupLocation,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (isEditingPickup)
                  const Icon(Icons.edit, size: 16, color: Color(0xFF6A1B9A)),
                IconButton(icon: const Icon(Icons.search), onPressed: onSearchTap),
              ],
            ),
          ),
        ),
        const SizedBox(height: 15),
        InkWell(
          onTap: onDestinationTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(15),
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
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("To?",
                          style: TextStyle(color: Colors.grey, fontSize: 10)),
                      !isEditingPickup && isLoadingAddress
                          ? const Text("Updating...",
                              style: TextStyle(color: Colors.grey))
                          : Text(destinationLocation,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
                if (!isEditingPickup)
                  const Icon(Icons.edit, size: 16, color: Colors.red),
                IconButton(icon: const Icon(Icons.search), onPressed: onSearchTap),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
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
            child: const Text("Select Vehicle",
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
