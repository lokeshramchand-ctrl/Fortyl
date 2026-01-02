// ignore_for_file: deprecated_member_use

import 'package:aegis_mobile/Screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'dart:ui';


class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF030507),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // 1. Atmospheric Depth (Soft Ambient Glows)
          Positioned(
            top: size.height * 0.1,
            child: Container(
              width: size.width * 1.2,
              height: size.height * 0.4,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFF0D9488).withOpacity(0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          
          // 2. Main Content Stack
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Hero Branding Section
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // The "Vault" Icon Container
                    _buildPremiumLogo(),
                    
                    const SizedBox(height: 48),
                    
                    // Ultra-refined Typography
                    const Text(
                      'AEGIS',
                      style: TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.w200, // Thinner weight for elegance
                        letterSpacing: 16.0,
                        color: Colors.white,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    Text(
                      'VERIFIED BY DESIGN',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 4.0,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ],
                ),

                const Spacer(flex: 3),

                // 3. Minimalist Action Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 40),
                  child: Column(
                    children: [
                      _buildPrimaryButton(context),
                      const SizedBox(height: 24),
                      _buildSecondaryButton(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiumLogo() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Halo
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                const Color(0xFF14B8A6).withOpacity(0.1),
                Colors.transparent,
              ],
            ),
          ),
        ),
        // Glassmorphic Shield Base
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0F18).withOpacity(0.6),
            borderRadius: BorderRadius.circular(32),
            border: Border.all(
              color: Colors.white.withOpacity(0.08),
              width: 1.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(32),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: const Center(
                child: Icon(
                  Icons.shield_rounded,
                  size: 40,
                  color: Color(0xFF2DD4BF),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrimaryButton(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white, // Inverted for high-end contrast
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.1),
            blurRadius: 30,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          // Navigate to the next onboarding step or main app
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const HomeScreen()),
  );
          },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text(
          'Get Started',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton() {
    return TextButton(
      onPressed: () {},
      style: TextButton.styleFrom(
        foregroundColor: Colors.white.withOpacity(0.4),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Learn More',
            style: TextStyle(
              fontSize: 13,
              letterSpacing: 1.0,
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(width: 4),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16),
        ],
      ),
    );
  }
}