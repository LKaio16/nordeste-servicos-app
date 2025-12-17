import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart' as cached;
import '../config/app_colors.dart';
import '../models/article.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../widgets/cached_image.dart';
import '../widgets/whatsapp_button.dart';

/// Tela de Dicas e Artigos
class ArticlesScreen extends StatefulWidget {
  final VoidCallback? onBack;
  final Article? initialArticle; // Artigo para mostrar diretamente

  const ArticlesScreen({super.key, this.onBack, this.initialArticle});

  @override
  State<ArticlesScreen> createState() => _ArticlesScreenState();
}

class _ArticlesScreenState extends State<ArticlesScreen> {
  final _apiService = ApiService();
  Article? _selectedArticle;
  
  List<Article> _articles = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Se um artigo inicial foi fornecido, define como selecionado
    if (widget.initialArticle != null) {
      _selectedArticle = widget.initialArticle;
    }
    _carregarDicas();
  }

  Future<void> _carregarDicas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('ArticlesScreen: Iniciando carregamento de dicas...');
      final response = await _apiService.getTips();
      debugPrint('ArticlesScreen: Resposta recebida - success: ${response.isSuccess}');
      
      if (response.isSuccess && response.data != null) {
        debugPrint('ArticlesScreen: Dados recebidos: ${response.data}');
        final dicas = (response.data as List)
            .map((json) => Article.fromApiJson(json as Map<String, dynamic>))
            .toList();
        debugPrint('ArticlesScreen: ${dicas.length} dicas carregadas');
        setState(() {
          _articles = dicas;
          _isLoading = false;
        });
      } else {
        debugPrint('ArticlesScreen: Erro - ${response.error}');
        setState(() {
          _errorMessage = response.error ?? 'Erro ao carregar dicas';
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('ArticlesScreen: Exceção - $e');
      setState(() {
        _errorMessage = 'Erro ao carregar dicas. Verifique sua conexão.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Se tem artigo inicial ou selecionado, mostra o detalhe
    final articleToShow = widget.initialArticle ?? _selectedArticle;
    if (articleToShow != null) {
      return _ArticleDetailView(
        article: articleToShow,
        onBack: () {
          if (widget.initialArticle != null) {
            // Se veio de navegação direta (da home), usa o callback onBack
            widget.onBack?.call();
          } else {
            // Se foi selecionado da lista, limpa a seleção para voltar à lista
            setState(() => _selectedArticle = null);
          }
        },
      );
    }

    return Column(
      children: [
        // Header with back button
        if (widget.onBack != null)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(bottom: BorderSide(color: AppColors.gray200)),
            ),
            child: Row(
              children: [
                IconButton(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back),
                ),
                Text(
                  'Dicas e Artigos',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),

        // Content
        Expanded(
          child: _buildContent(),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppColors.primary,
            ),
            SizedBox(height: 16),
            Text(
              'Carregando dicas...',
              style: TextStyle(
                color: AppColors.gray500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
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
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.gray600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _carregarDicas,
                icon: const Icon(Icons.refresh),
                label: const Text('Tentar novamente'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_articles.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.article_outlined,
              size: 64,
              color: AppColors.gray400,
            ),
            const SizedBox(height: 16),
            const Text(
              'Nenhuma dica disponível no momento',
              style: TextStyle(
                color: AppColors.gray600,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _carregarDicas,
              icon: const Icon(Icons.refresh),
              label: const Text('Atualizar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _carregarDicas,
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _articles.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _ArticleCard(
              article: _articles[index],
              onTap: () => setState(() => _selectedArticle = _articles[index]),
            ),
          );
        },
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final Article article;
  final VoidCallback onTap;

  const _ArticleCard({required this.article, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          height: 110,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.gray100),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
                child: SizedBox(
                  width: 100,
                  height: double.infinity,
                  child: CachedImage(
                    imageUrl: article.imageUrl,
                    useAuth: true, // Usa autenticação para imagens da API
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          article.category,
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        article.title,
                        style: const TextStyle(
                          color: AppColors.gray800,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        article.content,
                        style: const TextStyle(
                          color: AppColors.gray500,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArticleDetailView extends StatefulWidget {
  final Article article;
  final VoidCallback onBack;

  const _ArticleDetailView({required this.article, required this.onBack});

  @override
  State<_ArticleDetailView> createState() => _ArticleDetailViewState();
}

class _ArticleDetailViewState extends State<_ArticleDetailView> {
  bool _isImageLoaded = false;
  bool _isIconLoaded = false;
  bool _isContentReady = false;

  @override
  void initState() {
    super.initState();
    // Precarrega as imagens
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    // Aguarda um frame para garantir que o widget está montado
    await Future.delayed(const Duration(milliseconds: 100));
    
    if (!mounted) return;

    // Precarrega a imagem principal
    try {
      final imageProvider = cached.CachedNetworkImageProvider(
        widget.article.imageUrl,
        headers: _getAuthHeaders(),
      );
      final imageStream = imageProvider.resolve(const ImageConfiguration());
      final completer = Completer<void>();
      
      final listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        if (mounted) {
          setState(() => _isImageLoaded = true);
        }
      }, onError: (exception, stackTrace) {
        if (!completer.isCompleted) {
          completer.complete();
        }
        if (mounted) {
          setState(() => _isImageLoaded = true); // Mostra mesmo se der erro
        }
      });
      
      imageStream.addListener(listener);
      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          if (mounted) {
            setState(() => _isImageLoaded = true);
          }
        },
      );
      imageStream.removeListener(listener);
    } catch (e) {
      debugPrint('Erro ao precarregar imagem: $e');
      if (mounted) {
        setState(() => _isImageLoaded = true);
      }
    }

    // Precarrega o ícone se for uma URL
    if (widget.article.icon.isNotEmpty && widget.article.icon.startsWith('http')) {
      try {
        final iconProvider = cached.CachedNetworkImageProvider(
          widget.article.icon,
          headers: _getAuthHeaders(),
        );
        final iconStream = iconProvider.resolve(const ImageConfiguration());
        final completer = Completer<void>();
        
        final listener = ImageStreamListener((ImageInfo info, bool synchronousCall) {
          if (!completer.isCompleted) {
            completer.complete();
          }
          if (mounted) {
            setState(() => _isIconLoaded = true);
          }
        }, onError: (exception, stackTrace) {
          if (!completer.isCompleted) {
            completer.complete();
          }
          if (mounted) {
            setState(() => _isIconLoaded = true);
          }
        });
        
        iconStream.addListener(listener);
        await completer.future.timeout(
          const Duration(seconds: 5),
          onTimeout: () {
            if (mounted) {
              setState(() => _isIconLoaded = true);
            }
          },
        );
        iconStream.removeListener(listener);
      } catch (e) {
        debugPrint('Erro ao precarregar ícone: $e');
        if (mounted) {
          setState(() => _isIconLoaded = true);
        }
      }
    } else {
      // Se não é URL, já está pronto
      if (mounted) {
        setState(() => _isIconLoaded = true);
      }
    }

    // Aguarda um pouco mais para garantir que tudo está renderizado
    await Future.delayed(const Duration(milliseconds: 200));
    
    if (mounted) {
      setState(() => _isContentReady = true);
    }
  }

  Map<String, String>? _getAuthHeaders() {
    try {
      final authService = AuthService();
      final token = authService.accessToken;
      if (token != null && token.isNotEmpty) {
        return {'Authorization': 'Bearer $token'};
      }
    } catch (e) {
      debugPrint('Erro ao obter token: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Mostra loading enquanto as imagens não estão prontas
    if (!_isContentReady || !_isImageLoaded) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'Carregando...',
                style: TextStyle(
                  color: AppColors.gray600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Image Header
          Stack(
            children: [
              SizedBox(
                height: 280,
                width: double.infinity,
                child: CachedImage(
                  imageUrl: widget.article.imageUrl,
                  useAuth: true,
                ),
              ),
              Container(
                height: 280,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.3),
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                left: 16,
                child: Material(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(50),
                  child: InkWell(
                    onTap: widget.onBack,
                    borderRadius: BorderRadius.circular(50),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                      ),
                      child: Text(
                        widget.article.category,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Ícone da dica (imagem da API)
                    if (widget.article.icon.isNotEmpty && widget.article.icon.startsWith('http'))
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 56,
                          height: 56,
                          child: _isIconLoaded
                              ? CachedImage(
                                  imageUrl: widget.article.icon,
                                  useAuth: true,
                                )
                              : Container(
                                  color: Colors.white.withOpacity(0.1),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                ),
                        ),
                      )
                    else
                      Text(
                        widget.article.icon,
                        style: const TextStyle(fontSize: 48),
                      ),
                    const SizedBox(height: 8),
                    Text(
                      widget.article.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.gray50,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    widget.article.content,
                    style: const TextStyle(
                      color: AppColors.gray700,
                      fontSize: 15,
                      height: 1.6,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                WhatsAppButton(
                  text: 'Tire suas dúvidas no WhatsApp',
                  phoneNumber: widget.article.whatsappLink,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
