import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String _apiBase = String.fromEnvironment(
  'API_BASE',
  defaultValue: 'https://emobies-ap-135-production.up.railway.app',
);

class ComplaintSubmitScreen extends StatefulWidget {
  final String token;
  const ComplaintSubmitScreen({super.key, required this.token});
  @override
  State<ComplaintSubmitScreen> createState() => _ComplaintSubmitScreenState();
}

class _ComplaintSubmitScreenState extends State<ComplaintSubmitScreen> {
  final _device = TextEditingController();
  final _imei = TextEditingController();
  final _problem = TextEditingController();
  final _address = TextEditingController();
  String _condition = 'Good';
  bool _loading = false;
  String? _error;
  String? _success;

  Future<void> _submit() async {
    if (_device.text.isEmpty || _address.text.isEmpty || _problem.text.isEmpty) {
      setState(() => _error = 'Please fill all required fields');
      return;
    }
    setState(() { _loading = true; _error = null; _success = null; });
    try {
      final res = await http.post(
        Uri.parse('$_apiBase/api/complaints'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ${widget.token}'},
        body: jsonEncode({
          'deviceName': _device.text.trim(),
          'imei': _imei.text.trim(),
          'natureOfComplaint': _problem.text.trim(),
          'bodyCondition': _condition,
          'pickupAddress': _address.text.trim(),
        }),
      ).timeout(const Duration(seconds: 10));
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        setState(() => _success = '✅ Complaint submitted! We will contact you soon.');
        _device.clear(); _imei.clear(); _problem.clear(); _address.clear();
      } else {
        setState(() => _error = data['error'] ?? 'Submission failed');
      }
    } catch (e) {
      setState(() => _error = '⚠️ Cannot reach server. Check connection.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF07080B),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0F14),
        title: Text('New Repair Request', style: GoogleFonts.syne(fontWeight: FontWeight.w800)),
        iconTheme: const IconThemeData(color: Color(0xFFFF5500)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label('📱 Device Name *'),
          _field(_device, 'e.g. iPhone 13, Samsung S21'),
          const SizedBox(height: 14),
          _label('🔢 IMEI Number'),
          _field(_imei, 'Optional but recommended'),
          const SizedBox(height: 14),
          _label('🔧 Problem Description *'),
          _field(_problem, 'Describe the issue...', lines: 3),
          const SizedBox(height: 14),
          _label('📦 Body Condition'),
          _conditionSelector(),
          const SizedBox(height: 14),
          _label('📍 Pickup Address *'),
          _field(_address, 'Your full address for pickup', lines: 2),
          const SizedBox(height: 24),
          if (_error != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (_success != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF00E676).withOpacity(0.1),
                border: Border.all(color: const Color(0xFF00E676).withOpacity(0.3)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity, height: 52,
            child: ElevatedButton(
              onPressed: _loading ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFF5500),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              ),
              child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : Text('⬡  Submit Repair Request', style: GoogleFonts.syne(fontWeight: FontWeight.w800, fontSize: 15)),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: GoogleFonts.jetBrainsMono(fontSize: 11, color: const Color(0xFF8892A4), fontWeight: FontWeight.w700)),
  );

  Widget _field(TextEditingController c, String hint, {int lines = 1}) => TextField(
    controller: c,
    maxLines: lines,
    style: const TextStyle(color: Color(0xFFEEF0F4), fontSize: 14),
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF424A58), fontSize: 13),
      filled: true,
      fillColor: const Color(0xFF0C0F14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xFF1A1F28))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(13), borderSide: const BorderSide(color: Color(0xFFFF5500), width: 1.5)),
    ),
  );

  Widget _conditionSelector() => Row(children: ['Good', 'Fair', 'Poor'].map((c) {
    final selected = _condition == c;
    final color = c == 'Good' ? const Color(0xFF00E676) : c == 'Fair' ? const Color(0xFFFBBF24) : const Color(0xFFEF4444);
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => setState(() => _condition = c),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: selected ? color.withOpacity(0.15) : const Color(0xFF0C0F14),
            border: Border.all(color: selected ? color : const Color(0xFF1A1F28), width: selected ? 1.5 : 1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(c, style: GoogleFonts.jetBrainsMono(fontSize: 12, color: selected ? color : const Color(0xFF8892A4), fontWeight: FontWeight.w700)),
        ),
      ),
    );
  }).toList());

  @override
  void dispose() { _device.dispose(); _imei.dispose(); _problem.dispose(); _address.dispose(); super.dispose(); }
}
