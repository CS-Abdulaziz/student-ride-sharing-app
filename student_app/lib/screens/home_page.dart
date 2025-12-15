import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../ride_controller.dart';
import '../auth_controller.dart';
import '../login_page.dart';
import 'support_dialog.dart';

import 'widgets/location_selector.dart';
import 'widgets/vehicle_selector.dart';
import 'tracking_page.dart';
import 'profile_page.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage>
    with TickerProviderStateMixin {
  final MapController _mapController = MapController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _pickupLocation = "Locating...";
  String _destinationLocation = "Choose Destination";

  LatLng _pickupLatLng = const LatLng(24.7136, 46.6753);
  LatLng? _destinationLatLng;
  LatLng _mapCenter = const LatLng(24.7136, 46.6753);

  bool _isEditingPickup = true;
  bool _isSelectingRide = false;
  int _selectedRideIndex = 0;
  bool _isLoadingAddress = false;

  final List<Map<String, dynamic>> _rides = [
    {
      "name": "Small",
      "price": "15 SAR",
      "seats": "3-4",
      "desc": "Economy",
    },
    {
      "name": "Medium",
      "price": "25 SAR",
      "seats": "4-5",
      "desc": "Standard",
    },
    {
      "name": "Large",
      "price": "40 SAR",
      "seats": "6-7",
      "desc": "Van/SUV",
    },
  ];

  Future<void> _updateAddressFromMap(LatLng point) async {
    setState(() {
      _isLoadingAddress = true;
      if (_isEditingPickup) {
        _pickupLocation = "Loading address...";
        _pickupLatLng = point;
      } else {
        _destinationLocation = "Loading address...";
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
          if (_isEditingPickup) {
            _pickupLocation = address;
          } else {
            _destinationLocation = address;
          }
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
            const Center(child: CircularProgressIndicator(color: Color(0xFF6A1B9A))));

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
          ScaffoldMessenger.of(context)
              .showSnackBar(const SnackBar(content: Text("Location not found")));
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
        title: Text(
            _isEditingPickup ? "Search Pickup Point" : "Search Destination"),
        content: TextField(
            controller: searchCtrl,
            decoration: const InputDecoration(hintText: "Type location name...")),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _searchPlace(searchCtrl.text);
            },
            style: ElevatedButton.styleFrom(
                backgroundColor:
                    _isEditingPickup ? const Color(0xFF6A1B9A) : Colors.red),
            child: const Text("Search", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUserId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            FutureBuilder<DocumentSnapshot>(
              future: currentUserId != null
                  ? FirebaseFirestore.instance
                      .collection('users')
                      .doc(currentUserId)
                      .get()
                  : null,
              builder: (context, snapshot) {
                String displayName = "Loading...";
                String universityId = "...";
                String phone = "";

                if (snapshot.hasData && snapshot.data != null) {
                  var data = snapshot.data!.data() as Map<String, dynamic>?;
                  if (data != null) {
                    displayName = data['name'] ?? "User";
                    universityId = data['universityId'] ?? "";
                    phone = data['phone'] ?? "";
                  }
                }

                return Container(
                  padding: EdgeInsets.only(
                      top: MediaQuery.of(context).padding.top + 20,
                      bottom: 30,
                      left: 20,
                      right: 20),
                  decoration: const BoxDecoration(
                    color: Color(0xFF6A1B9A),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 35,
                        backgroundColor: Colors.white,
                        child: Text(
                          displayName.isNotEmpty
                              ? displayName[0].toUpperCase()
                              : "U",
                          style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF6A1B9A)),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(displayName,
                                style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white)),
                            const SizedBox(height: 8),
                            Text("ID: $universityId",
                                style: const TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                            if (phone.isNotEmpty)
                              Text("Phone: $phone",
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFF6A1B9A)),
              title: const Text("Ride History"),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => ProfilePage()));
              },
            ),
            ListTile(
              leading: Icon(Icons.support_agent, color: Color(0xFF6A1B9A)),
              title: Text("Technical Support"),
              onTap: () {
                Navigator.pop(context);
                showSupportDialog(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context);

                await ref.read(authControllerProvider).signOut();

                if (mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                }
              },
            ),
          ],
        ),
      ),
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
                                ? const Color(0xFF6A1B9A)
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
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                    child: const CircleAvatar(
                        backgroundColor: Colors.white,
                        child: Icon(Icons.menu, color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
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
                            builder: (c) => const Center(
                                child: CircularProgressIndicator(
                                    color: Color(0xFF6A1B9A))));

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
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                            content: Text("Request sent successfully!"),
                            backgroundColor: Colors.green,
                          ));
                          if (mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    TrackingPage(rideId: rideId),
                              ),
                            );
                          }
                        } catch (e) {
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text("Error: $e"),
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
                        if (_destinationLatLng != null) {
                          _mapController.move(_destinationLatLng!, 15.0);
                        }
                      }),
                      onSearchTap: _showSearchDialog,
                      onConfirmTap: () {
                        if (_destinationLatLng == null ||
                            _destinationLocation == "Choose Destination") {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                              content:
                                  Text("Please select destination first")));
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
