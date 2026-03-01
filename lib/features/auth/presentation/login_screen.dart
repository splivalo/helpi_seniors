import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';
import 'package:helpi_senior/core/l10n/locale_notifier.dart';

/// Login / Register ekran — UI prototype, bez prave autentikacije.
class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
    required this.localeNotifier,
  });

  /// Callback kad korisnik "uspješno" klikne Login ili Register.
  final VoidCallback onLoginSuccess;
  final LocaleNotifier localeNotifier;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  static const _coral = Color(0xFFEF5B5B);
  static const _teal = Color(0xFF009D9D);

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  late String _selectedLang = AppStrings.currentLocale.toUpperCase();
  bool _isRegisterMode = false;
  bool _obscurePassword = true;

  // ── Registration step 2: profile data ─────────
  int _registerStep = 0; // 0 = email/pass, 1 = profile

  // Naručitelj
  final _ordFirstNameCtrl = TextEditingController();
  final _ordLastNameCtrl = TextEditingController();
  final _ordPhoneCtrl = TextEditingController();
  String _ordGender = 'M';
  DateTime? _ordDob;

  // Senior
  final _senFirstNameCtrl = TextEditingController();
  final _senLastNameCtrl = TextEditingController();
  final _senPhoneCtrl = TextEditingController();
  final _senAddressCtrl = TextEditingController();
  String _senGender = 'F';
  DateTime? _senDob;

  bool _orderingForOther = false;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
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
      backgroundColor: const Color(0xFFF9F7F4),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isProfileStep = _isRegisterMode && _registerStep == 1;
            return SingleChildScrollView(
              padding: isProfileStep
                  ? const EdgeInsets.all(16)
                  : const EdgeInsets.symmetric(horizontal: 28),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: isProfileStep
                    ? _buildProfileStep(theme)
                    : _buildLoginRegisterStep(theme),
              ),
            );
          },
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // STEP 0: Login / Register (email + password)
  // ══════════════════════════════════════════════
  Widget _buildLoginRegisterStep(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(height: 24),

        // ── Logo / Branding ──
        Container(
          width: 100,
          height: 100,
          decoration: const BoxDecoration(
            color: _coral,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: SvgPicture.asset(
              'assets/images/h_logo.svg',
              width: 50,
              height: 50,
              colorFilter: const ColorFilter.mode(
                Colors.white,
                BlendMode.srcIn,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── Title ──
        Text(
          AppStrings.loginTitle,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppStrings.loginSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: const Color(0xFF757575),
          ),
        ),
        const SizedBox(height: 40),

        // ── Email field ──
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: AppStrings.loginEmail,
            prefixIcon: const Icon(Icons.email_outlined, color: _teal),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 16),

        // ── Password field ──
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: AppStrings.loginPassword,
            prefixIcon: const Icon(Icons.lock_outline, color: _teal),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: const Color(0xFF757575),
              ),
            ),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 12),

        // ── Forgot password ──
        if (!_isRegisterMode)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Prototype — no action
              },
              child: Text(
                AppStrings.forgotPassword,
                style: TextStyle(color: _teal, fontSize: 14),
              ),
            ),
          ),
        const SizedBox(height: 20),

        // ── Main CTA button ──
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _isRegisterMode
                ? () => setState(() => _registerStep = 1)
                : widget.onLoginSuccess,
            style: ElevatedButton.styleFrom(
              backgroundColor: _coral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(
              _isRegisterMode ? AppStrings.next : AppStrings.loginButton,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── Toggle login / register ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isRegisterMode ? AppStrings.hasAccount : AppStrings.noAccount,
              style: theme.textTheme.bodyMedium,
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isRegisterMode = !_isRegisterMode;
                  _registerStep = 0;
                });
              },
              child: Text(
                _isRegisterMode
                    ? AppStrings.loginButton
                    : AppStrings.registerButton,
                style: const TextStyle(
                  color: _coral,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),

        // ── Language picker ──
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.language, color: _teal, size: 20),
            const SizedBox(width: 8),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedLang,
                isDense: true,
                style: TextStyle(
                  color: theme.colorScheme.onSurface,
                  fontSize: 15,
                ),
                onChanged: (v) {
                  if (v != null) {
                    setState(() => _selectedLang = v);
                    widget.localeNotifier.setLocale(v);
                  }
                },
                items: const [
                  DropdownMenuItem(value: 'HR', child: Text('Hrvatski')),
                  DropdownMenuItem(value: 'EN', child: Text('English')),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // STEP 1: Profile completion (registration)
  // ══════════════════════════════════════════════
  Widget _buildProfileStep(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),

        // ── Back arrow ──
        GestureDetector(
          onTap: () => setState(() => _registerStep = 0),
          child: const Icon(Icons.arrow_back, size: 28),
        ),
        const SizedBox(height: 16),

        // ── Title ──
        Center(
          child: Text(
            AppStrings.regProfileTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            AppStrings.regProfileSubtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: const Color(0xFF757575),
            ),
          ),
        ),
        const SizedBox(height: 32),

        // ── PODACI O NARUČITELJU ────────────────────
        _sectionHeader(theme, AppStrings.ordererData),
        const SizedBox(height: 12),
        _buildField(AppStrings.firstName, _ordFirstNameCtrl),
        const SizedBox(height: 12),
        _buildField(AppStrings.lastName, _ordLastNameCtrl),
        const SizedBox(height: 12),
        _buildGenderPicker(
          theme,
          _ordGender,
          (v) => setState(() => _ordGender = v),
        ),
        const SizedBox(height: 12),
        _buildDatePicker(
          theme,
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
        const SizedBox(height: 12),
        _buildField(AppStrings.address, _senAddressCtrl),
        const SizedBox(height: 16),

        // ── "Naručujem za drugog" toggle ──
        Row(
          children: [
            Checkbox(
              value: _orderingForOther,
              onChanged: (v) => setState(() => _orderingForOther = v ?? false),
              activeColor: _teal,
            ),
            Expanded(
              child: Text(
                AppStrings.orderingForOther,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),

        // ── PODACI O KORISNIKU (SENIOR) ─────────────
        // Prikazuje se samo ako naručujem za drugog
        if (_orderingForOther) ...[
          const SizedBox(height: 24),
          _sectionHeader(theme, AppStrings.seniorData),
          const SizedBox(height: 12),
          _buildField(AppStrings.firstName, _senFirstNameCtrl),
          const SizedBox(height: 12),
          _buildField(AppStrings.lastName, _senLastNameCtrl),
          const SizedBox(height: 12),
          _buildGenderPicker(
            theme,
            _senGender,
            (v) => setState(() => _senGender = v),
          ),
          const SizedBox(height: 12),
          _buildDatePicker(
            theme,
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
        ],
        const SizedBox(height: 16),

        // ── Uvjeti ──
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Checkbox(
              value: _agreedToTerms,
              onChanged: (v) => setState(() => _agreedToTerms = v ?? false),
              activeColor: _teal,
            ),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: theme.textTheme.bodyMedium,
                  children: [
                    TextSpan(text: AppStrings.agreeToTerms),
                    TextSpan(
                      text: AppStrings.termsOfUse,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _teal,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // ── CTA: Završi registraciju ──
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _agreedToTerms ? widget.onLoginSuccess : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: _coral,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              textStyle: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: Text(AppStrings.completeRegistration),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // HELPERS (matching profile_screen.dart style)
  // ══════════════════════════════════════════════

  Widget _sectionHeader(ThemeData theme, String title) {
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
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  Widget _buildGenderPicker(
    ThemeData theme,
    String value,
    ValueChanged<String> onChanged,
  ) {
    return InputDecorator(
      decoration: InputDecoration(
        labelText: AppStrings.gender,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
        filled: true,
        fillColor: Colors.white,
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          isExpanded: true,
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
          style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 16),
          items: [
            DropdownMenuItem(value: 'M', child: Text(AppStrings.genderMale)),
            DropdownMenuItem(value: 'F', child: Text(AppStrings.genderFemale)),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(
    ThemeData theme,
    String label,
    DateTime? date,
    ValueChanged<DateTime> onChanged,
  ) {
    final formatted = date != null
        ? '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}.'
        : null;

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime(1960),
          firstDate: DateTime(1920),
          lastDate: DateTime.now(),
        );
        if (picked != null && context.mounted) {
          onChanged(picked);
        }
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
          filled: true,
          fillColor: Colors.white,
          suffixIcon: Icon(Icons.calendar_today, size: 20, color: _teal),
        ),
        child: Text(
          formatted ?? AppStrings.dobPlaceholder,
          style: TextStyle(
            color: formatted != null
                ? theme.colorScheme.onSurface
                : const Color(0xFF757575),
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
