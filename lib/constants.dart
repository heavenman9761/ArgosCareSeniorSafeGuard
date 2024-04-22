import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:intl/intl.dart';

import 'package:argoscareseniorsafeguard/utils/device_info.dart';
import 'package:argoscareseniorsafeguard/models/sensor_event.dart';

class Constants {
  static const platform = MethodChannel('est.co.kr/IoT_Hub');

  static const DEVICE_TYPE_HUB = 'hub';
  static const DEVICE_TYPE_ILLUMINANCE = 'illuminance_sensor';
  static const DEVICE_TYPE_TEMPERATURE_HUMIDITY = 'temperature_humidity';
  static const DEVICE_TYPE_SMOKE = 'smoke_sensor';
  static const DEVICE_TYPE_EMERGENCY = 'emergency_button';
  static const DEVICE_TYPE_MOTION = 'motion_sensor';
  static const DEVICE_TYPE_DOOR = 'door_sensor';

  static const MQTT_HOST = '14.42.209.174';
  static const MQTT_PORT = 6002;
  static const MQTT_IDENTIFIER = 'ArgosCareSeniorSafeGuard';
  static const MQTT_ID = 'mings';
  static const MQTT_PASSWORD = 'Sct91234!';

  static const BASE_URL = 'http://14.42.209.174:6008/api';

  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white60,
    backgroundColor: Colors.lightBlue, // text color
    elevation: 5, //
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  );
}

late Dio dio;

var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

enum ConfigState {
  none,
  findingHub, findingHubError, findingHubPermissionError, findingHubDone, findingHubEmpty,
  settingMqtt, settingMqttError, settingMqttDone,
  settingWifiScan, settingWifiScanError, settingWifiScanDone,
  settingWifi, settingWifiError, settingWifiDone,

  findingSensor, findingSensorError, findingSensorDone
}

double deviceCardHeight = 40;
double deviceFontSize = 18.0;
double deviceIconSize = 16.0;

void getDeviceFontSize(BuildContext context) {
  if (DeviceScreen.isPhone(context)) {
    print("isPhone()");
    deviceFontSize = 18.0;
  } else if (DeviceScreen.isTablet(context)) {
    print("isTablet()");
    deviceFontSize = 20.0;
  } else if (DeviceScreen.isSmallPhone(context)) {
    print("isSmallPhone()");
  }
}

String removeJsonAndArray(String text) {
  if (text.startsWith('[') || text.startsWith('{')) {
    text = text.substring(1, text.length - 1);
    if (text.startsWith('[') || text.startsWith('{')) {
      text = removeJsonAndArray(text);
    }
  }
  return text;
}

String analysisSensorEvent(SensorEvent event) {
  String? stringJson = event.getStatus();
  stringJson = removeJsonAndArray(stringJson!);
  var dataSp = stringJson.split(',');

  Map<String, String> data = {};
  for (var element in dataSp) {
    data[element.split(':')[0].trim()] = element.split(':')[1].trim();
  }
  String time = event.getCreatedAt()!.split('.')[0];

  if (event.getDeviceType() == Constants.DEVICE_TYPE_EMERGENCY) {
    return '$time에 SOS 호출이 있었습니다.';

  } else if (event.getDeviceType() == Constants.DEVICE_TYPE_SMOKE) {
    if (data['fire'] == '1') {
      return '$time에 화재 감지 신호가 있었습니다.';
    } else {
      return '';
    }

  } else if (event.getDeviceType() == Constants.DEVICE_TYPE_DOOR) {
    if (data['door'] == '1') {
      return '$time에 문이 열렸습니다.';
    } else {
      return '$time부터 문이 닫혔습니다.';
    }

  } else if (event.getDeviceType() == Constants.DEVICE_TYPE_MOTION) {
    if (data['motion'] == '1') {
      return '$time에 움직임이 감지되었습니다.';
    } else {
      return '$time부터 움직임이 감지되지 않습니다.';
    }

  } else if (event.getDeviceType() == Constants.DEVICE_TYPE_ILLUMINANCE) {
    return "$time 조도: ${data['illuminance']}";

  } else if (event.getDeviceType() == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
    var celsius = int.parse(data['temp']!) / 10;

    NumberFormat format = NumberFormat("#0.0");
    String strCelsius = format.format(celsius);

    return "$time 온도: $strCelsius°, 습도: ${data['hum']}%";

  } else {
    return '';
  }
}

