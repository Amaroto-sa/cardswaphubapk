import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../services/api_service.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final ApiService _api = ApiService();
  late Future<Map<String, dynamic>> _transactionsFuture;

  @override
  void initState() {
    super.initState();
    _transactionsFuture = _api.getTransactions();
  }

  Future<void> _refresh() async {
    setState(() {
      _transactionsFuture = _api.getTransactions();
    });
    await _transactionsFuture;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF030508),
      appBar: AppBar(
        title: Text('History', style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: const Color(0xFF6366F1),
        child: FutureBuilder<Map<String, dynamic>>(
          future: _transactionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator(color: Color(0xFF6366F1)));
            }
            
            if (snapshot.hasError) {
              return Center(child: Text('Error loading history', style: GoogleFonts.spaceGrotesk(color: Colors.red)));
            }

            final data = snapshot.data;
            if (data == null || data['success'] != true) {
               return Center(child: Text(data?['message'] ?? 'No transactions found', style: GoogleFonts.spaceGrotesk(color: Colors.white54)));
            }

            final List transactions = data['data']['transactions'] ?? [];

            if (transactions.isEmpty) {
               return Center(
                 child: Column(
                   mainAxisAlignment: MainAxisAlignment.center,
                   children: [
                     Icon(Icons.history, size: 60, color: Colors.white.withOpacity(0.2)),
                     const SizedBox(height: 16),
                     Text('No transactions yet', style: GoogleFonts.outfit(color: Colors.white30))
                   ],
                 ),
               );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(20),
              itemCount: transactions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final txn = transactions[index];
                final isCredit = txn['type'] == 'deposit' || txn['type'] == 'referral' || txn['type'] == 'refund';
                final amount = double.tryParse(txn['amount'].toString()) ?? 0.0;
                final date = DateTime.tryParse(txn['created_at']) ?? DateTime.now();
                
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isCredit ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isCredit ? Icons.arrow_downward : Icons.arrow_upward,
                          color: isCredit ? Colors.green : Colors.red,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              txn['description'] ?? txn['type'].toString().toUpperCase(),
                              style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold),
                              maxLines: 1, overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              DateFormat('MMM d, y • h:mm a').format(date),
                              style: GoogleFonts.spaceGrotesk(color: Colors.white54, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isCredit ? '+' : '-'}₦${amount.toStringAsFixed(2)}',
                            style: GoogleFonts.spaceGrotesk(
                              color: isCredit ? Colors.greenAccent : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            txn['status'],
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 10,
                              color: _getStatusColor(txn['status']),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed': return Colors.green;
      case 'pending': return Colors.orange;
      case 'failed': return Colors.red;
      default: return Colors.white54;
    }
  }
}
