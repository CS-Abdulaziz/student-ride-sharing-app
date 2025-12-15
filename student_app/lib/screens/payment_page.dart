import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PaymentPage extends StatefulWidget {
  final String rideId;
  final String amount;

  const PaymentPage({Key? key, required this.rideId, required this.amount})
      : super(key: key);

  @override
  _PaymentPageState createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  bool _isProcessing = false;
  int _selectedMethod = 0;

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);

    await Future.delayed(Duration(seconds: 2));

    try {
      await FirebaseFirestore.instance
          .collection('rides')
          .doc(widget.rideId)
          .update({
        'status': 'in_progress',
        'paymentStatus': 'paid',
        'paymentMethod': _selectedMethod == 2 ? 'Cash' : 'Online',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Payment Successful! Ride Started.")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error processing payment")),
      );
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Payment", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  Text("Total Amount", style: TextStyle(color: Colors.grey)),
                  Text(widget.amount,
                      style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A1B9A))),
                ],
              ),
            ),
            SizedBox(height: 40),
            Text("Select Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            _buildPaymentOption(0, "Apple Pay", Icons.apple),
            _buildPaymentOption(1, "Credit Card", Icons.credit_card),
            _buildPaymentOption(2, "Cash", Icons.money),
            Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6A1B9A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: _isProcessing
                    ? CircularProgressIndicator(
                        color: const Color.fromARGB(255, 0, 0, 0))
                    : Text(
                        "Pay Now & Start Ride",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: const Color.fromARGB(255, 255, 255, 255)),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentOption(int value, String title, IconData icon) {
    return RadioListTile(
      value: value,
      groupValue: _selectedMethod,
      onChanged: (val) => setState(() => _selectedMethod = val as int),
      title: Text(title),
      secondary: Icon(icon, color: Color(0xFF6A1B9A)),
      activeColor: Color(0xFF6A1B9A),
    );
  }
}
