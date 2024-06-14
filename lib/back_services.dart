import 'dart:async';
import 'dart:ui';
import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/models/device.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/auth/auth_dio.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  /// OPTIONAL, using custom notification channel id
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'argoscare_foreground', // id
    'ARGOSCARE SERVICE', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.low, // importance must be at low or higher level
  );

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (Platform.isIOS || Platform.isAndroid) {
    await flutterLocalNotificationsPlugin.initialize(
      const InitializationSettings(
        iOS: DarwinInitializationSettings(),
        android: AndroidInitializationSettings('ic_bg_service_small'),
      ),
    );
  }

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      // this will be executed when app is in foreground or background in separated isolate
      onStart: onStart,

      // auto start service
      autoStart: true,
      isForegroundMode: true, // Android O 버전 이상부터는 백그라운드 실행이 제한되기 때문에 ForegroundMode로 해야 함.

      notificationChannelId: 'argoscare_foreground',
      initialNotificationTitle: 'ARGOSCARE SERVICE',
      initialNotificationContent: 'Initializing',
      foregroundServiceNotificationId: 777,
    ),
    iosConfiguration: IosConfiguration(
      // auto start service
      autoStart: true,

      // this will be executed when app is in foreground in separated isolate
      onForeground: onStart,

      // you have to enable background fetch capability on xcode project
      onBackground: onIosBackground,
    ),
  );
}

// to ensure this is executed
// run app from xcode, then from xcode menu, select Simulate Background Fetch

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  DartPluginRegistrant.ensureInitialized();

  /*SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.reload();
  final log = preferences.getStringList('log') ?? <String>[];
  log.add(DateTime.now().toIso8601String());
  await preferences.setStringList('log', log);*/

  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  // Only available for flutter 3.0.0 and later
  DartPluginRegistrant.ensureInitialized();

  // For flutter prior to version 3.0.0
  // We have to register the plugin manually

  /*SharedPreferences preferences = await SharedPreferences.getInstance();
  await preferences.setString("hello", "world");*/

  /// OPTIONAL when use custom notification
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  if (service is AndroidServiceInstance) {
    service.on('setAsForeground').listen((event) {
      service.setAsForegroundService();
    });

    service.on('setAsBackground').listen((event) {
      service.setAsBackgroundService();
    });
  }

  service.on('stopService').listen((event) {
    service.stopSelf();
  });

  // bring to foreground
  /*Timer.periodic(const Duration(minutes: 5), (timer) async {
    if (service is AndroidServiceInstance) {
      print('Argoscare BACKGROUND SERVICE(5 Minutes): ${DateTime.now()}');

      DBHelper sd = DBHelper();

      List<Device> deviceList = await sd.getDevices('4408d105-d4a8-45e2-a5d3-fd00cdbf597b');
      print(deviceList[0]);

      const storage = FlutterSecureStorage(
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

      final email = await storage.read(key: 'EMAIL');
      final password = await storage.read(key: 'PASSWORD');

      if (email != '' && password != '') {
        try {
          dio = await authDio();
          final response = await dio.post(
              "/auth/background_signin",
              data: jsonEncode({
                "email": email,
                "password": password
              })
          );

          final loginResponse = await dio.get(
              "/auth/me"
          );

          print('name: ${loginResponse.data['name']}, id: ${loginResponse.data['id']}');
        } catch (e) {
          print(e);
        }
      }
    }
  });*/

  Timer.periodic(const Duration(seconds: 30), (timer) async {
    if (service is AndroidServiceInstance) {
      if (await service.isForegroundService()) {
        /// OPTIONAL for use custom notification
        /// the notification id must be equals with AndroidConfiguration when you call configure() method.


        final SharedPreferences pref = await SharedPreferences.getInstance();
        bool? isLogin = pref.getBool("isLogin");
        if (isLogin != null) {
          if (isLogin == true) {
            print("This is ForegroundService. Login: TRUE");
          } else {
            print("This is ForegroundService. Login: FALSE");
          }
        } else {
          print("This is ForegroundService. Login: FALSE");
        }
        /*flutterLocalNotificationsPlugin.show(
          777,
          'COOL SERVICE',
          'Awesome ${DateTime.now()}',
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'argoscare_foreground',
              'ARGOSCARE SERVICE',
              icon: 'ic_bg_service_small',
              ongoing: true,
            ),
          ),
        );

        // if you don't using custom notification, uncomment this
        service.setForegroundNotificationInfo(
          title: "My App Service",
          content: "Updated at ${DateTime.now()}",
        );*/
      }
    }

    /// you can see this log in logcat
    ///

    print('Argoscare BACKGROUND SERVICE(30 Sec): ${DateTime.now()}');

    // test using external plugin
    /*final deviceInfo = DeviceInfoPlugin();
    String? device;
    if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      device = androidInfo.model;
    }

    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      device = iosInfo.model;
    }

    service.invoke(
      'update',
      {
        "current_date": DateTime.now().toIso8601String(),
        "device": device,
      },
    );*/
  });
}