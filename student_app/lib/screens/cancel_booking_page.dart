import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

class CancelBookingPage extends StatefulWidget {
  final String rideId;

  const CancelBookingPage({Key? key, required this.rideId}) : super(key: key);

  @override
  _CancelBookingPageState createState() => _CancelBookingPageState();
}

class _CancelBookingPageState extends State<CancelBookingPage> {
  final List<String> _reasons = [
    "I don't need this journey",
    "I want to change trip details",
    "Driver took too long to arrive",
    "Driver is moving in wrong direction",
    "Found another ride",
    "Clicked by mistake",
    "Driver asked me to cancel",
    "Other"
  ];

  String? _selectedReason;
  bool _isSending = false;

  void _submitCancellation() async {
    if (_selectedReason == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please select a reason first")));
      return;
    }

    setState(() => _isSending = true);

    try {
      await FirebaseFirestore.instance
          .collection('rides')
          .doc(widget.rideId)
          .update({
        'status': 'cancelled',
        'cancelReason': _selectedReason,
        'cancelledAt': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A1B9A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Cancel Booking",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 40),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(25),
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Why do you want to cancel?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: _reasons.length,
                      separatorBuilder: (c, i) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return RadioListTile<String>(
                            value: _reasons[index],
                            groupValue: _selectedReason,
                            onChanged: (val) =>
                                setState(() => _selectedReason = val),
                            title: Text(_reasons[index],
                                style: TextStyle(
                                    color: Colors.grey[800], fontSize: 14)),
                            activeColor: const Color(0xFF6A1B9A),
                            contentPadding: EdgeInsets.zero,
                            dense: true);
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _submitCancellation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30)),
                      ),
                      child: _isSending
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Send",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
