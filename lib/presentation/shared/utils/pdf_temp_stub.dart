import 'dart:typed_data';

Future<String> savePdfToTempFile(Uint8List bytes, String safeName) async {
  throw UnsupportedError('savePdfToTempFile só está disponível em plataformas com dart:io');
}

Future<Uint8List> readPdfFileBytes(String path) async {
  throw UnsupportedError('readPdfFileBytes só está disponível em plataformas com dart:io');
}
