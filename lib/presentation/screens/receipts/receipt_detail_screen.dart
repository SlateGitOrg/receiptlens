import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:receiptlens/domain/entities/receipt.dart';
import 'package:receiptlens/presentation/providers/app_providers.dart';
import 'package:receiptlens/presentation/widgets/category_badge.dart';

class ReceiptDetailScreen extends ConsumerWidget {
  const ReceiptDetailScreen({super.key, required this.receipt});

  final Receipt receipt;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(receipt.vendor),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () async {
              final repo = ref.read(receiptRepositoryProvider);
              if (receipt.id != null) {
                await repo.delete(receipt.id!);
                ref.read(receiptsRefreshProvider.notifier).state++;
              }
              if (context.mounted) Navigator.of(context).pop();
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final item in receipt.lineItems)
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(item.description),
              subtitle: Align(
                alignment: Alignment.centerLeft,
                child: CategoryBadge(category: item.category),
              ),
              trailing: Text(item.amount.format()),
            ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Total'),
            trailing: Text(
              receipt.total.format(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
