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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final daysLeft = DateTime(now.year, now.month + 1, 0).day - now.day;
    _displayedMonth = daysLeft < 7
        ? DateTime(now.year, now.month + 1)
        : DateTime(now.year, now.month);
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

  void _openTimePicker() {
    // Use the first available slot from the student as default.
    final firstSlot = widget.student.availableSlots.first;
    final startHour = int.parse(firstSlot.startTime.split(':')[0]);
    final endHour = int.parse(firstSlot.endTime.split(':')[0]);
    final maxHours = endHour - startHour;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return _TimePickerSheet(
          slot: firstSlot,
          student: widget.student,
          startHour: startHour,
          endHour: endHour,
          maxHours: maxHours,
          hourlyRate: widget.student.hourlyRate,
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
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                CircleAvatar(
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
                if (widget.student.rating >= 4.8)
                  Positioned(
                    bottom: -8,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          AppStrings.topBadge,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              widget.student.fullName,
              style: theme.textTheme.headlineLarge,
            ),
          ),
          const SizedBox(height: 4),
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
          const SizedBox(height: 20),

          // ── Rezerviraj ────────────────────────────
          ElevatedButton.icon(
            onPressed: () {
              HapticFeedback.mediumImpact();
              _openTimePicker();
            },
            icon: const Icon(Icons.calendar_month),
            label: Text(AppStrings.bookNow),
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

      cells.add(
        _buildDateCell(
          theme: theme,
          day: day,
          isPast: isPast,
          isToday: isToday,
          availability: availability,
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
  }) {
    Color bgColor;
    Color textColor;

    if (isPast) {
      bgColor = Colors.transparent;
      textColor = Colors.grey.shade300;
    } else if (availability == null) {
      bgColor = Colors.transparent;
      textColor = Colors.grey.shade400;
    } else if (availability.isFullyBooked) {
      bgColor = Colors.red.shade100;
      textColor = Colors.red.shade400;
    } else if (availability.isPartiallyBooked) {
      bgColor = Colors.amber.shade100;
      textColor = Colors.amber.shade800;
    } else {
      bgColor = theme.colorScheme.secondary.withAlpha(50);
      textColor = theme.colorScheme.secondary;
    }

    return Container(
      height: 44,
      margin: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
        border: isToday
            ? Border.all(color: theme.colorScheme.secondary, width: 2)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '$day',
        style: TextStyle(
          fontSize: 16,
          fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
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
          theme.colorScheme.secondary,
          AppStrings.calendarFree,
          theme,
        ),
        const SizedBox(width: 16),
        _legendItem(Colors.amber, AppStrings.calendarPartial, theme),
        const SizedBox(width: 16),
        _legendItem(Colors.red.shade400, AppStrings.calendarBooked, theme),
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
}

/// Status datuma za ponavljajuću rezervaciju.
enum _RecurringDateStatus { confirmed, conflict, skipped, outsideWindow }

/// Postavke vremena za jedan dan.
class _DayTimeSettings {
  int startHour;
  int duration = 1;
  bool startSelected = false;
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
  });

  final MockSlot slot;
  final MockStudent student;
  final int startHour;
  final int endHour;
  final int maxHours;
  final double hourlyRate;

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

/// Booking mode for the time picker sheet.
enum _BookingMode { oneTime, continuous, untilDate }

class _TimePickerSheetState extends State<_TimePickerSheet> {
  _BookingMode _bookingMode = _BookingMode.oneTime;
  DateTime? _endDate; // For untilDate mode
  final Map<int, _DayTimeSettings> _daySettings = {};
  late Set<int> _selectedDays; // 1=Pon .. 7=Ned (za recurring)
  late int _primaryDay; // Dan koji je korisnik kliknuo u kalendaru

  /// Convenience: any repeating mode (continuous or untilDate).
  bool get _isRecurring => _bookingMode != _BookingMode.oneTime;

  static const _dayLabelToInt = {
    'Pon': 1,
    'Uto': 2,
    'Sri': 3,
    'Čet': 4,
    'Pet': 5,
    'Sub': 6,
    'Ned': 7,
  };

  static const _intToShort = {
    1: 'dayMon',
    2: 'dayTue',
    3: 'dayWed',
    4: 'dayThu',
    5: 'dayFri',
    6: 'daySat',
    7: 'daySun',
  };

  static const _intToDayLabel = {
    1: 'Pon',
    2: 'Uto',
    3: 'Sri',
    4: 'Čet',
    5: 'Pet',
    6: 'Sub',
    7: 'Ned',
  };

  /// Dani na koje je student dostupan (iz availableSlots).
  List<int> get _studentAvailableDays {
    final days =
        widget.student.availableSlots
            .map((s) => _dayLabelToInt[s.dayLabel])
            .whereType<int>()
            .toSet()
            .toList()
          ..sort();
    return days;
  }

  /// Find MockSlot for a specific weekday.
  MockSlot? _slotForDay(int dayInt) {
    final label = _intToDayLabel[dayInt];
    if (label == null) return null;
    return widget.student.availableSlots
        .where((s) => s.dayLabel == label)
        .firstOrNull;
  }

  /// Ensure settings exist for a day, using that day's available window.
  void _ensureDaySettings(int dayInt) {
    if (_daySettings.containsKey(dayInt)) return;
    final slot = _slotForDay(dayInt);
    final start = slot != null
        ? int.parse(slot.startTime.split(':')[0])
        : widget.startHour;
    _daySettings[dayInt] = _DayTimeSettings(startHour: start);
  }

  /// Primary day's settings (the day user clicked in calendar).
  _DayTimeSettings? get _primarySettingsOrNull => _daySettings[_primaryDay];
  _DayTimeSettings get _primarySettings =>
      _daySettings[_primaryDay] ??
      _DayTimeSettings(startHour: widget.startHour);

  /// Whether all selected days have been configured.
  bool get _allConfigured =>
      _selectedDays.isNotEmpty &&
      _selectedDays.every((d) => _daySettings[d]?.configured ?? false);

  /// Start hour of a day's available window.
  int _dayStartHour(int dayInt) {
    final slot = _slotForDay(dayInt);
    return slot != null
        ? int.parse(slot.startTime.split(':')[0])
        : widget.startHour;
  }

  /// End hour of a day's available window.
  int _dayEndHour(int dayInt) {
    final slot = _slotForDay(dayInt);
    return slot != null
        ? int.parse(slot.endTime.split(':')[0])
        : widget.endHour;
  }

  @override
  void initState() {
    super.initState();
    _primaryDay = _dayLabelToInt[widget.slot.dayLabel] ?? 1;
    _selectedDays = {};
    _daySettings[_primaryDay] = _DayTimeSettings(startHour: widget.startHour);
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

  String _dayName(int day) => _dayString(_intToShort[day] ?? '');

  // ── Recurring helpers ──────────────────────────────────────────

  DateTime get _displayMonth {
    final now = DateTime.now();
    final daysLeft = DateTime(now.year, now.month + 1, 0).day - now.day;
    return daysLeft < 7
        ? DateTime(now.year, now.month + 1)
        : DateTime(now.year, now.month);
  }

  /// Get all dates matching ANY selected weekday, sorted chronologically.
  /// Filtered by _endDate when in untilDate mode.
  List<MockDateAvailability> get _recurringDates {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dm = _displayMonth;

    final allAvail = widget.student.getMonthAvailability(dm.year, dm.month);

    return allAvail
        .where((a) => _selectedDays.contains(a.date.weekday))
        .where((a) => !a.date.isBefore(today))
        .where((a) => _endDate == null || !a.date.isAfter(_endDate!))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  /// For a recurring date, check if the chosen start+duration fits.
  /// Also checks if the time is within that day's work window.
  _RecurringDateStatus _statusFor(MockDateAvailability avail) {
    if (avail.isFullyBooked) return _RecurringDateStatus.skipped;

    final dayInt = avail.date.weekday;
    final settings = _daySettings[dayInt];
    if (settings == null || !settings.configured) {
      return _RecurringDateStatus.outsideWindow;
    }

    final start = settings.startHour;
    final end = start + settings.duration;

    // Check if time is outside this day's available window
    if (start < avail.startHour || end > avail.endHour) {
      return _RecurringDateStatus.outsideWindow;
    }

    final booked = avail.bookedHours.toSet();
    for (var h = start; h < end; h++) {
      if (booked.contains(h)) return _RecurringDateStatus.conflict;
    }
    return _RecurringDateStatus.confirmed;
  }

  int get _confirmedCount => _recurringDates
      .where((a) => _statusFor(a) == _RecurringDateStatus.confirmed)
      .length;

  int get _skippedCount => _recurringDates
      .where((a) => _statusFor(a) != _RecurringDateStatus.confirmed)
      .length;

  double get _oneTimePrice => _primarySettings.duration * widget.hourlyRate;

  // ─── BUILD ──────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          32 + MediaQuery.of(context).viewPadding.bottom,
        ),
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

            // ── Jednokratno / Kontinuirano / Do datuma ─────
            Row(
              children: [
                Expanded(
                  child: _chip(
                    label: AppStrings.oneTime,
                    isSelected: _bookingMode == _BookingMode.oneTime,
                    onTap: () => setState(() {
                      _bookingMode = _BookingMode.oneTime;
                      _endDate = null;
                    }),
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _chip(
                    label: AppStrings.continuous,
                    isSelected: _bookingMode == _BookingMode.continuous,
                    onTap: () => setState(() {
                      _bookingMode = _BookingMode.continuous;
                      _endDate = null;
                    }),
                    theme: theme,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: _chip(
                    label: AppStrings.untilDateLabel,
                    isSelected: _bookingMode == _BookingMode.untilDate,
                    onTap: () => setState(() {
                      _bookingMode = _BookingMode.untilDate;
                    }),
                    theme: theme,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── PONAVLJAJUĆE: chipovi dana ─────
            if (_isRecurring) ...[
              Text(
                AppStrings.recurringDaysLabel,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _studentAvailableDays.map((dayInt) {
                  final isSelected = _selectedDays.contains(dayInt);
                  return SizedBox(
                    width: (MediaQuery.of(context).size.width - 48 - 36) / 7,
                    child: _chip(
                      label: _dayName(dayInt),
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            _selectedDays.remove(dayInt);
                            _daySettings.remove(dayInt);
                            // Update primaryDay if removed
                            if (dayInt == _primaryDay &&
                                _selectedDays.isNotEmpty) {
                              _primaryDay =
                                  (_selectedDays.toList()..sort()).first;
                            }
                          } else {
                            _selectedDays.add(dayInt);
                            _ensureDaySettings(dayInt);
                          }
                        });
                      },
                      theme: theme,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
            ],

            // ── DO DATUMA: odabir krajnjeg datuma ──
            if (_bookingMode == _BookingMode.untilDate &&
                _selectedDays.isNotEmpty) ...[
              _buildEndDatePicker(theme),
              const SizedBox(height: 20),
            ],

            // ── Time picker (isti za oba moda) ──
            _buildTimePicker(theme),

            // ── PONAVLJAJUĆE: lista datuma (samo za 1 dan) ──
            if (_isRecurring &&
                _allConfigured &&
                _selectedDays.length <= 1) ...[
              const SizedBox(height: 20),
              _buildRecurringDateList(theme),
            ],

            const SizedBox(height: 20),

            // ── Sažetak ───────────────────────
            if ((_isRecurring
                ? _allConfigured
                : (_primarySettingsOrNull?.configured ?? false))) ...[
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
                      Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_dayName(_primaryDay)}: '
                              '${_primarySettings.startTimeFormatted} – '
                              '${_primarySettings.endTimeFormatted}',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${_oneTimePrice.toStringAsFixed(2)} €',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    if (_isRecurring) ...[
                      ...(_selectedDays.toList()..sort()).map((d) {
                        final s = _daySettings[d]!;
                        final dayPrice = (s.duration * widget.hourlyRate)
                            .toStringAsFixed(2);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${_dayName(d)}: '
                                '${s.startTimeFormatted} – '
                                '${s.endTimeFormatted}',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$dayPrice €',
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                    if (_isRecurring) ...[
                      const Divider(height: 20),
                      _buildRecurringSummaryBar(theme),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: theme.colorScheme.onSurface.withAlpha(130),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              AppStrings.recurringBillingInfo,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurface.withAlpha(
                                  130,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // ── CTA ────────────────────────────
            ElevatedButton.icon(
              onPressed:
                  ((_isRecurring
                          ? _allConfigured
                          : (_primarySettingsOrNull?.configured ?? false)) &&
                      (!_isRecurring || _confirmedCount > 0) &&
                      (_bookingMode != _BookingMode.untilDate ||
                          _endDate != null))
                  ? () {
                      HapticFeedback.mediumImpact();
                      Navigator.of(context).pop();

                      final customSlot = MockSlot(
                        dayLabel: widget.slot.dayLabel,
                        date: widget.slot.date,
                        startTime: _primarySettings.startTimeFormatted,
                        endTime: _primarySettings.endTimeFormatted,
                      );

                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => BookingFlowScreen(
                            student: widget.student,
                            selectedSlot: customSlot,
                            durationHours: _primarySettings.duration,
                            isRecurring: _isRecurring,
                            recurringDays: _isRecurring
                                ? (_selectedDays.toList()..sort())
                                : null,
                            daySchedules:
                                _isRecurring && _selectedDays.length > 1
                                ? {
                                    for (final d in _selectedDays)
                                      d: {
                                        'start':
                                            _daySettings[d]!.startTimeFormatted,
                                        'end':
                                            _daySettings[d]!.endTimeFormatted,
                                        'duration': _daySettings[d]!.duration
                                            .toString(),
                                      },
                                  }
                                : null,
                          ),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.arrow_forward),
              label: Text(AppStrings.next),
            ),
          ],
        ),
      ),
    );
  }

  /// Time picker — per-day for multi-day recurring.
  Widget _buildTimePicker(ThemeData theme) {
    // Recurring with no days selected — show prompt
    if (_isRecurring && _selectedDays.isEmpty) {
      return const SizedBox.shrink();
    }
    if (!_isRecurring || _selectedDays.length <= 1) {
      final dayToShow = _isRecurring ? _selectedDays.first : _primaryDay;
      return _buildDayTimePicker(
        theme,
        dayToShow,
        showBookedHours: !_isRecurring,
      );
    }
    // Multi-day: flat sections per day with inline dates
    final sortedDays = _selectedDays.toList()..sort();
    final allDates = _recurringDates;
    final grouped = <int, List<MockDateAvailability>>{};
    for (final d in sortedDays) {
      grouped[d] = allDates.where((a) => a.date.weekday == d).toList();
    }
    final showDates = _allConfigured;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < sortedDays.length; i++) ...[
          if (i > 0) const SizedBox(height: 24),
          _buildDaySectionHeader(theme, sortedDays[i]),
          const SizedBox(height: 12),
          _buildDayTimePicker(theme, sortedDays[i]),
          // Inline date rows for this day
          if (showDates && (grouped[sortedDays[i]]?.isNotEmpty ?? false)) ...[
            const SizedBox(height: 12),
            ...grouped[sortedDays[i]]!.map((avail) {
              final status = _statusFor(avail);
              return Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: _buildDateStatusRow(theme, avail, status),
              );
            }),
          ],
        ],
        // Summary + auto-renewal after all days
        if (showDates) ...[
          const SizedBox(height: 16),
          _buildAutoRenewalCard(theme),
        ],
      ],
    );
  }

  /// Header for a per-day section showing day name and available window.
  Widget _buildDaySectionHeader(ThemeData theme, int dayInt) {
    final slot = _slotForDay(dayInt);
    final startStr =
        slot?.startTime ?? '${widget.startHour.toString().padLeft(2, '0')}:00';
    final endStr =
        slot?.endTime ?? '${widget.endHour.toString().padLeft(2, '0')}:00';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Text(
            _dayName(dayInt),
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '($startStr – $endStr)',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withAlpha(153),
            ),
          ),
        ],
      ),
    );
  }

  /// Time picker for a single day — start hour + duration grids.
  Widget _buildDayTimePicker(
    ThemeData theme,
    int dayInt, {
    bool showBookedHours = false,
  }) {
    final settings = _daySettings[dayInt];
    if (settings == null) return const SizedBox.shrink();
    final startH = _dayStartHour(dayInt);
    final endH = _dayEndHour(dayInt);

    // Available start hours
    final startHours = <int>[];
    for (var h = startH; h + settings.duration <= endH; h++) {
      startHours.add(h);
    }

    // Booked hours (only for single-day / one-time)
    final Set<int> bookedHours;
    if (showBookedHours) {
      bookedHours = widget.slot.bookedHours.toSet();
    } else {
      bookedHours = {};
    }

    // Available durations
    final maxFromStart = endH - settings.startHour;
    int maxBeforeBooked = maxFromStart;
    for (final b in bookedHours) {
      if (b >= settings.startHour) {
        final limit = b - settings.startHour;
        if (limit < maxBeforeBooked) maxBeforeBooked = limit;
      }
    }
    final durations = <int>[];
    for (var d = 1; d <= maxBeforeBooked && d <= 4; d++) {
      durations.add(d);
    }

    const spacing = 8.0;

    // Auto-clamp
    if (settings.configured &&
        durations.isNotEmpty &&
        !durations.contains(settings.duration)) {
      settings.duration = durations.last;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
            final isSelected =
                settings.startSelected && hour == settings.startHour;
            return _chip(
              label: '${hour.toString().padLeft(2, '0')}:00',
              isSelected: isSelected && !isBooked,
              isBooked: isBooked,
              onTap: isBooked
                  ? null
                  : () {
                      setState(() {
                        settings.startHour = hour;
                        settings.startSelected = true;
                        settings.clamp(startH, endH);
                      });
                    },
              theme: theme,
            );
          },
        ),
        const SizedBox(height: 16),
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
            final isSelected = settings.configured && dur == settings.duration;
            return _chip(
              label: _durationLabel(dur),
              isSelected: isSelected,
              onTap: () {
                setState(() {
                  settings.duration = dur;
                  settings.configured = true;
                  settings.clamp(startH, endH);
                });
              },
              theme: theme,
            );
          },
        ),
      ],
    );
  }

  /// Recurring date list — for single-day recurring mode.
  Widget _buildRecurringDateList(ThemeData theme) {
    final dates = _recurringDates;
    if (dates.isEmpty) return const SizedBox.shrink();

    final monthName = AppStrings.monthName(_displayMonth.month);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Naslov s mjesecom ──
        Text(
          monthName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),

        // ── Date rows ──
        ...dates.map((avail) {
          final status = _statusFor(avail);
          return Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: _buildDateStatusRow(theme, avail, status),
          );
        }),
        const SizedBox(height: 16),

        _buildAutoRenewalCard(theme),
      ],
    );
  }

  /// Confirmed/skipped summary row with header.
  Widget _buildRecurringSummaryBar(ThemeData theme) {
    final confirmed = _confirmedCount;
    final skipped = _skippedCount;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.sessionsLabel,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Icon(
              Icons.check_circle,
              size: 20,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(width: 6),
            Text(
              AppStrings.recurringConfirmed(confirmed.toString()),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.secondary,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (skipped > 0) ...[
              const SizedBox(width: 16),
              Icon(Icons.cancel_outlined, size: 20, color: Colors.red.shade400),
              const SizedBox(width: 6),
              Text(
                AppStrings.recurringSkipped(skipped.toString()),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.red.shade400,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  /// Blue auto-renewal info card (continuous) or until-date info card.
  Widget _buildAutoRenewalCard(ThemeData theme) {
    final isContinuous = _bookingMode == _BookingMode.continuous;

    // Don't show until-date info card when no date is selected yet.
    if (!isContinuous && _endDate == null) return const SizedBox.shrink();

    final String infoText;
    if (isContinuous) {
      final monthName = AppStrings.monthName(_displayMonth.month);
      infoText = AppStrings.recurringAutoRenew(monthName);
    } else {
      final formatted =
          '${_endDate!.day.toString().padLeft(2, '0')}.'
          '${_endDate!.month.toString().padLeft(2, '0')}.'
          '${_endDate!.year}';
      infoText = AppStrings.recurringUntilDateInfo(formatted);
    }
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, size: 20, color: Colors.blue.shade700),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              infoText,
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.blue.shade800,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// End-date picker row for "Do datuma" mode.
  Widget _buildEndDatePicker(ThemeData theme) {
    final hasDate = _endDate != null;
    final dateText = hasDate
        ? '${_endDate!.day.toString().padLeft(2, '0')}.'
              '${_endDate!.month.toString().padLeft(2, '0')}.'
              '${_endDate!.year}.'
        : AppStrings.selectEndDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.lastSessionLabel,
          style: theme.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final now = DateTime.now();
            final lastDay = DateTime(
              _displayMonth.year,
              _displayMonth.month + 1,
              0,
            );
            final picked = await showDatePicker(
              context: context,
              initialDate: _endDate ?? lastDay,
              firstDate: DateTime(now.year, now.month, now.day + 1),
              lastDate: DateTime(
                _displayMonth.year,
                _displayMonth.month + 2,
                0,
              ),
              locale: Locale(AppStrings.currentLocale),
            );
            if (!context.mounted) return;
            if (picked != null) {
              setState(() => _endDate = picked);
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: hasDate
                    ? theme.colorScheme.secondary
                    : Colors.grey.shade300,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  size: 20,
                  color: hasDate
                      ? theme.colorScheme.secondary
                      : Colors.grey.shade500,
                ),
                const SizedBox(width: 12),
                Text(
                  dateText,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                    color: hasDate
                        ? theme.colorScheme.onSurface
                        : Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDateStatusRow(
    ThemeData theme,
    MockDateAvailability avail,
    _RecurringDateStatus status,
  ) {
    final IconData icon;
    final Color iconColor;
    final String statusText;
    final Color textColor;
    final bool strikeDate;

    switch (status) {
      case _RecurringDateStatus.confirmed:
        icon = Icons.check_circle;
        iconColor = theme.colorScheme.secondary;
        statusText = AppStrings.recurringFree;
        textColor = theme.colorScheme.secondary;
        strikeDate = false;
      case _RecurringDateStatus.conflict:
        final cSettings = _daySettings[avail.date.weekday];
        icon = Icons.warning_amber_rounded;
        iconColor = Colors.amber.shade800;
        statusText =
            '${cSettings?.startTimeFormatted ?? ''} ${AppStrings.recurringOccupied.toLowerCase()}';
        textColor = Colors.amber.shade800;
        strikeDate = false;
      case _RecurringDateStatus.outsideWindow:
        icon = Icons.schedule;
        iconColor = Colors.amber.shade800;
        statusText = AppStrings.recurringOutsideWindow;
        textColor = Colors.amber.shade800;
        strikeDate = false;
      case _RecurringDateStatus.skipped:
        icon = Icons.cancel_outlined;
        iconColor = Colors.red.shade400;
        statusText = AppStrings.recurringOccupied;
        textColor = Colors.red.shade400;
        strikeDate = true;
    }

    final isOk = status == _RecurringDateStatus.confirmed;
    final isWarn =
        status == _RecurringDateStatus.conflict ||
        status == _RecurringDateStatus.outsideWindow;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: isOk
            ? theme.colorScheme.secondary.withAlpha(15)
            : isWarn
            ? Colors.amber.withAlpha(20)
            : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isOk
              ? theme.colorScheme.secondary.withAlpha(60)
              : isWarn
              ? Colors.amber.withAlpha(80)
              : Colors.red.shade100,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 10),
          Text(
            avail.dateFormatted,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.w600,
              decoration: strikeDate ? TextDecoration.lineThrough : null,
              color: strikeDate ? Colors.grey.shade500 : null,
            ),
          ),
          const Spacer(),
          Text(
            statusText,
            style: theme.textTheme.bodySmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
              ? const Color(0xFF009D9D)
              : theme.colorScheme.surface,
          border: Border.all(
            color: isBooked
                ? Colors.grey.shade200
                : isSelected
                ? const Color(0xFF009D9D)
                : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(12),
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
