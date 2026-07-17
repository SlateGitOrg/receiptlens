import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Writes an exported CSV/QuickBooks string to a local file and hands it
/// off to the OS share sheet (AirDrop, email, Files app, etc). Writing
/// happens entirely on local storage; sharing is a user-initiated,
/// OS-level action outside the app's own "no network" core flow.
class ExportFileService {
  const ExportFileService();

  Future<File> writeToTempFile(String content, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    return file.writeAsString(content);
  }

  Future<void> share(File file, {String? subject}) async {
    await Share.shareXFiles([XFile(file.path)], subject: subject);
  }
}
