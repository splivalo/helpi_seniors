import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:helpi_senior/core/l10n/app_strings.dart';
import 'package:helpi_senior/features/booking/data/order_model.dart';

/// Detalji narudžbe — puni ekran s podacima + sekcija Studenti + ocjene.
class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({
    super.key,
    required this.order,
    required this.ordersNotifier,
  });

  final OrderModel order;
  final OrdersNotifier ordersNotifier;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  static const _teal = Color(0xFF009D9D);
  static const _coral = Color(0xFFEF5B5B);
  static const _grey = Color(0xFF757575);

  // ── Pricing ──
  static const _hourlyRate = 14; // €/h standard
  static const _sundayRate = 16; // €/h Sunday

  int _priceForDay(int weekday, int hours) {
    final rate = weekday == DateTime.sunday ? _sundayRate : _hourlyRate;
    return rate * hours;
  }

  String _formatPrice(int euros) => '$euros,00 €';

  bool _jobsExpanded = false;

  @override
  void initState() {
    super.initState();
    widget.ordersNotifier.addListener(_onChanged);
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.ordersNotifier.removeListener(_onChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final order = widget.order;

    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.orderDetails)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──
              Row(
                children: [
                  Expanded(
                    child: Text(
                      AppStrings.orderNumber(order.id.toString()),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  _statusChip(theme, order.status),
                ],
              ),
              const SizedBox(height: 20),

              // ── Summary card ──
              _summaryCard(theme, order),
              const SizedBox(height: 20),

              // ── Jobs / sessions ──
              if (order.status != OrderStatus.processing)
                _jobsSection(theme, order),
              if (order.status != OrderStatus.processing)
                const SizedBox(height: 20),

              // ── Action buttons ──
              if (order.status == OrderStatus.processing)
                OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    widget.ordersNotifier.cancelOrder(order.id);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, size: 20),
                  label: Text(AppStrings.cancelOrder),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _coral,
                    side: const BorderSide(color: _coral, width: 2),
                  ),
                ),
              if (order.status == OrderStatus.active)
                OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    widget.ordersNotifier.cancelOrder(order.id);
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close, size: 20),
                  label: Text(AppStrings.cancelOrder),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: _coral,
                    side: const BorderSide(color: _coral, width: 2),
                  ),
                ),
              if (order.status == OrderStatus.completed)
                OutlinedButton.icon(
                  onPressed: () {
                    HapticFeedback.selectionClick();
                    widget.ordersNotifier.addOrder(
                      OrderModel(
                        id: widget.ordersNotifier.nextId,
                        services: List<String>.from(order.services),
                        date: order.date,
                        frequency: order.frequency,
                        notes: order.notes,
                        isOneTime: order.isOneTime,
                        time: order.time,
                        duration: order.duration,
                        dayEntries: order.dayEntries,
                        endDate: order.endDate,
                      ),
                    );
                    if (!context.mounted) return;
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.refresh, size: 20),
                  label: Text(AppStrings.repeatOrder),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Summary card (like Pregled) ──
  Widget _summaryCard(ThemeData theme, OrderModel order) {
    return Container(
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
          _summaryRow(theme, AppStrings.orderSummaryFrequency, order.frequency),
          const Divider(height: 24),

          // Date
          _summaryRow(
            theme,
            order.isOneTime
                ? AppStrings.orderSummaryDate
                : AppStrings.orderSummaryStartDate,
            order.date,
          ),

          if (order.endDate.isNotEmpty) ...[
            const Divider(height: 24),
            _summaryRow(theme, AppStrings.orderSummaryEndDate, order.endDate),
          ],

          // One-time: time + duration + price
          if (order.isOneTime) ...[
            const Divider(height: 24),
            _summaryRow(theme, AppStrings.orderSummaryTime, order.time),
            const Divider(height: 24),
            _summaryRow(theme, AppStrings.orderSummaryDuration, order.duration),
            if (order.durationHours > 0) ...[
              const Divider(height: 24),
              _summaryRow(
                theme,
                AppStrings.orderSummaryPrice,
                _formatPrice(_priceForDay(order.weekday, order.durationHours)),
                bold: true,
              ),
            ],
          ],

          // Recurring: day entries
          if (!order.isOneTime && order.dayEntries.isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              AppStrings.orderSummaryDays,
              style: theme.textTheme.bodySmall?.copyWith(color: _grey),
            ),
            const SizedBox(height: 8),
            ...order.dayEntries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Text(
                      _dayMediumName(entry.weekday),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      entry.durationHours > 0
                          ? '${entry.time}  ·  ${entry.durationHours}h  ·  ${_formatPrice(_priceForDay(entry.weekday, entry.durationHours))}'
                          : '${entry.time}  ·  ${entry.duration}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            // Weekly total
            if (order.dayEntries.any((e) => e.durationHours > 0)) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Text(
                    AppStrings.orderSummaryWeeklyTotal,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    _formatPrice(
                      order.dayEntries.fold<int>(
                        0,
                        (sum, e) =>
                            sum + _priceForDay(e.weekday, e.durationHours),
                      ),
                    ),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ],
          ],

          const Divider(height: 24),

          // Services as chips
          Text(
            AppStrings.orderSummaryServices,
            style: theme.textTheme.bodySmall?.copyWith(color: _grey),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: order.services.map((label) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F5F5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _teal),
                ),
                child: Text(
                  label,
                  style: const TextStyle(
                    color: _teal,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),

          // Notes
          if (order.notes.isNotEmpty) ...[
            const Divider(height: 24),
            Text(
              AppStrings.orderSummaryNotes,
              style: theme.textTheme.bodySmall?.copyWith(color: _grey),
            ),
            const SizedBox(height: 4),
            Text(order.notes, style: theme.textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }

  Widget _summaryRow(
    ThemeData theme,
    String label,
    String value, {
    bool bold = false,
  }) {
    return Row(
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: _grey)),
        const Spacer(),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ── Jobs / sessions section ──
  Widget _jobsSection(ThemeData theme, OrderModel order) {
    if (order.jobs.isEmpty) return const SizedBox.shrink();

    return Container(
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
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _jobsExpanded = !_jobsExpanded);
            },
            child: Row(
              children: [
                Text(
                  AppStrings.jobsSection,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Icon(
                  _jobsExpanded
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: _grey,
                ),
              ],
            ),
          ),
          if (!order.isOneTime) ...[
            const SizedBox(height: 6),
            Text(
              AppStrings.jobsMonthlySubtitle,
              style: theme.textTheme.bodySmall?.copyWith(color: _grey),
            ),
          ],
          if (_jobsExpanded) ...[
            const SizedBox(height: 16),
            ...order.jobs.asMap().entries.map((mapEntry) {
              final jobIndex = mapEntry.key;
              final job = mapEntry.value;
              final isLast = jobIndex == order.jobs.length - 1;
              final price = _priceForDay(job.weekday, job.durationHours);

              return Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : 16),
                child: _jobCard(theme, order, jobIndex, job, price),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _jobCard(
    ThemeData theme,
    OrderModel order,
    int jobIndex,
    JobModel job,
    int price,
  ) {
    final isCompleted = job.status == JobStatus.completed;
    final isCancelled = job.status == JobStatus.cancelled;
    final isUpcoming = job.status == JobStatus.upcoming;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCancelled ? const Color(0xFFFAFAFA) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: date + status badge
          Row(
            children: [
              Icon(
                isCompleted
                    ? Icons.check_circle
                    : isCancelled
                    ? Icons.cancel
                    : Icons.schedule,
                size: 18,
                color: isCompleted
                    ? _teal
                    : isCancelled
                    ? _coral
                    : const Color(0xFFF57C00),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${_dayMediumName(job.weekday)}, ${job.date}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCancelled ? _grey : const Color(0xFF212121),
                    decoration: isCancelled ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              _jobStatusBadge(theme, job.status),
            ],
          ),
          const SizedBox(height: 6),

          // Row 2: time · duration · price
          Padding(
            padding: const EdgeInsets.only(left: 26),
            child: Text(
              '${job.time}  ·  ${job.durationHours}h  ·  ${_formatPrice(price)}',
              style: theme.textTheme.bodySmall?.copyWith(color: _grey),
            ),
          ),

          // Row 3: student name
          Padding(
            padding: const EdgeInsets.only(left: 26, top: 4),
            child: Row(
              children: [
                const Icon(Icons.person_outline, size: 14, color: _teal),
                const SizedBox(width: 4),
                Text(
                  job.studentName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _teal,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Row 4: action buttons
          if (isUpcoming || (isCompleted && job.review == null)) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Row(
                children: [
                  // Rate button (completed only, no review yet)
                  if (isCompleted && job.review == null)
                    SizedBox(
                      height: 30,
                      child: ElevatedButton.icon(
                        onPressed: () => _showJobReviewSheet(order, jobIndex),
                        icon: const Icon(
                          Icons.star,
                          size: 14,
                          color: Colors.white,
                        ),
                        label: Text(AppStrings.rateStudent),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _coral,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          minimumSize: Size.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),

                  // Cancel button (upcoming only)
                  if (isUpcoming) ...[
                    const Spacer(),
                    SizedBox(
                      height: 30,
                      child: OutlinedButton.icon(
                        onPressed: () => _confirmCancelJob(order, jobIndex),
                        icon: const Icon(Icons.close, size: 14),
                        label: Text(AppStrings.cancelJobLabel),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: _coral,
                          side: const BorderSide(color: _coral),
                          padding: const EdgeInsets.symmetric(horizontal: 10),
                          textStyle: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          minimumSize: Size.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],

          // Show existing review inline
          if (job.review != null) ...[
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 26),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        ...List.generate(
                          5,
                          (i) => Icon(
                            i < job.review!.rating
                                ? Icons.star
                                : Icons.star_border,
                            color: const Color(0xFFFFC107),
                            size: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          job.review!.date,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _grey,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    if (job.review!.comment.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          job.review!.comment,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _jobStatusBadge(ThemeData theme, JobStatus status) {
    final Color bg;
    final Color fg;
    final String label;

    switch (status) {
      case JobStatus.completed:
        bg = const Color(0xFFE0F5F5);
        fg = _teal;
        label = AppStrings.jobCompleted;
      case JobStatus.upcoming:
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFF57C00);
        label = AppStrings.jobUpcoming;
      case JobStatus.cancelled:
        bg = const Color(0xFFFFEBEE);
        fg = _coral;
        label = AppStrings.jobCancelled;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 11, fontWeight: FontWeight.w600),
      ),
    );
  }

  /// Confirm cancel dialog for a job.
  void _confirmCancelJob(OrderModel order, int jobIndex) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(AppStrings.cancelJobLabel),
        content: Text(AppStrings.cancelJobConfirm),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              widget.ordersNotifier.cancelJob(order.id, jobIndex);
              Navigator.pop(ctx);
            },
            child: Text(
              AppStrings.cancelJobLabel,
              style: const TextStyle(color: _coral),
            ),
          ),
        ],
      ),
    );
  }

  /// Review bottom sheet for a specific job.
  void _showJobReviewSheet(OrderModel order, int jobIndex) {
    int selectedRating = 0;
    final commentCtrl = TextEditingController();
    final job = order.jobs[jobIndex];

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            final theme = Theme.of(ctx);
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                24 + MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${AppStrings.rateStudent}: ${job.studentName}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_dayMediumName(job.weekday)}, ${job.date}',
                    style: theme.textTheme.bodySmall?.copyWith(color: _grey),
                  ),
                  const SizedBox(height: 20),

                  // Stars
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (i) {
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setSheetState(() => selectedRating = i + 1);
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Icon(
                            i < selectedRating ? Icons.star : Icons.star_border,
                            color: const Color(0xFFFFC107),
                            size: 40,
                          ),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),

                  // Comment
                  TextField(
                    controller: commentCtrl,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: AppStrings.reviewHint,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Submit
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: selectedRating > 0
                          ? () {
                              final now = DateTime.now();
                              final dateStr =
                                  '${now.day.toString().padLeft(2, '0')}.'
                                  '${now.month.toString().padLeft(2, '0')}.'
                                  '${now.year}';
                              widget.ordersNotifier.addJobReview(
                                order.id,
                                jobIndex,
                                ReviewModel(
                                  rating: selectedRating,
                                  comment: commentCtrl.text.trim(),
                                  date: dateStr,
                                ),
                              );
                              if (!ctx.mounted) return;
                              Navigator.pop(ctx);
                            }
                          : null,
                      child: Text(AppStrings.sendReview),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 3-letter day abbreviation from weekday int.
  String _dayMediumName(int day) {
    switch (day) {
      case 1:
        return AppStrings.dayMon;
      case 2:
        return AppStrings.dayTue;
      case 3:
        return AppStrings.dayWed;
      case 4:
        return AppStrings.dayThu;
      case 5:
        return AppStrings.dayFri;
      case 6:
        return AppStrings.daySat;
      case 7:
        return AppStrings.daySun;
      default:
        return '';
    }
  }

  // ── Status chip ──
  Widget _statusChip(ThemeData theme, OrderStatus status) {
    final Color bg;
    final Color fg;
    final String label;

    switch (status) {
      case OrderStatus.processing:
        bg = const Color(0xFFFFF3E0);
        fg = const Color(0xFFE65100);
        label = AppStrings.orderProcessing;
      case OrderStatus.active:
        bg = const Color(0xFFE0F5F5);
        fg = _teal;
        label = AppStrings.orderActive;
      case OrderStatus.completed:
        bg = const Color(0xFFE8F5E9);
        fg = const Color(0xFF2E7D32);
        label = AppStrings.orderCompleted;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(color: fg, fontSize: 13, fontWeight: FontWeight.w600),
      ),
    );
  }
}
