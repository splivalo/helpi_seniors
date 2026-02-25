import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';
import 'package:helpi_senior/core/utils/mock_data.dart';

/// Kartica studenta za marketplace listu.
/// Prikazuje emoji avatar, ime, rating, cijenu i usluge.
class StudentCard extends StatelessWidget {
  const StudentCard({super.key, required this.student, required this.onTap});

  final MockStudent student;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // ── Avatar ────────────────────────
              CircleAvatar(
                radius: 36,
                backgroundColor: theme.colorScheme.secondary.withAlpha(38),
                backgroundImage: student.imageAsset != null
                    ? AssetImage(student.imageAsset!)
                    : null,
                child: student.imageAsset == null
                    ? Text(
                        student.initials,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: theme.colorScheme.secondary,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 16),

              // ── Info ──────────────────────────
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.fullName,
                      style: theme.textTheme.headlineSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    RatingStars(rating: student.rating),
                    const SizedBox(height: 2),
                    Text(
                      AppStrings.ratingCount(student.reviewCount.toString()),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              // ── Badge ─────────────────────────
              if (student.rating >= 4.8) ...[
                const SizedBox(width: 8),
                Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/award.svg',
                      width: 26,
                      height: 26,
                      colorFilter: const ColorFilter.mode(
                        Colors.amber,
                        BlendMode.srcIn,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.amber,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        AppStrings.topBadge,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Zvjezdice za ocjenu (1-5), s polu-zvjezdicama.
class RatingStars extends StatelessWidget {
  const RatingStars({super.key, required this.rating, this.size = 18});

  final double rating;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(5, (i) {
          if (i < rating.floor()) {
            return Icon(Icons.star_rounded, size: size, color: Colors.amber);
          } else if (i < rating) {
            return Icon(
              Icons.star_half_rounded,
              size: size,
              color: Colors.amber,
            );
          }
          return Icon(
            Icons.star_outline_rounded,
            size: size,
            color: Colors.amber,
          );
        }),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: TextStyle(
            fontSize: size - 2,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF212121),
          ),
        ),
      ],
    );
  }
}

/// Chip za vrstu usluge.
class ServiceChip extends StatelessWidget {
  const ServiceChip({
    super.key,
    required this.service,
    this.selected = false,
    this.showIcon = true,
    this.subtle = false,
  });

  final ServiceType service;
  final bool selected;
  final bool showIcon;

  /// Glovo-style: light grey bg + dark text, no accent color.
  final bool subtle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color bgColor;
    final Color fgColor;

    if (subtle) {
      bgColor = Colors.white;
      fgColor = theme.colorScheme.onSurface.withAlpha(200);
    } else if (selected) {
      bgColor = theme.colorScheme.primary;
      fgColor = Colors.white;
    } else {
      bgColor = theme.colorScheme.primaryContainer;
      fgColor = theme.colorScheme.primary;
    }

    return Chip(
      label: Text(
        serviceLabel(service),
        style: TextStyle(fontSize: 12, color: fgColor),
      ),
      avatar: showIcon
          ? SvgPicture.asset(
              serviceAsset(service),
              width: 16,
              height: 16,
              colorFilter: ColorFilter.mode(fgColor, BlendMode.srcIn),
            )
          : null,
      backgroundColor: bgColor,
      side: subtle ? BorderSide(color: Colors.grey.shade300) : BorderSide.none,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }

  static String serviceLabel(ServiceType type) {
    switch (type) {
      case ServiceType.activities:
        return AppStrings.serviceActivities;
      case ServiceType.shopping:
        return AppStrings.serviceShopping;
      case ServiceType.household:
        return AppStrings.serviceHousehold;
      case ServiceType.companionship:
        return AppStrings.serviceCompanionship;
      case ServiceType.techHelp:
        return AppStrings.serviceTechHelp;
      case ServiceType.pets:
        return AppStrings.servicePets;
    }
  }

  static String serviceAsset(ServiceType type) {
    switch (type) {
      case ServiceType.activities:
        return 'assets/images/socializing.svg';
      case ServiceType.shopping:
        return 'assets/images/shopping.svg';
      case ServiceType.household:
        return 'assets/images/household.svg';
      case ServiceType.companionship:
        return 'assets/images/transport.svg';
      case ServiceType.techHelp:
        return 'assets/images/technology.svg';
      case ServiceType.pets:
        return 'assets/images/pets.svg';
    }
  }
}
