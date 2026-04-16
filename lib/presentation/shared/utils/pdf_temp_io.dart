import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

Future<String> savePdfToTempFile(Uint8List bytes, String safeName) async {
  final dir = await getTemporaryDirectory();
  final file = File('${dir.path}/$safeName');
  await file.writeAsBytes(bytes, flush: true);
  return file.path;
}

Future<Uint8List> readPdfFileBytes(String path) => File(path).readAsBytes();
