import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:receiptlens/presentation/screens/capture/capture_screen.dart';
import 'package:receiptlens/presentation/screens/receipts/receipt_list_screen.dart';
import 'package:receiptlens/presentation/screens/summary/monthly_summary_screen.dart';

/// The app's root shell: a bottom-navigation scaffold switching between the
/// receipt list and the monthly summary/export screen, with a floating
/// action button that starts the capture -> crop -> OCR review flow.
///
/// This is the only screen [MyApp] mounts directly - everything else is
/// reached by pushing routes from here, which keeps `main.dart` a thin,
/// declarative entry point instead of the Flutter counter-app boilerplate.
class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key});

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  int _tabIndex = 0;

  static const _tabs = [ReceiptListScreen(), MonthlySummaryScreen()];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _tabIndex, children: _tabs),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (_) => const CaptureScreen())),
        icon: const Icon(Icons.document_scanner_outlined),
        label: const Text('Scan'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Receipts',
          ),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            selectedIcon: Icon(Icons.pie_chart),
            label: 'Summary',
          ),
        ],
      ),
    );
  }
}
