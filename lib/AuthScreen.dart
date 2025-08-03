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
      title: 'Daily Dine Pro',
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
      home: const AuthScreen(),
    );
  }
}

// Enum to define user types for the signup form
enum UserType { messOwner, customer }

// The main screen holding the flippable card and background
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _cardFlipController;
  late Animation<double> _cardFlipAnimation;
  late AnimationController _backgroundAnimationController;

  // State variables
  final List<FoodParticle> _particles = [];
  bool _isLogin = true;

  // List of image paths for the animation
  final List<String> _foodImagePaths = [
    'assets/food.png',
    'assets/food2.png',
    'assets/food3.jpg',
    'assets/food4.jpg',
  ];

  @override
  void initState() {
    super.initState();
    // Controller for the card flip animation
    _cardFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _cardFlipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _cardFlipController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Controller for the background animation
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 25),
    )..repeat();

    // Initialize background particles
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
    _cardFlipController.dispose();
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  void _flipCard() {
    if (_cardFlipController.isCompleted) {
      _cardFlipController.reverse();
    } else {
      _cardFlipController.forward();
    }
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // This prevents the UI from resizing when the keyboard appears, letting SingleChildScrollView handle it.
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Animated background
          AnimatedBuilder(
            animation: _backgroundAnimationController,
            builder: (context, child) {
              for (var particle in _particles) {
                particle.update();
              }
              return Stack(
                children: _particles.map((p) => p.build(context)).toList(),
              );
            },
          ),
          // Main content centered and scrollable
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: IntrinsicHeight(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Spacer(),
                            SizedBox(
                              height: 100,
                              child: Image.asset('assets/DailyDinePro.jpg'),
                            ),
                            const SizedBox(height: 20),
                            // The Flippable Card
                            AnimatedBuilder(
                              animation: _cardFlipAnimation,
                              builder: (context, child) {
                                final angle = _cardFlipAnimation.value * -pi;
                                final transform = Matrix4.identity()
                                  ..setEntry(3, 2, 0.001)
                                  ..rotateY(angle);
                                return Transform(
                                  transform: transform,
                                  alignment: Alignment.center,
                                  child: _cardFlipAnimation.value >= 0.5
                                      ? Transform( // Flips the back panel
                                    transform: Matrix4.identity()..rotateY(pi),
                                    alignment: Alignment.center,
                                    child: _buildAuthCard(isLogin: false),
                                  )
                                      : _buildAuthCard(isLogin: true),
                                );
                              },
                            ),
                            const Spacer(),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Builds the card UI for either login or signup
  Widget _buildAuthCard({required bool isLogin}) {
    return Card(
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withOpacity(0.95),
        ),
        child: isLogin
            ? _LoginForm(onFlip: _flipCard)
            : _SignupForm(onFlip: _flipCard),
      ),
    );
  }
}

// --- LOGIN FORM WIDGET ---
class _LoginForm extends StatelessWidget {
  final VoidCallback onFlip;
  _LoginForm({required this.onFlip});

  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('loginForm'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Welcome Back", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text("Log in to your account", style: TextStyle(color: Colors.grey.shade600)),
        const SizedBox(height: 24),
        _buildTextFormField(controller: _loginEmailController, label: "Email", icon: Icons.email_outlined),
        const SizedBox(height: 16),
        _buildTextFormField(controller: _loginPasswordController, label: "Password", icon: Icons.lock_outline, obscureText: true),
        const SizedBox(height: 24),
        _buildSubmitButton(label: "Login", onPressed: () {}),
        const SizedBox(height: 16),
        _buildFlipButton(label: "Don't have an account? Sign Up", onFlip: onFlip),
      ],
    );
  }
}

// --- SIGNUP FORM WIDGET ---
class _SignupForm extends StatefulWidget {
  final VoidCallback onFlip;
  const _SignupForm({required this.onFlip});

  @override
  State<_SignupForm> createState() => _SignupFormState();
}

class _SignupFormState extends State<_SignupForm> {
  // State and controllers from your provided UI
  final _messOwnerFormKey = GlobalKey<FormState>();
  final _customerFormKey = GlobalKey<FormState>();
  UserType _selectedUserType = UserType.messOwner;

  // Mess Owner Controllers
  final _messNameController = TextEditingController();
  final _ownerNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _ownerPasswordController = TextEditingController();
  final _ownerConfirmPasswordController = TextEditingController();

  // Customer Controllers
  final _customerNameController = TextEditingController();
  final _customerPasswordController = TextEditingController();
  final _customerConfirmPasswordController = TextEditingController();

  // Common Controllers
  final _signupPhoneController = TextEditingController();
  final _signupEmailController = TextEditingController();


