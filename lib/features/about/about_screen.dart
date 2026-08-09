import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('ABOUT BLUE ARROW',
              style: TextStyle(color: BrandColors.primary, fontWeight: FontWeight.bold, fontSize: 13)),
          const SizedBox(height: 8),
          Text('A trusted compliance partner in a complex regulatory landscape',
              style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Text(
            'Blue Arrow Management Consultants is a UAE-based AML and regulatory compliance consultancy, helping '
            'Designated Non-Financial Businesses and Professions (DNFBPs) — bullion dealers, real estate brokers, '
            'company service providers and accounting firms — build and run effective AML/CFT compliance programs.',
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),
          const SizedBox(height: 12),
          Text(
            "We're also a technology company. Blue Arrow designs and builds our own software — including the "
            'RegTech platform behind our compliance service — and we take on custom software and mobile app '
            'development for clients, whether the need is compliance-related, accounting-related, or in a '
            'completely different field.',
            style: TextStyle(color: Colors.grey.shade700, height: 1.5),
          ),
          const SizedBox(height: 24),
          Row(
            children: const [
              Expanded(child: _StatCard(value: '100%', label: 'Compliance Rate')),
              SizedBox(width: 10),
              Expanded(child: _StatCard(value: '25+', label: 'Years Combined Experience')),
              SizedBox(width: 10),
              Expanded(child: _StatCard(value: '5', label: 'DNFBP Sectors Served')),
            ],
          ),
          const SizedBox(height: 28),
          const _BulletSection(
            title: 'Compliance Advisory',
            items: [
              'AML/CFT policy design & implementation for DNFBPs',
              'KYC/KYB onboarding & ongoing due diligence',
              'Sanctions & PEP screening against UN, OFAC, EU and UAE lists',
              'goAML STR/SAR/DPMSR reporting support',
              'Risk assessment & UBO/beneficial ownership verification',
              'Regulatory training & ongoing compliance monitoring',
            ],
          ),
          const SizedBox(height: 20),
          const _BulletSection(
            title: 'Technology & Software Development',
            items: [
              'Our own RegTech platform — client onboarding, screening & reporting',
              'Custom accounting & business software',
              'Mobile app development, for compliance, accounting, or any other field',
              'Web portals & internal business tools',
              'System integrations with existing business software',
              'Ongoing support & maintenance',
            ],
          ),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Certified & regulator-aligned', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                    'Our consultants hold recognized regulatory compliance certifications and work directly with '
                    'UAE DNFBP supervisory requirements — including Ministry of Economy guidance and Financial '
                    'Intelligence Unit (FIU) goAML reporting obligations — so our clients stay ahead of evolving '
                    'requirements rather than reacting to them.',
                    style: TextStyle(color: Colors.grey.shade700, height: 1.4, fontSize: 13),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Card(
            color: const Color(0xFFF9FAFB),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const Text('Want to get in touch?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 6),
                  Text(
                    'Find our office, email and phone details on the contact page.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                  const SizedBox(height: 14),
                  ElevatedButton(
                    onPressed: () => context.push('/contact'),
                    child: const Text('Contact Us'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  const _StatCard({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Column(
          children: [
            Text(value, style: const TextStyle(color: BrandColors.primary, fontWeight: FontWeight.bold, fontSize: 22)),
            const SizedBox(height: 4),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
          ],
        ),
      ),
    );
  }
}

class _BulletSection extends StatelessWidget {
  final String title;
  final List<String> items;
  const _BulletSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 10),
        ...items.map((item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('•  ', style: TextStyle(color: BrandColors.primary, fontWeight: FontWeight.bold)),
                  Expanded(child: Text(item, style: TextStyle(color: Colors.grey.shade700, fontSize: 13, height: 1.4))),
                ],
              ),
            )),
      ],
    );
  }
}
