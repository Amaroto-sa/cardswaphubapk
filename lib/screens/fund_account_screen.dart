import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/api_service.dart';

class FundAccountScreen extends StatefulWidget {
  const FundAccountScreen({super.key});

  @override
  State<FundAccountScreen> createState() => _FundAccountScreenState();
}

class _FundAccountScreenState extends State<FundAccountScreen> {
  final _amountCtrl = TextEditingController();
  String _selectedProvider = 'paystack';
  String _selectedMethod = 'card';
  bool _isLoading = false;
  final ApiService _api = ApiService();

  Future<void> _initiatePayment() async {
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount < 100) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimum amount is ₦100')));
      return;
    }

    setState(() => _isLoading = true);
    
    // In a real app, this would initialize the Paystack/Flutterwave SDK
    // Here we simulate the API call which returns the payment URL or SDK config
    final result = await _api.fundAccount(amount, _selectedProvider, _selectedMethod);

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success'] == true) {
        // Here you would launch the Webview or SDK
        // For this demo:
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Payment initialized! Redirecting...'), backgroundColor: Colors.green));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result['message'] ?? 'Error'), backgroundColor: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030508),
      appBar: AppBar(
        title: Text('Fund Wallet', style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF6366F1), Color(0xFF8B5CF6)]),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Text('Enter Amount', style: GoogleFonts.spaceGrotesk(color: Colors.white70)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    style: GoogleFonts.spaceGrotesk(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '₦0.00',
                      hintStyle: TextStyle(color: Colors.white30),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            Text('Payment Method', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
            const SizedBox(height: 16),
            
            _buildOption('Paystack', 'Card, Bank Transfer', 'paystack', Colors.green),
            const SizedBox(height: 12),
            _buildOption('Flutterwave', 'Card, USSD, Bank', 'flutterwave', Colors.orange),
            
            const SizedBox(height: 32),
            
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _initiatePayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Proceed to Pay', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOption(String title, String subtitle, String val, Color color) {
    bool isSelected = _selectedProvider == val;
    return GestureDetector(
      onTap: () => setState(() => _selectedProvider = val),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.white.withOpacity(0.05),
          border: Border.all(color: isSelected ? color : Colors.transparent),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(Icons.credit_card, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
                Text(subtitle, style: GoogleFonts.spaceGrotesk(fontSize: 12, color: Colors.white54)),
              ],
            ),
            const Spacer(),
            if (isSelected) Icon(Icons.check_circle, color: color),
          ],
        ),
      ),
    );
  }
}
