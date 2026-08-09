import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _scale = Tween<double>(begin: 0.8, end: 1.0)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));
    _opacity = CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.6, curve: Curves.easeOut));

    _controller.forward();
    Future.delayed(const Duration(milliseconds: 1600), () {
      if (mounted) context.go('/');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [BrandColors.primaryDark, BrandColors.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) => Opacity(
              opacity: _opacity.value,
              child: Transform.scale(scale: _scale.value, child: child),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset('assets/splash/splash_logo.png', width: 160),
                const SizedBox(height: 24),
                const Text(
                  'Blue Arrow',
                  style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  'Management Consultants',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, letterSpacing: 1.2),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
