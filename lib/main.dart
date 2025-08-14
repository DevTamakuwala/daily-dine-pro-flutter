import 'dart:math';
import 'package:dailydine/Screens/Auth/LoginForm.dart';
import 'package:dailydine/Screens/Auth/SignupForm.dart';
import 'package:flutter/material.dart';
// Note: You might need to create these widget files if they don't exist
// import 'package:dailydine/widgets/BuildFlipButton.dart';
// import 'package:dailydine/widgets/BuildSubmitButton.dart';
// import 'package:dailydine/widgets/BuildTextFormField.dart';

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
      title: 'Daily Dine ',
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

// The main screen holding the flippable card and background
class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _cardFlipController;
  late Animation<double> _cardFlipAnimation;
  late AnimationController _backgroundAnimationController;

  final List<HybridFoodParticle> _particles = []; // Use the new Hybrid class
  bool _isLogin = true;

  // --- MODIFICATION START ---

  // 1. List of standard material icons
  final List<IconData> _foodIcons = [
    Icons.local_cafe,
    Icons.lunch_dining,
    Icons.ramen_dining,
    Icons.food_bank_outlined,
  ];

  // 2. List of custom Indian food image assets
  final List<String> _indianFoodImagePaths = [
    'assets/food_icons/icon1.png',
    'assets/food_icons/icon2.png',
    'assets/food_icons/icon3.png',
  ];

  // --- MODIFICATION END ---


  @override
  void initState() {
    super.initState();
    _cardFlipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _cardFlipAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _cardFlipController, curve: Curves.easeInOutCubic));
    _backgroundAnimationController = AnimationController(vsync: this, duration: const Duration(seconds: 25))..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        _particles.clear();
        for (int i = 0; i < 50; i++) {
          // --- MODIFICATION ---
          // Pass both lists to the new hybrid particle constructor
          _particles.add(HybridFoodParticle(size, _foodIcons, _indianFoodImagePaths));
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
    setState(() { _isLogin = !_isLogin; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
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
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(height: 100, child: Image.asset('assets/DailyDinePro.png')),
                      const SizedBox(height: 20),
                      AnimatedBuilder(
                        animation: _cardFlipAnimation,
                        builder: (context, child) {
                          final angle = _cardFlipAnimation.value * -pi;
                          final transform = Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle);
                          return Transform(
                            transform: transform,
                            alignment: Alignment.center,
                            child: _cardFlipAnimation.value >= 0.5
                                ? Transform(
                              transform: Matrix4.identity()..rotateY(pi),
                              alignment: Alignment.center,
                              child: _buildAuthCard(isLogin: false),
                            )
                                : _buildAuthCard(isLogin: true),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard({required bool isLogin}) {
    return Card(
      elevation: 12,
      shadowColor: Colors.black.withOpacity(0.4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: double.infinity,
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: Colors.white.withOpacity(0.95)),
        child: isLogin ? LoginForm(onFlip: _flipCard) : SignupForm(onFlip: _flipCard),
      ),
    );
  }
}

// --- NEW HYBRID PARTICLE CLASS ---

// An enum to determine if the particle is a standard Icon or a custom Image
enum ParticleType { icon, image }

class HybridFoodParticle {
  // Common properties
  late double x, y, speed, rotation, rotationSpeed, size, opacity;
  final Size bounds;
  final Random _random = Random();

  // Type-specific properties
  late ParticleType type;
  IconData? icon; // Nullable: only used if type is 'icon'
  String? imagePath; // Nullable: only used if type is 'image'
  Color? color; // Nullable: only used if type is 'icon'

  // Source lists
  final List<IconData> _icons;
  final List<String> _imagePaths;

  // Colors for the standard icons
  final List<Color> _colors = [
    Colors.orange, Colors.green, Colors.red, Colors.blue, Colors.yellow, Colors.purple, Colors.brown,
  ];

  HybridFoodParticle(this.bounds, this._icons, this._imagePaths) {
    _reset();
  }

  void _reset() {
    final totalSources = _icons.length + _imagePaths.length;
    final randomIndex = _random.nextInt(totalSources);

    if (randomIndex < _icons.length) {
      // Create an ICON particle
      type = ParticleType.icon;
      icon = _icons[randomIndex];
      imagePath = null;
      color = _colors[_random.nextInt(_colors.length)];
      opacity = _random.nextDouble() * 0.6 + 0.3;
      size = _random.nextDouble() * 30 + 20; // Smaller size for icons
    } else {
      // Create an IMAGE particle
      type = ParticleType.image;
      imagePath = _imagePaths[randomIndex - _icons.length];
      icon = null;
      color = null; // Color is not needed for image assets
      opacity = _random.nextDouble() * 0.5 + 0.4; // Slightly less transparent for images
      size = _random.nextDouble() * 40 + 30; // Larger size for images
    }

    // Reset common physics properties
    x = _random.nextDouble() * bounds.width;
    y = _random.nextDouble() * bounds.height;
    speed = _random.nextDouble() * 0.5 + 0.2;
    rotation = _random.nextDouble() * 2 * pi;
    rotationSpeed = (_random.nextDouble() - 0.5) * 0.01;
  }

  void update() {
    y -= speed;
    rotation += rotationSpeed;
    if (y < -size) {
      // Reset particle when it goes off-screen, it will randomly become an icon or image again
      _reset();
      y = bounds.height + size; // Start just off the bottom of the screen
    }
  }

  Widget build(BuildContext context) {
    // Decide which widget to build based on the particle's type
    Widget particleWidget;
    if (type == ParticleType.icon) {
      particleWidget = Icon(
        icon!,
        size: size,
        color: color!.withOpacity(opacity),
      );
    } else {
      particleWidget = Opacity(
        opacity: opacity,
        child: Image.asset(
          imagePath!,
          width: size,
          height: size,
        ),
      );
    }

    return Positioned(
      left: x,
      top: y,
      child: Transform.rotate(
        angle: rotation,
        child: particleWidget,
      ),
    );
  }
}