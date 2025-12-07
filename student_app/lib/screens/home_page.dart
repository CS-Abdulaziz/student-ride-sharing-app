import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../ride_controller.dart';
import 'widgets/location_selector.dart';
import 'widgets/vehicle_selector.dart';

class HomePage extends ConsumerStatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();

  String _pickupLocation = "جاري تحديد الموقع...";
  String _destinationLocation = "اختر الوجهة";

  LatLng _pickupLatLng = LatLng(24.7136, 46.6753);
  LatLng? _destinationLatLng;
  LatLng _mapCenter = LatLng(24.7136, 46.6753);

  bool _isEditingPickup = true;
  bool _isSelectingRide = false;
  int _selectedRideIndex = 0;
  bool _isLoadingAddress = false;

  final List<Map<String, dynamic>> _rides = [
    {
      "name": "Toyota Camry",
      "price": "15 SAR",
      "seats": "3-4",
      "color": Colors.grey
    },
    {
      "name": "Lexus R700",
      "price": "25 SAR",
      "seats": "2-3",
      "color": Color(0xFF7F00FF)
    },
    {
      "name": "Mercedes W90",
      "price": "40 SAR",
      "seats": "4",
      "color": Colors.black87
    },
  ];

  Future<void> _updateAddressFromMap(LatLng point) async {
    setState(() {
      _isLoadingAddress = true;
      if (_isEditingPickup) {
        _pickupLocation = "جاري جلب العنوان...";
        _pickupLatLng = point;
      } else {
        _destinationLocation = "جاري جلب العنوان...";
        _destinationLatLng = point;
      }
    });

    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/reverse?format=json&lat=${point.latitude}&lon=${point.longitude}&accept-language=ar');
      final response = await http
          .get(url, headers: {'User-Agent': 'com.example.student_app'});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        String address = data['display_name'].split(',')[0];
        setState(() {
          if (_isEditingPickup)
            _pickupLocation = address;
          else
            _destinationLocation = address;
        });
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      if (mounted) setState(() => _isLoadingAddress = false);
    }
  }

  void _searchPlace(String query) async {
    if (query.isEmpty) return;
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) =>
            Center(child: CircularProgressIndicator(color: Color(0xFF7F00FF))));

    try {
      final url = Uri.parse(
          'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1&accept-language=ar');
      final response = await http
          .get(url, headers: {'User-Agent': 'com.example.student_app'});
      Navigator.pop(context);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty) {
          final newPos = LatLng(
              double.parse(data[0]['lat']), double.parse(data[0]['lon']));
          _mapController.move(newPos, 15.0);
          setState(() {
            _mapCenter = newPos;
            if (_isEditingPickup) {
              _pickupLatLng = newPos;
              _pickupLocation = data[0]['display_name'].split(',')[0];
            } else {
              _destinationLatLng = newPos;
              _destinationLocation = data[0]['display_name'].split(',')[0];
            }
          });
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("لم يتم العثور على المكان")));
        }
      }
    } catch (e) {
      Navigator.pop(context);
    }
  }

  void _showSearchDialog() {
    TextEditingController searchCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(_isEditingPickup ? "بحث عن نقطة انطلاق" : "بحث عن وجهة"),
        content: TextField(
            controller: searchCtrl,
            decoration: InputDecoration(hintText: "اكتب اسم المكان...")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: Text("إلغاء")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _searchPlace(searchCtrl.text);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isEditingPickup ? Color(0xFF7F00FF) : Colors.red),
            child: Text("بحث", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _mapCenter,
              initialZoom: 15.0,
              onMapEvent: (event) {
                if (event is MapEventMoveEnd) {
                  _updateAddressFromMap(event.camera.center);
                  _mapCenter = event.camera.center;
                }
              },
            ),
            children: [
              TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.student_app'),
            ],
          ),
          IgnorePointer(
            child: Stack(
              children: [
                Center(
                    child: Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: Icon(Icons.location_pin,
                            color: _isEditingPickup
                                ? Color(0xFF7F00FF)
                                : Colors.red,
                            size: 50))),
                Center(
                    child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle))),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: Duration(milliseconds: 300),
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
              ),
              child: _isSelectingRide
                  ? VehicleSelector(
                      rides: _rides,
                      onClose: () => setState(() => _isSelectingRide = false),
                      onRideSelected: (index) =>
                          setState(() => _selectedRideIndex = index),
                      onConfirm: () async {
                        showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (c) => Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF7F00FF))));

                        try {
                          final selectedCar = _rides[_selectedRideIndex];

                          String rideId = await ref
                              .read(rideControllerProvider)
                              .requestRide(
                                pickupAddress: _pickupLocation,
                                pickupLatLng: _pickupLatLng,
                                destinationAddress: _destinationLocation,
                                destinationLatLng: _destinationLatLng!,
                                carType: selectedCar['name'],
                                price: selectedCar['price'],
                              );

                          Navigator.pop(context);

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(
                                "تم إرسال الطلب بنجاح! رقم الرحلة: $rideId"),
                            backgroundColor: Colors.green,
                          ));
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("خطأ: $e"),
                              backgroundColor: Colors.red));
                        }
                      },
                    )
                  : LocationSelector(
                      pickupLocation: _pickupLocation,
                      destinationLocation: _destinationLocation,
                      isEditingPickup: _isEditingPickup,
                      isLoadingAddress: _isLoadingAddress,
                      onPickupTap: () => setState(() {
                        _isEditingPickup = true;
                        _mapController.move(_pickupLatLng, 15.0);
                      }),
                      onDestinationTap: () => setState(() {
                        _isEditingPickup = false;
                        if (_destinationLatLng != null)
                          _mapController.move(_destinationLatLng!, 15.0);
                      }),
                      onSearchTap: _showSearchDialog,
                      onConfirmTap: () {
                        if (_destinationLatLng == null ||
                            _destinationLocation == "اختر الوجهة") {
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("الرجاء تحديد الوجهة أولاً")));
                          return;
                        }
                        setState(() => _isSelectingRide = true);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
