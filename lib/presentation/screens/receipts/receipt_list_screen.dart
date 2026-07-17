import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:receiptlens/presentation/providers/app_providers.dart';
import 'package:receiptlens/presentation/screens/receipts/receipt_detail_screen.dart';

class ReceiptListScreen extends ConsumerWidget {
  const ReceiptListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final receiptsAsync = ref.watch(allReceiptsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Receipts')),
      body: receiptsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Failed to load receipts: $e')),
        data: (receipts) {
          if (receipts.isEmpty) {
            return const Center(
              child: Text('No receipts yet. Tap Scan to add one.'),
            );
          }
          return ListView.separated(
            itemCount: receipts.length,
            separatorBuilder: (_, _) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final receipt = receipts[index];
              return ListTile(
                title: Text(receipt.vendor),
                subtitle: Text(
                  '${receipt.purchasedAt.year}-${receipt.purchasedAt.month.toString().padLeft(2, '0')}-${receipt.purchasedAt.day.toString().padLeft(2, '0')} · ${receipt.lineItems.length} items',
                ),
                trailing: Text(receipt.total.format()),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ReceiptDetailScreen(receipt: receipt),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
