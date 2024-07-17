
import 'package:flutter/foundation.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:argoscareseniorsafeguard/utils/firebase_options.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await setupFlutterNotifications();

  // debugPrint("백그라운드 메시지 처리.. ${message.notification!.body!}");
  print("==========================");

  showFlutterNotificationData(message);
}

late AndroidNotificationChannel channel;

bool isFlutterLocalNotificationsInitialized = false;

Future<void> setupFlutterNotifications() async {
  if (isFlutterLocalNotificationsInitialized) {
    return;
  }
  channel = const AndroidNotificationChannel(
    //'high_importance_channel', // id
    'foreground_service',
    'High Importance Notifications', // title
    description: 'This channel is used for important notifications.', // description
    importance: Importance.high,
  );

  flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

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

    debugPrint('showFlutterNotification() - ${notification.hashCode} ${notification.title} ${notification.body}');

    flutterLocalNotificationsPlugin.show(
      notification.hashCode,
      notification.title,
      notification.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          //'high_importance_channel',
          'foreground_service',
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

void showFlutterNotificationData(RemoteMessage message) {
  RemoteNotification? notification = message.notification;

  AndroidNotification? android = message.notification?.android;

  flutterLocalNotificationsPlugin.show(
    notification.hashCode,
    message.data['title'],
    message.data['body'],
    const NotificationDetails(
      android: AndroidNotificationDetails(
        //'high_importance_channel',
        'foreground_service',
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

  // if (notification != null ){//&& android != null && !kIsWeb) {
  //
  //   debugPrint('showFlutterNotification() - ${notification.hashCode} ${notification.title} ${notification.body}');
  //
  //   flutterLocalNotificationsPlugin.show(
  //     notification.hashCode,
  //     message.data['title'],
  //     message.data['body'],
  //     const NotificationDetails(
  //       android: AndroidNotificationDetails(
  //         'high_importance_channel',
  //         'high_importance_notification',
  //         importance: Importance.max,
  //         // channel.id,
  //         // channel.name,
  //         // channelDescription: channel.description,
  //         // TODO add a proper drawable resource to android, for now using
  //         //      one that already exists in example app.
  //         //icon: 'launch_background',
  //       ),
  //     ),
  //   );
  // }
}

late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

void initializeNotification() async {
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  final flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
      AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(const AndroidNotificationChannel(
      //'high_importance_channel',
      'foreground_service',
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


