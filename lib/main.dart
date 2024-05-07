import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:argoscareseniorsafeguard/utils/firebase_options.dart';
import 'package:argoscareseniorsafeguard/pages/login_page.dart';
import 'package:argoscareseniorsafeguard/pages/Intro_page.dart';
import 'package:argoscareseniorsafeguard/pages/home_page.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/utils/fcm.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  initializeNotification();
  runApp(const ProviderScope(child: MainApp()));
}

const seedColor = Color(0xff00ffff);

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) async {
    _MainAppState? state = context.findAncestorStateOfType<_MainAppState>();

    var prefs = await SharedPreferences.getInstance();
    prefs.setString('languageCode', newLocale.languageCode);
    prefs.setString('countryCode', "");

    state?.setState(() {
      state._locale = newLocale;
    });
  }

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  Locale _locale = const Locale('ko', '');
  // Locale _locale = const Locale('en', '');

  @override
  void initState() {
    super.initState();
    _fetchLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });
  }

  /*
  To get local from SharedPreferences if exists
   */
  Future<Locale> _fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();

    String languageCode = prefs.getString('languageCode') ?? 'ko';
    String countryCode = prefs.getString('countryCode') ?? '';

    return Locale(languageCode, countryCode);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,//edit
      supportedLocales: AppLocalizations.supportedLocales,//edit
      title: Constants.APP_TITLE,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        colorSchemeSeed: seedColor,
        brightness: Brightness.light,
        useMaterial3: true,
        fontFamily: "Pretendard"
      ),
      // home: const LoginPage()
      home: FutureBuilder(
        future: Future.delayed(
            const Duration(seconds: 3), () => "Intro Completed."),
        builder: (context, snapshot) {
          const LoginPage();
          return AnimatedSwitcher(
            duration: const Duration(milliseconds: 2000),
            transitionBuilder: (Widget child, Animation<double> animation) {
              //return ScaleTransition(child: child, scale: animation);
              return FadeTransition(opacity: animation, child: child);
            },
            child: _splashLoadingWidget(snapshot),

          );
        },
      )
    );
  }

  Widget _splashLoadingWidget(AsyncSnapshot<Object?> snapshot) {
    if (snapshot.hasError) {
      return const Text("Error!!");
    } else if (snapshot.hasData) {

      return isLogin()
          ? const HomePage(title: Constants.APP_TITLE, userName: "guest", userID: '')
          : const LoginPage();
    } else {
      return const IntroScreen();
    }
  }

  bool isLogin() {
    return false;
  }
}