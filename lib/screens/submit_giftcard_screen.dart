import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/api_service.dart';

class SubmitGiftCardScreen extends StatefulWidget {
  const SubmitGiftCardScreen({super.key});

  @override
  State<SubmitGiftCardScreen> createState() => _SubmitGiftCardScreenState();
}

class _SubmitGiftCardScreenState extends State<SubmitGiftCardScreen> {
  final ApiService _api = ApiService();
  File? _imageFile;
  final _amountCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  String _selectedCurrency = 'USD';
  String? _selectedCardId;
  bool _isLoading = false;

  // Placeholder data - in real app would come from API
  final List<Map<String, dynamic>> _cardTypes = [
     {'id': '1', 'name': 'iTunes', 'color': Colors.black},
     {'id': '2', 'name': 'Amazon', 'color': Colors.orange},
     {'id': '3', 'name': 'Steam', 'color': Colors.blueGrey},
     {'id': '4', 'name': 'Google Play', 'color': Colors.blueAccent},
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _imageFile = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (_selectedCardId == null || _amountCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please fill all required fields')));
      return;
    }

    setState(() => _isLoading = true);

    final result = await _api.submitGiftCard({
      'gift_card_type_id': _selectedCardId,
      'currency': _selectedCurrency,
      'original_amount': _amountCtrl.text,
      'card_code': _codeCtrl.text,
      'is_custom': '0'
    }, _imageFile?.path);

    setState(() => _isLoading = false);

    if (mounted) {
      if (result['success'] == true) {
         ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Submitted successfully'), backgroundColor: Colors.green));
         Navigator.pop(context);
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
        title: Text('Trade Card', style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Select Brand', style: GoogleFonts.spaceGrotesk(color: Colors.white54, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _cardTypes.length,
                itemBuilder: (context, index) {
                  final card = _cardTypes[index];
                  final isSelected = _selectedCardId == card['id'];
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCardId = card['id']),
                    child: Container(
                      width: 80,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? card['color'] : (card['color'] as Color).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                        border: isSelected ? Border.all(color: Colors.white, width: 2) : null
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.card_giftcard, color: Colors.white, size: 30),
                          const SizedBox(height: 8),
                          Text(card['name'], style: GoogleFonts.outfit(color: Colors.white, fontSize: 10), textAlign: TextAlign.center)
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            
            const SizedBox(height: 24),
            
            _buildSection(
              'Card Details',
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: DropdownButtonFormField<String>(
                          dropdownColor: const Color(0xFF1E293B),
                          value: _selectedCurrency,
                          style: GoogleFonts.outfit(color: Colors.white),
                          decoration: _inputDecor('Currency'),
                          items: ['USD', 'GBP', 'EUR', 'CAD'].map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                          onChanged: (v) => setState(() => _selectedCurrency = v!),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: _amountCtrl,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: Colors.white),
                          decoration: _inputDecor('Amount'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _codeCtrl,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecor('E-Code (Optional)'),
                  ),
                ],
              )
            ),

            const SizedBox(height: 24),

            _buildSection(
              'Card Image',
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.white.withOpacity(0.2), style: BorderStyle.solid),
                    image: _imageFile != null ? DecorationImage(image: FileImage(_imageFile!), fit: BoxFit.cover) : null,
                  ),
                  child: _imageFile == null 
                    ? Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.cloud_upload_outlined, color: Colors.white54, size: 40),
                          const SizedBox(height: 8),
                          Text('Tap to upload image', style: GoogleFonts.spaceGrotesk(color: Colors.white30))
                        ],
                      )
                    : null,
                ),
              )
            ),

            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isLoading 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text('Submit Trade', style: GoogleFonts.spaceGrotesk(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: GoogleFonts.spaceGrotesk(color: Colors.white54, fontWeight: FontWeight.bold)),
        const SizedBox(height: 12),
        content
      ],
    );
  }

  InputDecoration _inputDecor(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.white54),
      fillColor: Colors.white.withOpacity(0.05),
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
    );
  }
}
