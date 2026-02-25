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
  final Set<String> _selectedDays = {};
  List<MockStudent> _filtered = MockData.students;

  static const _filterDays = ['Pon', 'Uto', 'Sri', 'Čet', 'Pet', 'Sub', 'Ned'];

  void _applyFilters() {
    setState(() {
      _filtered = MockData.students.where((s) {
        if (_selectedDays.isNotEmpty &&
            !_selectedDays.every(
              (day) => s.availableSlots.any((slot) => slot.dayLabel == day),
            )) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedDays.clear();
      _filtered = MockData.students;
    });
  }

  void _openFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final bottomPad = MediaQuery.of(sheetContext).viewPadding.bottom;
        return StatefulBuilder(
          builder: (builderContext, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(24, 16, 24, 32 + bottomPad),
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

                  // ── Dostupnost ─────────────────
                  Text(
                    AppStrings.filterDay,
                    style: Theme.of(builderContext).textTheme.bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _filterDays.map((day) {
                      final isSelected = _selectedDays.contains(day);
                      return FilterChip(
                        label: Text(day),
                        selected: isSelected,
                        onSelected: (selected) {
                          setSheetState(() {
                            if (selected) {
                              _selectedDays.add(day);
                            } else {
                              _selectedDays.remove(day);
                            }
                          });
                        },
                        selectedColor: Theme.of(
                          builderContext,
                        ).colorScheme.primary,
                        side: isSelected
                            ? BorderSide.none
                            : BorderSide(color: Colors.grey.shade300),
                        labelStyle: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(builderContext).colorScheme.onSurface,
                        ),
                        showCheckmark: true,
                        checkmarkColor: Colors.white,
                      );
                    }).toList(),
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
    final hasFilters = _selectedDays.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.navStudents),
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
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
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
}
