import 'package:flutter/material.dart';

class VehicleSelector extends StatefulWidget {
  final List<Map<String, dynamic>> rides;
  final VoidCallback onClose;
  final Function(int) onRideSelected;
  final VoidCallback onConfirm;

  const VehicleSelector({
    Key? key,
    required this.rides,
    required this.onClose,
    required this.onRideSelected,
    required this.onConfirm,
  }) : super(key: key);

  @override
  _VehicleSelectorState createState() => _VehicleSelectorState();
}

class _VehicleSelectorState extends State<VehicleSelector> {
  int _selectedRideIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Select Vehicle Size",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(icon: Icon(Icons.close), onPressed: widget.onClose),
          ],
        ),
        SizedBox(height: 10),

        SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.rides.length,
            itemBuilder: (context, index) {
              bool selected = _selectedRideIndex == index;
              final ride = widget.rides[index];

              return GestureDetector(
                onTap: () {
                  setState(() => _selectedRideIndex = index);
                  widget.onRideSelected(index);
                },
                child: Container(
                  width: 130,
                  margin: EdgeInsets.only(right: 12),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: selected
                        ? Color(0xFF6A1B9A).withOpacity(0.05)
                        : Colors.white,
                    border: Border.all(
                        color: selected ? Color(0xFF6A1B9A) : Colors.grey[300]!,
                        width: 2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car_filled,
                          size: 35, color: Colors.black),

                      SizedBox(height: 8),

                      // Name
                      Text(ride['name'],
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16)),

                      // Price
                      Text(ride['price'],
                          style: TextStyle(
                              color: Color(0xFF6A1B9A),
                              fontWeight: FontWeight.w600)),

                      SizedBox(height: 5),

                      // Seats Info (Range)
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.person,
                                size: 14, color: Colors.grey[600]),
                            SizedBox(width: 4),
                            Text(ride['seats'],
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800])),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        SizedBox(height: 20),

        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: widget.onConfirm,
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, shape: StadiumBorder()),
            child: Text("Confirm Booking",
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}
