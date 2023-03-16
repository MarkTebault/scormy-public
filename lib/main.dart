import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scormy/pages/home_page.dart';
import 'package:scormy/pages/url_page.dart';
import 'package:scormy/pages/youtube_page.dart';
import 'package:scormy/pages/embed_page.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license =
        await rootBundle.loadString('assets/fonts/ConertOne/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  runApp(SCORMYApp());
}

class SCORMYApp extends StatelessWidget {
  SCORMYApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) => MaterialApp.router(
      onGenerateTitle: (context) => 'SCORMY',
      debugShowCheckedModeBanner: false,
      title: 'SCORMY',
      theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme: TextTheme(
            headlineLarge: GoogleFonts.concertOne(
                fontSize: 70,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800),
            headlineMedium: GoogleFonts.concertOne(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800),
            headlineSmall: GoogleFonts.concertOne(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade800),
            bodyLarge: GoogleFonts.concertOne(fontSize: 16),
            bodyMedium: GoogleFonts.concertOne(fontSize: 14),
            bodySmall: GoogleFonts.concertOne(fontSize: 12),
          ),
          inputDecorationTheme: const InputDecorationTheme(
            border:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.black)),
            errorBorder:
                OutlineInputBorder(borderSide: BorderSide(color: Colors.red)),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
            elevation: 10,
          ))),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('es', ''),
        Locale('fr', ''),
        Locale('de', '')
      ],
      routerConfig: _router);

  final GoRouter _router = GoRouter(routes: <GoRoute>[
    GoRoute(
        path: '/',
        builder: ((context, state) => const HomePage()),
        routes: <GoRoute>[
          GoRoute(
              path: 'youtube',
              builder: ((context, state) => const YouTubePage())),
          GoRoute(
              path: 'embed', builder: ((context, state) => const EmbedPage())),
          GoRoute(path: 'url', builder: ((context, state) => const UrlPage())),
        ]),
  ]);
}
