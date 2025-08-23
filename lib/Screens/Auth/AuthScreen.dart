import 'dart:math';
import 'package:dailydine/animations/animated_background.dart';
import 'package:flutter/material.dart';
import 'LoginForm.dart';
import 'SignupForm.dart';

class AuthScreen extends StatefulWidget {
  final Size screenSize;

  const AuthScreen({super.key, required this.screenSize});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  late AnimationController _cardFlipController;
  late Animation<double> _cardFlipAnimation;
  late AnimationController _backgroundAnimationController;

  bool _isLogin = true;

  @override
  void initState() {
    super.initState();

    _cardFlipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _cardFlipAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _cardFlipController, curve: Curves.easeInOutCubic));
    _backgroundAnimationController = AnimationController(vsync: this, duration: const Duration(seconds: 25))..repeat();
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
    // 4. The build method is now much cleaner
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          AnimatedBackground(),
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
                                ? Transform(transform: Matrix4.identity()..rotateY(pi), alignment: Alignment.center, child: _buildAuthCard(isLogin: false))
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
    // ... (This method remains unchanged)
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