import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import 'login_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService auth = AuthService();

    return Scaffold(
      backgroundColor: const Color(0xFF030508),
      appBar: AppBar(
        title: Text('My Profile', style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Header
            Center(
              child: Column(
                children: [
                   CircleAvatar(
                     radius: 50,
                     backgroundColor: const Color(0xFF6366F1),
                     child: Text('JD', style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                   ),
                   const SizedBox(height: 16),
                   Text('John Doe', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white)),
                   Text('john.doe@example.com', style: GoogleFonts.spaceGrotesk(color: Colors.white54)),
                   const SizedBox(height: 8),
                   Container(
                     padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                     decoration: BoxDecoration(
                       color: Colors.green.withOpacity(0.1),
                       borderRadius: BorderRadius.circular(20),
                       border: Border.all(color: Colors.green.withOpacity(0.2))
                     ),
                     child: Text('Verified User', style: GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.green)),
                   )
                ],
              ),
            ),
            
            const SizedBox(height: 40),
            
            // Settings List
            _buildSettingItem(Icons.security, 'Security', '2FA, Password Change'),
            _buildSettingItem(Icons.account_balance, 'Bank Accounts', 'Manage saved accounts'),
            _buildSettingItem(Icons.notifications_outlined, 'Notifications', 'App alerts'),
            _buildSettingItem(Icons.help_outline, 'Help & Support', 'FAQ, Chat with us'),
            
            const SizedBox(height: 40),
            
            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () async {
                   await auth.logout();
                   if (context.mounted) {
                      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const LoginScreen()), (route) => false);
                   }
                },
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.red.withOpacity(0.1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: Text('Log Out', style: GoogleFonts.spaceGrotesk(color: Colors.red, fontWeight: FontWeight.bold)),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: Icon(icon, color: Colors.white70),
        title: Text(title, style: GoogleFonts.outfit(color: Colors.white)),
        subtitle: Text(subtitle, style: GoogleFonts.spaceGrotesk(color: Colors.white30, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right, color: Colors.white30),
        onTap: () {},
      ),
    );
  }
}
