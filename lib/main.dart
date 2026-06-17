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
import 'package:mapstay_host/presentation/screens/test_component_screen.dart';
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
        '/componentes': (context) => const TestComponentScreen(),
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


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('You have pushed the button this many times:'),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Text(const String.fromEnvironment("PUBLIC_API_URL", defaultValue: "No encontrado")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}
