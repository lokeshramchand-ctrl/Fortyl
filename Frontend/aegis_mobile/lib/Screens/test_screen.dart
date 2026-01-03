
import 'package:aegis_mobile/Screens/home_screen.dart';
import 'package:aegis_mobile/core/service/auth_service.dart';

import 'package:flutter/material.dart';

class LockScreen extends StatelessWidget {
  const LockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.blue),

            const SizedBox(height: 20),

            const Text(
              "App is Locked",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () async {
                bool authenticated = await AuthService.authenticate();

                if (authenticated && context.mounted) {
                  Navigator.pushReplacement(
                    context,

                    MaterialPageRoute(
                      builder: (context) => const HomeScreen(),
                    ),
                  );
                }
              },

              child: const Text("Unlock Now"),
            ),
          ],
        ),
      ),
    );
  }
}
