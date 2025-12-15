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

    await Future.delayed(const Duration(seconds: 2));

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
          const SnackBar(content: Text("Payment Successful! Ride Started.")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error processing payment")),
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
        title: const Text("Payment", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  const Text("Total Amount",
                      style: TextStyle(color: Colors.grey)),
                  Text(widget.amount,
                      style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF6A1B9A))),
                ],
              ),
            ),
            const SizedBox(height: 40),
            const Text("Select Payment Method",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            _buildPaymentOption(0, "Apple Pay", Icons.apple),
            _buildPaymentOption(1, "Credit Card", Icons.credit_card),
            _buildPaymentOption(2, "Cash", Icons.money),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isProcessing ? null : _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6A1B9A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30)),
                ),
                child: _isProcessing
                    ? const CircularProgressIndicator(
                        color: Color.fromARGB(255, 0, 0, 0))
                    : const Text(
                        "Pay Now & Start Ride",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 255, 255, 255)),
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
      secondary: Icon(icon, color: const Color(0xFF6A1B9A)),
      activeColor: const Color(0xFF6A1B9A),
    );
  }
}
