import 'dart:math';
import 'package:flutter/material.dart';

// This class defines the state and behavior of a single animated particle.
class FoodParticle {
  late double x, y, speed, rotation, rotationSpeed;
  late Color fillColor;
  late Color strokeColor;
  late int type; // 0 for Samosa, 1 for Dosa, 2 for Idli
  final Size bounds;
  final Random _random = Random();

  FoodParticle(this.bounds) {
    _reset();
  }

  // Resets the particle's properties to a new random state.
  void _reset() {
    x = _random.nextDouble() * bounds.width;
    y = _random.nextDouble() * bounds.height;
    speed = _random.nextDouble() * 0.8 + 0.2;
    rotation = _random.nextDouble() * 2 * pi;
    rotationSpeed = (_random.nextDouble() - 0.5) * 0.02;
    type = _random.nextInt(3);

    // Assign colors based on the food type.
    switch(type) {
      case 0: // Samosa
        fillColor = const Color(0xFFF0E4C8).withOpacity(0.7);
        strokeColor = const Color(0xFFC88B48).withOpacity(0.9);
        break;
      case 1: // Dosa
        fillColor = const Color(0xFFF5DDBA).withOpacity(0.7);
        strokeColor = const Color(0xFFD98242).withOpacity(0.9);
        break;
      case 2: // Idli
        fillColor = const Color(0xFFFFFFFF).withOpacity(0.7);
        strokeColor = const Color(0xFFD0D0D0).withOpacity(0.9);
        break;
    }
  }

  // Updates the particle's position and rotation for each frame of the animation.
  void update() {
    y -= speed;
    rotation += rotationSpeed;
    // If the particle goes off the top of the screen, reset it to the bottom.
    if (y < -25) {
      y = bounds.height + 25;
      x = _random.nextDouble() * bounds.width;
    }
  }
}