import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../config/app_colors.dart';

/// Widget para visualizar PDFs dentro do app
class PdfViewer extends StatefulWidget {
  final String pdfUrl;
  final String? title;

  const PdfViewer({
    super.key,
    required this.pdfUrl,
    this.title,
  });

  @override
  State<PdfViewer> createState() => _PdfViewerState();
}

class _PdfViewerState extends State<PdfViewer> {
  String? localPath;
  bool _isLoading = true;
  String? _errorMessage;
  PDFViewController? _pdfViewController;
  int _totalPages = 0;
  int _currentPage = 0;

  bool get _isSupportedPlatform {
    // flutter_pdfview só funciona em Android e iOS
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  @override
  void initState() {
    super.initState();
    if (_isSupportedPlatform) {
      _loadPdf();
    } else {
      // Para Windows/Web, não precisa carregar, apenas abrir no navegador
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _openPdfInBrowser() async {
    try {
      final uri = Uri.parse(widget.pdfUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Não foi possível abrir o PDF'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Erro ao abrir PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Erro ao abrir o PDF'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // Baixa o PDF
      final response = await http.get(Uri.parse(widget.pdfUrl));
      
      if (response.statusCode == 200) {
        // Salva temporariamente
        final tempDir = await getTemporaryDirectory();
        final file = File('${tempDir.path}/cardapio_${DateTime.now().millisecondsSinceEpoch}.pdf');
        await file.writeAsBytes(response.bodyBytes);
        
        if (mounted) {
          setState(() {
            localPath = file.path;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _errorMessage = 'Erro ao carregar PDF: ${response.statusCode}';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Erro ao carregar PDF: $e');
      if (mounted) {
        setState(() {
          _errorMessage = 'Erro ao carregar PDF: $e';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: AppColors.gray800),
        title: widget.title != null
            ? Text(
                widget.title!,
                style: const TextStyle(color: AppColors.gray800),
              )
            : const Text(
                'Cardápio',
                style: TextStyle(color: AppColors.gray800),
              ),
        actions: [
          if (_totalPages > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  '$_currentPage / $_totalPages',
                  style: const TextStyle(
                    color: AppColors.gray600,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColors.gray800),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      body: _isSupportedPlatform
          ? (_isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : _errorMessage != null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            size: 64,
                            color: AppColors.gray400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            _errorMessage!,
                            style: const TextStyle(color: AppColors.gray600),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: _loadPdf,
                            child: const Text('Tentar Novamente'),
                          ),
                        ],
                      ),
                    )
                  : localPath != null
                      ? PDFView(
                          filePath: localPath!,
                          enableSwipe: true,
                          swipeHorizontal: false,
                          autoSpacing: true,
                          pageFling: true,
                          onRender: (pages) {
                            setState(() {
                              _totalPages = pages ?? 0;
                            });
                          },
                          onError: (error) {
                            setState(() {
                              _errorMessage = 'Erro ao renderizar PDF: $error';
                            });
                          },
                          onPageError: (page, error) {
                            debugPrint('Erro na página $page: $error');
                          },
                          onViewCreated: (PDFViewController controller) {
                            _pdfViewController = controller;
                          },
                          onLinkHandler: (String? uri) {
                            debugPrint('Link clicado: $uri');
                          },
                          onPageChanged: (int? page, int? total) {
                            setState(() {
                              _currentPage = page ?? 0;
                              _totalPages = total ?? 0;
                            });
                          },
                        )
                      : const Center(
                          child: Text('Erro ao carregar PDF'),
                        ))
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(32),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.picture_as_pdf,
                      size: 64,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Cardápio PDF',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.gray800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'O cardápio será aberto no visualizador de PDF do seu dispositivo',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    onPressed: _openPdfInBrowser,
                    icon: const Icon(Icons.open_in_browser),
                    label: const Text('Abrir Cardápio'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

