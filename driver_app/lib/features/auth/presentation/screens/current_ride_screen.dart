import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CurrentRideScreen extends StatefulWidget {
  final String rideId;

  const CurrentRideScreen({super.key, required this.rideId});

  @override
  State<CurrentRideScreen> createState() => _CurrentRideScreenState();
}

class _CurrentRideScreenState extends State<CurrentRideScreen> {
  Future<void> _updateRideStatus(
    String currentStatus,
    String paymentStatus,
    String paymentMethod,
  ) async {
    String nextStatus = '';
    currentStatus = currentStatus.trim();

    // 1. منطق زر الوصول: ينتقل مباشرة من Accepted/Pending إلى Arrived
    if (currentStatus == 'pending' || currentStatus == 'accepted') {
      nextStatus = 'arrived';
    }
    // 2. منطق زر الإكمال:
    // - إذا كانت الحالة in_progress (يعني الطالب دفع بالمحفظة) -> إنهاء
    // - إذا كانت الحالة arrived والدفع كاش (يعني السائق يقبض بيده) -> إنهاء
    // - إذا كانت الحالة started (احتياط) -> إنهاء
    else if (currentStatus == 'in_progress' ||
        currentStatus == 'started' ||
        (currentStatus == 'arrived' && paymentMethod == 'Cash')) {
      nextStatus = 'completed';
    }

    // --- سيناريو الدفع الكاش عند الإنهاء ---
    if (nextStatus == 'completed' &&
        paymentMethod == 'Cash' &&
        paymentStatus != 'paid') {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Confirm Cash Payment"),
          content:
              const Text("Did you receive the cash amount from the student?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("No", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                "Yes, Received",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      // تحديث الحالة إلى مدفوع ومنتهية
      await FirebaseFirestore.instance
          .collection('rides')
          .doc(widget.rideId)
          .update({
        'status': 'completed',
        'paymentStatus': 'paid',
        'completedAt': FieldValue.serverTimestamp(),
      });

      if (mounted) Navigator.pop(context); // الخروج
      return;
    }

    // --- التحديث الطبيعي لبقية الحالات ---
    if (nextStatus.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection('rides')
          .doc(widget.rideId)
          .update({
        'status': nextStatus,
        if (nextStatus == 'completed')
          'completedAt': FieldValue.serverTimestamp(),
      });
    }

    if (nextStatus == 'completed' && mounted) {
      Navigator.pop(context);
    }
  }

  // --- بناء الواجهة (UI) ---

  @override
  Widget build(BuildContext context) {
    const Color mainPurpleColor = Color(0xFF9446C2);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: mainPurpleColor,
        elevation: 0,
        centerTitle: true,
        title: const Text("Current Ride",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content:
                      Text("You cannot go back until the ride is finished!")),
            );
          },
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('rides')
            .doc(widget.rideId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(child: Text("Ride not found"));
          }

          var rideData = snapshot.data!.data() as Map<String, dynamic>;

          String rawStatus = rideData['status'] ?? 'accepted';
          String status = rawStatus.toString().trim();

          String price = rideData['price'] ?? '0';
          String paymentStatus = rideData['paymentStatus'] ?? 'unpaid';
          String paymentMethod = rideData['PaymentMethod'] ?? 'Cash';

          bool isPaid = (paymentStatus == 'paid');

          // --- تحديد حالة الزر والنصوص (الجزئية المهمة) ---
          String btnText = "Loading...";
          Color btnColor = Colors.grey;
          bool isButtonEnabled = true;

          if (status == 'pending' || status == 'accepted') {
            btnText = "I Arrived";
            btnColor = mainPurpleColor;
          } else if (status == 'arrived') {
            if (paymentMethod == 'Cash') {
              // إذا كاش، الزر متاح للإنهاء
              btnText = "Complete Trip";
              btnColor = Colors.green;
            } else {
              // إذا محفظة، ننتظر الدفع
              btnText = "Waiting for Payment...";
              btnColor = Colors.grey;
              isButtonEnabled = false;
            }
          } else if (status == 'in_progress' || status == 'started') {
            // حل مشكلة الزر الأصفر: إذا دفع الطالب وتغيرت الحالة
            btnText = "Complete Trip";
            btnColor = Colors.green;
          } else if (status == 'completed') {
            btnText = "Trip Completed";
            btnColor = Colors.grey;
            isButtonEnabled = false;
          } else {
            btnText = "Status: $status";
            btnColor = Colors.orange;
          }

          return Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: [
                  Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      color: mainPurpleColor,
                      borderRadius: BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30)),
                    ),
                  ),
                  Positioned(
                    top: 10,
                    left: 20,
                    right: 20,
                    bottom: -50,
                    child: _buildPassengerCard(),
                  ),
                ],
              ),
              const SizedBox(height: 70),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Trip Route",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.1),
                                blurRadius: 10)
                          ],
                        ),
                        child: Column(
                          children: [
                            _buildTimelineRow(
                              title: "Pickup",
                              address: rideData['pickupAddress'] ?? "Unknown",
                              icon: Icons.my_location,
                              color: mainPurpleColor,
                              isLast: false,
                            ),
                            _buildTimelineRow(
                              title: "Drop-off",
                              address:
                                  rideData['destinationAddress'] ?? "Unknown",
                              icon: Icons.location_on,
                              color: Colors.redAccent,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text("Payment Details",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey.shade200),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.grey.withOpacity(0.05),
                                blurRadius: 10)
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Payment Method",
                                    style: TextStyle(color: Colors.grey)),
                                Row(
                                  children: [
                                    Icon(
                                        paymentMethod == 'Wallet'
                                            ? Icons.account_balance_wallet
                                            : Icons.money,
                                        color: mainPurpleColor,
                                        size: 20),
                                    const SizedBox(width: 8),
                                    Text(paymentMethod,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16)),
                                  ],
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Status",
                                    style: TextStyle(color: Colors.grey)),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: isPaid
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                          isPaid
                                              ? Icons.check_circle
                                              : Icons.pending,
                                          size: 16,
                                          color: isPaid
                                              ? Colors.green
                                              : Colors.orange),
                                      const SizedBox(width: 6),
                                      Text(
                                        isPaid ? "PAID" : "PENDING",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: isPaid
                                                ? Colors.green
                                                : Colors.orange,
                                            fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text("Total Amount",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16)),
                                Text("$price SAR",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 22,
                                        color: mainPurpleColor)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SafeArea(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: isButtonEnabled
                          ? () => _updateRideStatus(
                              status, paymentStatus, paymentMethod)
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: btnColor,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        btnText,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // --- Widgets مساعدة (لم تتغير) ---

  Widget _buildPassengerCard() {
    return Container(
      height: 100,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.person, size: 35, color: Colors.grey),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Student Passenger",
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 18),
                    Text("4.8",
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
          CircleAvatar(
            backgroundColor: Colors.green.withOpacity(0.1),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.phone, color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineRow(
      {required String title,
      required String address,
      required IconData icon,
      required Color color,
      required bool isLast}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Icon(icon, color: color, size: 20),
            if (!isLast)
              Container(
                  width: 2,
                  height: 40,
                  color: Colors.grey[300],
                  margin: const EdgeInsets.symmetric(vertical: 4)),
          ],
        ),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(address,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ],
    );
  }
}
