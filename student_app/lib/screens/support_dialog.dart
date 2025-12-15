import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

void showSupportDialog(BuildContext context) {
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  showDialog(
    context: context,
    builder: (context) {
      bool _isSending = false;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.support_agent, color: Color(0xFF6A1B9A)),
                SizedBox(width: 10),
                Text("Technical Support",
                    style: TextStyle(
                        color: Color(0xFF6A1B9A),
                        fontWeight: FontWeight.bold,
                        fontSize: 18)),
              ],
            ),
            content: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Facing an issue? Write to us and we'll help you.",
                      style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _messageController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: "Describe your problem here...",
                      hintStyle: TextStyle(fontSize: 14),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide:
                            BorderSide(color: Color(0xFF6A1B9A), width: 2),
                      ),
                    ),
                    validator: (val) => val == null || val.trim().isEmpty
                        ? "Message cannot be empty"
                        : null,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text("Cancel", style: TextStyle(color: Colors.grey)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6A1B9A),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20)),
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
                onPressed: _isSending
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          setState(() => _isSending = true);
                          try {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              final userDoc = await FirebaseFirestore.instance
                                  .collection('users')
                                  .doc(user.uid)
                                  .get();

                              await FirebaseFirestore.instance
                                  .collection('support_tickets')
                                  .add({
                                'uid': user.uid,
                                'name': userDoc.data()?['name'] ?? 'Unknown',
                                'universityId':
                                    userDoc.data()?['universityId'] ??
                                        'Unknown',
                                'phone': userDoc.data()?['phone'] ?? '',
                                'message': _messageController.text.trim(),
                                'timestamp': FieldValue.serverTimestamp(),
                                'status': 'new',
                              });
                            }

                            Navigator.pop(context);

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Message sent successfully!"),
                                backgroundColor: Colors.green,
                              ),
                            );
                          } catch (e) {
                            setState(() => _isSending = false);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text("Error: $e"),
                                  backgroundColor: Colors.red),
                            );
                          }
                        }
                      },
                child: _isSending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2))
                    : Text("Send",
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ],
          );
        },
      );
    },
  );
}
