import 'package:flutter/material.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';

/// Profil ekran seniora — prikaz podataka, postavke, odjava.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.profile)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 16),

          // ── Avatar + ime ────────────────────────────
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text('👵', style: const TextStyle(fontSize: 48)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text('Marija Novak', style: theme.textTheme.headlineMedium),
          ),
          Center(
            child: Text(
              'marija.novak@email.com',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // ── Akcije ──────────────────────────────────
          _ProfileTile(
            icon: Icons.person,
            label: AppStrings.editProfile,
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.language,
            label: AppStrings.language,
            trailing: 'HR',
            onTap: () {},
          ),
          _ProfileTile(
            icon: Icons.settings,
            label: AppStrings.settings,
            onTap: () {},
          ),
          const SizedBox(height: 24),
          _ProfileTile(
            icon: Icons.logout,
            label: AppStrings.logout,
            isDestructive: true,
            onTap: () {},
          ),
          const SizedBox(height: 32),

          // ── Verzija ─────────────────────────────────
          Center(child: Text('Helpi v1.0.0', style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }

  // TODO(i18n): dodati u AppStrings
}

class _ProfileTile extends StatelessWidget {
  const _ProfileTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.trailing,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? trailing;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isDestructive
        ? theme.colorScheme.error
        : theme.colorScheme.primary;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Row(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isDestructive ? color : null,
                  ),
                ),
              ),
              if (trailing != null)
                Text(
                  trailing!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios,
                size: 18,
                color: theme.colorScheme.onSurface.withAlpha(100),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
