// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
// dart:html está deprecado; Blob + âncora continua estável até migração para package:web.

import 'dart:html' as html;
import 'dart:typed_data';

void triggerPdfBrowserDownload(Uint8List bytes, String fileName) {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = fileName
    ..style.display = 'none';
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}

void openPdfInBrowserTab(Uint8List bytes) {
  final blob = html.Blob([bytes], 'application/pdf');
  final url = html.Url.createObjectUrlFromBlob(blob);
  html.window.open(url, '_blank');
  Future<void>.delayed(const Duration(seconds: 2), () {
    html.Url.revokeObjectUrl(url);
  });
}
