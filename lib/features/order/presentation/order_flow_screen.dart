import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_senior/app/theme.dart';
import 'package:helpi_senior/core/l10n/app_strings.dart';

// ─── Model za jednu stavku dana s vremenom ──────────────────────
class _DayEntry {
  _DayEntry({required this.day});

  final int day; // 1=Mon … 7=Sun
  int? fromHour; // 8–20
  int? duration; // 1–4
}

// ─── Booking mode enum ──────────────────────────────────────────
enum _BookingMode { oneTime, recurring }

/// 3-step order flow:
///   1) Kada?       — frekvencija, datum, dani + vrijeme
///   2) Što vam treba?  — usluge (placeholder)
///   3) Pregled         — summary + poruka (placeholder)
class OrderFlowScreen extends StatefulWidget {
  const OrderFlowScreen({super.key});

  @override
  State<OrderFlowScreen> createState() => _OrderFlowScreenState();
}

class _OrderFlowScreenState extends State<OrderFlowScreen> {
  int _currentStep = 0;

  // ── Scroll controller for auto-focus ──────────
  final ScrollController _step1Scroll = ScrollController();

  // ── Step 1 state ──────────────────────────────
  _BookingMode _bookingMode = _BookingMode.oneTime;

  // One-time
  DateTime? _oneTimeDate;
  int? _oneTimeFromHour;
  int? _oneTimeDuration;

  // Recurring
  DateTime? _startDate;
  DateTime? _endDate;
  bool _hasEndDate = false;
  final List<_DayEntry> _dayEntries = [];
  bool _showingDayPicker = false;

  // ── Step 2 state ──────────────────────────────
  final Set<String> _selectedServices = {};
  final TextEditingController _serviceNoteController = TextEditingController();

  // ── Step 3 state ──────────────────────────────
  final TextEditingController _notesController = TextEditingController();

  // ── Constants ─────────────────────────────────
  static const _teal = Color(0xFF009D9D);
  static const _timeHours = [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19];
  static const _durations = [1, 2, 3, 4];

  @override
  void dispose() {
    _notesController.dispose();
    _serviceNoteController.dispose();
    _step1Scroll.dispose();
    super.dispose();
  }

  // ── Helpers ───────────────────────────────────
  Set<int> get _usedDays => _dayEntries.map((e) => e.day).toSet();

  List<int> get _availableDays {
    final all = [1, 2, 3, 4, 5, 6, 7].where((d) => !_usedDays.contains(d));
    // When end date is set, only show days that fall within the range
    if (_hasEndDate && _endDate != null && _startDate != null) {
      return all.where((d) => _isDayInRange(d)).toList();
    }
    return all.toList();
  }

  /// Returns true if [weekday] has at least one occurrence between
  /// [_startDate] and [_endDate].
  bool _isDayInRange(int weekday) {
    if (_startDate == null) return true;
    final first = _firstOccurrence(weekday, _startDate!);
    if (!_hasEndDate || _endDate == null) return true;
    return !first.isAfter(_endDate!);
  }

  String _dayFullName(int day) {
    switch (day) {
      case 1:
        return AppStrings.dayMonFull;
      case 2:
        return AppStrings.dayTueFull;
      case 3:
        return AppStrings.dayWedFull;
      case 4:
        return AppStrings.dayThuFull;
      case 5:
        return AppStrings.dayFriFull;
      case 6:
        return AppStrings.daySatFull;
      case 7:
        return AppStrings.daySunFull;
      default:
        return '';
    }
  }

  String _dayShortName(int day) {
    switch (day) {
      case 1:
        return AppStrings.dayMonShort;
      case 2:
        return AppStrings.dayTueShort;
      case 3:
        return AppStrings.dayWedShort;
      case 4:
        return AppStrings.dayThuShort;
      case 5:
        return AppStrings.dayFriShort;
      case 6:
        return AppStrings.daySatShort;
      case 7:
        return AppStrings.daySunShort;
      default:
        return '';
    }
  }

  String _formatDate(DateTime date) {
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    return '$d.$m.${date.year}';
  }

  /// Removes day entries whose weekday no longer falls between
  /// [_startDate] and [_endDate].
  void _removeInvalidDayEntries() {
    if (_startDate == null) return;
    _dayEntries.removeWhere((e) => !_isDayInRange(e.day));
  }

  /// Finds the first occurrence of [weekday] (1=Mon… 7=Sun) on or after [from].
  DateTime _firstOccurrence(int weekday, DateTime from) {
    // DateTime.weekday: 1=Mon … 7=Sun (matches our convention)
    final diff = (weekday - from.weekday + 7) % 7;
    return from.add(Duration(days: diff == 0 ? 0 : diff));
  }

