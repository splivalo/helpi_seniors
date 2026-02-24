import 'package:flutter/material.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';
import 'package:helpi_senior/core/utils/mock_data.dart';
import 'package:helpi_senior/features/marketplace/presentation/student_detail_screen.dart';
import 'package:helpi_senior/shared/widgets/student_card.dart';

/// Marketplace — lista studenata s filterima.
class MarketplaceScreen extends StatefulWidget {
  const MarketplaceScreen({super.key});

  @override
  State<MarketplaceScreen> createState() => MarketplaceScreenState();
}

class MarketplaceScreenState extends State<MarketplaceScreen> {
  final Set<ServiceType> _selectedServices = {};
  String? _selectedDayLabel; // null = bilo koji dan
  List<MockStudent> _filtered = MockData.students;

  static const _filterDays = ['Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sub', 'Ned'];

  /// Postavi filter usluge izvana (npr. klik s HomeScreen).
  void applyServiceFilter(ServiceType type) {
    _selectedServices
      ..clear()
      ..add(type);
    _selectedDayLabel = null;
    _applyFilters();
  }

  void _applyFilters() {
    setState(() {
      _filtered = MockData.students.where((s) {
        if (_selectedServices.isNotEmpty &&
            !_selectedServices.every((t) => s.services.contains(t))) {
          return false;
        }
        if (_selectedDayLabel != null &&
            !s.availableSlots.any(
              (slot) => slot.dayLabel == _selectedDayLabel,
            )) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedServices.clear();
      _selectedDayLabel = null;
      _filtered = MockData.students;
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Ručka ─────────────────────────
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.filterTitle,
                    style: Theme.of(builderContext).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 24),

                  // ── Vrsta usluge ──────────────────
                  Text(
                    AppStrings.filterService,
                    style: Theme.of(builderContext).textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: ServiceType.values.map((type) {
                      final isSelected = _selectedServices.contains(type);
                      return FilterChip(
                        label: Text(_serviceLabel(type)),
                        selected: isSelected,
                        onSelected: (selected) {
                          setSheetState(() {
                            if (selected) {
                              _selectedServices.add(type);
                            } else {
                              _selectedServices.remove(type);
                            }
                          });
                        },
                        selectedColor: Theme.of(
                          builderContext,
                        ).colorScheme.primary,
                        labelStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(builderContext).colorScheme.primary,
                        ),
                        showCheckmark: true,
                        checkmarkColor: Colors.white,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),

                  // ── Slobodan dan ─────────────────
                  Text(
                    AppStrings.filterDay,
                    style: Theme.of(builderContext).textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(AppStrings.filterAnyDay),
                        selected: _selectedDayLabel == null,
                        onSelected: (_) {
                          setSheetState(() {
                            _selectedDayLabel = null;
                          });
                        },
                        selectedColor: Theme.of(
                          builderContext,
                        ).colorScheme.primary,
                        labelStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: _selectedDayLabel == null
                              ? Colors.white
                              : Theme.of(builderContext).colorScheme.primary,
                        ),
                        showCheckmark: false,
                      ),
                      ..._filterDays.map((day) {
                        final isSelected = _selectedDayLabel == day;
                        return ChoiceChip(
                          label: Text(day),
                          selected: isSelected,
                          onSelected: (selected) {
                            setSheetState(() {
                              _selectedDayLabel = selected ? day : null;
                            });
                          },
                          selectedColor: Theme.of(
                            builderContext,
                          ).colorScheme.primary,
                          labelStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(builderContext).colorScheme.primary,
                          ),
                          showCheckmark: false,
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ── Gumbi ─────────────────────────
                  ElevatedButton.icon(
                    onPressed: () {
                      _applyFilters();
                      Navigator.of(sheetContext).pop();
                    },
                    icon: const Icon(Icons.check),
                    label: Text(AppStrings.filterApply),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: () {
                      _clearFilters();
                      Navigator.of(sheetContext).pop();
                    },
                    icon: const Icon(Icons.clear),
                    label: Text(AppStrings.filterClear),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasFilters =
        _selectedServices.isNotEmpty || _selectedDayLabel != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.marketplace),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.tune, size: 28),
                onPressed: _openFilterSheet,
                tooltip: AppStrings.filterTitle,
              ),
              if (hasFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: _filtered.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.search_off,
                    size: 64,
                    color: theme.colorScheme.onSurface.withAlpha(100),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.noResults,
                    style: theme.textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: OutlinedButton.icon(
                      onPressed: _clearFilters,
                      icon: const Icon(Icons.clear),
                      label: Text(AppStrings.filterClear),
                    ),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _filtered.length,
              itemBuilder: (context, index) {
                final student = _filtered[index];
                return StudentCard(
                  student: student,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => StudentDetailScreen(student: student),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }

  String _serviceLabel(ServiceType type) {
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
}
