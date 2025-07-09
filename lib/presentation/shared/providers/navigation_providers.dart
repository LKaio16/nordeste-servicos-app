import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider para controlar o índice da aba selecionada na navegação principal
final mainNavigationIndexProvider = StateProvider<int>((ref) => 0); // Começa na aba 0 (Dashboard)
final tecnicoNavigationIndexProvider = StateProvider<int>((ref) => 0);