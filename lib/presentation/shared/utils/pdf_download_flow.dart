import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:open_filex/open_filex.dart';
import 'package:share_plus/share_plus.dart';

import '../styles/app_colors.dart';
import 'pdf_temp_io.dart' if (dart.library.html) 'pdf_temp_stub.dart' as pdf_temp;
import 'web_pdf_stub.dart' if (dart.library.html) 'web_pdf_html.dart' as web_pdf;

String _sanitizePdfFileName(String name) {
  var n = name.trim();
  if (!n.toLowerCase().endsWith('.pdf')) n = '$n.pdf';
  return n.replaceAll(RegExp(r'[^\w\-\.]'), '_');
}

Future<String> _writePdfToTemp(Uint8List bytes, String fileName) async {
  final safe = _sanitizePdfFileName(fileName);
  return pdf_temp.savePdfToTempFile(bytes, safe);
}

Future<void> _presentWebPdfDialog(
  BuildContext context,
  Uint8List bytes,
  String safeName,
) async {
  web_pdf.triggerPdfBrowserDownload(bytes, safeName);
  if (!context.mounted) return;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Text('PDF pronto', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
      content: Text(
        'O download deve aparecer na barra do navegador. Se não começou, use os botões abaixo.',
        style: GoogleFonts.poppins(fontSize: 14, height: 1.35),
      ),
      actions: [
        TextButton(
          onPressed: () {
            web_pdf.openPdfInBrowserTab(bytes);
            Navigator.of(ctx).pop();
          },
          child: Text('Abrir em nova aba', style: GoogleFonts.poppins(color: AppColors.primaryBlue)),
        ),
        TextButton(
          onPressed: () {
            web_pdf.triggerPdfBrowserDownload(bytes, safeName);
          },
          child: Text('Baixar novamente', style: GoogleFonts.poppins(color: AppColors.primaryBlue)),
        ),
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(),
          child: Text('Fechar', style: GoogleFonts.poppins()),
        ),
      ],
    ),
  );
}

/// Abre o diálogo de carregamento. **Não use `await`** — o `Future` do [showDialog] só termina quando o diálogo fecha.
/// Fechar com [dismissPdfLoadingDialog] após a operação assíncrona.
void openPdfLoadingDialog(BuildContext context, String message) {
  showDialog<void>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (ctx) => PopScope(
      canPop: false,
      child: AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Row(
          children: [
            const CircularProgressIndicator(color: AppColors.primaryBlue),
            const SizedBox(width: 20),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.poppins(fontSize: 15, height: 1.35),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

void dismissPdfLoadingDialog(BuildContext context) {
  final nav = Navigator.of(context, rootNavigator: true);
  if (nav.canPop()) nav.pop();
}

/// Após o PDF estar em disco (mobile), mostra opções estáveis: abrir, compartilhar/WhatsApp, salvar.
Future<void> showPdfActionsBottomSheet({
  required BuildContext context,
  required String filePath,
  required String fileName,
  required String sheetTitle,
  String? shareMessage,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (sheetCtx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                sheetTitle,
                style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600, color: AppColors.textDark),
              ),
              const SizedBox(height: 6),
              Text(
                fileName,
                style: GoogleFonts.poppins(fontSize: 13, color: AppColors.textLight),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.of(sheetCtx).pop();
                  await OpenFilex.open(filePath);
                },
                icon: const Icon(Icons.open_in_new_rounded),
                label: Text('Abrir PDF', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
              const SizedBox(height: 10),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  final box = sheetCtx.findRenderObject() as RenderBox?;
                  final origin = box != null && box.hasSize ? box.localToGlobal(Offset.zero) & box.size : null;
                  Navigator.of(sheetCtx).pop();
                  await Share.shareXFiles(
                    [
                      XFile(
                        filePath,
                        mimeType: 'application/pdf',
                        name: fileName,
                      ),
                    ],
                    text: shareMessage ?? 'Segue o PDF em anexo.',
                    subject: sheetTitle,
                    sharePositionOrigin: origin,
                  );
                },
                icon: const Icon(Icons.chat_rounded),
                label: Text(
                  'Enviar por WhatsApp ou outro app',
                  style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: const BorderSide(color: AppColors.primaryBlue),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () async {
                  Navigator.of(sheetCtx).pop();
                  final bytes = await pdf_temp.readPdfFileBytes(filePath);
                  await FileSaver.instance.saveFile(
                    name: fileName,
                    bytes: bytes,
                    ext: 'pdf',
                    mimeType: MimeType.pdf,
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Salvo no dispositivo.', style: GoogleFonts.poppins()),
                        backgroundColor: AppColors.successGreen,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.save_alt_rounded),
                label: Text('Salvar em arquivos / compartilhar pelo sistema', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ),
      );
    },
  );
}

/// Baixa o PDF com diálogo de carregamento e, no mobile, abre folha de ações. Na web, dispara download via Blob e oferece abrir em nova aba.
Future<void> runPdfDownloadFlow({
  required BuildContext context,
  required Future<Uint8List> Function() fetchPdf,
  required String fileName,
  required String loadingMessage,
  String sheetTitle = 'PDF pronto',
  String? shareMessage,
}) async {
  if (!context.mounted) return;
  openPdfLoadingDialog(context, loadingMessage);
  try {
    final bytes = await fetchPdf();
    if (!context.mounted) return;
    dismissPdfLoadingDialog(context);

    final safeName = _sanitizePdfFileName(fileName);

    if (kIsWeb) {
      await _presentWebPdfDialog(context, bytes, safeName);
      return;
    }

    final path = await _writePdfToTemp(bytes, safeName);
    if (!context.mounted) return;
    await showPdfActionsBottomSheet(
      context: context,
      filePath: path,
      fileName: safeName,
      sheetTitle: sheetTitle,
      shareMessage: shareMessage,
    );
  } catch (e) {
    if (context.mounted) {
      dismissPdfLoadingDialog(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao obter PDF: $e', style: GoogleFonts.poppins()),
          backgroundColor: AppColors.errorRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

/// Quando os bytes já existem (ex.: PDF gerado localmente após criar recibo).
Future<void> presentPdfFromBytes({
  required BuildContext context,
  required Uint8List bytes,
  required String fileName,
  String sheetTitle = 'PDF pronto',
  String? shareMessage,
}) async {
  final safeName = _sanitizePdfFileName(fileName);

  if (kIsWeb) {
    await _presentWebPdfDialog(context, bytes, safeName);
    return;
  }

  final path = await _writePdfToTemp(bytes, safeName);
  if (!context.mounted) return;
  await showPdfActionsBottomSheet(
    context: context,
    filePath: path,
    fileName: safeName,
    sheetTitle: sheetTitle,
    shareMessage: shareMessage,
  );
}
