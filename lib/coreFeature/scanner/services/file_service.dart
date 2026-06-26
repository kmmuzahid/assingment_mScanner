import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import '../models/inspection_item.dart';

class FileService {
  static Future<String> saveInspectionListToCsv(
    List<InspectionItem> items, {
    String? filePath,
  }) async {
    List<List<dynamic>> rows = [];
    // Header
    rows.add(["ID", "Code", "Quantity", "Timestamp", "Type"]);

    for (var item in items) {
      rows.add([
        item.id,
        item.value,
        item.quantity,
        item.timestamp.toIso8601String(),
        item.type,
      ]);
    }

    String csvData = Csv().encode(rows);

    String? path = filePath;
    if (path == null) {
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      path = "${directory.path}/inspection_$timestamp.csv";
    }
    final File file = File(path);
    await file.writeAsString(csvData);
    return path;
  }

  static Future<List<File>> getSavedFiles() async {
    final directory = await getApplicationDocumentsDirectory();
    final List<FileSystemEntity> entities = directory.listSync();
    return entities
        .whereType<File>()
        .where((file) => file.path.endsWith('.csv'))
        .toList()
        ..sort((a, b) => b.lastModifiedSync().compareTo(a.lastModifiedSync()));
  }
  
  static Future<void> deleteFile(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  static Future<List<List<dynamic>>> readCsvFile(File file) async {
    final input = await file.readAsString();
    return Csv().decode(input);
  }
}
