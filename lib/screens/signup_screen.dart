import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmPassCtrl = TextEditingController();
  final _fNameCtrl = TextEditingController();
  final _lNameCtrl = TextEditingController();
  final _referralCtrl = TextEditingController();
  
  bool _isLoading = false;
  final ApiService _api = ApiService();

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    final result = await _api.register({
      'email': _emailCtrl.text,
      'password': _passCtrl.text,
      'first_name': _fNameCtrl.text,
      'last_name': _lNameCtrl.text,
      'referral_code': _referralCtrl.text
    });
    
    setState(() => _isLoading = false);
    
    if (!mounted) return;

    if (result['success'] == true) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          title: Text('Success', style: GoogleFonts.outfit(color: Colors.white)),
          content: Text('Account created! Please check your email to verify.', style: GoogleFonts.spaceGrotesk(color: Colors.white70)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
              },
              child: const Text('Login Now'),
            )
          ],
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Registration failed'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030508),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Create Account', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
              Text('Join the trading revolution today.', style: GoogleFonts.spaceGrotesk(color: Colors.white54)),
              const SizedBox(height: 32),
              
              Row(
                children: [
                  Expanded(child: _buildInput(_fNameCtrl, 'First Name', Icons.person)),
                  const SizedBox(width: 12),
                  Expanded(child: _buildInput(_lNameCtrl, 'Last Name', Icons.person_outline)),
                ],
              ),
              const SizedBox(height: 16),
              _buildInput(_emailCtrl, 'Email Address', Icons.email, type: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildInput(_passCtrl, 'Password', Icons.lock, isObscure: true),
              const SizedBox(height: 16),
              _buildInput(_confirmPassCtrl, 'Confirm Password', Icons.lock_clock, isObscure: true, validator: (val) {
                if (val != _passCtrl.text) return 'Passwords do not match';
                return null;
              }),
              const SizedBox(height: 16),
              _buildInput(_referralCtrl, 'Referral Code (Optional)', Icons.tag, isOptional: true),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignup,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text('Create Account', style: GoogleFonts.spaceGrotesk(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
              
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account?', style: GoogleFonts.outfit(color: Colors.white54)),
                  TextButton(
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                    child: Text('Login', style: GoogleFonts.outfit(color: const Color(0xFF6366F1), fontWeight: FontWeight.bold)),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput(TextEditingController ctrl, String hint, IconData icon, {
    bool isObscure = false, 
    TextInputType type = TextInputType.text,
    bool isOptional = false,
    String? Function(String?)? validator
  }) {
    return TextFormField(
      controller: ctrl,
      obscureText: isObscure,
      keyboardType: type,
      style: const TextStyle(color: Colors.white),
      validator: isOptional ? null : (val) {
        if (val == null || val.isEmpty) return 'Required';
        if (validator != null) return validator(val);
        return null;
      },
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.white24),
        prefixIcon: Icon(icon, color: Colors.white54),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.all(16),
      ),
    );
  }
}
