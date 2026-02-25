import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';
import 'package:helpi_senior/core/utils/mock_data.dart';
import 'package:helpi_senior/features/booking/presentation/booking_flow_screen.dart';
import 'package:helpi_senior/shared/widgets/student_card.dart';

/// Detalji profila studenta — bio, recenzije, kalendar dostupnosti, CTA gumb.
class StudentDetailScreen extends StatefulWidget {
  const StudentDetailScreen({super.key, required this.student});

  final MockStudent student;

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late DateTime _displayedMonth;
  MockDateAvailability? _selectedAvailability;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final daysLeft = DateTime(now.year, now.month + 1, 0).day - now.day;
    _displayedMonth = daysLeft < 7
        ? DateTime(now.year, now.month + 1)
        : DateTime(now.year, now.month);
    _autoSelectFirstAvailable();
  }

  void _autoSelectFirstAvailable() {
    final avail = widget.student.getMonthAvailability(
      _displayedMonth.year,
      _displayedMonth.month,
    );
    final first = avail.where((a) => !a.isFullyBooked).firstOrNull;
    _selectedAvailability = first;
  }

  bool get _canGoBack {
    final now = DateTime.now();
    return _displayedMonth.isAfter(DateTime(now.year, now.month));
  }

  bool get _canGoForward {
    final now = DateTime.now();
    final limit = DateTime(now.year, now.month + 2);
    return _displayedMonth.isBefore(limit);
  }

  void _openTimePicker(MockDateAvailability avail) {
    final slot = MockSlot(
      dayLabel: avail.dayLabel,
      date: avail.dateFormatted,
      startTime: '${avail.startHour.toString().padLeft(2, '0')}:00',
      endTime: '${avail.endHour.toString().padLeft(2, '0')}:00',
      bookedHours: avail.bookedHours,
    );
    final startHour = avail.startHour;
    final endHour = avail.endHour;
    final maxHours = endHour - startHour;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _TimePickerSheet(
          slot: slot,
          student: widget.student,
          startHour: startHour,
          endHour: endHour,
          maxHours: maxHours,
          hourlyRate: widget.student.hourlyRate,
          availableSlots: widget.student.availableSlots,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(widget.student.fullName)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Avatar + osnovni info ─────────────────
          Center(
            child: CircleAvatar(
              radius: 60,
              backgroundColor: theme.colorScheme.secondary.withAlpha(38),
              backgroundImage: widget.student.imageAsset != null
                  ? AssetImage(widget.student.imageAsset!)
                  : null,
              child: widget.student.imageAsset == null
                  ? Text(
                      widget.student.initials,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.secondary,
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              widget.student.fullName,
              style: theme.textTheme.headlineLarge,
            ),
          ),
          const SizedBox(height: 8),
          Center(child: RatingStars(rating: widget.student.rating, size: 24)),
          const SizedBox(height: 4),
          Center(
            child: Text(
              AppStrings.ratingCount(widget.student.reviewCount.toString()),
              style: theme.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 24),

          // ── Bio ───────────────────────────────────
          Text(AppStrings.aboutStudent, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(widget.student.bio, style: theme.textTheme.bodyLarge),
          const SizedBox(height: 24),

          // ── Kalendar dostupnosti ──────────────────
          Text(AppStrings.availability, style: theme.textTheme.headlineSmall),
          const SizedBox(height: 12),
          _buildCalendar(theme),
          const SizedBox(height: 8),
          _buildLegend(theme),
          const SizedBox(height: 16),

          // ── Odabrani datum info + Rezerviraj ──────
          if (_selectedAvailability != null) ...[
            _buildSelectedDateInfo(theme),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                HapticFeedback.mediumImpact();
                _openTimePicker(_selectedAvailability!);
              },
              icon: const Icon(Icons.calendar_month),
              label: Text(AppStrings.bookNow),
            ),
          ] else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  AppStrings.selectDatePrompt,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 24),

          // ── Recenzije (mock) ──────────────────────
          Text(
            '${AppStrings.reviews} (${widget.student.reviewCount})',
            style: theme.textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          _MockReview(
            name: 'Josip K.',
            rating: 5,
            text:
                'Izvrsna pomoć! Strpljivo mi objasnila kako koristiti '
                'WhatsApp. Toplo preporučujem.',
          ),
          const SizedBox(height: 8),
          _MockReview(
            name: 'Marica S.',
            rating: 4,
            text:
                'Vrlo ljubazna i točna. Došla na vrijeme i sve obavila '
                'kako smo se dogovorili.',
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── Calendar ───────────────────────────────────────────────────

  Widget _buildCalendar(ThemeData theme) {
    final year = _displayedMonth.year;
    final month = _displayedMonth.month;
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    final avail = widget.student.getMonthAvailability(year, month);
    final availMap = <int, MockDateAvailability>{};
    for (final a in avail) {
      availMap[a.date.day] = a;
    }

    final firstOfMonth = DateTime(year, month, 1);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final startWeekday = firstOfMonth.weekday; // 1=Mon..7=Sun

    // Build cells
    final cells = <Widget>[];
    for (var i = 0; i < startWeekday - 1; i++) {
      cells.add(const SizedBox());
    }
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(year, month, day);
      final isPast = date.isBefore(todayDate);
      final isToday =
          date.year == todayDate.year &&
          date.month == todayDate.month &&
          date.day == todayDate.day;
      final availability = availMap[day];
      final isSelected =
          _selectedAvailability?.date.day == day &&
          _selectedAvailability?.date.month == month &&
          _selectedAvailability?.date.year == year;

      final canTap =
          !isPast && availability != null && !availability.isFullyBooked;

      cells.add(
        GestureDetector(
          onTap: canTap
              ? () => setState(() => _selectedAvailability = availability)
              : null,
          child: _buildDateCell(
            theme: theme,
            day: day,
            isPast: isPast,
            isToday: isToday,
            availability: availability,
            isSelected: isSelected,
          ),
        ),
      );
    }

    // Build rows of 7
    final rows = <Widget>[];
    for (var i = 0; i < cells.length; i += 7) {
      final end = (i + 7).clamp(0, cells.length);
      final rowChildren = <Widget>[];
      for (var j = i; j < end; j++) {
        rowChildren.add(Expanded(child: cells[j]));
      }
      for (var j = end - i; j < 7; j++) {
        rowChildren.add(const Expanded(child: SizedBox()));
      }
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 2),
          child: Row(children: rowChildren),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildMonthHeader(theme),
          const SizedBox(height: 16),
          _buildWeekdayHeaders(theme),
          const SizedBox(height: 8),
          ...rows,
        ],
      ),
    );
  }

  Widget _buildMonthHeader(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: _canGoBack
              ? () => setState(() {
                  _displayedMonth = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month - 1,
                  );
                  _selectedAvailability = null;
                  _autoSelectFirstAvailable();
                })
              : null,
        ),
        Text(
          '${AppStrings.monthName(_displayedMonth.month)} '
          '${_displayedMonth.year}',
          style: theme.textTheme.headlineSmall,
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: _canGoForward
              ? () => setState(() {
                  _displayedMonth = DateTime(
                    _displayedMonth.year,
                    _displayedMonth.month + 1,
                  );
                  _selectedAvailability = null;
                  _autoSelectFirstAvailable();
                })
              : null,
        ),
      ],
    );
  }

  Widget _buildWeekdayHeaders(ThemeData theme) {
    final headers = [
      AppStrings.dayMonShort,
      AppStrings.dayTueShort,
      AppStrings.dayWedShort,
      AppStrings.dayThuShort,
      AppStrings.dayFriShort,
      AppStrings.daySatShort,
      AppStrings.daySunShort,
    ];
    return Row(
      children: headers
          .map(
            (h) => Expanded(
              child: Center(
                child: Text(
                  h,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildDateCell({
    required ThemeData theme,
    required int day,
    required bool isPast,
    required bool isToday,
    MockDateAvailability? availability,
    required bool isSelected,
  }) {
    Color bgColor;
    Color textColor;

    if (isSelected && availability != null && !availability.isFullyBooked) {
      bgColor = theme.colorScheme.secondary;
      textColor = Colors.white;
    } else if (isPast) {
      bgColor = Colors.transparent;
      textColor = Colors.grey.shade300;
    } else if (availability == null) {
      bgColor = Colors.transparent;
      textColor = Colors.grey.shade400;
    } else if (availability.isFullyBooked) {
      bgColor = Colors.red.shade50;
      textColor = Colors.grey.shade500;
    } else if (availability.isPartiallyBooked) {
      bgColor = Colors.orange.shade50;
      textColor = Colors.orange.shade800;
    } else {
      bgColor = theme.colorScheme.secondary.withAlpha(30);
      textColor = theme.colorScheme.secondary;
    }

    return Container(
      height: 44,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isToday && !isSelected
            ? Border.all(color: theme.colorScheme.secondary, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '$day',
        style: TextStyle(
          fontSize: 16,
          fontWeight: isToday || isSelected ? FontWeight.w700 : FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem(
          theme.colorScheme.secondary.withAlpha(30),
          AppStrings.calendarFree,
          theme,
        ),
        const SizedBox(width: 16),
        _legendItem(Colors.orange.shade50, AppStrings.calendarPartial, theme),
        const SizedBox(width: 16),
        _legendItem(Colors.red.shade50, AppStrings.calendarBooked, theme),
      ],
    );
  }

  Widget _legendItem(Color color, String label, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }

  Widget _buildSelectedDateInfo(ThemeData theme) {
    final avail = _selectedAvailability!;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondary.withAlpha(15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.secondary.withAlpha(60)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withAlpha(30),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              Icons.event_available,
              color: theme.colorScheme.secondary,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${avail.dayLabel} ${avail.dateFormatted}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${avail.startHour.toString().padLeft(2, '0')}:00 – '
                  '${avail.endHour.toString().padLeft(2, '0')}:00',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
          ),
          Text(
            avail.isPartiallyBooked
                ? AppStrings.freeHoursCount(
                    avail.freeHourCount.toString(),
                    avail.totalHours.toString(),
                  )
                : AppStrings.allHoursFree,
            style: theme.textTheme.bodySmall?.copyWith(
              color: avail.isPartiallyBooked
                  ? Colors.orange.shade800
                  : theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Postavke vremena za jedan dan.
class _DayTimeSettings {
  int startHour;
  int duration = 1;
  bool configured = false;

  _DayTimeSettings({required this.startHour});

  int get endHour => startHour + duration;

  String get startTimeFormatted => _fmt(startHour);
  String get endTimeFormatted => _fmt(endHour);

  static String _fmt(int h) {
    return '${h.toString().padLeft(2, '0')}:00';
  }

  /// Klamp sve da bude validno unutar [windowStart..windowEnd].
  void clamp(int windowStart, int windowEnd) {
    final maxDur = windowEnd - startHour;
    if (duration > maxDur) {
      duration = maxDur.clamp(1, 4);
    }
    if (startHour + duration > windowEnd) {
      startHour = windowEnd - duration;
    }
  }
}

/// Bottom sheet za odabir početnog sata i trajanja unutar dostupnog prozora.
class _TimePickerSheet extends StatefulWidget {
  const _TimePickerSheet({
    required this.slot,
    required this.student,
    required this.startHour,
    required this.endHour,
    required this.maxHours,
    required this.hourlyRate,
    required this.availableSlots,
  });

  final MockSlot slot;
  final MockStudent student;
  final int startHour;
  final int endHour;
  final int maxHours;
  final double hourlyRate;
  final List<MockSlot> availableSlots;

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  bool _isRecurring = false;
  Set<int> _selectedDays = {}; // 1=Pon .. 7=Ned
  bool _hasEndDate = false;
  DateTime? _endDate;
  int? _expandedDay; // koji dan je otvoren u recurring modu

  /// Per-day postavke (svaki dan ima svoj start i duration).
  final Map<int, _DayTimeSettings> _daySettings = {};

  static const _dayLabelToInt = {
    'Pon': 1,
    'Uto': 2,
    'Sri': 3,
    'Čet': 4,
    'Pet': 5,
    'Sub': 6,
    'Ned': 7,
  };

  static const _allDays = [
    (1, 'dayMon'),
    (2, 'dayTue'),
    (3, 'dayWed'),
    (4, 'dayThu'),
    (5, 'dayFri'),
    (6, 'daySat'),
    (7, 'daySun'),
  ];

  /// Only the days the student is actually available.
  List<(int, String)> get _studentAvailableDays {
    final availableInts = widget.availableSlots
        .map((s) => _dayLabelToInt[s.dayLabel])
        .whereType<int>()
        .toSet();
    return _allDays.where((e) => availableInts.contains(e.$1)).toList();
  }

  static const _intToShort = {
    1: 'dayMon',
    2: 'dayTue',
    3: 'dayWed',
    4: 'dayThu',
    5: 'dayFri',
    6: 'daySat',
    7: 'daySun',
  };

  @override
  void initState() {
    super.initState();
    final dayInt = _dayLabelToInt[widget.slot.dayLabel] ?? 1;
    _selectedDays = {dayInt};
    _expandedDay = dayInt;
    _ensureDaySettings(dayInt);
  }

  /// Osiguraj da dan ima _DayTimeSettings, ako nema — kreiraj default.
  _DayTimeSettings _ensureDaySettings(int day) {
    return _daySettings.putIfAbsent(
      day,
      () => _DayTimeSettings(startHour: widget.startHour),
    );
  }

  /// Trenutni dan-settings (za jednokratni mod ili expanded dan).
  _DayTimeSettings get _currentSettings {
    final day = _isRecurring
        ? (_expandedDay ?? _selectedDays.first)
        : (_dayLabelToInt[widget.slot.dayLabel] ?? 1);
    return _ensureDaySettings(day);
  }

  /// Mogući početni sati za dani settings.
  List<int> _availableStartHoursFor(_DayTimeSettings s) {
    final hours = <int>[];
    for (var h = widget.startHour; h + s.duration <= widget.endHour; h++) {
      hours.add(h);
    }
    return hours;
  }

  /// Rezervirani sati za dani (iz MockSlot.bookedHours).
  Set<int> _bookedHoursForDay(int dayInt) {
    final dayLabel = _dayLabelToInt.entries
        .where((e) => e.value == dayInt)
        .map((e) => e.key)
        .firstOrNull;
    if (dayLabel == null) return {};
    final slot = widget.availableSlots
        .where((s) => s.dayLabel == dayLabel)
        .firstOrNull;
    return slot?.bookedHours.toSet() ?? {};
  }

  /// Rezervirani sati za trenutni dan.
  Set<int> get _currentBookedHours {
    if (!_isRecurring) {
      return widget.slot.bookedHours.toSet();
    }
    final day = _expandedDay ?? _selectedDays.first;
    return _bookedHoursForDay(day);
  }

  List<int> _availableDurationsFor(_DayTimeSettings s, Set<int> bookedHours) {
    final maxFromStart = widget.endHour - s.startHour;
    // Limit to first booked hour after start.
    int maxBeforeBooked = maxFromStart;
    for (final b in bookedHours) {
      if (b >= s.startHour) {
        final limit = b - s.startHour;
        if (limit < maxBeforeBooked) maxBeforeBooked = limit;
      }
    }
    final durations = <int>[];
    for (var d = 1; d <= maxBeforeBooked && d <= 4; d++) {
      durations.add(d);
    }
    return durations;
  }

  double get _totalPrice => _currentSettings.duration * widget.hourlyRate;

  /// Jesu li svi odabrani dani konfigurirani?
  bool get _allConfigured {
    if (!_isRecurring) {
      final day = _dayLabelToInt[widget.slot.dayLabel] ?? 1;
      return _daySettings[day]?.configured ?? false;
    }
    return _selectedDays.every((d) => _daySettings[d]?.configured ?? false);
  }

  String _durationLabel(int d) {
    if (d == 1) return '1 ${AppStrings.hourSingular}';
    return '$d ${AppStrings.hourPlural}';
  }

  String _dayString(String key) {
    return switch (key) {
      'dayMon' => AppStrings.dayMon,
      'dayTue' => AppStrings.dayTue,
      'dayWed' => AppStrings.dayWed,
      'dayThu' => AppStrings.dayThu,
      'dayFri' => AppStrings.dayFri,
      'daySat' => AppStrings.daySat,
      'daySun' => AppStrings.daySun,
      _ => key,
    };
  }

  String _dayShortString(String key) {
    return switch (key) {
      'dayMon' => AppStrings.dayMonShort,
      'dayTue' => AppStrings.dayTueShort,
      'dayWed' => AppStrings.dayWedShort,
      'dayThu' => AppStrings.dayThuShort,
      'dayFri' => AppStrings.dayFriShort,
      'daySat' => AppStrings.daySatShort,
      'daySun' => AppStrings.daySunShort,
      _ => key,
    };
  }

  String _dayName(int day) => _dayString(_intToShort[day] ?? '');

  String get _recurringSummary {
    final sortedDays = _selectedDays.toList()..sort();
    final dayNames = sortedDays.map(_dayName).join(', ');
    final endText = _hasEndDate && _endDate != null
        ? AppStrings.untilDate(_formatDate(_endDate!))
        : AppStrings.noEndDate;
    return '${AppStrings.everyWeek} $dayNames — $endText';
  }

  String _formatDate(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}.${d.month.toString().padLeft(2, '0')}.${d.year}.';

  // ─── BUILD ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
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

            // ── Naslov: dan i dostupni prozor ──
            Text(
              '${widget.slot.dayLabel} ${widget.slot.date}',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 18,
                  color: theme.colorScheme.onSurface.withAlpha(153),
                ),
                const SizedBox(width: 6),
                Text(
                  AppStrings.availableWindow(
                    widget.slot.startTime,
                    widget.slot.endTime,
                  ),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurface.withAlpha(153),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Jednokratno / Ponavljajuće ─────
            Row(
              children: [
                Expanded(
                  child: _chip(
                    label: AppStrings.oneTime,
                    isSelected: !_isRecurring,
                    onTap: () => setState(() => _isRecurring = false),
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _chip(
                    label: AppStrings.recurring,
                    isSelected: _isRecurring,
                    onTap: () => setState(() => _isRecurring = true),
                    theme: theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── JEDNOKRATNO: jedan time picker ──
            if (!_isRecurring) ...[
              _buildTimePickerFor(theme, _currentSettings, _currentBookedHours),
            ],

            // ── PONAVLJAJUĆE: dan chipovi + expandable kartice ──
            if (_isRecurring) ...[
              Text(
                AppStrings.selectDays,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final chipWidth =
                      (constraints.maxWidth - 6 * 4) / 7; // 7 slots, 4px gap
                  return Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: _studentAvailableDays.map((entry) {
                      final (dayInt, keyName) = entry;
                      final isSelected = _selectedDays.contains(dayInt);
                      return SizedBox(
                        width: chipWidth,
                        child: _chip(
                          label: _dayShortString(keyName),
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              if (!isSelected) {
                                _selectedDays.add(dayInt);
                                _ensureDaySettings(dayInt);
                                _expandedDay = dayInt;
                              } else if (_selectedDays.length > 1) {
                                _selectedDays.remove(dayInt);
                                _daySettings.remove(dayInt);
                                if (_expandedDay == dayInt) {
                                  _expandedDay = _selectedDays.first;
                                }
                              }
                            });
                          },
                          theme: theme,
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Expandable kartice po danu
              ...(_selectedDays.toList()..sort()).map((dayInt) {
                final s = _ensureDaySettings(dayInt);
                final isExpanded = _expandedDay == dayInt;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Column(
                      children: [
                        // ── Header (uvijek vidljiv) ──
                        InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: () => setState(() {
                            _expandedDay = isExpanded ? null : dayInt;
                          }),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 14,
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  isExpanded
                                      ? Icons.expand_less
                                      : Icons.expand_more,
                                  color: theme.colorScheme.onSurface.withAlpha(
                                    153,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _dayName(dayInt),
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const Spacer(),
                                if (s.configured) ...[
                                  Text(
                                    '${s.startTimeFormatted} – ${s.endTimeFormatted}',
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withAlpha(153),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    _durationLabel(s.duration),
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurface
                                          .withAlpha(120),
                                    ),
                                  ),
                                ] else ...[
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.orange.shade700,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    AppStrings.notConfigured,
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: Colors.orange.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                        // ── Expanded: time picker ──
                        if (isExpanded)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: _buildTimePickerFor(
                              theme,
                              s,
                              _bookedHoursForDay(dayInt),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 8),

              // Do kad?
              Row(
                children: [
                  ChoiceChip(
                    label: Text(AppStrings.noEndDate),
                    selected: !_hasEndDate,
                    onSelected: (_) => setState(() {
                      _hasEndDate = false;
                      _endDate = null;
                    }),
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: !_hasEndDate
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                    showCheckmark: false,
                    side: _hasEndDate
                        ? BorderSide(color: Colors.grey.shade300)
                        : BorderSide.none,
                  ),
                  const SizedBox(width: 10),
                  ChoiceChip(
                    label: Text(
                      _hasEndDate && _endDate != null
                          ? _formatDate(_endDate!)
                          : AppStrings.selectEndDate,
                    ),
                    selected: _hasEndDate,
                    onSelected: (_) async {
                      final picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now().add(
                          const Duration(days: 7),
                        ),
                        firstDate: DateTime.now().add(const Duration(days: 1)),
                        lastDate: DateTime.now().add(const Duration(days: 365)),
                      );
                      if (!context.mounted) return;
                      if (picked != null) {
                        setState(() {
                          _hasEndDate = true;
                          _endDate = picked;
                        });
                      }
                    },
                    selectedColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _hasEndDate
                          ? Colors.white
                          : theme.colorScheme.onSurface,
                    ),
                    showCheckmark: false,
                    side: !_hasEndDate
                        ? BorderSide(color: Colors.grey.shade300)
                        : BorderSide.none,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),

            // ── Sažetak ───────────────────────
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                children: [
                  if (!_isRecurring) ...[
                    Text(
                      '${_currentSettings.startTimeFormatted} – '
                      '${_currentSettings.endTimeFormatted}',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  Text(
                    '${_totalPrice.toStringAsFixed(2)} €'
                    '${_isRecurring ? AppStrings.perSession : ''}',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      color: theme.colorScheme.onSurface,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (_isRecurring) ...[
                    const SizedBox(height: 8),
                    Text(
                      _recurringSummary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withAlpha(153),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // ── Validacijska poruka ──
            if (!_allConfigured)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.orange.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        AppStrings.configureAllDays,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // ── CTA ────────────────────────────
            ElevatedButton.icon(
              onPressed: _allConfigured
                  ? () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop();

                      final s = _currentSettings;
                      final customSlot = MockSlot(
                        dayLabel: widget.slot.dayLabel,
                        date: widget.slot.date,
                        startTime: s.startTimeFormatted,
                        endTime: s.endTimeFormatted,
                      );

                      // Build per-day schedule map for recurring
                      Map<int, Map<String, String>>? daySchedules;
                      if (_isRecurring) {
                        daySchedules = {};
                        for (final day in _selectedDays) {
                          final ds = _ensureDaySettings(day);
                          daySchedules[day] = {
                            'start': ds.startTimeFormatted,
                            'end': ds.endTimeFormatted,
                            'duration': ds.duration.toString(),
                          };
                        }
                      }

                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => BookingFlowScreen(
                            student: widget.student,
                            selectedSlot: customSlot,
                            durationHours: s.duration,
                            isRecurring: _isRecurring,
                            recurringDays: _isRecurring
                                ? (_selectedDays.toList()..sort())
                                : null,
                            recurringEndDate: _hasEndDate ? _endDate : null,
                            daySchedules: daySchedules,
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.arrow_forward),
              label: Text(
                '${AppStrings.next}  •  ${_totalPrice.toStringAsFixed(2)} €',
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable time picker widget za jedan dan.
  Widget _buildTimePickerFor(
    ThemeData theme,
    _DayTimeSettings s,
    Set<int> bookedHours,
  ) {
    final startHours = _availableStartHoursFor(s);
    final durations = _availableDurationsFor(s, bookedHours);
    const spacing = 8.0;

    // Auto-clamp duration if current exceeds max available.
    if (s.configured &&
        durations.isNotEmpty &&
        !durations.contains(s.duration)) {
      s.duration = durations.last;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Početni sat ──
        Text(
          AppStrings.startTimeLabel,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _buildChipGrid(
          itemCount: startHours.length,
          spacing: spacing,
          builder: (i) {
            final hour = startHours[i];
            final isBooked = bookedHours.contains(hour);
            final isSelected = s.configured && hour == s.startHour;
            return _chip(
              label: '${hour.toString().padLeft(2, '0')}:00',
              isSelected: isSelected && !isBooked,
              isBooked: isBooked,
              onTap: isBooked
                  ? null
                  : () {
                      setState(() {
                        s.startHour = hour;
                        s.configured = true;
                        s.clamp(widget.startHour, widget.endHour);
                      });
                    },
              theme: theme,
            );
          },
        ),
        const SizedBox(height: 16),

        // ── Trajanje ──
        Text(
          AppStrings.durationLabel,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        _buildChipGrid(
          itemCount: durations.length,
          spacing: spacing,
          builder: (i) {
            final dur = durations[i];
            final isSelected = s.configured && dur == s.duration;
            return _chip(
              label: _durationLabel(dur),
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  s.duration = dur;
                  s.configured = true;
                  s.clamp(widget.startHour, widget.endHour);
                });
              },
              theme: theme,
            );
          },
        ),
      ],
    );
  }

  /// Custom chip koji popuni parent širinu.
  Widget _chip({
    required String label,
    required bool isSelected,
    required VoidCallback? onTap,
    required ThemeData theme,
    bool isBooked = false,
  }) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isBooked
              ? Colors.grey.shade100
              : isSelected
              ? theme.colorScheme.primary
              : theme.colorScheme.surface,
          border: Border.all(
            color: isBooked
                ? Colors.grey.shade200
                : isSelected
                ? theme.colorScheme.primary
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            decoration: isBooked ? TextDecoration.lineThrough : null,
            color: isBooked
                ? Colors.grey.shade400
                : isSelected
                ? Colors.white
                : enabled
                ? theme.colorScheme.onSurface
                : Colors.grey.shade400,
          ),
        ),
      ),
    );
  }

  /// Gradi grid — 4 po redu, Expanded pa svaki chip popuni slot.
  Widget _buildChipGrid({
    required int itemCount,
    required double spacing,
    required Widget Function(int index) builder,
  }) {
    const columns = 4;
    final rows = (itemCount / columns).ceil();
    return Column(
      children: List.generate(rows, (row) {
        final start = row * columns;
        final end = (start + columns).clamp(0, itemCount);
        final itemsInRow = end - start;
        return Padding(
          padding: EdgeInsets.only(bottom: row < rows - 1 ? spacing : 0),
          child: Row(
            children: [
              for (var i = start; i < end; i++) ...[
                if (i > start) SizedBox(width: spacing),
                Expanded(child: builder(i)),
              ],
              // Popuni prazna mjesta da se sačuva grid
              for (var e = itemsInRow; e < columns; e++) ...[
                SizedBox(width: spacing),
                const Expanded(child: SizedBox()),
              ],
            ],
          ),
        );
      }),
    );
  }
}

class _MockReview extends StatelessWidget {
  const _MockReview({
    required this.name,
    required this.rating,
    required this.text,
  });

  final String name;
  final int rating;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              RatingStars(rating: rating.toDouble(), size: 16),
            ],
          ),
          const SizedBox(height: 8),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
