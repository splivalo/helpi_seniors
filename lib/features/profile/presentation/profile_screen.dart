import 'package:flutter/material.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';
import 'package:helpi_senior/core/l10n/locale_notifier.dart';

/// Profil ekran — pristupni podaci, naručitelj, senior, kartice, uvjeti.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.localeNotifier});

  final LocaleNotifier localeNotifier;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // ── Pristupni podaci ──────────────────────────
  final _emailCtrl = TextEditingController(text: 'marija.novak@email.com');

  // ── Naručitelj ────────────────────────────────
  final _ordFirstNameCtrl = TextEditingController(text: 'Ivan');
  final _ordLastNameCtrl = TextEditingController(text: 'Novak');
  final _ordPhoneCtrl = TextEditingController(text: '+385 91 234 5678');
  String _ordGender = 'M';
  DateTime _ordDob = DateTime(1985, 3, 15);

  // ── Senior / korisnik ─────────────────────────
  final _senFirstNameCtrl = TextEditingController(text: 'Marija');
  final _senLastNameCtrl = TextEditingController(text: 'Novak');
  final _senPhoneCtrl = TextEditingController(text: '+385 91 987 6543');
  final _senAddressCtrl = TextEditingController(text: 'Ilica 42, Zagreb');
  String _senGender = 'F';
  DateTime _senDob = DateTime(1948, 7, 22);

  // ── Ostalo ────────────────────────────────────
  late String _selectedLang = AppStrings.currentLocale.toUpperCase();
  bool _isEditing = false;
  bool _agreedToTerms = true;

  // Mock kartice
  final List<String> _cards = ['**** 4821', '**** 9037'];

  @override
  void dispose() {
    _emailCtrl.dispose();
    _ordFirstNameCtrl.dispose();
    _ordLastNameCtrl.dispose();
    _ordPhoneCtrl.dispose();
    _senFirstNameCtrl.dispose();
    _senLastNameCtrl.dispose();
    _senPhoneCtrl.dispose();
    _senAddressCtrl.dispose();
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
          // ── PRISTUPNI PODACI ────────────────────────
          _sectionHeader(AppStrings.accessData),
          const SizedBox(height: 12),
          _buildField(
            AppStrings.email,
            _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 12),
          // Promijeni lozinku
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.lock_outline, size: 20),
            label: Text(AppStrings.changePassword),
          ),
          const SizedBox(height: 32),

          // ── PODACI O NARUČITELJU ────────────────────
          _sectionHeader(AppStrings.ordererData),
          const SizedBox(height: 12),
          _buildField(AppStrings.firstName, _ordFirstNameCtrl),
          const SizedBox(height: 12),
          _buildField(AppStrings.lastName, _ordLastNameCtrl),
          const SizedBox(height: 12),
          _buildGenderPicker(_ordGender, (v) => setState(() => _ordGender = v)),
          const SizedBox(height: 12),
          _buildDatePicker(
            AppStrings.dateOfBirth,
            _ordDob,
            (d) => setState(() => _ordDob = d),
          ),
          const SizedBox(height: 12),
          _buildField(
            AppStrings.phone,
            _ordPhoneCtrl,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 32),

          // ── PODACI O KORISNIKU (SENIOR) ─────────────
          _sectionHeader(AppStrings.seniorData),
          const SizedBox(height: 12),
          _buildField(AppStrings.firstName, _senFirstNameCtrl),
          const SizedBox(height: 12),
          _buildField(AppStrings.lastName, _senLastNameCtrl),
          const SizedBox(height: 12),
          _buildGenderPicker(_senGender, (v) => setState(() => _senGender = v)),
          const SizedBox(height: 12),
          _buildDatePicker(
            AppStrings.dateOfBirth,
            _senDob,
            (d) => setState(() => _senDob = d),
          ),
          const SizedBox(height: 12),
          _buildField(AppStrings.address, _senAddressCtrl),
          const SizedBox(height: 12),
          _buildField(
            AppStrings.phone,
            _senPhoneCtrl,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 32),

          // ── KREDITNE KARTICE ────────────────────────
          _sectionHeader(AppStrings.creditCards),
          const SizedBox(height: 12),
          if (_cards.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: const Color(0xFFE0E0E0)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  AppStrings.noCards,
                  style: TextStyle(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                    fontSize: 16,
                  ),
                ),
              ),
            )
          else
            ..._cards.map(
              (card) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: InputDecorator(
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    disabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    enabled: _isEditing,
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.credit_card,
                      color: theme.colorScheme.secondary,
                    ),
                    suffixIcon: _isEditing
                        ? GestureDetector(
                            onTap: () {
                              setState(() => _cards.remove(card));
                            },
                            child: Icon(
                              Icons.delete_outline,
                              color: theme.colorScheme.error,
                              size: 22,
                            ),
                          )
                        : null,
                  ),
                  child: Text(
                    card,
                    style: TextStyle(
                      color: _isEditing
                          ? theme.colorScheme.onSurface
                          : theme.colorScheme.onSurface.withAlpha(153),
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          if (_isEditing) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add, size: 20),
              label: Text(AppStrings.addCard),
            ),
          ],
          const SizedBox(height: 8),

          // ── UVJETI ──────────────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Checkbox(
                value: _agreedToTerms,
                onChanged: _isEditing
                    ? (v) => setState(() => _agreedToTerms = v ?? false)
                    : null,
                activeColor: theme.colorScheme.secondary,
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    // TODO: otvori uvjete korištenja
                  },
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium,
                      children: [
                        TextSpan(text: AppStrings.agreeToTerms),
                        TextSpan(
                          text: AppStrings.termsOfUse,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: theme.colorScheme.secondary,
                            decorationColor: theme.colorScheme.secondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // ── UREDI / SPREMI ──────────────────────────
          SizedBox(
            width: double.infinity,
            child: _isEditing
                ? Column(
                    children: [
                      ElevatedButton(
                        onPressed: () => setState(() => _isEditing = false),
                        child: Text(AppStrings.save),
                      ),
                      const SizedBox(height: 8),
                      TextButton(
                        onPressed: () => setState(() => _isEditing = false),
                        child: Text(AppStrings.cancel),
                      ),
                    ],
                  )
                : OutlinedButton.icon(
                    onPressed: () => setState(() => _isEditing = true),
                    icon: const Icon(Icons.edit, size: 20),
                    label: Text(AppStrings.editProfile),
                  ),
          ),
          const SizedBox(height: 32),

          // ── JEZIK ───────────────────────────────────
          InputDecorator(
            decoration: InputDecoration(
              labelText: AppStrings.language,
              labelStyle: TextStyle(
                color: theme.colorScheme.onSurface.withAlpha(180),
              ),
              prefixIcon: Icon(
                Icons.language,
                color: theme.colorScheme.secondary,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              filled: true,
              fillColor: Colors.white,
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLang,
                isDense: true,
                isExpanded: true,
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _selectedLang = v);
                    widget.localeNotifier.setLocale(v);
                  }
                },
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 16,
                ),
                items: const [
                  DropdownMenuItem(value: 'HR', child: Text('Hrvatski')),
                  DropdownMenuItem(value: 'EN', child: Text('English')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── ODJAVA ──────────────────────────────────
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.logout),
            label: Text(AppStrings.logout),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFFEF5B5B),
              side: const BorderSide(color: Color(0xFFEF5B5B), width: 2),
            ),
          ),
          const SizedBox(height: 32),

          // ── Verzija ─────────────────────────────────
          Center(child: Text('Helpi v1.0.0', style: theme.textTheme.bodySmall)),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────

  Widget _sectionHeader(String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.onSurface,
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      enabled: _isEditing,
      style: TextStyle(
        color: _isEditing
            ? theme.colorScheme.onSurface
            : theme.colorScheme.onSurface.withAlpha(153),
        fontSize: 16,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withAlpha(_isEditing ? 180 : 153),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildGenderPicker(String value, ValueChanged<String> onChanged) {
    final theme = Theme.of(context);

    return InputDecorator(
      decoration: InputDecoration(
        labelText: AppStrings.gender,
        labelStyle: TextStyle(
          color: theme.colorScheme.onSurface.withAlpha(_isEditing ? 180 : 153),
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabled: _isEditing,
        filled: true,
        fillColor: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          onChanged: _isEditing
              ? (v) {
                  if (v != null) onChanged(v);
                }
              : null,
          style: TextStyle(
            color: _isEditing
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withAlpha(153),
            fontSize: 16,
          ),
          items: [
            DropdownMenuItem(value: 'M', child: Text(AppStrings.genderMale)),
            DropdownMenuItem(value: 'F', child: Text(AppStrings.genderFemale)),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    String label,
    DateTime date,
    ValueChanged<DateTime> onChanged,
  ) {
    final theme = Theme.of(context);
    final formatted =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}.';

    return GestureDetector(
      onTap: _isEditing
          ? () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: date,
                firstDate: DateTime(1920),
                lastDate: DateTime.now(),
              );
              if (picked != null && context.mounted) {
                onChanged(picked);
              }
            }
          : null,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: theme.colorScheme.onSurface.withAlpha(
              _isEditing ? 180 : 153,
            ),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: _isEditing
                  ? theme.colorScheme.onSurface.withAlpha(100)
                  : const Color(0xFFE0E0E0),
            ),
          ),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: _isEditing
              ? Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: theme.colorScheme.secondary,
                )
              : null,
        ),
        child: Text(
          formatted,
          style: TextStyle(
            color: _isEditing
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withAlpha(153),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
