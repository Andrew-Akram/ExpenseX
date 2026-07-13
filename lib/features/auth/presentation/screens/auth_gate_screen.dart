import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


import '../providers/auth_provider.dart';

class AuthGateScreen extends ConsumerStatefulWidget {
  const AuthGateScreen({super.key});

  @override
  ConsumerState<AuthGateScreen> createState() => _AuthGateScreenState();
}

class _AuthGateScreenState extends ConsumerState<AuthGateScreen> {
  @override
  void initState() {
    super.initState();
    // Wait for exactly 3 seconds, then complete the splash screen
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        ref.read(authStateProvider.notifier).finishSplash();
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Image.asset(
          'assets/splash/Splash.png',
          fit: BoxFit.cover,
        )
            .animate()
            .fadeIn(duration: 800.ms)
            .scale(
              begin: const Offset(1.05, 1.05),
              end: const Offset(1.0, 1.0),
              duration: 1200.ms,
              curve: Curves.easeOutCubic,
            ),
      ),
    );
  }
}
