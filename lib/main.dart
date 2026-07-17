import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:receiptlens/presentation/screens/home/home_shell.dart';

void main() {
  runApp(const ProviderScope(child: ReceiptLensApp()));
}

/// ReceiptLens: on-device receipt digitization for freelancers and SMBs.
///
/// Every provider wired here (see `presentation/providers/app_providers.dart`)
/// resolves to an on-device implementation - camera capture, ML Kit OCR, a
/// TFLite/pure-Dart categorization model, and an encrypted local Drift/
/// SQLite database. Nothing in the default provider graph performs network
/// I/O.
class ReceiptLensApp extends StatelessWidget {
  const ReceiptLensApp({super.key});

  static const _seedColor = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ReceiptLens',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _seedColor),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _seedColor,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeShell(),
    );
  }
}
