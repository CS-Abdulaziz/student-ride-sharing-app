import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:driver_app/features/auth/presentation/screens/available_ride_screen.dart';
import 'package:driver_app/features/auth/presentation/screens/current_ride_screen.dart';


class SignupVehicleScreen extends StatefulWidget {
  final String? fullName;
  final String? email;
  final String? phone;
  final String? nationalId;
  final String? password;

  const SignupVehicleScreen({
    super.key,
    this.fullName,
    this.email,
    this.phone,
    this.nationalId,
    this.password,
  });

  @override
  State<SignupVehicleScreen> createState() => _SignupVehicleScreenState();
}

class _SignupVehicleScreenState extends State<SignupVehicleScreen> {
  final Map<String, List<String>> _carData = {
    'Toyota': [
      'Camry',
      'Corolla',
      'Yaris',
      'Land Cruiser',
      'Hilux',
      'Innova',
      'Avalon'
    ],
    'Hyundai': ['Sonata', 'Elantra', 'Accent', 'Tucson', 'Santa Fe', 'Azera'],
    'Kia': ['K5', 'Pegas', 'Sportage', 'Sorento', 'Cerato', 'Rio'],
    'Ford': ['Taurus', 'Explorer', 'Expedition', 'F-150', 'Mustang'],
    'Nissan': ['Sunny', 'Altima', 'Maxima', 'Patrol', 'Kicks'],
    'Honda': ['Accord', 'Civic', 'Pilot', 'City'],
    'Mazda': ['Mazda 6', 'Mazda 3', 'CX-9', 'CX-5'],
    'Chevrolet': ['Tahoe', 'Suburban', 'Malibu', 'Caprice'],
    'Lexus': ['ES', 'LS', 'LX', 'RX', 'IS'],
    'Mercedes': ['C-Class', 'E-Class', 'S-Class', 'G-Class'],
    'BMW': ['3 Series', '5 Series', '7 Series', 'X5'],
  };

  final List<String> _carTypes = [
    'Sedan',
    'SUV',
    'Hatchback',
    'Coupe',
    'Van',
    'Truck'
  ];
  final List<String> _colors = [
    'White',
    'Black',
    'Silver',
    'Grey',
    'Red',
    'Blue',
    'Brown',
    'Beige',
    'Green',
    'Gold'
  ];
  final List<String> _seats =
      List.generate(6, (index) => (index + 3).toString());
  final List<String> _years = List.generate(
      35, (index) => (DateTime.now().year + 1 - index).toString());

  String? _selectedBrand;
  String? _selectedModel;
  String? _selectedYear;
  String? _selectedColor;
  String? _selectedType;
  String? _selectedSeats;

