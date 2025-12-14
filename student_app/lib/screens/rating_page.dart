import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RatingPage extends StatefulWidget {
  final String rideId;
  const RatingPage({Key? key, required this.rideId}) : super(key: key);

  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  final Color _primaryColor = const Color(0xFF6A1B9A);

  final _formKey = GlobalKey<FormState>();
  final _complaintController = TextEditingController();

  int _rating = 0;
  bool _isSubmitting = false;

  void _submitRating() async {
    if (_rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("الرجاء تحديد تقييم قبل الإرسال")));
      return;
    }

    if (_rating == 1 && !_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSubmitting = true);

    final rideDoc = await FirebaseFirestore.instance
        .collection('rides')
        .doc(widget.rideId)
        .get();

    final rideData = rideDoc.data();
    final String? driverId = rideData?['driverId'];

    WriteBatch batch = FirebaseFirestore.instance.batch();

    DocumentReference rideRef =
        FirebaseFirestore.instance.collection('rides').doc(widget.rideId);

    batch.update(rideRef, {
      'rating': _rating,
    });

    if (_rating == 1 && _complaintController.text.isNotEmpty) {
      DocumentReference complaintRef =
          FirebaseFirestore.instance.collection('complaints').doc();

      batch.set(complaintRef, {
        'rideId': widget.rideId,
        'passengerId': FirebaseAuth.instance.currentUser!.uid,
        'driverId': driverId,
        'complaintText': _complaintController.text.trim(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    try {
      await batch.commit();

      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => HomePage()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("فشل في إرسال التقييم: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool showComplaintBox = _rating == 1;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.check_circle, size: 80, color: Colors.green),
                SizedBox(height: 20),
                Text("وصلت بسلام!",
                    style:
                        TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                Text("كيف كانت رحلتك؟",
                    style: TextStyle(color: Colors.grey, fontSize: 16)),
                SizedBox(height: 40),
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
                SizedBox(height: 30),
                if (showComplaintBox)
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("نجمة واحدة؟ يرجى كتابة شكوتك:",
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.red)),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _complaintController,
                          maxLines: 4,
                          maxLength: 250,
                          decoration: InputDecoration(
                            hintText:
                                "اكتب هنا تفاصيل الشكوى بحد أقصى 250 حرف...",
                            fillColor: Colors.grey[100],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(15),
                              borderSide: BorderSide.none,
                            ),
                            errorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 1)),
                            focusedErrorBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(15),
                                borderSide:
                                    BorderSide(color: Colors.red, width: 1)),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'الرجاء إدخال تفاصيل الشكوى قبل الإرسال.';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _submitRating,
                    style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryColor),
                    child: _isSubmitting
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text("إرسال التقييم",
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
