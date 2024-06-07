import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:argoscareseniorsafeguard/utils/firebase_options.dart';
import 'package:argoscareseniorsafeguard/pages/login_page.dart';
import 'package:argoscareseniorsafeguard/pages/Intro_page.dart';
import 'package:argoscareseniorsafeguard/pages/home_page.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/utils/fcm.dart';

Future<void> main() async {
  print("main() ================================================================");
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // await SystemChrome.setPreferredOrientations([
  //   DeviceOrientation.portraitUp,
  //   DeviceOrientation.portraitDown,
  // ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  initializeNotification();

  KakaoSdk.init(nativeAppKey: 'a8748a5f0bf6184b2cc89fc11f3ab459');

  runApp(const ProviderScope(child: MainApp()));
}

// const seedColor = Color(0xff00ffff);
const seedColor = Colors.indigo;

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
    print("initState() ================================================================");
    _fetchLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });

    initialization();
  }

  void initialization() async {
    // This is where you can initialize the resources needed by your app while
    // the splash screen is displayed.  Remove the following example because
    // delaying the user experience is a bad design practice!
    // ignore_for_file: avoid_print
    print('ready in 3...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 2...');
    await Future.delayed(const Duration(seconds: 1));
    print('ready in 1...');
    await Future.delayed(const Duration(seconds: 1));
    print('go!');
    FlutterNativeSplash.remove();
  }

  @override
  void deactivate() {
    super.deactivate();
    print("deactivate() ===============================================================");
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
        // colorSchemeSeed: seedColor,
        // brightness: Brightness.light,
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.light),
        fontFamily: "Pretendard"
      ),
      // home: const LoginPage()
      home: isLogin()
        ? const HomePage(title: Constants.APP_TITLE, userName: "guest", userID: '')
        : const LoginPage()
        /*: FutureBuilder(
            future: Future.delayed(
                const Duration(seconds: 3), () => "Intro Completed."),
            builder: (context, snapshot) {
              return AnimatedSwitcher(
                duration: const Duration(milliseconds: 2000),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  //return ScaleTransition(child: child, scale: animation);
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _splashLoadingWidget(snapshot),

              );
            },
          )*/
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