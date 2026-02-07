import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'submit_giftcard_screen.dart';
import 'bills_screen.dart';
import 'transactions_screen.dart';
import 'fund_account_screen.dart';
import 'withdraw_screen.dart';
import 'referrals_screen.dart';
import 'profile_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final ApiService _api = ApiService();
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final data = await _api.getDashboardData();
    if (mounted) {
      if (data['success'] == true) {
        setState(() {
          _userData = data['data']; // Assuming API structure returns 'data' wrapper
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
        // Show error...
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030508),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.wallet, color: Color(0xFF6366F1)),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('CardSwapHub', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('System Online', style: GoogleFonts.spaceGrotesk(fontSize: 10, color: Colors.greenAccent)),
              ],
            )
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen())),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)))
        : RefreshIndicator(
            onRefresh: _loadData,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Balance Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF6366F1), Color(0xFFEC4899)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(color: const Color(0xFF6366F1).withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 10))
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Balance', style: GoogleFonts.spaceGrotesk(color: Colors.white70, fontSize: 12, letterSpacing: 1.5)),
                        const SizedBox(height: 8),
                        Text(
                          '₦${_userData?['balance'] ?? '0.00'}',
                          style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            _buildActionButton(Icons.add, 'Fund', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const FundAccountScreen()))),
                            const SizedBox(width: 12),
                            _buildActionButton(Icons.arrow_upward, 'Withdraw', () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WithdrawScreen()))),
                            const SizedBox(width: 12),
                            Expanded(child: Container()), // Spacer
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.black26, borderRadius: BorderRadius.circular(20)
                              ),
                              child: Text('${_userData?['reward_points'] ?? 0} PTS', style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.bold, fontSize: 12)),
                            )
                          ],
                        )
                      ],
                    ),
                  ).animate().fadeIn().slideY(begin: 0.2, end: 0),

                  const SizedBox(height: 30),

                  // Quick Actions
                  Text('Quick Actions', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildQuickAction(Icons.card_giftcard, 'Sell Card', Colors.purpleAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SubmitGiftCardScreen()))),
                      _buildQuickAction(Icons.receipt_long, 'Pay Bills', Colors.orangeAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const BillsScreen()))),
                      _buildQuickAction(Icons.swap_calls, 'History', Colors.blueAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen()))),
                      _buildQuickAction(Icons.people, 'Referrals', Colors.greenAccent, () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ReferralsScreen()))),
                    ],
                  ),

                  const SizedBox(height: 30),
                  
                  // Recent Activity Placeholder
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Recent Activity', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                            Text('View All', style: GoogleFonts.outfit(color: const Color(0xFF6366F1), fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        // Empty State for demo
                        Center(
                          child: Column(
                            children: [
                              Icon(Icons.history, size: 48, color: Colors.white.withOpacity(0.2)),
                              const SizedBox(height: 8),
                              Text('No recent transactions', style: GoogleFonts.outfit(color: Colors.white30))
                            ],
                          ),
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildActionButton(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF6366F1), size: 16),
            const SizedBox(width: 8),
            Text(label, style: GoogleFonts.outfit(color: const Color(0xFF6366F1), fontWeight: FontWeight.bold))
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60, height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: color.withOpacity(0.2))
            ),
            child: Icon(icon, color: color),
          ),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.outfit(color: Colors.white70, fontSize: 12))
        ],
      ),
    );
  }
}
