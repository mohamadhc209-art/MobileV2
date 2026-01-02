import 'package:flutter/material.dart';
import 'home.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset("assets/success.jpeg", fit: BoxFit.cover),

          Container(color: Colors.black.withOpacity(0.4)),

          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Thanks for shopping\nfrom Mohammad Market",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              SizedBox(
                width: 220,
                height: 45,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                    );
                  },
                  child: const Text("Back to Home"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
