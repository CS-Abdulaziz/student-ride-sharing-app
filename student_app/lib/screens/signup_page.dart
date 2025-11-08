import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _nameController = TextEditingController();
  final _universityIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _universityIdController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,

        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF9446C2),
              const Color.fromARGB(255, 217, 166, 249),
            ],
            begin: Alignment.center,
            end: Alignment.bottomCenter,
          ),
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      "New user",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 30),

                  Text(
                    "User name",
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    textAlign: TextAlign.left,
                    decoration: _buildInputDecoration(),
                  ),
                  SizedBox(height: 15),

                  Text(
                    "University ID",
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _universityIdController,
                    textAlign: TextAlign.left,
                    decoration: _buildInputDecoration(),
                  ),
                  SizedBox(height: 15),

                  Text(
                    "Phone number",
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _phoneController,
                    textAlign: TextAlign.left,
                    keyboardType: TextInputType.phone,
                    decoration: _buildInputDecoration(),
                  ),
                  SizedBox(height: 15),

                  Text(
                    "Password",
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _passwordController,
                    textAlign: TextAlign.left,
                    obscureText: true,
                    decoration: _buildInputDecoration(),
                  ),
                  SizedBox(height: 15),

                  Text(
                    "Confirm Password",
                    style: TextStyle(color: Colors.white.withOpacity(0.9)),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    controller: _confirmPasswordController,
                    textAlign: TextAlign.left,
                    obscureText: true,
                    decoration: _buildInputDecoration(),
                  ),
                  SizedBox(height: 30),

                  Center(
                    child: TextButton(
                      onPressed: () {},
                      child: Text(
                        "Log in?",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration() {
    return InputDecoration(
      fillColor: Colors.white,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
    );
  }
}
