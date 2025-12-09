import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';

class RatingPage extends StatefulWidget {
  final String rideId;
  const RatingPage({Key? key, required this.rideId}) : super(key: key);

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  int _rating = 0;

  void _submitRating() async {
    if (_rating == 0) return;

    await FirebaseFirestore.instance
        .collection('rides')
        .doc(widget.rideId)
        .update({
      'rating': _rating,
    });

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => HomePage()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, size: 80, color: Colors.green),
            SizedBox(height: 20),
            Text("You arrived safely!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            Text("How was your ride?",
                style: TextStyle(color: Colors.grey, fontSize: 16)),

            SizedBox(height: 40),

            // Rating stars
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _rating ? Icons.star : Icons.star_border,
                    size: 40,
                    color: Colors.amber,
                  ),
                  onPressed: () => setState(() => _rating = index + 1),
                );
              }),
            ),

            SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _rating > 0 ? _submitRating : null,
                style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF7F00FF)),
                child: Text("Submit Rating",
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),

            TextButton(
              onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => HomePage()),
                  (route) => false),
              child: Text("Skip", style: TextStyle(color: Colors.grey)),
            )
          ],
        ),
      ),
    );
  }
}
