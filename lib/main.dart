import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: DotLoadingAnimation(),
    );
  }
}

class DotLoadingAnimation extends StatefulWidget {
  const DotLoadingAnimation({super.key});

  @override
  State<DotLoadingAnimation> createState() => _DotLoadingAnimationState();
}

class _DotLoadingAnimationState extends State<DotLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final double spacing = 23.0;
  final double dotSize = 13.0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1300),
    );
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);
    _controller.forward();
    _controller.addListener(() {
      if (_controller.isCompleted) {
        _controller.reset();
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Offset _getArcOffset(int from, int to, bool upward, double t) {
    final startX = from * spacing;
    final endX = to * spacing;

    final x = lerpDouble(startX, endX, t)!;
    double arcHeight = 15.0;

    // For odd dots
    if (from % 2 != 0) {
      arcHeight = 40.0;
    }

    // Use a sine wave for arc effect
    final y = upward ? -sin(pi * t) * arcHeight : sin(pi * t) * arcHeight;

    return Offset(x, y);
  }

  Widget _buildAnimatedDot(Color color, int from, int to, bool upward) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (_, child) {
        final offset = _getArcOffset(from, to, upward, _animation.value);
        // To check if the dot is going up or down
        bool up = true;
        if (from % 2 != 0) {
          up = false; // For odd dots it is going down
        }

        double t = sin(pi * _controller.value);

        // Upward arc dot
        double scaleUp = lerpDouble(1.0, 1.8, t)!;

        // Downward arc dot
        double scaleDown = lerpDouble(1.0, 1.4, t)!;
        return Positioned(
          left: offset.dx,
          top: 100 + offset.dy,
          child: Transform.scale(
            scale: up ? scaleUp : scaleDown,
            child: child!,
          ),
        );
      },
      child: Container(
        width: dotSize,
        height: dotSize,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 4 * spacing,
          height: 200,
          child: Stack(
            children: [
              _buildAnimatedDot(
                Colors.red,
                0,
                3,
                true,
              ), // 1st to 4th (upward arc)
              _buildAnimatedDot(
                Colors.green,
                1,
                2,
                true,
              ), // 2nd to 3rd (upward arc)
              _buildAnimatedDot(
                Colors.blue,
                2,
                1,
                false,
              ), // 3rd to 2nd (downward arc)
              _buildAnimatedDot(
                Colors.orange,
                3,
                0,
                false,
              ), // 4th to 1st (downward arc)
            ],
          ),
        ),
      ),
    );
  }
}
