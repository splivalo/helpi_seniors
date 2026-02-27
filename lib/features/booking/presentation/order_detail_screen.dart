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
      body: SingleChildScrollView(
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

            // ── Students section ──
            _studentsSection(theme, order),
            const SizedBox(height: 24),

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

          // One-time: time + duration
          if (order.isOneTime) ...[
            const Divider(height: 24),
            _summaryRow(theme, AppStrings.orderSummaryTime, order.time),
            const Divider(height: 24),
            _summaryRow(theme, AppStrings.orderSummaryDuration, order.duration),
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
                      entry.dayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${entry.time}  ·  ${entry.duration}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
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

  Widget _summaryRow(ThemeData theme, String label, String value) {
    return Row(
      children: [
        Text(label, style: theme.textTheme.bodySmall?.copyWith(color: _grey)),
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

  // ── Students section ──
  Widget _studentsSection(ThemeData theme, OrderModel order) {
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
          Text(
            AppStrings.studentsSection,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const Divider(height: 24),
          if (order.students.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Center(
                child: Text(
                  AppStrings.noStudentsYet,
                  style: theme.textTheme.bodyMedium?.copyWith(color: _grey),
                ),
              ),
            )
          else
            ...order.students.asMap().entries.map((entry) {
              final idx = entry.key;
              final student = entry.value;
              return _studentCard(theme, order, idx, student);
            }),
        ],
      ),
    );
  }

  Widget _studentCard(
    ThemeData theme,
    OrderModel order,
    int studentIndex,
    StudentAssignment student,
  ) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: studentIndex < order.students.length - 1 ? 16 : 0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + rate button
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0F5F5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: _teal, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${AppStrings.assignedSince}: ${student.fromDate}',
                      style: theme.textTheme.bodySmall?.copyWith(color: _grey),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 36,
                child: OutlinedButton.icon(
                  onPressed: () => _showReviewSheet(order, studentIndex),
                  icon: const Icon(Icons.star, size: 16),
                  label: Text(AppStrings.rateStudent),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    textStyle: const TextStyle(fontSize: 13),
                    minimumSize: Size.zero,
                  ),
                ),
              ),
            ],
          ),

          // Reviews list
          if (student.reviews.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              AppStrings.yourReviews,
              style: theme.textTheme.bodySmall?.copyWith(color: _grey),
            ),
            const SizedBox(height: 8),
            ...student.reviews.map(
              (review) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF9F7F4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Row 1: stars + date
                      Row(
                        children: [
                          ...List.generate(
                            5,
                            (i) => Icon(
                              i < review.rating
                                  ? Icons.star
                                  : Icons.star_border,
                              color: const Color(0xFFFFC107),
                              size: 16,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            review.date,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: _grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                      // Row 2: comment (max 3 lines)
                      if (review.comment.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            review.comment,
                            style: theme.textTheme.bodySmall,
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Review bottom sheet ──
  void _showReviewSheet(OrderModel order, int studentIndex) {
    int selectedRating = 0;
    final commentCtrl = TextEditingController();

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
                    '${AppStrings.rateStudent}: '
                    '${order.students[studentIndex].name}',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
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
                              widget.ordersNotifier.addReview(
                                order.id,
                                studentIndex,
                                ReviewModel(
                                  rating: selectedRating,
                                  comment: commentCtrl.text.trim(),
                                  date: dateStr,
                                ),
                              );
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