  @override
  void dispose() {
    _messNameController.dispose();
    _ownerNameController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _signupPhoneController.dispose();
    _signupEmailController.dispose();
    _customerNameController.dispose();
    _ownerPasswordController.dispose();
    _ownerConfirmPasswordController.dispose();
    _customerPasswordController.dispose();
    _customerConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('signupForm'),
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Create Account", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        ToggleButtons(
          isSelected: [_selectedUserType == UserType.messOwner, _selectedUserType == UserType.customer],
          onPressed: (index) {
            setState(() {
              _selectedUserType = index == 0 ? UserType.messOwner : UserType.customer;
            });
          },
          borderRadius: BorderRadius.circular(8),
          selectedColor: Colors.white,
          fillColor: Colors.orange.shade700,
          color: Colors.orange.shade700,
          borderColor: Colors.orange.shade700,
          selectedBorderColor: Colors.orange.shade700,
          children: const [
            Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("Mess Owner")),
            Padding(padding: EdgeInsets.symmetric(horizontal: 12), child: Text("Customer")),
          ],
        ),
        const SizedBox(height: 16),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
          child: _selectedUserType == UserType.messOwner
              ? _buildMessOwnerSubForm()
              : _buildCustomerSubForm(),
        ),
        const SizedBox(height: 16),
        _buildFlipButton(label: "Already have an account? Login", onFlip: widget.onFlip),
      ],
    );
  }

  Widget _buildMessOwnerSubForm() {
    return Form(
      key: _messOwnerFormKey,
      child: Column(
        key: const ValueKey('messOwnerForm'),
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextFormField(controller: _messNameController, label: "Mess Name", icon: Icons.storefront, validator: (v) => v!.isEmpty ? "Mess Name is required" : null),
          const SizedBox(height: 12),
          _buildTextFormField(controller: _ownerNameController, label: "Owner's Full Name", icon: Icons.person_outline, validator: (v) => v!.isEmpty ? "Owner's Name is required" : null),
          const SizedBox(height: 12),
          _buildTextFormField(controller: _addressController, label: "Address", icon: Icons.location_on_outlined, validator: (v) => v!.isEmpty ? "Address is required" : null),
          const SizedBox(height: 12),
          _buildTextFormField(controller: _cityController, label: "City", icon: Icons.location_city, validator: (v) => v!.isEmpty ? "City is required" : null),
          const SizedBox(height: 12),
          _buildTextFormField(controller: _signupPhoneController, label: "Phone Number", icon: Icons.phone_outlined, keyboardType: TextInputType.phone, validator: (v) => v!.length < 10 ? "Enter a valid phone number" : null),
          const SizedBox(height: 12),
          _buildTextFormField(controller: _signupEmailController, label: "Email Address", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => !RegExp(r'\S+@\S+\.\S+').hasMatch(v!) ? "Enter a valid email" : null),
          const SizedBox(height: 12),
          _buildTextFormField(controller: _ownerPasswordController, label: "Password", icon: Icons.lock_outline, obscureText: true, validator: (v) => v!.length < 6 ? "Password must be at least 6 characters" : null),
          const SizedBox(height: 12),
          _buildTextFormField(controller: _ownerConfirmPasswordController, label: "Confirm Password", icon: Icons.lock_outline, obscureText: true, validator: (v) => v != _ownerPasswordController.text ? "Passwords do not match" : null),
          const SizedBox(height: 20),
          _buildSubmitButton(label: "Sign Up as Owner", onPressed: () {}),
        ],
      ),
    );
  }

  Widget _buildCustomerSubForm() {
    return Form(
      key: _customerFormKey,
      child: Column(
        key: const ValueKey('customerForm'),
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildTextFormField(controller: _customerNameController, label: "Full Name", icon: Icons.person_outline, validator: (v) => v!.isEmpty ? "Full Name is required" : null),
          const SizedBox(height: 12),
          _buildTextFormField(controller: _signupEmailController, label: "Email Address", icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, validator: (v) => !RegExp(r'\S+@\S+\.\S+').hasMatch(v!) ? "Enter a valid email" : null),
          const SizedBox(height: 12),
          _buildTextFormField(controller: _customerPasswordController, label: "Password", icon: Icons.lock_outline, obscureText: true, validator: (v) => v!.length < 6 ? "Password must be at least 6 characters" : null),
          const SizedBox(height: 12),
          _buildTextFormField(controller: _customerConfirmPasswordController, label: "Confirm Password", icon: Icons.lock_outline, obscureText: true, validator: (v) => v != _customerPasswordController.text ? "Passwords do not match" : null),
          const SizedBox(height: 20),
          _buildSubmitButton(label: "Sign Up as Customer", onPressed: () {}),
        ],
      ),
    );
  }
}

// --- COMMON HELPER WIDGETS ---

Widget _buildTextFormField({
  required TextEditingController controller,
  required String label,
  required IconData icon,
  bool obscureText = false,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    validator: validator,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
    ),
  );
}

Widget _buildSubmitButton({required String label, required VoidCallback onPressed}) {
  return SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.orange.shade700,
        foregroundColor: Colors.white,
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
    ),
  );
}

Widget _buildFlipButton({required String label, required VoidCallback onFlip}) {
  return TextButton(
    onPressed: onFlip,
    child: Text(label, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold)),
  );
}


// --- BACKGROUND PARTICLE ANIMATION ---

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

  Widget build(BuildContext context) {
    return Positioned(
      left: x,
      top: y,
      child: Transform.rotate(
        angle: rotation,
        child: Opacity(
          opacity: opacity,
          child: Image.asset(imagePath, width: size, height: size),
        ),
      ),
    );
  }
}
