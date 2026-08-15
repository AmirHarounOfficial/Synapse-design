import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/di/service_locator.dart';
import '../../../core/theme/app_colors.dart';
import '../data/auth_repository.dart';

/// Ported from `Splash.tsx`. Centered wordmark + tagline + three pulsing dots.
/// Also acts as the startup session guard: if a saved token validates against
/// `/auth/me`, jump straight to the user's role home; otherwise go to login.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _controller =
      AnimationController(vsync: this, duration: const Duration(milliseconds: 1000))..repeat();

  @override
  void initState() {
    super.initState();
    _decideStart();
  }

  Future<void> _decideStart() async {
    final auth = sl<AuthRepository>();
    // Keep the splash visible briefly for a smooth launch.
    final minDelay = Future<void>.delayed(const Duration(milliseconds: 700));

    if (!auth.isLoggedIn) {
      await minDelay;
      if (mounted) context.go('/login');
      return;
    }
    try {
      final user = await auth.me();
      await minDelay;
      if (mounted) context.go(user.homeRoute);
    } catch (_) {
      // Invalid/expired token (interceptor clears it) or offline → sign in again.
      await minDelay;
      if (mounted) context.go('/login');
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: SchooKeepColors.surface,
      child: Column(
        children: [
          const SizedBox(height: 44),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'SchooKeep',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.w500, color: SchooKeepColors.primary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Smart School Health',
                  style: TextStyle(fontSize: 16, color: SchooKeepColors.textSecondary),
                ),
                const SizedBox(height: 128),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (i) => _Dot(controller: _controller, delayMs: i * 200)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 44),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot({required this.controller, required this.delayMs});
  final AnimationController controller;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final begin = delayMs / 1000.0;
    final animation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.4, end: 1.0), weight: 50),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.4), weight: 50),
    ]).animate(
      CurvedAnimation(parent: controller, curve: Interval(begin, 1.0, curve: Curves.easeInOut)),
    );
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: FadeTransition(
        opacity: animation,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(color: SchooKeepColors.primary, shape: BoxShape.circle),
        ),
      ),
    );
  }
}
