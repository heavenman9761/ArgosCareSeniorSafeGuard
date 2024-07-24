import 'dart:async';
import 'dart:ui';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:uuid/uuid.dart';

import 'package:argoscareseniorsafeguard/constants.dart';

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

  service.on('startMqtt').listen((event) {
    print("startMqtt");
    mqttInit1(
        Constants.MQTT_HOST,
        Constants.MQTT_PORT,
        Constants.MQTT_ID,
        Constants.MQTT_PASSWORD
    );
    service.invoke(
      'startedMqtt',
      {
        "result":"success"
      }
    );
  });

  service.on('receiveMqtt').listen((event) {
    print("receiveMqtt");
    service.invoke(
        'receiveMqtt',
        {
          "result":event
        }
    );
  });

  /*Timer.periodic(const Duration(seconds: 30), (timer) async {
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
        *//*flutterLocalNotificationsPlugin.show(
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
        );*//*
      }
    }

    /// you can see this log in logcat
    ///

    print('Argoscare BACKGROUND SERVICE(30 Sec): ${DateTime.now()}');

    // test using external plugin
    *//*final deviceInfo = DeviceInfoPlugin();
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
    );*//*
  });*/
}

late MqttServerClient mqttClient;

void mqttInit1(String host, int port, String id, String password) async {
  var uuid = const Uuid();
  String uuid_v4 = uuid.v4();

  mqttClient = MqttServerClient(host, uuid_v4);

  mqttClient.logging(on: false);
  mqttClient.setProtocolV311();
  mqttClient.port = port;
  mqttClient.keepAlivePeriod = 20;
  mqttClient.connectTimeoutPeriod = 2000; // milliseconds
  mqttClient.onDisconnected = onDisconnected;
  mqttClient.onConnected = onConnected;
  mqttClient.onSubscribed = onSubscribed;

  final connMess = MqttConnectMessage()
      .withClientIdentifier(uuid_v4)
      .withWillTopic('will-topic') // If you set this you must set a will message
      .withWillMessage('My Will message')
      .startClean() // Non persistent session for testing
      .authenticateAs(id, password)
      .withWillQos(MqttQos.exactlyOnce);

  mqttClient.connectionMessage = connMess;

  try {
    await mqttClient.connect();
  } on NoConnectionException catch (e) {
    // Raised by the client when connection fails.
    logger.e('EXAMPLE::client exception - $e');
    mqttClient.disconnect();
  } on SocketException catch (e) {
    // Raised by the socket layer
    logger.e('EXAMPLE::socket exception - $e');
    mqttClient.disconnect();
  }

  if (mqttClient.connectionStatus!.state == MqttConnectionState.connected) {
  } else {
    logger.e('EXAMPLE::ERROR Mosquitto client connection failed - disconnecting, status is ${mqttClient.connectionStatus}');
    mqttClient.disconnect();
  }

  mqttClient.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
    final recMess = c![0].payload as MqttPublishMessage;
    final pt = MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

    // FlutterBackgroundService().invoke(
    //     'receiveMqtt',
    //     {
    //       "topic":c[0].topic,
    //       "event": pt
    //     }
    // );

    print('${c[0].topic} / $pt');

    // ref.read(mqttCurrentTopicProvider.notifier).state = c[0].topic;
    // ref.read(mqttCurrentMessageProvider.notifier).state = pt;
  });

  mqttClient.published!.listen((MqttPublishMessage message) {
    // logger.i('EXAMPLE::Published notification:: topic is ${message.variableHeader!.topicName}, with Qos ${message.header!.qos}');
  });
}

void onDisconnected() {
  // if (mqttClient.connectionStatus!.disconnectionOrigin == MqttDisconnectionOrigin.solicited) {
  //   debugPrint('EXAMPLE::OnDisconnected callback is solicited, this is correct');
  // } else {
  //   debugPrint('EXAMPLE::OnDisconnected callback is unsolicited or none, this is incorrect - exiting');
  // }
  //
  // _ref.read(mqttCurrentStateProvider.notifier).doChangeState(MqttConnectionState.disconnected);
}

/// The successful connect callback
void onConnected() {
  debugPrint('EXAMPLE::OnConnected client callback - Client connection was successful');
  mqttClient.subscribe('result/00003494543ebb58', MqttQos.atMostOnce);

  // _ref.read(mqttCurrentStateProvider.notifier).doChangeState(MqttConnectionState.connected);

  // mqttPublish('request/00003494543ebb58', jsonEncode({
  //   "order": "device_add",
  //   "deviceID": "aabbccdd11223344",
  //   "accountID": "dn9318dn@gmail.com",
  //   "device_type": "door_sensor",
  //   "time": "20240321_175100"
  // }));
}

void onSubscribed(String topic) {
  debugPrint("onSubscribed() - $topic");
}