import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';
import 'package:helpi_senior/core/utils/mock_data.dart';
import 'package:helpi_senior/shared/widgets/student_card.dart';

/// Booking flow — pregled narudžbe → mock plaćanje → potvrda.
/// Tri koraka u jednom ekranu (Stepper-like).
class BookingFlowScreen extends StatefulWidget {
  const BookingFlowScreen({
    super.key,
    required this.student,
    required this.selectedSlot,
    required this.durationHours,
    this.isRecurring = false,
    this.recurringDays,
    this.recurringEndDate,
    this.daySchedules,
  });

  final MockStudent student;
  final MockSlot selectedSlot;
  final int durationHours;
  final bool isRecurring;
  final List<int>? recurringDays;
  final DateTime? recurringEndDate;

  /// Per-day schedules when recurring: {dayInt: {'start','end','duration'}}
  final Map<int, Map<String, String>>? daySchedules;

  @override
  State<BookingFlowScreen> createState() => _BookingFlowScreenState();
}

class _BookingFlowScreenState extends State<BookingFlowScreen> {
  int _currentStep = 0; // 0=pregled, 1=plaćanje, 2=potvrda
  final _notesController = TextEditingController();
  bool _isProcessing = false;
  final Set<String> _selectedServiceChips = {};

  double get _totalPrice {
    return widget.student.hourlyRate * widget.durationHours;
  }

  static const _dayNames = {
    1: 'Pon',
    2: 'Uto',
    3: 'Sri',
    4: 'Čet',
    5: 'Pet',
    6: 'Sub',
    7: 'Ned',
  };

  String get _recurringText {
    final days = (widget.recurringDays ?? [])
        .map((d) => _dayNames[d] ?? '')
        .join(', ');
    final endText = widget.recurringEndDate != null
        ? AppStrings.untilDate(
            '${widget.recurringEndDate!.day.toString().padLeft(2, '0')}.'
            '${widget.recurringEndDate!.month.toString().padLeft(2, '0')}.'
            '${widget.recurringEndDate!.year}.',
          )
        : AppStrings.noEndDate;
    return '${AppStrings.everyWeek} $days — $endText';
  }

