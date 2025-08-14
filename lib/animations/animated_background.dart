import 'dart:math';
import 'package:flutter/material.dart';

// An enum to determine if the particle is a standard Icon or a custom Image
enum ParticleType { icon, image }

// This class defines the state and behavior of a single animated particle.
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
    if (totalSources == 0) return;

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
      _reset();
      y = bounds.height + size;
    }
  }

  Widget build(BuildContext context) {
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


// This is the main widget that creates and manages the background animation.
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> with SingleTickerProviderStateMixin {
  late AnimationController _backgroundAnimationController;
  final List<HybridFoodParticle> _particles = [];

  // Define the icons and images for the animation here
  final List<IconData> _foodIcons = [
    // Icons.local_cafe,
    // Icons.lunch_dining,
    // Icons.ramen_dining,
    // Icons.food_bank_outlined,
    // Icons.cake,
    // Icons.fastfood,
  ];

  final List<String> _indianFoodImagePaths = [
    'assets/food_icons/icon1.png',
    'assets/food_icons/icon2.png',
    'assets/food_icons/icon3.png',
    'assets/food_icons/icon4.png',
  ];

  @override
  void initState() {
    super.initState();
    _backgroundAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final size = MediaQuery.of(context).size;
      setState(() {
        for (int i = 0; i < 50; i++) {
          _particles.add(HybridFoodParticle(size, _foodIcons, _indianFoodImagePaths));
        }
      });
    });
  }

  @override
  void dispose() {
    _backgroundAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _backgroundAnimationController,
      builder: (context, child) {
        for (var particle in _particles) {
          particle.update();
        }
        return Stack(
          children: _particles.map((p) => p.build(context)).toList(),
        );
      },
    );
  }
}