String analysisSimpleSensorEvent(SensorEvent event) {
  String? stringJson = event.getStatus();
  stringJson = removeJsonAndArray(stringJson!);
  var dataSp = stringJson.split(',');

  Map<String, String> data = {};
  for (var element in dataSp) {
    data[element.split(':')[0].trim()] = element.split(':')[1].trim();
  }
  String time = event.getCreatedAt()!.split('.')[0];

  if (event.getDeviceType() == Constants.DEVICE_TYPE_EMERGENCY) {
    return 'SOS 호출이 있었습니다.';

  } else if (event.getDeviceType() == Constants.DEVICE_TYPE_SMOKE) {
    if (data['fire'] == '1') {
      return '화재 감지 신호가 있었습니다.';
    } else {
      return '';
    }

  } else if (event.getDeviceType() == Constants.DEVICE_TYPE_DOOR) {
    if (data['door'] == '1') {
      return '문이 열렸습니다.';
    } else {
      return '문이 닫혔습니다.';
    }

  } else if (event.getDeviceType() == Constants.DEVICE_TYPE_MOTION) {
    if (data['motion'] == '1') {
      return '움직임이 감지되었습니다.';
    } else {
      return '움직임이 감지되지 않습니다.';
    }

  } else if (event.getDeviceType() == Constants.DEVICE_TYPE_ILLUMINANCE) {
    return "조도: ${data['illuminance']}";

  } else if (event.getDeviceType() == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
    var celsius = int.parse(data['temp']!) / 10;

    NumberFormat format = NumberFormat("#0.0");
    String strCelsius = format.format(celsius);

    return "온도: $strCelsius°, 습도: ${data['hum']}%";

  } else {
    return '';
  }
}

void getMyDeviceToken() async {
  final token = await FirebaseMessaging.instance.getToken();

  const storage = FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final email = await storage.read(key: 'EMAIL');

  try {
    final response = await dio.post(
        "/users/fcmtoken",
        data: jsonEncode({
          "email": email,
          "token": token,
          "platform": "android"
        })
    );
  } catch(e) {
    print(e);
  }

  logger.i("FCM Device Token: $token,   $email");
}

permission() async {
  var requestStatus = await Permission.location.request();
  var status = await Permission.location.status;
  if (requestStatus.isGranted && status.isLimited) {
    // isLimited - 제한적 동의 (ios 14 < )
    // 요청 동의됨
    debugPrint("isGranted");
    if (await Permission.locationWhenInUse.serviceStatus.isEnabled) {
      // 요청 동의 + gps 켜짐
      var position = await Geolocator.getCurrentPosition();
      debugPrint("serviceStatusIsEnabled position = ${position.toString()}");
    } else {
      // 요청 동의 + gps 꺼짐
      debugPrint("serviceStatusIsDisabled");
    }
  } else if (requestStatus.isPermanentlyDenied || status.isPermanentlyDenied) {
    // 권한 요청 거부, 해당 권한에 대한 요청에 대해 다시 묻지 않음 선택하여 설정화면에서 변경해야함. android
    debugPrint("isPermanentlyDenied");
    openAppSettings();
  } else if (status.isRestricted) {
    // 권한 요청 거부, 해당 권한에 대한 요청을 표시하지 않도록 선택하여 설정화면에서 변경해야함. ios
    debugPrint("isRestricted");
    openAppSettings();
  } else if (status.isDenied) {
    // 권한 요청 거절
    debugPrint("isDenied");
  }
  debugPrint("requestStatus ${requestStatus.name}");
  debugPrint("status ${status.name}");
}