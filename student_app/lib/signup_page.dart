import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'auth_controller.dart';
import 'screens/home_page.dart';

class SignUpPage extends ConsumerStatefulWidget {
  @override
  ConsumerState<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends ConsumerState<SignUpPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _universityIdController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  final Color _primaryColor = const Color(0xFF6A1B9A);

  void _handleSignUp() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);
    try {
      await ref.read(authControllerProvider).signUp(
            name: _nameController.text.trim(),
            universityId: _universityIdController.text.trim(),
            phone: _phoneController.text.trim(),
            password: _passwordController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.green,
            content: Text("تم إنشاء الحساب بنجاح")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(backgroundColor: Colors.red, content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
      appBar: AppBar(
        backgroundColor: _primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Text("تسجيل حساب جديد", // ترجمة
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.bold)),
                  SizedBox(height: 30),
                  _buildField(
                    _nameController,
                    "الاسم الكامل",
                    Icons.person,
                    'الرجاء إدخال الاسم',
                    inputType: 'name',
                  ),
                  _buildField(
                    _universityIdController,
                    "الرقم الجامعي",
                    Icons.school,
                    'الرجاء إدخال الرقم الجامعي',
                    keyboard: TextInputType.number,
                    inputType: 'id',
                  ),
                  _buildField(
                    _phoneController,
                    "رقم الجوال (966XXXXXXXXX)",
                    Icons.phone,
                    'الرجاء إدخال رقم الجوال',
                    keyboard: TextInputType.phone,
                    inputType: 'phone',
                  ),
                  _buildField(
                    _passwordController,
                    "كلمة المرور",
                    Icons.lock,
                    'الرجاء إدخال كلمة المرور',
                    isObscure: true,
                    inputType: 'password',
                  ),
                  _buildField(
                    _confirmPasswordController,
                    "تأكيد كلمة المرور",
                    Icons.lock_outline,
                    'الرجاء تأكيد كلمة المرور',
                    isObscure: true,
                    inputType: 'confirm_password',
                  ),
                  SizedBox(height: 30),
                  _isLoading
                      ? CircularProgressIndicator(color: Colors.white)
                      : SizedBox(
                          width: 200,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _handleSignUp,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: Text("تسجيل",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.bold)),
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

  Widget _buildField(TextEditingController controller, String hint,
      IconData icon, String requiredMessage,
      {bool isObscure = false,
      TextInputType keyboard = TextInputType.text,
      String inputType = ''}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        obscureText: isObscure,
        keyboardType: keyboard,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: _primaryColor),
          filled: true,
          fillColor: Colors.white,
          hintText: hint,
          errorStyle: TextStyle(fontSize: 12, color: Colors.red, height: 1.2),
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30.0),
            borderSide: BorderSide(color: Colors.red, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return requiredMessage;
          }

          switch (inputType) {
            case 'name':
              if (!RegExp(r'^[a-zA-Z\u0621-\u064A\s]+$').hasMatch(value)) {
                return 'يجب أن يحتوي الاسم على حروف ومسافات فقط.';
              }
              break;
            case 'id':
              if (!RegExp(r'^\d{9}$').hasMatch(value)) {
                return 'يجب أن يتكون الرقم الجامعي من 9 أرقام فقط.';
              }
              break;
            case 'phone':
              if (!RegExp(r'^966[0-9]{9}$').hasMatch(value)) {
                return 'يجب أن يبدأ رقم الجوال بـ 966 ويتكون من 12 رقم.';
              }
              break;
            case 'password':
              if (value.length < 8) {
                return 'يجب أن لا تقل كلمة المرور عن 8 خانات.';
              }
              if (!RegExp(r'^(?=.*[a-zA-Z])(?=.*[0-9]).{8,}$')
                  .hasMatch(value)) {
                return 'يجب أن تحتوي كلمة المرور على حروف وأرقام.';
              }
              break;
            case 'confirm_password':
              if (value != _passwordController.text) {
                return 'كلمة المرور غير متطابقة.';
              }
              break;
          }

          return null;
        },
      ),
    );
  }
}
