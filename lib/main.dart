import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'config/app_theme.dart';
import 'config/app_colors.dart';
import 'providers/auth_provider.dart';
import 'widgets/bottom_nav_bar.dart';
import 'widgets/app_drawer.dart';
import 'screens/home_screen.dart';
import 'screens/tours_screen.dart';
import 'screens/map_screen.dart';
import 'screens/gastronomy_screen.dart';
import 'screens/more_screen.dart';
import 'screens/articles_screen.dart';
import 'screens/tide_screen.dart';
import 'screens/weather_screen.dart';
import 'screens/transport_screen.dart';
import 'screens/services_screen.dart';
import 'screens/nightlife_screen.dart';
import 'screens/vehicle_rental_screen.dart';
import 'screens/calculator_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  
  runApp(const MeLevaNoronhaApp());
}

class MeLevaNoronhaApp extends StatelessWidget {
  const MeLevaNoronhaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Me Leva Noronha',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('pt', 'BR'),
        ],
        locale: const Locale('pt', 'BR'),
        home: const AppInitializer(),
      ),
    );
  }
}

/// Widget que inicializa os serviços do app (auth automático em background)
class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    // Usa addPostFrameCallback para evitar chamar setState durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeApp();
    });
  }

  Future<void> _initializeApp() async {
    // Inicializa o AuthProvider para obter tokens automaticamente
    final authProvider = context.read<AuthProvider>();
    await authProvider.init();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        // Mostra splash enquanto inicializa
        if (!authProvider.isInitialized) {
          return Scaffold(
            backgroundColor: AppColors.primary,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Icon(
                      Icons.flight_rounded,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Me Leva Noronha',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ],
              ),
            ),
          );
        }
        
        // App inicializado, mostra navegador principal
        return const MainNavigator();
      },
    );
  }
}

class MainNavigator extends StatefulWidget {
  const MainNavigator({super.key});

  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _currentIndex = 0;
  String _currentPage = 'home';
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Páginas que usam a bottom nav bar
  final _bottomNavPages = ['home', 'tours', 'map', 'gastronomy', 'more'];

  // Páginas secundárias (não na bottom nav)
  final _secondaryPages = [
    'articles', 'tide', 'weather', 'transport', 
    'services', 'nightlife', 'rental', 'calculator'
  ];

  void _navigateTo(String page) {
    setState(() {
      _currentPage = page;
      // Atualiza o index da bottom nav se for uma página principal
      final index = _bottomNavPages.indexOf(page);
      if (index != -1) {
        _currentIndex = index;
      }
    });
  }

  void _onBottomNavTap(int index) {
    setState(() {
      _currentIndex = index;
      _currentPage = _bottomNavPages[index];
    });
  }

  String _getAppBarTitle() {
    // Páginas secundárias sempre mostram "Me Leva Noronha"
    if (_secondaryPages.contains(_currentPage)) {
      return 'Me Leva Noronha';
    }
    
    switch (_currentPage) {
      case 'home':
        return 'Me Leva Noronha';
      case 'tours':
        return 'Passeios';
      case 'map':
        return 'Mapa da Ilha';
      case 'gastronomy':
        return 'Gastronomia';
      case 'more':
        return 'Mais';
      default:
        return 'Me Leva Noronha';
    }
  }

  Widget _buildCurrentPage() {
    switch (_currentPage) {
      case 'home':
        return HomeScreen(onNavigate: _navigateTo);
      case 'tours':
        return const ToursScreen();
      case 'map':
        return MapScreen();
      case 'gastronomy':
        return const GastronomyScreen();
      case 'more':
        return MoreScreen(onNavigate: _navigateTo);
      case 'articles':
        return ArticlesScreen(onBack: () => _navigateTo('home'));
      case 'tide':
        return TideScreen(onBack: () => _navigateTo('more'));
      case 'weather':
        return WeatherScreen(onBack: () => _navigateTo('more'));
      case 'transport':
        return TransportScreen(onBack: () => _navigateTo('more'));
      case 'services':
        return ServicesScreen(onBack: () => _navigateTo('more'));
      case 'nightlife':
        return NightlifeScreen(onBack: () => _navigateTo('more'));
      case 'rental':
        return VehicleRentalScreen(onBack: () => _navigateTo('home'));
      case 'calculator':
        return CalculatorScreen(onBack: () => _navigateTo('more'));
      default:
        return HomeScreen(onNavigate: _navigateTo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.gray50,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.flight, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              _getAppBarTitle(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      drawer: AppDrawer(
        currentPage: _currentPage,
        onNavigate: _navigateTo,
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _buildCurrentPage(),
      ),
      bottomNavigationBar: AppBottomNavBar(
        currentIndex: _currentIndex,
        onTap: _onBottomNavTap,
      ),
    );
  }
}
