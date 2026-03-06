import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:helpi_senior/core/constants/colors.dart';
import 'package:helpi_senior/core/l10n/app_strings.dart';
import 'package:helpi_senior/core/l10n/locale_notifier.dart';
import 'package:helpi_senior/shared/widgets/helpi_form_fields.dart';

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
      backgroundColor: AppColors.background,
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
            color: AppColors.coral,
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
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 40),

        // ── Email field ──
        TextField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: AppStrings.loginEmail,
            prefixIcon: const Icon(Icons.email_outlined, color: AppColors.teal),
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
            prefixIcon: const Icon(Icons.lock_outline, color: AppColors.teal),
            suffixIcon: GestureDetector(
              onTap: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
              child: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: AppColors.textSecondary,
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
                style: TextStyle(color: AppColors.teal, fontSize: 14),
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
              backgroundColor: AppColors.coral,
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
                  color: AppColors.coral,
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
            Icon(Icons.language, color: AppColors.teal, size: 20),
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
                items: [
                  DropdownMenuItem(value: 'HR', child: Text(AppStrings.langHr)),
                  DropdownMenuItem(value: 'EN', child: Text(AppStrings.langEn)),
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
              color: AppColors.textSecondary,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // ── PODACI O NARUČITELJU ────────────────────
        HelpiSectionHeader(title: AppStrings.ordererData),
        const SizedBox(height: 12),
        HelpiTextField(
          label: AppStrings.firstName,
          controller: _ordFirstNameCtrl,
        ),
        const SizedBox(height: 12),
        HelpiTextField(
          label: AppStrings.lastName,
          controller: _ordLastNameCtrl,
        ),
        const SizedBox(height: 12),
        HelpiGenderPicker(
          value: _ordGender,
          onChanged: (v) => setState(() => _ordGender = v),
        ),
        const SizedBox(height: 12),
        HelpiDatePicker(
          label: AppStrings.dateOfBirth,
          date: _ordDob,
          onChanged: (d) => setState(() => _ordDob = d),
        ),
        const SizedBox(height: 12),
        HelpiTextField(
          label: AppStrings.phone,
          controller: _ordPhoneCtrl,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 12),
        HelpiTextField(label: AppStrings.address, controller: _senAddressCtrl),
        const SizedBox(height: 16),

        // ── "Naručujem za drugog" toggle ──
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.orderingForOther,
                style: theme.textTheme.bodyMedium,
              ),
            ),
            Switch(
              value: _orderingForOther,
              onChanged: (v) => setState(() => _orderingForOther = v),
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.teal,
              inactiveThumbColor: AppColors.teal,
              trackOutlineColor: WidgetStateProperty.all(AppColors.teal),
            ),
          ],
        ),

        // ── PODACI O KORISNIKU (SENIOR) ─────────────
        // Prikazuje se samo ako naručujem za drugog
        if (_orderingForOther) ...[
          const SizedBox(height: 24),
          HelpiSectionHeader(title: AppStrings.seniorData),
          const SizedBox(height: 12),
          HelpiTextField(
            label: AppStrings.firstName,
            controller: _senFirstNameCtrl,
          ),
          const SizedBox(height: 12),
          HelpiTextField(
            label: AppStrings.lastName,
            controller: _senLastNameCtrl,
          ),
          const SizedBox(height: 12),
          HelpiGenderPicker(
            value: _senGender,
            onChanged: (v) => setState(() => _senGender = v),
          ),
          const SizedBox(height: 12),
          HelpiDatePicker(
            label: AppStrings.dateOfBirth,
            date: _senDob,
            onChanged: (d) => setState(() => _senDob = d),
          ),
          const SizedBox(height: 12),
          HelpiTextField(
            label: AppStrings.address,
            controller: _senAddressCtrl,
          ),
          const SizedBox(height: 12),
          HelpiTextField(
            label: AppStrings.phone,
            controller: _senPhoneCtrl,
            keyboardType: TextInputType.phone,
          ),
        ],
        const SizedBox(height: 32),

        // ── CTA: Završi registraciju ──
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: widget.onLoginSuccess,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.coral,
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
        const SizedBox(height: 12),

        // ── Uvjeti (tekst ispod gumba) ──
        Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
              children: [
                TextSpan(text: AppStrings.byClickingRegister),
                TextSpan(
                  text: AppStrings.termsOfUseLink,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // HELPERS (matching profile_screen.dart style)
  // ══════════════════════════════════════════════
}
