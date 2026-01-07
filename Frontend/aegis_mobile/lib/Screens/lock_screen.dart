// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

// Internal imports
import 'package:aegis_mobile/Screens/home_screen.dart';
import 'package:aegis_mobile/core/service/auth_service.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
    );

    _blurAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutQuart),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 1.1, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 1.0, curve: Curves.easeOutQuart),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _handleUnlock(BuildContext context) async {
    // Mechanical-grade haptic feedback
    HapticFeedback.heavyImpact();

    bool authenticated = await AuthService.authenticate();

    if (authenticated && context.mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 1000),
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Premium Sage Palette: Sophisticated, secure, and modern
    const Color sageGreen = Color(0xFF30D158); 
    const Color backgroundBlack = Colors.black;

    return Scaffold(
      backgroundColor: backgroundBlack,
      body: Stack(
        children: [
          // Background Aura (Ultra-soft depth glow)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Center(
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          sageGreen.withOpacity(0.05 * _fadeAnimation.value),
                          sageGreen.withOpacity(0.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          // Main Centered Content
          Positioned.fill(
            child: SafeArea(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return ImageFiltered(
                    imageFilter: ImageFilter.blur(
                      sigmaX: _blurAnimation.value,
                      sigmaY: _blurAnimation.value,
                    ),
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: ScaleTransition(
                        scale: _scaleAnimation,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Glassmorphic Biometric Unit
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer Pulsating Halo
                          TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0.8, end: 1.2),
                            duration: const Duration(seconds: 4),
                            curve: Curves.easeInOut,
                            builder: (context, value, child) {
                              return Container(
                                width: 140 * value,
                                height: 140 * value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: sageGreen.withOpacity(0.05 / value),
                                    width: 1.0,
                                  ),
                                ),
                              );
                            },
                          ),
                          // Inner Glass Shield
                          Container(
                            width: 100,
                            height: 100,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.03),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.08),
                                width: 0.5,
                              ),
                            ),
                            child: ClipOval(
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                child: const Icon(
                                  Icons.face,
                                  size: 48,
                                  color: sageGreen,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 56),

                      // Premium Typography
                      Text(
                        "Vault Locked",
                        style: GoogleFonts.inter(
                          fontSize: 32,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -1.2,
                        ),
                      ),

                      const SizedBox(height: 12),

                      Text(
                        "Secure Authentication Required",
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.3),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.5,
                        ),
                      ),

                      const SizedBox(height: 80),

                      // Refined Glass Button
                      _PremiumGlassButton(
                        onPressed: () => _handleUnlock(context),
                        label: "Unlock",
                        color: sageGreen,
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
}

class _PremiumGlassButton extends StatefulWidget {
  final VoidCallback onPressed;
  final String label;
  final Color color;

  const _PremiumGlassButton({
    required this.onPressed,
    required this.label,
    required this.color,
  });

  @override
  State<_PremiumGlassButton> createState() => _PremiumGlassButtonState();
}

class _PremiumGlassButtonState extends State<_PremiumGlassButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onPressed,
      child: AnimatedScale(
        scale: _isPressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          width: 160,
          height: 56,
          decoration: BoxDecoration(
            color: widget.color,
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: widget.color.withOpacity(0.25),
                blurRadius: 25,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: Text(
              widget.label,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.white,
                letterSpacing: 0.2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}