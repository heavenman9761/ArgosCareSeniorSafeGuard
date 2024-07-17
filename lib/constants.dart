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
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:argoscareseniorsafeguard/utils/device_info.dart';
import 'package:argoscareseniorsafeguard/models/sensor_event.dart';
import 'package:argoscareseniorsafeguard/models/hub_infos.dart';
import 'package:argoscareseniorsafeguard/models/sensor_infos.dart';
import 'package:argoscareseniorsafeguard/models/location_infos.dart';
import 'package:argoscareseniorsafeguard/models/share_infos.dart';
import 'package:argoscareseniorsafeguard/models/airplaneday.dart';
import 'package:argoscareseniorsafeguard/models/airplanetime.dart';
import 'package:argoscareseniorsafeguard/models/alarm_infos.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';

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
  static const MQTT_ID = 'mings';
  static const MQTT_PASSWORD = 'Sct91234!';
  // static const MQTT_ID_BACK = 'scthealthcare';
  // static const MQTT_PASSWORD_BACK = 'Sct91234!';

  static const BASE_URL = 'http://14.42.209.174:6008/api';
  static const KAKAO_REDIRECT_URL = 'http://14.42.209.174:6008/api/auth/kakao_flutter/callback';

  static const APP_TITLE = 'Argos Care';

  static const borderColor = Color(0xFFF0F0F0);
  static const scaffoldBackgroundColor = Color(0xFFF9F9F9);
  static const dividerColor = Color(0xFF818181);
  static const hintColor = Color(0xFFCBCBCB);
  static const primaryColor = Color(0xFF47B752);
  static const primaryButtonColor = Color(0xFF47B752);
  static const primaryButtonTextColor = Color(0xFFFFFFFF);
  static const secondaryColor = Color(0xFFEBF7EC);

  static const titleFontSize = 20;

  static const List<String> yearText = [
    '1930년생', '1931년생', '1932년생', '1933년생', '1934년생', '1935년생', '1936년생', '1937년생', '1938년생', '1939년생',
    '1940년생', '1941년생', '1942년생', '1943년생', '1944년생', '1945년생', '1946년생', '1947년생', '1948년생', '1949년생',
    '1950년생', '1951년생', '1952년생', '1953년생', '1954년생', '1955년생', '1956년생', '1957년생', '1958년생', '1959년생',
    '1960년생', '1961년생', '1962년생', '1963년생', '1964년생', '1965년생', '1966년생', '1967년생', '1968년생', '1969년생',
  ];

  static const List<String> year = [
    '1930', '1931', '1932', '1933', '1934', '1935', '1936', '1937', '1938', '1939',
    '1940', '1941', '1942', '1943', '1944', '1945', '1946', '1947', '1948', '1949',
    '1950', '1951', '1952', '1953', '1954', '1955', '1956', '1957', '1958', '1959',
    '1960', '1961', '1962', '1963', '1964', '1965', '1966', '1967', '1968', '1969',
  ];

  static const List<int> ages = [
    95, 94, 93, 92, 91, 90, 89, 88, 87, 86,
    85, 84, 83, 82, 81, 70, 79, 78, 77, 76,
    75, 74, 73, 72, 71, 60, 69, 68, 67, 66,
  ];

  // static const List<String> ampm = ['오전', '오후'];

  static const List<String> hourTable = [
    '01', '02', '03', '04', '05', '06', '07', '08', '09',
    '10', '11', '12', '13', '14', '15', '16', '17', '18', '19',
    '20', '21', '22', '23',
  ];

  static const List<String> minuteTable = [
    '00', '01', '02', '03', '04', '05', '06', '07', '08', '09',
    '10', '11', '12', '13', '14', '15', '16', '17', '18', '19',
    '20', '21', '22', '23', '24', '25', '26', '27', '28', '29',
    '30', '31', '32', '33', '34', '35', '36', '37', '38', '39',
    '40', '41', '42', '43', '44', '45', '46', '47', '48', '49',
    '50', '51', '52', '53', '54', '55', '56', '57', '58', '59',
  ];


  static final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white60,
    backgroundColor: Colors.lightBlue, // text color
    elevation: 5, //
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
  );
}

bool gSendPush_After_5H_Toilet = false;
bool gSendPush_After_5H_Refrigerator = false;

Map gParentInfo = {};
List<HubInfo> gHubList = [];
List<SensorInfo> gSensorList = [];
List<LocationInfo> gLocationList = [];
List<AirplaneDay> gAirPlaneDayList = [];
List<AirplaneTime> gAirPlaneTimeList = [];
late AlarmInfo gLastAlarm;
bool gUseAirPlaneMode = false;
// late LocationInfo gCurrentLocation;

List<ShareInfo> gShareInfo = [];

const outPadding = 16.0;

late Dio dio;

String gCookie = '';

