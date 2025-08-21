import 'dart:math';

import 'package:flutter/material.dart';

import 'LoginForm.dart';
import 'SignupForm.dart';

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
                                      ? Transform(
                                          // Flips the back panel
                                          transform: Matrix4.identity()
                                            ..rotateY(pi),
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
            ? LoginForm(onFlip: _flipCard)
            : SignupForm(onFlip: _flipCard),
      ),
    );
  }
}

// --- LOGIN FORM WIDGET ---

// --- COMMON HELPER WIDGETS ---

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
