import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';
import 'package:helpi_senior/core/utils/mock_data.dart';
import 'package:helpi_senior/features/marketplace/presentation/student_detail_screen.dart';
import 'package:helpi_senior/shared/widgets/student_card.dart';

/// Početni ekran — prikazuje pozdrav, brze akcije i preporučene studente.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, this.onCategoryTap});

  final void Function(ServiceType type)? onCategoryTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final topStudents = MockData.students.toList()
      ..sort((a, b) => b.rating.compareTo(a.rating));

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.navHome)),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // ── Pozdrav ─────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              AppStrings.welcomeUser('Marija'),
              style: theme.textTheme.headlineMedium,
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              AppStrings.appTagline,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurface.withAlpha(153),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Brze akcije ─────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _quickActionsTitle,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: ServiceType.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (_, i) {
                final type = ServiceType.values[i];
                return _QuickAction(
                  svgAsset: ServiceChip.serviceAsset(type),
                  label: ServiceChip.serviceLabel(type),
                  onTap: onCategoryTap != null
                      ? () => onCategoryTap!(type)
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: 24),

          // ── Preporučeni studenti ────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              _recommendedTitle,
              style: theme.textTheme.headlineSmall,
            ),
          ),
          const SizedBox(height: 8),
          ...topStudents
              .take(3)
              .map(
                (student) => StudentCard(
                  student: student,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => StudentDetailScreen(student: student),
                      ),
                    );
                  },
                ),
              ),
        ],
      ),
    );
  }

  // TODO(i18n): dodati u AppStrings kad se potvrdi copy
  static const _quickActionsTitle = 'Što vam treba?';
  static const _recommendedTitle = 'Preporučeni studenti';
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.svgAsset, required this.label, this.onTap});

  final String svgAsset;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const iconColor = Color(0xFF212121);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 110,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              svgAsset,
              width: 40,
              height: 40,
              colorFilter: const ColorFilter.mode(iconColor, BlendMode.srcIn),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
