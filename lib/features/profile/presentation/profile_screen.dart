import 'package:flutter/material.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';

/// Profil ekran seniora — forma za podatke, jezik, odjava.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _firstNameCtrl = TextEditingController(text: 'Marija');
  final _lastNameCtrl = TextEditingController(text: 'Novak');
  final _phoneCtrl = TextEditingController(text: '+385 91 234 5678');
  final _emailCtrl = TextEditingController(text: 'marija.novak@email.com');
  final _addressCtrl = TextEditingController(text: 'Ilica 42, Zagreb');

  String _selectedLang = 'HR';

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _addressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.profile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 8),

          // ── Podaci ──────────────────────────────────
          _buildField(AppStrings.firstName, _firstNameCtrl),
          const SizedBox(height: 12),
          _buildField(AppStrings.lastName, _lastNameCtrl),
          const SizedBox(height: 12),
          _buildField(AppStrings.phone, _phoneCtrl,
              keyboardType: TextInputType.phone),
          const SizedBox(height: 12),
          _buildField(AppStrings.email, _emailCtrl,
              keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _buildField(AppStrings.address, _addressCtrl),
          const SizedBox(height: 24),

          // ── Spremi ──────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () {},
              child: Text(AppStrings.save),
            ),
          ),
          const SizedBox(height: 32),

          // ── Jezik ───────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.language, color: theme.colorScheme.secondary,
                    size: 28),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    AppStrings.language,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment<String>(value: 'HR', label: Text('HR')),
                    ButtonSegment<String>(value: 'EN', label: Text('EN')),
                  ],
                  selected: {_selectedLang},
                  onSelectionChanged: (value) {
                    setState(() => _selectedLang = value.first);
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // ── Odjava ──────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.logout),
              label: Text(AppStrings.logout),
              style: OutlinedButton.styleFrom(
                foregroundColor: theme.colorScheme.error,
                side: BorderSide(color: theme.colorScheme.error),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ── Verzija ─────────────────────────────────
          Center(
            child: Text('Helpi v1.0.0', style: theme.textTheme.bodySmall),
          ),
        ],
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}
