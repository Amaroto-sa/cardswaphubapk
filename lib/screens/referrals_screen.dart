import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';

class ReferralsScreen extends StatefulWidget {
  const ReferralsScreen({super.key});

  @override
  State<ReferralsScreen> createState() => _ReferralsScreenState();
}

class _ReferralsScreenState extends State<ReferralsScreen> {
  final ApiService _api = ApiService();
  late Future<Map<String, dynamic>> _referralFuture;

  @override
  void initState() {
    super.initState();
    _referralFuture = _api.getReferrals();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030508),
      appBar: AppBar(
        title: Text('Refer & Earn', style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _referralFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
          }

          final data = snapshot.data?['data'];
          final code = data?['referral_code'] ?? '...';
          final stats = data?['stats'];
          final referrals = data?['recent_referrals'] as List? ?? [];

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)]),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.card_giftcard, size: 48, color: Colors.white),
                      const SizedBox(height: 16),
                      Text(
                        '${stats?['total_earnings'] ?? 0} Points',
                        style: GoogleFonts.outfit(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      Text(
                        'Total Earned from ${stats?['total_referrals'] ?? 0} Invites',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.spaceGrotesk(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                
                Text('Your Referral Code', style: GoogleFonts.spaceGrotesk(color: Colors.white54)),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code));
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied to clipboard!')));
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          code,
                          style: GoogleFonts.robotoMono(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                        ), 
                        const Icon(Icons.copy, color: Color(0xFF6366F1)),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 40),
                Text('Recent Referrals', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                const SizedBox(height: 16),
                
                if (referrals.isEmpty) 
                  Container(
                    padding: const EdgeInsets.all(32),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        const Icon(Icons.people_outline, size: 40, color: Colors.white24),
                        const SizedBox(height: 8),
                        Text('No referrals yet', style: GoogleFonts.spaceGrotesk(color: Colors.white30)),
                      ],
                    ),
                  )
                else
                  ...referrals.map((r) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: Colors.white10,
                      child: Text(
                        (r['first_name'] as String?)?.isNotEmpty == true ? (r['first_name'][0]) : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(r['first_name'] ?? '', style: GoogleFonts.outfit(color: Colors.white)),
                    subtitle: Text(
                      r['email_verified'] == 1 ? 'Verified' : 'Pending',
                      style: TextStyle(
                        color: r['email_verified'] == 1 ? Colors.green : Colors.orange,
                        fontSize: 10,
                      ),
                    ),
                    trailing: Text('+${r['reward_points_awarded']} pts', style: GoogleFonts.spaceGrotesk(color: Colors.greenAccent)),
                  )).toList()
              ],
            ),
          );
        }
      ),
    );
  }
}
