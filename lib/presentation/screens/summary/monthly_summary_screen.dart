import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:receiptlens/domain/entities/receipt.dart';
import 'package:receiptlens/domain/export/csv_exporter.dart';
import 'package:receiptlens/domain/export/quickbooks_exporter.dart';
import 'package:receiptlens/presentation/providers/app_providers.dart';
import 'package:receiptlens/presentation/widgets/category_badge.dart';
import 'package:receiptlens/services/export/export_file_service.dart';

class MonthlySummaryScreen extends ConsumerStatefulWidget {
  const MonthlySummaryScreen({super.key});

  @override
  ConsumerState<MonthlySummaryScreen> createState() =>
      _MonthlySummaryScreenState();
}

class _MonthlySummaryScreenState extends ConsumerState<MonthlySummaryScreen> {
  int _selectedIndex = 0;
  bool _exporting = false;

  @override
  Widget build(BuildContext context) {
    final receiptsAsync = ref.watch(allReceiptsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Monthly Summary')),
      body: receiptsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load: $e')),
        data: (receipts) {
          if (receipts.isEmpty) {
            return const Center(child: Text('No receipts yet.'));
          }

          final calculator = ref.read(monthlySummaryCalculatorProvider);
          final summaries = calculator.calculate(receipts);
          final index = _selectedIndex.clamp(0, summaries.length - 1);
          final summary = summaries[index];

          final monthReceipts = receipts
              .where(
                (r) =>
                    r.purchasedAt.year == summary.year &&
                    r.purchasedAt.month == summary.month,
              )
              .toList();

          final sortedCategories = summary.totalsByCategory.entries.toList()
            ..sort((a, b) => b.value.cents.compareTo(a.value.cents));

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: index,
                  items: [
                    for (var i = 0; i < summaries.length; i++)
                      DropdownMenuItem(
                        value: i,
                        child: Text(summaries[i].label),
                      ),
                  ],
                  onChanged: (v) => setState(() => _selectedIndex = v ?? 0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(
                      summary.grandTotal.format(),
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 24),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    for (final entry in sortedCategories)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CategoryBadge(category: entry.key),
                            Text(entry.value.format()),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _exporting
                              ? null
                              : () => _export(monthReceipts, quickBooks: false),
                          icon: const Icon(Icons.table_view),
                          label: const Text('Export CSV'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: _exporting
                              ? null
                              : () => _export(monthReceipts, quickBooks: true),
                          icon: const Icon(Icons.receipt_long),
                          label: const Text('Export QuickBooks'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _export(
    List<Receipt> monthReceipts, {
    required bool quickBooks,
  }) async {
    setState(() => _exporting = true);
    try {
      final content = quickBooks
          ? const QuickBooksExporter().export(monthReceipts)
          : const CsvExporter().export(monthReceipts);

      final fileName = quickBooks
          ? 'receiptlens_quickbooks_export.csv'
          : 'receiptlens_export.csv';

      const service = ExportFileService();
      final file = await service.writeToTempFile(content, fileName);
      await service.share(file, subject: 'ReceiptLens export');
    } finally {
      if (mounted) setState(() => _exporting = false);
    }
  }
}
