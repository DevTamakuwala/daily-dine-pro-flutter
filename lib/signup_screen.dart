import 'dart:math';
import 'package:flutter/material.dart';

// Main function to run the app
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sign Up',
      theme: ThemeData(
        primarySwatch: Colors.orange,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFEAE3D9),
        fontFamily: 'Poppins',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Color(0xFF333333)),
          bodyMedium: TextStyle(color: Color(0xFF333333)),
        ),
      ),
      home: const SignUpScreen(),
    );
  }
}

// Enum to define user types
enum UserType { messOwner, customer }

// The main sign-up screen widget
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> with SingleTickerProviderStateMixin {
  // State variables
  final _messOwnerFormKey = GlobalKey<FormState>();
  final _customerFormKey = GlobalKey<FormState>();
  late AnimationController _animationController;
  final List<FoodParticle> _particles = [];
  UserType _selectedUserType = UserType.messOwner; // Default to Mess Owner
  int _selectedMessTypeChip = 0;

  // *** UPDATED: List of image paths for the animation ***
  final List<String> _foodImagePaths = [
    'assets/food.png',
    'assets/food2.png',
    'assets/food3.jpg',
    //'assets/food4.jpg',
  ];

  // Controllers for Mess Owner form
  final _messNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();

  // Controllers for both forms
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  // Controllers for Customer form
  final _customerNameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();


  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25), // Slightly slower for more images
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        for (int i = 0; i < 15; i++) {
          _particles.add(FoodParticle(size, _foodImagePaths));
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Dispose all controllers
    _messNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _customerNameController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Animated background using images
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              for (var particle in _particles) {
                particle.update();
              }
              return Stack(
                children: _particles.map((p) {
                  return Positioned(
                    left: p.x,
                    top: p.y,
                    child: Transform.rotate(
                      angle: p.rotation,
                      child: Opacity(
                        opacity: p.opacity,
                        child: Image.asset(
                          p.imagePath,
                          width: p.size,
                          height: p.size,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
          // Main content with form
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 100,
                    child: Image.asset('assets/DailyDinePro.png'),
                  ),
                  const SizedBox(height: 16),

                  // *** NEW: User Type Selector ***
                  Text(
                    "I am a...",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
                  ),
                  const SizedBox(height: 12),
                  ToggleButtons(
                    isSelected: [_selectedUserType == UserType.messOwner, _selectedUserType == UserType.customer],
                    onPressed: (index) {
                      setState(() {
                        _selectedUserType = index == 0 ? UserType.messOwner : UserType.customer;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    selectedColor: Colors.white,
                    fillColor: Colors.orange.shade700,
                    color: Colors.orange.shade700,
                    borderColor: Colors.orange.shade700,
                    selectedBorderColor: Colors.orange.shade700,
                    children: const [
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Mess Owner")),
                      Padding(padding: EdgeInsets.symmetric(horizontal: 16), child: Text("Customer")),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // *** Conditional Form Display ***
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: _selectedUserType == UserType.messOwner
                        ? _buildMessOwnerForm()
                        : _buildCustomerForm(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget for Mess Owner Sign Up Form
  Widget _buildMessOwnerForm() {
    return Form(
      key: _messOwnerFormKey,
      child: Column(
        key: const ValueKey('messOwnerForm'),
        children: [
          const Text("Mess Owner Onboarding", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextFormField(controller: _messNameController, label: "Mess Name", icon: Icons.storefront, validator: (v) => v!.isEmpty ? "Mess Name is required" : null),
          const SizedBox(height: 16),
          _buildTextFormField(controller: _addressController, label: "Address", icon: Icons.location_on_outlined, validator: (v) => v!.isEmpty ? "Address is required" : null),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextFormField(controller: _cityController, label: "City", icon: Icons.location_city, validator: (v) => v!.isEmpty ? "City is required" : null)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextFormField(controller: _stateController, label: "State", icon: Icons.map_outlined, validator: (v) => v!.isEmpty ? "State is required" : null)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextFormField(controller: _zipCodeController, label: "Zip Code", icon: Icons.pin_drop_outlined, keyboardType: TextInputType.number, validator: (v) => v!.isEmpty ? "Zip Code is required" : null),
          const SizedBox(height: 16),
          _buildTextFormField(controller: _phoneController, label: "Phone Number", icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => v!.length < 10 ? "Enter a valid phone number" : null),
          const SizedBox(height: 16),
          _buildTextFormField(controller: _emailController, label: "Email Address", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => !RegExp(r'\S+@\S+\.\S+').hasMatch(v!) ? "Enter a valid email" : null),
          const SizedBox(height: 24),
          Text("Type of Mess", style: TextStyle(fontSize: 16, color: const Color(0xFF333333).withOpacity(0.9), fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Center(child: _buildChoiceChip(0, "Dining Hall", Icons.dinner_dining)),
          const SizedBox(height: 32),
          _buildSubmitButton(() {
            if (_messOwnerFormKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Processing Mess Owner Data...')));
            }
          }),
        ],
      ),
    );
  }

  // Widget for Customer Sign Up Form
  Widget _buildCustomerForm() {
    return Form(
      key: _customerFormKey,
      child: Column(
        key: const ValueKey('customerForm'),
        children: [
          const Text("Create Customer Account", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildTextFormField(controller: _customerNameController, label: "Full Name", icon: Icons.person_outline, validator: (v) => v!.isEmpty ? "Full Name is required" : null),
          const SizedBox(height: 16),
          _buildTextFormField(controller: _emailController, label: "Email Address", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => !RegExp(r'\S+@\S+\.\S+').hasMatch(v!) ? "Enter a valid email" : null),
          const SizedBox(height: 16),
          _buildTextFormField(controller: _phoneController, label: "Phone Number", icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => v!.length < 10 ? "Enter a valid phone number" : null),
          const SizedBox(height: 16),
          _buildTextFormField(controller: _passwordController, label: "Password", icon: Icons.lock_outline, obscureText: true, validator: (v) => v!.length < 6 ? "Password must be at least 6 characters" : null),
          const SizedBox(height: 16),
          _buildTextFormField(controller: _confirmPasswordController, label: "Confirm Password", icon: Icons.lock_outline, obscureText: true, validator: (v) => v != _passwordController.text ? "Passwords do not match" : null),
          const SizedBox(height: 32),
          _buildSubmitButton(() {
            if (_customerFormKey.currentState!.validate()) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Processing Customer Data...')));
            }
          }),
        ],
      ),
    );
  }

  // Helper for building the submit button
  Widget _buildSubmitButton(VoidCallback onPressed) {
    return Center(
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Colors.orange.shade700,
          foregroundColor: Colors.white,
          elevation: 8,
          shadowColor: Colors.orange.withOpacity(0.5),
        ),
        onPressed: onPressed,
        child: const Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      ),
    );
  }

  // Helper for building text form fields
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
    bool obscureText = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      obscureText: obscureText,
      style: const TextStyle(color: Color(0xFF333333)),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: const Color(0xFF333333).withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.orange.shade700),
        filled: true,
        fillColor: Colors.black.withOpacity(0.05),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.orange.shade400, width: 2)),
      ),
    );
  }

  // Helper for building choice chips
  Widget _buildChoiceChip(int index, String label, IconData icon) {
    final isSelected = _selectedMessTypeChip == index;
    return ChoiceChip(
      label: Text(label),
      labelStyle: TextStyle(color: isSelected ? Colors.white : const Color(0xFF333333), fontWeight: FontWeight.bold),
      avatar: Icon(icon, color: isSelected ? Colors.white : Colors.orange.shade700),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedMessTypeChip = index;
          });
        }
      },
      backgroundColor: Colors.black.withOpacity(0.05),
      selectedColor: Colors.orange.shade400,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isSelected ? Colors.orange.shade400 : Colors.grey.withOpacity(0.2)),
      ),
    );
  }
}

// Data class for a single food particle using an image.
class FoodParticle {
  late double x, y, speed, rotation, rotationSpeed, size, opacity;
  late String imagePath;
  final Size bounds;
  final Random _random = Random();
  final List<String> _imagePaths;

  FoodParticle(this.bounds, this._imagePaths) {
    _reset();
  }

  void _reset() {
    x = _random.nextDouble() * bounds.width;
    y = _random.nextDouble() * bounds.height;
    speed = _random.nextDouble() * 0.5 + 0.2;
    rotation = _random.nextDouble() * 2 * pi;
    rotationSpeed = (_random.nextDouble() - 0.5) * 0.01;
    size = _random.nextDouble() * 80 + 60;
    opacity = _random.nextDouble() * 0.4 + 0.2;
    imagePath = _imagePaths[_random.nextInt(_imagePaths.length)];
  }

  void update() {
    y -= speed;
    rotation += rotationSpeed;
    if (y < -size) {
      y = bounds.height + size;
      x = _random.nextDouble() * bounds.width;
    }
  }
}
