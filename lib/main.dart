import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

import 'package:provider/provider.dart';

// Services & Controllers
import 'services/language_service.dart';
import 'controllers/settings_controller.dart';

// Auth pages
import 'views/auth/login_page.dart';
import 'views/auth/register_page.dart';

// Home & Settings pages
import 'views/home/home_page.dart';
import 'views/home/settings_page.dart';
import 'views/home/edit_profile.page.dart';
import 'views/home/change_password.page.dart';
import 'views/home/language.page.dart';
import 'views/home/help_centre.page.dart';
import 'views/home/contact.page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => SettingsController()),
        ChangeNotifierProvider(create: (_) => LanguageService()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = Provider.of<SettingsController>(context);
    final lang = Provider.of<LanguageService>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // 🌍 Langues
      locale: lang.locale,
      supportedLocales: const [
        Locale('fr'),
        Locale('en'),
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // 🎨 Thèmes
      themeMode: settings.darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.light,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.pink,
          brightness: Brightness.dark,
        ),
      ),

      // 🚀 Routes
      initialRoute: "/login",
      routes: {
        "/login": (_) => LoginPage(),
        "/register": (_) => RegisterPage(),
        "/home": (_) => HomePage(),
        "/settings": (_) => SettingsPage(),
        "/edit-profile": (_) => EditProfilePage(),
        "/change-password": (_) => ChangePasswordPage(),
        "/language": (_) => LanguagePage(),
        "/help-center": (_) => HelpCenterPage(),
        "/contact": (_) => ContactPage(),
      },
    );
  }
}