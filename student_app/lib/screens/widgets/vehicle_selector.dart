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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Select Vehicle",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(icon: Icon(Icons.close), onPressed: widget.onClose),
          ],
        ),
        SizedBox(height: 10),
        SizedBox(
          height: 140,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: widget.rides.length,
            itemBuilder: (context, index) {
              bool selected = _selectedRideIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedRideIndex = index);
                  widget.onRideSelected(index);
                },
                child: Container(
                  width: 120,
                  margin: EdgeInsets.only(right: 10),
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: selected
                        ? Color(0xFF7F00FF).withOpacity(0.1)
                        : Colors.white,
                    border: Border.all(
                        color:
                            selected ? Color(0xFF7F00FF) : Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.directions_car,
                          size: 40,
                          color: selected ? Color(0xFF7F00FF) : Colors.black),
                      SizedBox(height: 5),
                      Text(widget.rides[index]['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center),
                      Text(widget.rides[index]['price'],
                          style: TextStyle(color: Colors.grey)),
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
