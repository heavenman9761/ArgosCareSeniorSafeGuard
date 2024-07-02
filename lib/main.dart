import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:argoscareseniorsafeguard/utils/firebase_options.dart';
import 'package:argoscareseniorsafeguard/pages/login_page.dart';
import 'package:argoscareseniorsafeguard/pages/Intro_page.dart';
import 'package:argoscareseniorsafeguard/pages/home_page.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/utils/fcm.dart';
import 'package:argoscareseniorsafeguard/utils/theme.dart';
import 'package:argoscareseniorsafeguard/auth/auth_dio.dart';

bool _isLogin = false;
String userName = '';
String userID = '';
String userMail = '';

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  initializeNotification();

  KakaoSdk.init(nativeAppKey: 'a8748a5f0bf6184b2cc89fc11f3ab459');

  await checkLogin();

  runApp(const ProviderScope(child: MainApp()));
}

Future<void> checkLogin() async {
  final SharedPreferences pref = await SharedPreferences.getInstance();
  _isLogin = pref.getBool('isLogin') ?? false;
  // _isLogin = false;

  if (_isLogin) { //이전에 로그인 했으므로 그 정보를 이용하여 다시 로그인 한다.
    dio = await authDio();

    try {
      final loginResponse = await dio.get(
          "/auth/me"
      );

      userID = loginResponse.data['id'];
      userName = loginResponse.data['name'];
      userMail = loginResponse.data['email'];

      saveUserInfo(loginResponse);

    } catch (e) {
      // _isLogin = false;
    }
  }
}

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
    _fetchLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });

    FlutterNativeSplash.remove();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  Future<Locale> _fetchLocale() async {
    var prefs = await SharedPreferences.getInstance();
    String languageCode = prefs.getString('languageCode') ?? '';
    String countryCode = prefs.getString('countryCode') ?? '';

    if (languageCode == '') {
      final String defaultLocale = Platform.localeName;
      languageCode = defaultLocale.substring(0, 2);
    }

    return Locale(languageCode, countryCode);
  }

  final List<String> imageUrls = [
    // 'assets/images/intro_image.png',
    'assets/images/hub.png',
    'assets/images/parent_male.png',
    'assets/images/parent_female.png',
    "assets/images/onboarding_1.png",
    "assets/images/onboarding_2.png",
    "assets/images/onboarding_3.png",
  ];

  @override
  Widget build(BuildContext context) {
    for (var url in imageUrls) {
      precacheImage(Image(image: AssetImage(url),).image, context);
    }
    return ScreenUtilInit(
      designSize: const Size(360, 740),
      minTextAdapt: true,
      builder: (context, child) {
        return MaterialApp(
            locale: _locale,
            localizationsDelegates: AppLocalizations.localizationsDelegates,//edit
            supportedLocales: AppLocalizations.supportedLocales,//edit
            title: Constants.APP_TITLE,
            debugShowCheckedModeBanner: false,
            theme: initThemeData(),
            // darkTheme: initThemeData(brightness: Brightness.dark),
            // themeMode: ThemeMode.system, // 앱에 설정에 따라서 변경 가능 하게 처리
            /*theme: ThemeData(
              // colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
              // colorSchemeSeed: seedColor,
              // brightness: Brightness.light,
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(seedColor: seedColor, brightness: Brightness.light),
                fontFamily: "Pretendard"
            ),*/
            // home: const LoginPage()
            // home: const IntroScreen()
            home: _isLogin
                ? HomePage(title: Constants.APP_TITLE, userName: userName, userID: userID, userMail: userMail,)
                : FutureBuilder(
                    future: Future.delayed(
                        const Duration(seconds: 2), () => "Intro Completed."),
                    builder: (context, snapshot) {
                      return AnimatedSwitcher(
                        duration: const Duration(milliseconds: 3000),
                        // switchInCurve: Curves.fastOutSlowIn,
                        // switchOutCurve: Curves.fastLinearToSlowEaseIn,
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
    );
  }

  Widget _splashLoadingWidget(AsyncSnapshot<Object?> snapshot) {
    if (snapshot.hasError) {
      return const Text("Error!!");
    } else if (snapshot.hasData) {

      /*return await isLogin()
          ? const HomePage(title: Constants.APP_TITLE, userName: "guest", userID: '')
          : const LoginPage();*/
      return const LoginPage();
      // return const IntroScreen();
    } else {
      return const IntroScreen();
    }
  }

  /*Future<bool> isLogin() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    isLogin = pref.getBool('isLogin')!;
  }*/
}