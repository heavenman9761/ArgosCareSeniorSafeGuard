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
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:argoscareseniorsafeguard/utils/firebase_options.dart';
import 'package:argoscareseniorsafeguard/pages/login_page.dart';
import 'package:argoscareseniorsafeguard/pages/Intro_page.dart';
import 'package:argoscareseniorsafeguard/pages/home_page.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/utils/fcm.dart';
import 'package:argoscareseniorsafeguard/auth/auth_dio.dart';
import 'package:argoscareseniorsafeguard/utils/theme.dart';
bool _isLogin = false;
String userName = '';
String userID = '';

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

  /*const storage = FlutterSecureStorage(
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  String? email = await storage.read(key: 'EMAIL');
  String? password = await storage.read(key: 'PASSWORD');


  if (_isLogin != null) {
    if (_isLogin! && email != '' && password != '') {
      dio = await authDio();

      try {
        final response = await dio.post(
            "/auth/signin",
            data: jsonEncode({
              "email": email,
              "password": password
            })
        );

        final token = response.data['token'];

        await storage.write(key: 'ACCESS_TOKEN', value: token);

        final loginResponse = await dio.get(
            "/auth/me"
        );

        userID = loginResponse.data['id'];
        userName = loginResponse.data['name'];

        await storage.write(key: 'ID', value: loginResponse.data['id']);
        await storage.write(key: 'EMAIL', value: loginResponse.data['email']);
        await storage.write(key: 'PASSWORD', value: password); //세션 종료시 다시 로그인하기 위해 필요

        saveUserInfo(loginResponse);

      } catch (e) {
        _isLogin = false;
      }
    } else {
      _isLogin = false;
    }

  } else {
    _isLogin = false;
  }*/
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
    _fetchLocale().then((locale) {
      setState(() {
        _locale = locale;
      });
    });

    initialization();
  }

  void initialization() async {
    /*if (!_isLogin) {
      print('ready in 3...');
      await Future.delayed(const Duration(seconds: 3));

      FlutterNativeSplash.remove();
    } else {
      FlutterNativeSplash.remove();
    }*/
    /*await precacheImage(
      const Image(image: AssetImage('assets/images/intro_image.png'),).image,
      context,
    );*/

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
    'assets/images/intro_image.png',
    'assets/images/hub.png',
    'assets/images/parent_male.png'
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
            home: _isLogin
                ? HomePage(title: Constants.APP_TITLE, userName: userName, userID: userID, requireLogin: _isLogin,)
            //: const LoginPage()
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