  Future<void> _processPayment() async {
    setState(() => _isProcessing = true);
    HapticFeedback.mediumImpact();

    // Simulacija Stripe PaymentSheet-a
    await Future<void>.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    setState(() {
      _isProcessing = false;
      _currentStep = 2;
    });
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_stepTitle),
        leading: _currentStep == 2
            ? const SizedBox.shrink()
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () {
                  if (_currentStep == 0) {
                    Navigator.of(context).pop();
                  } else {
                    setState(() => _currentStep = 0);
                  }
                },
              ),
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: switch (_currentStep) {
          0 => _buildOrderSummary(context),
          1 => _buildPayment(context),
          2 => _buildConfirmation(context),
          _ => const SizedBox.shrink(),
        },
      ),
    );
  }

  String get _stepTitle {
    return switch (_currentStep) {
      0 => AppStrings.orderSummary,
      1 => AppStrings.payment,
      2 => AppStrings.orderConfirmed,
      _ => '',
    };
  }

  // ─── Korak 1: Pregled narudžbe ────────────────────────────────
  Widget _buildOrderSummary(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      key: const ValueKey('summary'),
      padding: const EdgeInsets.all(16),
      children: [
        // Student info
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Text(
                      widget.student.avatarEmoji,
                      style: const TextStyle(fontSize: 32),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.student.fullName,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      RatingStars(rating: widget.student.rating, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Termin
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppStrings.selectSlot,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                      Text(
                        '${widget.selectedSlot.dayLabel} ${widget.selectedSlot.date}',
                        style: theme.textTheme.headlineSmall,
                      ),
                      Text(
                        AppStrings.slotTime(
                          widget.selectedSlot.startTime,
                          widget.selectedSlot.endTime,
                        ),
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(153),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (widget.isRecurring) ...[
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.repeat, color: theme.colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _recurringText,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Per-day schedule lines
                  if (widget.daySchedules != null &&
                      widget.daySchedules!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 12),
                    ...(widget.daySchedules!.entries.toList()
                          ..sort((a, b) => a.key.compareTo(b.key)))
                        .map((e) {
                          final dayName = _dayNames[e.key] ?? '';
                          final start = e.value['start'] ?? '';
                          final end = e.value['end'] ?? '';
                          final dur = e.value['duration'] ?? '';
                          final durLabel = dur == '1'
                              ? '1 ${AppStrings.hourSingular}'
                              : '$dur ${AppStrings.hourPlural}';
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: [
                                SizedBox(
                                  width: 40,
                                  child: Text(
                                    dayName,
                                    style: theme.textTheme.bodyLarge?.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$start – $end',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  durLabel,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.secondary,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                  ],
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 16),

        // Napomene — s quick-tap chipovima
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.touch_app, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Text(
                      AppStrings.bookingServiceHeader,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      [
                        AppStrings.bookingChipShopping,
                        AppStrings.bookingChipPharmacy,
                        AppStrings.bookingChipCleaning,
                        AppStrings.bookingChipCompanionship,
                        AppStrings.bookingChipWalk,
                        AppStrings.bookingChipEscort,
                        AppStrings.bookingChipOther,
                      ].map((label) {
                        final isSelected = _selectedServiceChips.contains(
                          label,
                        );
                        return FilterChip(
                          label: Text(label),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedServiceChips.add(label);
                              } else {
                                _selectedServiceChips.remove(label);
                              }
                            });
                          },
                          selectedColor: theme.colorScheme.primary,
                          side: isSelected
                              ? BorderSide.none
                              : BorderSide(color: Colors.grey.shade300),
                          labelStyle: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: isSelected
                                ? Colors.white
                                : theme.colorScheme.onSurface,
                          ),
                          showCheckmark: true,
                          checkmarkColor: Colors.white,
                        );
                      }).toList(),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 16,
                      color: theme.colorScheme.onSurface.withAlpha(120),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        AppStrings.bookingDisclaimer,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withAlpha(120),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Napomene — slobodan tekst
        TextField(
          controller: _notesController,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: AppStrings.orderNotes,
            hintText: AppStrings.bookingNotesHint,
            alignLabelWithHint: true,
          ),
        ),
        const SizedBox(height: 24),

        // Cijena
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withAlpha(26),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: theme.colorScheme.primary.withAlpha(77),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(AppStrings.totalPrice, style: theme.textTheme.headlineSmall),
              Text(
                '${_totalPrice.toStringAsFixed(2)} €',
                style: theme.textTheme.headlineMedium?.copyWith(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // CTA
        ElevatedButton.icon(
          onPressed: () {
            HapticFeedback.lightImpact();
            setState(() => _currentStep = 1);
          },
          icon: const Icon(Icons.payment),
          label: Text(
            '${AppStrings.placeOrder}  •  ${_totalPrice.toStringAsFixed(2)} €',
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ─── Korak 2: Plaćanje (mock Stripe Sheet) ───────────────────
  Widget _buildPayment(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      key: const ValueKey('payment'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Icon(Icons.credit_card, size: 80, color: theme.colorScheme.primary),
          const SizedBox(height: 24),
          Text(AppStrings.payment, style: theme.textTheme.headlineLarge),
          const SizedBox(height: 8),
          Text(
            '${_totalPrice.toStringAsFixed(2)} €',
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 32),

          // Mock kartica
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withAlpha(200),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VISA',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 20),
                Text(
                  '**** **** **** 4242',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    letterSpacing: 2,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  'MARIJA NOVAK  •  12/28',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const Spacer(),

          if (_isProcessing)
            Column(
              children: [
                CircularProgressIndicator(color: theme.colorScheme.primary),
                const SizedBox(height: 16),
                Text(AppStrings.loading, style: theme.textTheme.bodyLarge),
              ],
            )
          else
            ElevatedButton.icon(
              onPressed: _processPayment,
              icon: const Icon(Icons.lock),
              label: Text(
                '${AppStrings.payNow}  •  ${_totalPrice.toStringAsFixed(2)} €',
              ),
            ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ─── Korak 3: Potvrda ────────────────────────────────────────
  Widget _buildConfirmation(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      key: const ValueKey('confirmation'),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Spacer(),
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: theme.colorScheme.secondary.withAlpha(40),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle,
              size: 80,
              color: theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            AppStrings.orderConfirmed,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: theme.colorScheme.secondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            _confirmationSubtitle(
              widget.student.firstName,
              widget.selectedSlot,
            ),
            style: theme.textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            AppStrings.paymentSuccess,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.secondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () {
              // Vrati se na root
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.home),
            label: Text(AppStrings.navHome),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              // TODO: navigiraj na chat
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            icon: const Icon(Icons.chat),
            label: Text(AppStrings.navMessages),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  static String _confirmationSubtitle(String name, MockSlot slot) {
    return '$name dolazi\n${slot.dayLabel} ${slot.date} u ${slot.startTime}';
  }
}
