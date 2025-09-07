import 'dart:io';
import 'package:path/path.dart' as path;

class FileUtils {
  static Future<void> createDirectory(String dirPath) async {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  static Future<void> writeFile(String filePath, String content) async {
    final file = File(filePath);
    await file.parent.create(recursive: true);
    await file.writeAsString(content);
  }

  static String toPascalCase(String text) {
    return text
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join('');
  }

  static String toSnakeCase(String text) {
    return text
        .replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), '_')
        .toLowerCase();
  }
}
