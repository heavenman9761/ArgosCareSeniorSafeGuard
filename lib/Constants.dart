import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

import 'package:logger/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:argoscareseniorsafeguard/utils/firebase_options.dart';
import 'package:geolocator/geolocator.dart';
import 'package:argoscareseniorsafeguard/mqtt/IMQTTController.dart';
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:argoscareseniorsafeguard/providers/Providers.dart';

class Constants{

  static String resultTopic = '';

  static const platform = MethodChannel('est.co.kr/IoT_Hub');
  static const DEVICE_TYPE_HUB = 'hub';
}

var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

enum MqttCommand {mcSensorList, mcParing}

enum ConfigState {
  none,
  findingHub, findingHubError, findingHubPermissionError, findingHubDone,
  settingMqtt, settingMqttError, settingMqttDone,
  settingWifiScan, settingWifiScanError, settingWifiScanDone,
  settingWifi, settingWifiError, settingWifiDone
}

void mqttCommand(IMQTTController _manager, String topic, MqttCommand mc, String deviceId) {
  var now = DateTime.now();
  String formatDate = DateFormat('yyyyMMdd_HHmmss').format(now);

  if (mc == MqttCommand.mcSensorList) {
    //펌웨어 에서 기능 구현 안됨.
    _manager.publishTopic(
        topic,
        jsonEncode({
          "order": "sensorList",
          "deviceID": deviceId,
          "time": formatDate
        }));
  } else if (mc == MqttCommand.mcParing) {
    _manager.publishTopic(
        topic,
        jsonEncode({
          "order": "pairingEnabled",
          "deviceID": deviceId,
          "time": formatDate
        }));
  }
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();

  print("백그라운드 메시지 처리.. ${message.notification!.body!}");

  showFlutterNotification(message);
}

late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    'high_importance_channel', // id
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  /// Create an Android Notification Channel.
  ///
  /// We use this channel in the `AndroidManifest.xml` file to override the
  /// default FCM channel to enable heads up notifications.
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  /// Update the iOS foreground notification presentation options to allow
  /// heads up notifications.
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
  isFlutterLocalNotificationsInitialized = true;
}

void showFlutterNotification(RemoteMessage message) {

  RemoteNotification? notification = message.notification;

  AndroidNotification? android = message.notification?.android;

  if (notification != null && android != null && !kIsWeb) {

    print('showFlutterNotification() - ${notification.hashCode} ${notification.title} ${notification.body}');

    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'high_importance_notification',
          importance: Importance.max,
          // channel.id,
          // channel.name,
          // channelDescription: channel.description,
          // TODO add a proper drawable resource to android, for now using
          //      one that already exists in example app.
          //icon: 'launch_background',
        ),
      ),
    );
  }
}

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void initializeNotification() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
      'high_importance_channel',
      'high_importance_notification',
      importance: Importance.max
  ));

  await flutterLocalNotificationsPlugin.initialize(const InitializationSettings(
    android: AndroidInitializationSettings("@mipmap/ic_launcher"),
  ));

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );
}

void getMyDeviceToken() async {
  final token = await FirebaseMessaging.instance.getToken();
  logger.i("FCM Device Token: $token");
}

permission() async {
  var requestStatus = await Permission.location.request();
  var status = await Permission.location.status;
  if (requestStatus.isGranted && status.isLimited) {
    // isLimited - 제한적 동의 (ios 14 < )
    // 요청 동의됨
    print("isGranted");
    if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      // 요청 동의 + gps 켜짐
      var position = await Geolocator.getCurrentPosition();
      print("serviceStatusIsEnabled position = ${position.toString()}");
    } else {
      // 요청 동의 + gps 꺼짐
      print("serviceStatusIsDisabled");
    }
  } else if (requestStatus.isPermanentlyDenied || status.isPermanentlyDenied) {
    // 권한 요청 거부, 해당 권한에 대한 요청에 대해 다시 묻지 않음 선택하여 설정화면에서 변경해야함. android
    print("isPermanentlyDenied");
    openAppSettings();
  } else if (status.isRestricted) {
    // 권한 요청 거부, 해당 권한에 대한 요청을 표시하지 않도록 선택하여 설정화면에서 변경해야함. ios
    print("isRestricted");
    openAppSettings();
  } else if (status.isDenied) {
    // 권한 요청 거절
    print("isDenied");
  }
  print("requestStatus ${requestStatus.name}");
  print("status ${status.name}");
}