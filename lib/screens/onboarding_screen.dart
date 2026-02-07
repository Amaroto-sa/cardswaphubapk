import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'login_screen.dart';
import 'signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Trade Gift Cards',
      'subtitle': 'Exchange your gift cards for cash instantly with the best market rates.',
      'icon': 'assets/images/onboarding_1.png' // Placeholder assets
    },
    {
      'title': 'Pay Bills Easily',
      'subtitle': 'Settle utility bills, airtime, and data subscriptions in seconds.',
      'icon': 'assets/images/onboarding_2.png'
    },
    {
      'title': 'Secure Wallet',
      'subtitle': 'Your funds are protected with bank-grade security and biometrics.',
      'icon': 'assets/images/onboarding_3.png'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030508),
      body: Stack(
        children: [
          // Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF030508), Color(0xFF0F172A)],
                ),
              ),
            ),
          ),
          
          SafeArea(
            child: Column(
              children: [
                // Top Skip
                Align(
                  alignment: Alignment.topRight,
                  child: TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: Text('Skip', style: GoogleFonts.outfit(color: Colors.white54)),
                  ),
                ),

                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (idx) => setState(() => _currentPage = idx),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.all(32.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 280, height: 280,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFF6366F1).withOpacity(0.1),
                                border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.2)),
                              ),
                              child: Center(
                                child: Icon(
                                  index == 0 ? Icons.card_giftcard : index == 1 ? Icons.payments : Icons.security,
                                  size: 100,
                                  color: const Color(0xFF6366F1),
                                ),
                              ),
                            ).animate().scale(duration: 600.ms, curve: Curves.easeOutBack),
                            const SizedBox(height: 40),
                            Text(
                              _pages[index]['title']!,
                              style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn().slideY(begin: 0.3, end: 0, delay: 200.ms),
                            const SizedBox(height: 16),
                            Text(
                              _pages[index]['subtitle']!,
                              style: GoogleFonts.spaceGrotesk(fontSize: 16, color: Colors.white60, height: 1.5),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn().slideY(begin: 0.3, end: 0, delay: 300.ms),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // Indicators & Buttons
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          _pages.length,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: _currentPage == index ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: _currentPage == index ? const Color(0xFFEC4899) : Colors.white24,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      if (_currentPage == _pages.length - 1)
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF6366F1),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 8,
                            ),
                            child: Text('Get Started', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold)),
                          ),
                        ).animate().fadeIn().scale()
                      else
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => _controller.previousPage(duration: 300.ms, curve: Curves.easeOut),
                              child: Text(_currentPage > 0 ? 'Back' : '', style: GoogleFonts.outfit(color: Colors.white54)),
                            ),
                            IconButton(
                              onPressed: () => _controller.nextPage(duration: 300.ms, curve: Curves.easeOut),
                              style: IconButton.styleFrom(
                                backgroundColor: Colors.white10,
                                padding: const EdgeInsets.all(16),
                              ),
                              icon: const Icon(Icons.arrow_forward, color: Colors.white),
                            ),
                          ],
                        ),
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
}