  final _plateNumController = TextEditingController();
  final _plateL1Controller = TextEditingController();
  final _plateL2Controller = TextEditingController();
  final _plateL3Controller = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final FocusNode _plateNumFocus = FocusNode();
  final FocusNode _plateL1Focus = FocusNode();
  final FocusNode _plateL2Focus = FocusNode();
  final FocusNode _plateL3Focus = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9446C2),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Vehicle Info",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  const Text("Select your vehicle details",
                      style: TextStyle(color: Colors.white70, fontSize: 16)),
                  const SizedBox(height: 24),
                  _buildDropdownField(
                    label: 'Vehicle Brand',
                    icon: Icons.branding_watermark,
                    value: _selectedBrand,
                    items: _carData.keys.toList(),
                    hint: 'Select Brand',
                    onChanged: (val) {
                      setState(() {
                        _selectedBrand = val;
                        _selectedModel = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  _buildDropdownField(
                    label: 'Vehicle Model',
                    icon: Icons.directions_car,
                    value: _selectedModel,
                    items:
                        _selectedBrand != null ? _carData[_selectedBrand]! : [],
                    hint: _selectedBrand != null
                        ? 'Select Model'
                        : 'Select Brand First',
                    onChanged: (val) => setState(() => _selectedModel = val),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Year',
                          icon: Icons.calendar_today,
                          value: _selectedYear,
                          items: _years,
                          hint: 'Year',
                          onChanged: (val) =>
                              setState(() => _selectedYear = val),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Color',
                          icon: Icons.color_lens,
                          value: _selectedColor,
                          items: _colors,
                          hint: 'Color',
                          onChanged: (val) =>
                              setState(() => _selectedColor = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Row(
                    children:[
                      Icon(Icons.confirmation_number,
                          color: Colors.white, size: 20),
                      SizedBox(width: 8),
                      Text("License Plate",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 14.0,
                              fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          flex: 4,
                          child: _buildPlateTextField(
                            controller: _plateNumController,
                            hint: '1234',
                            isDigit: true,
                            focusNode: _plateNumFocus,
                            nextFocus: _plateL1Focus,
                            maxLength: 4,
                          ),
                        ),
                        Container(
                            width: 1,
                            height: 24,
                            color: Colors.grey.shade300,
                            margin: const EdgeInsets.symmetric(horizontal: 4)),
                        Expanded(
                          flex: 2,
                          child: _buildPlateTextField(
                            controller: _plateL1Controller,
                            hint: 'A',
                            focusNode: _plateL1Focus,
                            nextFocus: _plateL2Focus,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          flex: 2,
                          child: _buildPlateTextField(
                            controller: _plateL2Controller,
                            hint: 'B',
                            focusNode: _plateL2Focus,
                            nextFocus: _plateL3Focus,
                          ),
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          flex: 2,
                          child: _buildPlateTextField(
                            controller: _plateL3Controller,
                            hint: 'C',
                            focusNode: _plateL3Focus,
                            isLast: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Vehicle Type',
                          icon: Icons.category,
                          value: _selectedType,
                          items: _carTypes,
                          hint: 'Type',
                          onChanged: (val) =>
                              setState(() => _selectedType = val),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdownField(
                          label: 'Seats',
                          icon: Icons.event_seat,
                          value: _selectedSeats,
                          items: _seats,
                          hint: 'Count',
                          onChanged: (val) =>
                              setState(() => _selectedSeats = val),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                  _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white))
                      : ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF9446C2),
                            minimumSize: const Size(double.infinity, 56),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16)),
                          ),
                          onPressed: _registerDriver,
                          child: const Text("Register",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.bold)),
                        ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required IconData icon,
    required String? value,
    required List<String> items,
    required String hint,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14.0,
                fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          initialValue: value,
          icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF9446C2)),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            prefixIcon: Icon(icon, color: const Color(0xFF9446C2), size: 22),
            contentPadding:
                const EdgeInsets.symmetric(vertical: 14, horizontal: 10),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none),
            errorStyle: const TextStyle(
                color: Colors.yellowAccent, fontWeight: FontWeight.bold),
          ),
          hint: Text(hint,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              overflow: TextOverflow.ellipsis),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (val) => val == null ? 'Required' : null,
          menuMaxHeight: 300,
        ),
      ],
    );
  }

  Widget _buildPlateTextField({
    required TextEditingController controller,
    required String hint,
    FocusNode? focusNode,
    FocusNode? nextFocus,
    bool isDigit = false,
    int maxLength = 1,
    bool isLast = false,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: isDigit ? TextInputType.number : TextInputType.text,
      textCapitalization: TextCapitalization.characters,
      textAlign: TextAlign.center,
      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
      maxLength: maxLength,
      decoration: InputDecoration(
        isDense: true,
        counterText: "",
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade300, fontSize: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF9446C2), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
      ),
      inputFormatters: [
        isDigit
            ? FilteringTextInputFormatter.digitsOnly
            : FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
      ],
      onChanged: (value) {
        if (value.length == maxLength && nextFocus != null) {
          nextFocus.requestFocus();
        }
      },
      validator: (val) {
        if (val == null || val.isEmpty) return '';
        if (isDigit && val.length < 4) return '';
        return null;
      },
    );
  }

  Future<void> _registerDriver() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      String fullPlate =
          "${_plateNumController.text} ${_plateL1Controller.text}${_plateL2Controller.text}${_plateL3Controller.text}"
              .toUpperCase();

      try {
        final credential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: widget.email ?? '',
          password: widget.password ?? '',
        );

        await FirebaseFirestore.instance
            .collection('drivers')
            .doc(credential.user!.uid)
            .set({
          'uid': credential.user!.uid,
          'fullName': widget.fullName,
          'email': widget.email,
          'phone': widget.phone,
          'nationalId': widget.nationalId,
          'role': 'driver',
          'createdAt': FieldValue.serverTimestamp(),
          'vehicleBrand': _selectedBrand,
          'vehicleModel': _selectedModel,
          'vehicleYear': _selectedYear,
          'vehicleColor': _selectedColor,
          'vehicleType': _selectedType,
          'seats': int.parse(_selectedSeats!),
          'vehiclePlate': fullPlate,
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Account Created Successfully!'),
                backgroundColor: Colors.green),
          );

          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) => const AvailableRidesScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields correctly'),
            backgroundColor: Colors.orange),
      );
    }
  }

  @override
  void dispose() {
    _plateNumController.dispose();
    _plateL1Controller.dispose();
    _plateL2Controller.dispose();
    _plateL3Controller.dispose();
    _plateNumFocus.dispose();
    _plateL1Focus.dispose();
    _plateL2Focus.dispose();
    _plateL3Focus.dispose();
    super.dispose();
  }
}
