import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

import 'package:argoscareseniorsafeguard/utils/firebase_options.dart';
import 'package:argoscareseniorsafeguard/pages/login_page.dart';
import 'package:argoscareseniorsafeguard/pages/Intro_page.dart';
import 'package:argoscareseniorsafeguard/pages/home_page.dart';

import 'package:argoscareseniorsafeguard/utils/fcm.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  initializeNotification();

  runApp(const ProviderScope(child: MyApp()));
}

const seedColor = Color(0xff00ffff);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
          colorSchemeSeed: seedColor,
          brightness: Brightness.light,
          useMaterial3: true,
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
          ? const HomePage(title: 'SCT Senior Care', userName: "게스트")
          : const LoginPage();
    } else {
      return const IntroScreen();
    }
  }

  bool isLogin() {
    return false;
  }
}