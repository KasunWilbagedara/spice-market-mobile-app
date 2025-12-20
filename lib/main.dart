import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/spice_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/common/splash_screen.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/buyer/interactive_buyer_home.dart';
import 'screens/buyer/checkout_screen.dart';
import 'screens/seller/seller_home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => SpiceProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Spice Market',
        theme: ThemeData(primarySwatch: Colors.orange),
        home: SplashScreen(),
        routes: {
          '/welcome': (_) => WelcomeScreen(),
          '/login': (_) => LoginScreen(),
          '/register': (_) => RegisterScreen(),
          '/buyer_home': (_) => InteractiveBuyerHome(),
          '/checkout': (_) => CheckoutScreen(),
          '/seller_home': (_) => SellerHome(),
        },
      ),
    );
  }
}
