import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ComingSoonScreen extends StatelessWidget {
  const ComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Change to white for light mode
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gradient Title
            ShaderMask(
              shaderCallback: (bounds) => const LinearGradient(
                colors: [Colors.orangeAccent, Colors.redAccent],
              ).createShader(bounds),
              child: const Text(
                "Coming Soon!",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // Will be overridden by gradient
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Shimmer Subtitle
            Shimmer.fromColors(
              baseColor: Colors.grey.shade700,
              highlightColor: Colors.white,
              child: const Text(
                "Something exciting is on the way.\nStay tuned!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Countdown Timer
            _buildCountdownTimer(),

            const SizedBox(height: 30),

            // Notify Me Button
            GestureDetector(
              onTap: () {
                // Handle notification logic
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Colors.orangeAccent, Colors.redAccent],
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.orangeAccent.withOpacity(0.6),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Text(
                  "Notify Me!",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Countdown Timer UI
  Widget _buildCountdownTimer() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildTimerBox("10", "Days"),
        const SizedBox(width: 10),
        _buildTimerBox("05", "Hours"),
        const SizedBox(width: 10),
        _buildTimerBox("30", "Min"),
        const SizedBox(width: 10),
        _buildTimerBox("50", "Sec"),
      ],
    );
  }

  Widget _buildTimerBox(String value, String label) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.grey[900]!.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orangeAccent, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.orangeAccent.withOpacity(0.5),
                blurRadius: 8,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.orangeAccent,
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}
