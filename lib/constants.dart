import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';

class Constants {
  static const platform = MethodChannel('est.co.kr/IoT_Hub');
  static const DEVICE_TYPE_HUB = 'hub';
  static const DEVICE_TYPE_ILLUMINANCE = 'illuminance_sensor';
  static const DEVICE_TYPE_TEMPERATURE_HUMIDITY = 'temperature_humidity';
  static const DEVICE_TYPE_SMOKE = 'smoke_sensor';
  static const DEVICE_TYPE_EMERGENCY = 'emergency_button';
  static const DEVICE_TYPE_MOTION = 'motion_sensor';
  static const DEVICE_TYPE_DOOR = 'door_sensor';
  static const ACCOUNT_ID = 'dn9318dn@gmail.com';
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

void getMyDeviceToken() async {
  final token = await FirebaseMessaging.instance.getToken();

  const storage = FlutterSecureStorage();
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