import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import 'dashboard_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final ApiService _api = ApiService();
  final AuthService _auth = AuthService();

  @override
  void initState() {
    super.initState();
    _checkBiometricLogin();
  }

  Future<void> _checkBiometricLogin() async {
    bool enabled = await _auth.isBiometricEnabled();
    if (enabled) {
      bool authenticated = await _auth.authenticateWithBiometrics();
      if (authenticated) {
        // In a real app, you'd silently login with stored credentials or token
        // For now, we'll just navigate if auth succeeds (assuming token is valid)
        if (mounted) {
           Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
        }
      }
    }
  }

  Future<void> _handleLogin() async {
    setState(() => _isLoading = true);
    
    // Call API
    final result = await _api.login(
      _emailController.text, 
      _passwordController.text, 
      '' // No 2FA code handling in this basic UI yet
    );

    setState(() => _isLoading = false);

    if (result['success'] == true) {
       if (context.mounted) {
         // Ask to enable biometrics if supported
         bool canBio = await _auth.isBiometricAvailable();
         if (canBio) {
            // Show dialog... skipped for brevity, auto-enabling for demo
            await _auth.enableBiometricLogin(true);
         }
         Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const DashboardScreen()));
       }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? 'Login failed'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030508), // Brand Dark
      body: Stack(
        children: [
          // Background Grid
          Positioned.fill(
            child: Opacity(
              opacity: 0.1,
              child: Image.asset('assets/images/grid_bg.png', repeat: ImageRepeat.repeat),
            ),
          ),
          
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo Placeholder
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1), // Brand Primary
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.5), blurRadius: 20)]
                    ),
                    child: const Icon(Icons.swap_horiz, color: Colors.white, size: 40),
                  ).animate().scale(duration: 500.ms),
                  
                  const SizedBox(height: 24),
                  Text(
                    'Welcome Back',
                    style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  Text(
                    'Securely access your wallet',
                    style: GoogleFonts.outfit(fontSize: 16, color: Colors.white54),
                  ),
                  
                  const SizedBox(height: 40),
                  
                  // Inputs
                  _buildTextField(controller: _emailController, hint: 'Email', icon: Icons.email),
                  const SizedBox(height: 16),
                  _buildTextField(controller: _passwordController, hint: 'Password', icon: Icons.lock, isObscure: true),
                  
                  const SizedBox(height: 30),
                  
                  // Button
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                        shadowColor: const Color(0xFF6366F1).withOpacity(0.5),
                      ),
                      child: _isLoading 
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text('INITIALIZE SESSION', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, letterSpacing: 1.5)),
                    ),
                  ),
                  
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                       TextButton.icon(
                        onPressed: _checkBiometricLogin,
                        icon: const Icon(Icons.fingerprint, color: Color(0xFFEC4899)), 
                        label: Text('Biometrics', style: GoogleFonts.outfit(color: Colors.white70)),
                      ),
                      const SizedBox(width: 8),
                      Container(width: 1, height: 20, color: Colors.white24),
                      const SizedBox(width: 8),
                      TextButton(
                        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                        child: Text('Create Account', style: GoogleFonts.outfit(color: Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                      )
                    ],
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller, required String hint, required IconData icon, bool isObscure = false}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: TextField(
        controller: controller,
        obscureText: isObscure,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          border: InputBorder.none,
          prefixIcon: Icon(icon, color: Colors.white54),
          hintText: hint,
          hintStyle: const TextStyle(color: Colors.white30),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
