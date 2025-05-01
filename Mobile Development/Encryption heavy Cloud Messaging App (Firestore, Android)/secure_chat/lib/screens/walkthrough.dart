import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg package

class WalkthroughScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Top Spacer to push everything down
            Spacer(flex: 1),

            // SVG Illustration (Centered and takes space)
            Expanded(
              flex: 3, // Takes 3/6 of available space
              child: SvgPicture.asset(
                "assets/undraw_mobile-encryption_flk2.svg",
                width: screenWidth * 0.6,
                fit: BoxFit.contain,
              ),
            ),

            SizedBox(height: 20), // Spacing between image and text

            // Title Text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Text(
                "Conversations privées, sécurisées.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0F1828),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Spacer(flex: 1), // Pushes the button down a bit

            // Start Button (Properly Spaced)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF4B00FA),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 16, horizontal: 40),
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/phone_verification');
                },
                child: Text(
                  "Démarrer la messagerie",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 15), // Space between button and text

            // Privacy Policy Text (Now visible and spaced correctly)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.1),
              child: Text(
                "Conditions et politique de confidentialité",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF0F1828),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            Spacer(flex: 2), // Pushes everything to take full screen space

            // Bottom Bar Indicator (Properly Positioned)
            Container(
              width: screenWidth * 0.4,
              height: 5,
              decoration: BoxDecoration(
                color: Color(0xFF0F1828),
                borderRadius: BorderRadius.circular(100),
              ),
            ),

            SizedBox(height: 20), // Extra space at bottom
          ],
        ),
      ),
    );
  }
}