void saveUserInfo(var loginResponse) async {
  gHubList.clear();
  gSensorList.clear();
  gLocationList.clear();
  gShareInfo.clear();

  final hList = loginResponse.data['Hub_Infos'] as List;
  for (var h in hList) {
    gHubList.add(HubInfo.fromJson(h));
  }

  final lList = loginResponse.data['Location_Infos'] as List;
  for (var l in lList) {
    List<SensorInfo> sl = [];
    for (var s in l['Sensor_Infos']) {
      gSensorList.add(SensorInfo.fromJson(s));
      sl.add(SensorInfo.fromJson(s));
    }

    List<AlarmInfo> al = [];
    for (var a in l['Alarm_Infos']) {
      al.add(AlarmInfo.fromJson(a));
    }

    List<SensorEvent> el = [];
    for (var e in l['Sensor_Event_Infos']) {
      el.add(SensorEvent.fromJson(e));
    }

    gLocationList.add(
      LocationInfo(
        id: l['id'],
        name: l['name'],
        userID: l['userID'],
        type: l['type'],
        displaySunBun: l['displaySunBun'],
        requireMotionSensorCount: l['requireMotionSensorCount'],
        detectedMotionSensorCount: l['detectedMotionSensorCount'],
        requireDoorSensorCount: l['requireDoorSensorCount'],
        detectedDoorSensorCount: l['detectedDoorSensorCount'],
        createdAt: l['createdAt'],
        updatedAt: l['updatedAt'],
        sensors: sl,
        alarms: al,
        events: el,
      )
    );
  }

  final aList = loginResponse.data['Alarm_Infos'] as List;
  if (aList.isNotEmpty) {
    gLastAlarm = AlarmInfo(
      id: aList[0]['id'],
      alarm: aList[0]['alarm'],
      jaeSilStatus: aList[0]['jaeSilStatus'],
      createdAt: aList[0]['createdAt'],
      updatedAt: aList[0]['updatedAt'],
      userID: aList[0]['userID'],
      locationID: aList[0]['locationID'],
    );
  }

  // final shList = loginResponse.data['Share_Infos'] as List;
  // for (var sh in shList) {
  //   gShareInfo.add(ShareInfo.fromJson(sh));
  // }

  final airPlaneDayList = loginResponse.data['AirplaneDay_Infos'] as List;
  for (var l in airPlaneDayList) {
    gAirPlaneDayList.add(AirplaneDay.fromJson(l));
  }

  final airPlaneTimeList = loginResponse.data['AirplaneTime_Infos'] as List;
  for (var l in airPlaneTimeList) {
    gAirPlaneTimeList.add(AirplaneTime.fromJson(l));
  }

  print(gAirPlaneTimeList);

  final SharedPreferences pref = await SharedPreferences.getInstance();

  pref.setString("name", loginResponse.data['name']);
  pref.setString("parentName", loginResponse.data['parentName']);
  pref.setInt("parentAge", loginResponse.data['parentAge']);
  pref.setString("parentPhone", loginResponse.data['parentPhone']);
  pref.setInt("parentSex", loginResponse.data['parentSex']);
  pref.setString("addr_zip", loginResponse.data['addr_zip']);
  pref.setString("addr", loginResponse.data['addr']);
  pref.setString("addr_detail", loginResponse.data['addr_detail']);
  pref.setString("mobilephone", loginResponse.data['mobilephone']);
  pref.setString("tel", loginResponse.data['tel']);
  pref.setString("snsId", loginResponse.data['snsId']);
  pref.setString("provider", loginResponse.data['provider']);
  pref.setBool("admin", loginResponse.data['admin']);
  pref.setString("shareKey", loginResponse.data['shareKey']);
  pref.setBool("enableAlarm", loginResponse.data['enableAlarm']);
  pref.setBool("useAirplaneMode", loginResponse.data['useAirplaneMode']);
  pref.setBool("isLogin", true);

  gParentInfo['parentName'] = loginResponse.data['parentName'];
  gParentInfo['parentAge'] = loginResponse.data['parentAge'];
  gParentInfo['parentPhone'] = loginResponse.data['parentPhone'];
  gParentInfo['parentSex'] = loginResponse.data['parentSex'];

  gUseAirPlaneMode = pref.getBool("useAirplaneMode") ?? false;

  /*DBHelper sd = DBHelper();
  sd.initAirplaneDayTable();
  gAirPlaneDayList = await sd.getAirplaneDays();
  gAirPlaneTimeList = await sd.getAirplaneTimes();*/
}

var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);

enum FindHubState {
  none,
  findingHub, findingHubError, findingHubPermissionError, findingHubDone, findingHubEmpty,
  bluetoothNotEnabledError, wifiNotEnabledError,
  settingMqtt, settingMqttError, settingMqttDone,
  settingWifiScan, settingWifiScanError, settingWifiScanDone,
  settingWifi, settingWifiError, settingWifiDone,
}

enum FindSensorState {
  none, findingSensor, findingSensorEmpty, findingSensorDone
}

enum JaeSilStateEnum {
  jsNone, jsIn, jsOut
}

double deviceCardHeight = 40;
double deviceFontSize = 18.0;
double deviceIconSize = 16.0;

String convertTimeStringToLocal(String sourStr) {
  DateTime dateSourStr = DateTime.parse(sourStr);
  DateTime dateSourStrLocal = dateSourStr.toLocal();
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateSourStrLocal);
}

void getDeviceFontSize(BuildContext context) {
  if (DeviceScreen.isPhone(context)) {
    debugPrint("isPhone()");
    deviceFontSize = 18.0;
  } else if (DeviceScreen.isTablet(context)) {
    debugPrint("isTablet()");
    deviceFontSize = 20.0;
  } else if (DeviceScreen.isSmallPhone(context)) {
    debugPrint("isSmallPhone()");
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
  String? stringJson = event.getState();
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
  String? stringJson = event.getState();
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
    debugPrint(e as String?);
  }
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