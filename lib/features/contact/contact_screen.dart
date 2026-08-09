import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/api_client.dart';
import '../../core/theme.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  bool _submitting = false;
  String? _error;
  bool _sent = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      await ApiClient.instance.post('/contact', data: {
        'name': _nameCtrl.text.trim(),
        'email': _emailCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(),
        'message': _messageCtrl.text.trim(),
      });
      setState(() => _sent = true);
    } on DioException catch (e) {
      setState(() => _error = e.response?.data?['message']?.toString() ??
          'Something went wrong sending your message. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact')),
      body: _sent ? _successView() : _form(),
    );
  }

  Widget _successView() {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 24),
        const Icon(Icons.check_circle, color: Colors.green, size: 48),
        const SizedBox(height: 16),
        const Text('Message sent', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18), textAlign: TextAlign.center),
        const SizedBox(height: 8),
        const Text(
          "Thanks — your message has been received. Our team will get back to you shortly.",
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        _contactInfo(),
      ],
    );
  }

  Widget _contactInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Get in touch directly', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(height: 12),
        _infoTile(icon: Icons.location_on_outlined, title: 'Office', value: 'SRTI Park, University Road, Sharjah, UAE'),
        _infoTile(
          icon: Icons.email_outlined,
          title: 'Email',
          value: 'info@bluearrow.ae',
          onTap: () => launchUrl(Uri.parse('mailto:info@bluearrow.ae')),
        ),
        _infoTile(
          icon: Icons.phone_outlined,
          title: 'Phone',
          value: '+971 52 6461499',
          onTap: () => launchUrl(Uri.parse('tel:+971526461499')),
        ),
      ],
    );
  }

  Widget _infoTile({required IconData icon, required String title, required String value, VoidCallback? onTap}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: BrandColors.primary),
        title: Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        subtitle: Text(value, style: TextStyle(color: onTap != null ? BrandColors.primary : Colors.black87)),
        onTap: onTap,
      ),
    );
  }

  Widget _form() {
    return Form(
      key: _formKey,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 12),
          ],
          TextFormField(
            controller: _nameCtrl,
            decoration: const InputDecoration(labelText: 'Name'),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _emailCtrl,
            decoration: const InputDecoration(labelText: 'Email'),
            keyboardType: TextInputType.emailAddress,
            validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _phoneCtrl,
            decoration: const InputDecoration(labelText: 'Phone (optional)'),
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _messageCtrl,
            decoration: const InputDecoration(labelText: 'Message'),
            maxLines: 5,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitting ? null : _submit,
            child: _submitting
                ? const SizedBox(
                    height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('Send message'),
          ),
          const SizedBox(height: 32),
          _contactInfo(),
        ],
      ),
    );
  }
}
