import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:receiptlens/domain/entities/expense_category.dart';
import 'package:receiptlens/domain/entities/line_item.dart';
import 'package:receiptlens/domain/entities/receipt.dart';
import 'package:receiptlens/presentation/providers/app_providers.dart';
import 'package:receiptlens/presentation/widgets/line_item_tile.dart';

/// Runs the on-device OCR + categorization pipeline against a captured,
/// cropped receipt image and lets the user confirm/correct the result
/// before it's saved (encrypted) to local storage.
///
/// [debugDraft] is exposed purely so widget tests can inject an
/// already-parsed [Receipt] and skip the (untestable-without-a-device)
/// OCR pipeline, exercising only the review/edit/save flow.
class ReviewReceiptScreen extends ConsumerStatefulWidget {
  const ReviewReceiptScreen({
    super.key,
    required this.imagePath,
    this.debugDraft,
  });

  final String imagePath;
  final Receipt? debugDraft;

  @override
  ConsumerState<ReviewReceiptScreen> createState() =>
      _ReviewReceiptScreenState();
}

class _ReviewReceiptScreenState extends ConsumerState<ReviewReceiptScreen> {
  Receipt? _draft;
  String? _error;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.debugDraft != null) {
      _draft = widget.debugDraft;
    } else {
      _runPipeline();
    }
  }

  Future<void> _runPipeline() async {
    final pipeline = await ref.read(receiptProcessingPipelineProvider.future);
    final result = await pipeline.process(widget.imagePath);
    if (!mounted) return;
    result.when(
      ok: (receipt) => setState(
        () => _draft = receipt.copyWith(imagePath: widget.imagePath),
      ),
      err: (message) => setState(() => _error = message),
    );
  }

  void _updateCategory(int index, ExpenseCategory category) {
    final draft = _draft;
    if (draft == null) return;
    final updated = List<LineItem>.from(draft.lineItems);
    updated[index] = updated[index].copyWith(category: category);
    setState(() => _draft = draft.copyWith(lineItems: updated));
  }

  Future<void> _save() async {
    final draft = _draft;
    if (draft == null) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(receiptRepositoryProvider);
      await repo.save(draft);
      ref.read(receiptsRefreshProvider.notifier).state++;
      if (!mounted) return;
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save: $e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Receipt')),
      body: _buildBody(),
      floatingActionButton: _draft == null
          ? null
          : FloatingActionButton.extended(
              onPressed: _saving ? null : _save,
              icon: _saving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: const Text('Save Receipt'),
            ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Colors.redAccent,
              ),
              const SizedBox(height: 12),
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  setState(() => _error = null);
                  _runPipeline();
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final draft = _draft;
    if (draft == null) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Reading receipt on-device…'),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        Text(
          draft.vendor,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          '${draft.purchasedAt.year}-${draft.purchasedAt.month.toString().padLeft(2, '0')}-${draft.purchasedAt.day.toString().padLeft(2, '0')}',
          style: TextStyle(color: Colors.grey.shade600),
        ),
        const Divider(height: 32),
        ...draft.lineItems.asMap().entries.map(
          (entry) => LineItemTile(
            item: entry.value,
            onCategoryChanged: (c) => _updateCategory(entry.key, c),
          ),
        ),
        const Divider(height: 32),
        _totalsRow('Subtotal', draft.subtotal.format()),
        _totalsRow('Tax', draft.tax.format()),
        _totalsRow('Total', draft.total.format(), bold: true),
      ],
    );
  }

  Widget _totalsRow(String label, String value, {bool bold = false}) {
    final style = TextStyle(
      fontSize: bold ? 18 : 15,
      fontWeight: bold ? FontWeight.bold : FontWeight.normal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: style),
          Text(value, style: style),
        ],
      ),
    );
  }
}