  String _durationLabel(int hours) {
    switch (hours) {
      case 1:
        return AppStrings.hour1;
      case 2:
        return AppStrings.hour2;
      case 3:
        return AppStrings.hour3;
      case 4:
        return AppStrings.hour4;
      default:
        return '$hours h';
    }
  }

  bool get _step1Valid {
    if (_bookingMode == _BookingMode.oneTime) {
      return _oneTimeDate != null &&
          _oneTimeFromHour != null &&
          _oneTimeDuration != null;
    }
    if (_startDate == null) return false;
    if (_hasEndDate && _endDate == null) return false;
    if (_dayEntries.isEmpty) return false;
    // Safety: ensure all day entries actually fall within the date range
    if (_hasEndDate && _endDate != null) {
      if (!_dayEntries.every((e) => _isDayInRange(e.day))) return false;
    }
    return _dayEntries.every((e) => e.fromHour != null && e.duration != null);
  }

  Future<void> _pickOneTimeDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _oneTimeDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      locale: const Locale('hr'),
    );
    if (!context.mounted) return;
    if (picked != null) {
      setState(() => _oneTimeDate = picked);
    }
  }

  Future<void> _pickEndDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? now,
      firstDate: _startDate ?? now,
      lastDate: DateTime(now.year + 2),
      locale: const Locale('hr'),
    );
    if (!context.mounted) return;
    if (picked != null) {
      setState(() {
        _endDate = picked;
        // Remove day entries that no longer fit in the date range
        _removeInvalidDayEntries();
      });
    }
  }

  Future<void> _pickStartDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      locale: const Locale('hr'),
    );
    if (!context.mounted) return;
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Reset end date if it's before start
        if (_endDate != null && _endDate!.isBefore(picked)) {
          _endDate = null;
        }
        // Remove day entries that no longer fit in the date range
        _removeInvalidDayEntries();
      });
    }
  }

  // ═════════════════════════════════════════════════════════════════
  //  BUILD
  // ═════════════════════════════════════════════════════════════════
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.newOrder),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            // Step indicator bar
            _buildStepIndicator(),

            // Step content
            Expanded(
              child: _currentStep == 0
                  ? _buildStep1(theme)
                  : _currentStep == 1
                  ? _buildStep2(theme)
                  : _buildStep3(theme),
            ),

            // CTA
            _buildCTA(theme),
          ],
        ),
      ),
    );
  }

  // ── Step indicator (3 bars) ───────────────────
  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Row(
        children: List.generate(3, (i) {
          final isActive = i <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive
                    ? const Color(0xFFEF5B5B)
                    : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  //  STEP 1 — KADA?
  // ═════════════════════════════════════════════════════════════════
  Widget _buildStep1(ThemeData theme) {
    return SingleChildScrollView(
      controller: _step1Scroll,
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            AppStrings.orderFlowStep1,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),

          // ── Frequency ──
          Text(
            AppStrings.frequency,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _buildFrequencyChips(),
          const SizedBox(height: 24),

          // ── Mode-specific content ──
          if (_bookingMode == _BookingMode.oneTime)
            _buildOneTimeContent(theme)
          else
            _buildRecurringContent(theme),
        ],
      ),
    );
  }

  Widget _buildFrequencyChips() {
    final modes = [
      (AppStrings.oneTime, _BookingMode.oneTime),
      (AppStrings.recurring, _BookingMode.recurring),
    ];
    return Row(
      children: [
        for (int i = 0; i < modes.length; i++) ...[
          if (i > 0) const SizedBox(width: 24),
          Expanded(
            child: GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _bookingMode = modes[i].$2;
                  _showingDayPicker = false;
                });
              },
              child: Column(
                children: [
                  Text(
                    modes[i].$1,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _bookingMode == modes[i].$2
                          ? const Color(0xFFEF5B5B)
                          : const Color(0xFF9E9E9E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: _bookingMode == modes[i].$2
                          ? const Color(0xFFEF5B5B)
                          : const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Generic chip — soft style, edge-to-edge.
  Widget _buildChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFE0F5F5) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? _teal : const Color(0xFFE0E0E0),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isSelected ? _teal : const Color(0xFF2D2D2D),
          ),
        ),
      ),
    );
  }

  // ── One-time: datum + Od + Trajanje ───────────
  Widget _buildOneTimeContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Datum
        Text(
          AppStrings.selectDate,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _buildDateButton(date: _oneTimeDate, onTap: _pickOneTimeDate),

        if (_oneTimeDate != null) ...[
          const SizedBox(height: 24),

          // Od
          Text(
            AppStrings.fromTime,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _buildTimeChips(
            selectedHour: _oneTimeFromHour,
            onSelected: (h) => setState(() => _oneTimeFromHour = h),
          ),
          const SizedBox(height: 20),

          // Trajanje
          Text(
            AppStrings.durationChoice,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          _buildDurationChips(
            selectedDuration: _oneTimeDuration,
            onSelected: (d) => setState(() => _oneTimeDuration = d),
          ),
        ],
      ],
    );
  }

  // ── Recurring: start date + end date (if untilDate) + day entries + add day ──
  Widget _buildRecurringContent(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Start date — always shown
        Text(
          AppStrings.selectStartDate,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _buildDateButton(date: _startDate, onTap: _pickStartDate),
        const SizedBox(height: 16),

        // Switch: Do određenog datuma
        Row(
          children: [
            Expanded(
              child: Text(
                AppStrings.hasEndDate,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Switch(
              value: _hasEndDate,
              onChanged: (val) {
                HapticFeedback.selectionClick();
                setState(() {
                  _hasEndDate = val;
                  if (!val) _endDate = null;
                });
              },
              activeThumbColor: Colors.white,
              activeTrackColor: _teal,
              inactiveThumbColor: _teal,
              trackOutlineColor: WidgetStateProperty.all(_teal),
            ),
          ],
        ),

        // End date — only when switch is ON
        if (_hasEndDate) ...[
          const SizedBox(height: 8),
          _buildDateButton(date: _endDate, onTap: _pickEndDate),
          const SizedBox(height: 24),
        ] else
          const SizedBox(height: 8),

        // Existing day entries
        ..._dayEntries.asMap().entries.map((mapEntry) {
          return _buildDayCard(theme, mapEntry.value, mapEntry.key);
        }),

        // Day picker (visible after "+" tap)
        if (_showingDayPicker && _availableDays.isNotEmpty)
          _buildDayPickerSection(theme),

        // "+ Dodaj dan" button
        if (!_showingDayPicker && _availableDays.isNotEmpty)
          _buildAddDayButton(),
      ],
    );
  }

  // ── Date button ──────────────────────────────
  Widget _buildDateButton({
    required DateTime? date,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE0E0E0)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              size: 20,
              color: date != null
                  ? const Color(0xFF212121)
                  : const Color(0xFF9E9E9E),
            ),
            const SizedBox(width: 12),
            Text(
              date != null ? _formatDate(date) : AppStrings.selectDate,
              style: TextStyle(
                fontSize: 16,
                color: date != null
                    ? const Color(0xFF212121)
                    : const Color(0xFF9E9E9E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Time chips (08:00 – 19:00) ───────────────
  Widget _buildTimeChips({
    required int? selectedHour,
    required ValueChanged<int> onSelected,
  }) {
    // 12 hours → rows of 4: 4+4+4
    const perRow = 4;
    final rows = <List<int>>[
      for (int s = 0; s < _timeHours.length; s += perRow)
        _timeHours.sublist(
          s,
          (s + perRow > _timeHours.length) ? _timeHours.length : s + perRow,
        ),
    ];
    return Column(
      children: [
        for (int r = 0; r < rows.length; r++) ...[
          if (r > 0) const SizedBox(height: 8),
          Row(
            children: [
              for (int i = 0; i < rows[r].length; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Expanded(
                  child: _buildChip(
                    label: '${rows[r][i].toString().padLeft(2, '0')}:00',
                    isSelected: selectedHour == rows[r][i],
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onSelected(rows[r][i]);
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ],
    );
  }

  // ── Duration chips (1–4 h) ───────────────────
  Widget _buildDurationChips({
    required int? selectedDuration,
    required ValueChanged<int> onSelected,
  }) {
    return Row(
      children: [
        for (int i = 0; i < _durations.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: _buildChip(
              label: _durationLabel(_durations[i]),
              isSelected: selectedDuration == _durations[i],
              onTap: () {
                HapticFeedback.selectionClick();
                onSelected(_durations[i]);
              },
            ),
          ),
        ],
      ],
    );
  }

  // ── Day card (one per added day) ─────────────
  Widget _buildDayCard(ThemeData theme, _DayEntry entry, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: day name + ✕
          Row(
            children: [
              Text(
                _dayFullName(entry.day),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _dayEntries.removeAt(index));
                },
                child: const Icon(
                  Icons.close,
                  size: 22,
                  color: Color(0xFF757575),
                ),
              ),
            ],
          ),

          // Info: first service date
          if (_startDate != null) ...[
            const SizedBox(height: 6),
            Text(
              AppStrings.firstServiceDate(
                _formatDate(_firstOccurrence(entry.day, _startDate!)),
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                color: const Color(0xFF757575),
              ),
            ),
          ],

          const SizedBox(height: 16),

          // Od
          Text(
            AppStrings.fromTime,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildTimeChips(
            selectedHour: entry.fromHour,
            onSelected: (h) => setState(() => entry.fromHour = h),
          ),
          const SizedBox(height: 14),

          // Trajanje
          Text(
            AppStrings.durationChoice,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildDurationChips(
            selectedDuration: entry.duration,
            onSelected: (d) => setState(() => entry.duration = d),
          ),
        ],
      ),
    );
  }

  // ── Day picker (shown after "+" tap) ─────────
  Widget _buildDayPickerSection(ThemeData theme) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.selectDay,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (int i = 0; i < _availableDays.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: _buildChip(
                    label: _dayShortName(_availableDays[i]),
                    isSelected: false,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _dayEntries.add(_DayEntry(day: _availableDays[i]));
                        _showingDayPicker = false;
                      });
                      // Auto-scroll to show the new card
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (_step1Scroll.hasClients) {
                          _step1Scroll.animateTo(
                            _step1Scroll.position.maxScrollExtent,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                          );
                        }
                      });
                    },
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // ── "+ Dodaj dan" button ──────────────────────
  Widget _buildAddDayButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _showingDayPicker = true);
        // Auto-scroll to show the day picker
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_step1Scroll.hasClients) {
            _step1Scroll.animateTo(
              _step1Scroll.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _teal, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.add_circle_outline,
              color: Color(0xFF009D9D),
              size: 24,
            ),
            const SizedBox(width: 10),
            Text(
              AppStrings.addDay,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF009D9D),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  //  STEP 2 — ŠTO VAM TREBA?
  // ═════════════════════════════════════════════════════════════════

  // Service chip definitions: key → label getter
  static final _serviceChips = <String, String Function()>{
    'shopping': () => AppStrings.bookingChipShopping,
    'pharmacy': () => AppStrings.bookingChipPharmacy,
    'cleaning': () => AppStrings.bookingChipCleaning,
    'companionship': () => AppStrings.bookingChipCompanionship,
    'walk': () => AppStrings.bookingChipWalk,
    'escort': () => AppStrings.bookingChipEscort,
    'other': () => AppStrings.bookingChipOther,
  };

  Widget _buildStep2(ThemeData theme) {
    final entries = _serviceChips.entries.toList();
    // 2 per row → 4 rows (7 items + 1 empty slot)
    const perRow = 2;
    final rows = <List<MapEntry<String, String Function()>>>[];
    for (var i = 0; i < entries.length; i += perRow) {
      rows.add(
        entries.sublist(
          i,
          (i + perRow > entries.length) ? entries.length : i + perRow,
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.orderFlowStep2,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),

          // Service chips — 2 per row, edge-to-edge
          for (int r = 0; r < rows.length; r++) ...[
            if (r > 0) const SizedBox(height: 8),
            Row(
              children: [
                for (int i = 0; i < rows[r].length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(
                    child: _buildChip(
                      label: rows[r][i].value(),
                      isSelected: _selectedServices.contains(rows[r][i].key),
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() {
                          final key = rows[r][i].key;
                          if (_selectedServices.contains(key)) {
                            _selectedServices.remove(key);
                          } else {
                            _selectedServices.add(key);
                          }
                        });
                      },
                    ),
                  ),
                ],
                // Pad odd row
                if (rows[r].length < perRow)
                  for (int p = 0; p < perRow - rows[r].length; p++) ...[
                    const SizedBox(width: 8),
                    const Expanded(child: SizedBox()),
                  ],
              ],
            ),
          ],

          const SizedBox(height: 24),

          // ── Escort info card (shown when Pratnja is selected) ──
          if (_selectedServices.contains('escort')) ...[
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: HelpiTheme.cardBlue,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 20,
                    color: Color(0xFF1976D2),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      AppStrings.escortInfo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: const Color(0xFF1565C0),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // Text field for additional description
          TextField(
            controller: _serviceNoteController,
            maxLines: 4,
            textCapitalization: TextCapitalization.sentences,
            decoration: InputDecoration(
              hintText: AppStrings.serviceNoteHint,
              hintMaxLines: 3,
              alignLabelWithHint: true,
            ),
          ),
        ],
      ),
    );
  }

  // ═════════════════════════════════════════════════════════════════
  //  STEP 3 — PREGLED
  // ═════════════════════════════════════════════════════════════════
  Widget _buildStep3(ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.orderFlowStep3,
            style: theme.textTheme.headlineMedium,
          ),
          const SizedBox(height: 20),

          // ── Summary card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Frequency
                _summaryRow(
                  theme,
                  AppStrings.orderSummaryFrequency,
                  _bookingModeLabel(),
                ),
                const Divider(height: 24),

                // Date / Start+End
                if (_bookingMode == _BookingMode.oneTime) ...[
                  _summaryRow(
                    theme,
                    AppStrings.orderSummaryDate,
                    _oneTimeDate != null ? _formatDate(_oneTimeDate!) : '-',
                  ),
                  const Divider(height: 24),
                  _summaryRow(
                    theme,
                    AppStrings.orderSummaryTime,
                    _oneTimeFromHour != null
                        ? '${_oneTimeFromHour.toString().padLeft(2, '0')}:00'
                        : '-',
                  ),
                  const Divider(height: 24),
                  _summaryRow(
                    theme,
                    AppStrings.orderSummaryDuration,
                    _oneTimeDuration != null
                        ? _durationLabel(_oneTimeDuration!)
                        : '-',
                  ),
                ] else ...[
                  _summaryRow(
                    theme,
                    AppStrings.orderSummaryStartDate,
                    _startDate != null ? _formatDate(_startDate!) : '-',
                  ),
                  if (_hasEndDate && _endDate != null) ...[
                    const Divider(height: 24),
                    _summaryRow(
                      theme,
                      AppStrings.orderSummaryEndDate,
                      _endDate != null ? _formatDate(_endDate!) : '-',
                    ),
                  ],
                  const Divider(height: 24),

                  // Days
                  Text(
                    AppStrings.orderSummaryDays,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ..._dayEntries.map((entry) {
                    final timeStr = entry.fromHour != null
                        ? '${entry.fromHour.toString().padLeft(2, '0')}:00'
                        : '-';
                    final durStr = entry.duration != null
                        ? _durationLabel(entry.duration!)
                        : '-';
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text(
                            _dayFullName(entry.day),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '$timeStr  ·  $durStr',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    );
                  }),
                ],

                const Divider(height: 24),

                // Services
                Text(
                  AppStrings.orderSummaryServices,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: const Color(0xFF757575),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _selectedServices.map((key) {
                    final label = _serviceChips[key]?.call() ?? key;
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2D2D2D),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }).toList(),
                ),

                // Service note
                if (_serviceNoteController.text.trim().isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    AppStrings.orderSummaryNotes,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF757575),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _serviceNoteController.text.trim(),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ── General overtime disclaimer ──
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: HelpiTheme.cardBlue,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 20,
                  color: Color(0xFF1976D2),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    AppStrings.overtimeDisclaimer,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0xFF1565C0),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _bookingModeLabel() {
    switch (_bookingMode) {
      case _BookingMode.oneTime:
        return AppStrings.oneTime;
      case _BookingMode.recurring:
        if (_hasEndDate && _endDate != null) {
          return AppStrings.recurringWithEnd(_formatDate(_endDate!));
        }
        return AppStrings.recurringNoEnd;
    }
  }

  Widget _summaryRow(ThemeData theme, String label, String value) {
    return Row(
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: const Color(0xFF757575),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ═════════════════════════════════════════════════════════════════
  //  CTA BUTTON
  // ═════════════════════════════════════════════════════════════════
  Widget _buildCTA(ThemeData theme) {
    final bool isEnabled;
    if (_currentStep == 0) {
      isEnabled = _step1Valid;
    } else if (_currentStep == 1) {
      isEnabled = _selectedServices.isNotEmpty;
    } else {
      isEnabled = true;
    }
    final label = _currentStep < 2 ? AppStrings.next : AppStrings.placeOrder;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      child: ElevatedButton(
        onPressed: isEnabled
            ? () {
                HapticFeedback.selectionClick();
                if (_currentStep < 2) {
                  setState(() => _currentStep++);
                } else {
                  // Final submit — will be implemented later
                  Navigator.pop(context);
                }
              }
            : null,
        child: Text(label),
      ),
    );
  }
}
