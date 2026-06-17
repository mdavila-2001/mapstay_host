import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mapstay_host/core/di/injection_container.dart';
import 'package:mapstay_host/core/theme/theme.dart';
import 'package:mapstay_host/domain/entities/property.dart';
import 'package:mapstay_host/presentation/providers/auth_provider.dart';
import 'package:mapstay_host/presentation/providers/property_provider.dart';
import 'package:mapstay_host/presentation/providers/reservation_provider.dart';
import 'package:mapstay_host/presentation/screens/login_screen.dart';
import 'package:mapstay_host/presentation/screens/register_screen.dart';
import 'package:mapstay_host/presentation/screens/dashboard_screen.dart';
import 'package:mapstay_host/presentation/screens/property_form_screen.dart';
import 'package:mapstay_host/presentation/screens/property_detail_screen.dart';
import 'package:mapstay_host/presentation/screens/place_reservations_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DI.instance.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(authRepository: DI.instance.authRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => PropertyProvider(propertyRepository: DI.instance.propertyRepository),
        ),
        ChangeNotifierProvider(
          create: (_) => ReservationProvider(reservationRepository: DI.instance.reservationRepository),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MapStay Arrendatario',
      theme: MapStayTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => LoginScreen(
              onRegisterPressed: () => Navigator.of(context).pushReplacementNamed('/register'),
              onLoginSuccess: () => Navigator.of(context).pushReplacementNamed('/dashboard'),
            ),
        '/register': (context) => RegisterScreen(
              onLoginPressed: () => Navigator.of(context).pushReplacementNamed('/login'),
              onRegisterSuccess: () => Navigator.of(context).pushReplacementNamed('/dashboard'),
            ),
        '/dashboard': (context) => const DashboardScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/property-form') {
          final property = settings.arguments as Property?;
          return MaterialPageRoute(
            builder: (context) => PropertyFormScreen(property: property),
            settings: settings,
          );
        } else if (settings.name == '/property-detail') {
          final property = settings.arguments as Property;
          return MaterialPageRoute(
            builder: (context) => PropertyDetailScreen(property: property),
            settings: settings,
          );
        } else if (settings.name == '/reservas') {
          final propertyId = settings.arguments as int?;
          return MaterialPageRoute(
            builder: (context) => PlaceReservationsScreen(propertyId: propertyId),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  bool _showLogin = true;

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (!authProvider.isSessionLoaded) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (authProvider.isAuthenticated) {
      return const DashboardScreen();
    }

    if (_showLogin) {
      return LoginScreen(
        onRegisterPressed: () {
          setState(() {
            _showLogin = false;
          });
        },
        onLoginSuccess: () {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        },
      );
    } else {
      return RegisterScreen(
        onLoginPressed: () {
          setState(() {
            _showLogin = true;
          });
        },
        onRegisterSuccess: () {
          Navigator.of(context).pushReplacementNamed('/dashboard');
        },
      );
    }
  }
}
