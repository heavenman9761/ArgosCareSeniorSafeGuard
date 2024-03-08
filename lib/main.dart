import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:argoscareseniorsafeguard/Constants.dart';
import 'package:argoscareseniorsafeguard/models/accesspoint.dart';
import 'package:argoscareseniorsafeguard/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  initializeNotification();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _hubID = "";
  List<AccessPoint> accessPoints = <AccessPoint>[];
  late AccessPoint selectedAp;
  String wifiPassword = "";
  bool _hasError = false;

  Future<bool> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.notification,

    ].request();

    logger.i('location ${statuses[Permission.location]}');
    logger.i('bluetooth ${statuses[Permission.bluetooth]}');
    logger.i('bluetoothAdvertise ${statuses[Permission.bluetoothAdvertise]}');
    logger.i('bluetoothConnect ${statuses[Permission.bluetoothConnect]}');
    logger.i('bluetoothScan ${statuses[Permission.bluetoothScan]}');
    logger.i('notification ${statuses[Permission.notification]}');

    if (statuses.values.every((element) => element.isGranted)) {
      return true;
    }
    return false;
  }

  void _permission() async {
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
    } else if (requestStatus.isPermanentlyDenied ||
        status.isPermanentlyDenied) {
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

  Future<void> _pairingHub(BuildContext context) async {
    await _checkPermissions().catchError((onError) {

    }).then((isGranted) {
      if (isGranted) {
        _findHub().catchError((onError) {
          _hasError = true;
        }).then((devices) {
          if (devices.isNotEmpty && !_hasError) {
            _settingHub(devices[0]).catchError((onError) {
              _hasError = true;
            }).then((hubID) {
              if (hubID != '' && !_hasError) {
                _hubID = hubID;
                logger.i(_hubID);
                if (!_hasError) {
                  _wifiScan(context).catchError((onError) {
                    _hasError = true;
                  }).then((isAccessPoint){
                    if (isAccessPoint && !_hasError) {
                      if (accessPoints.isNotEmpty) {
                        showWifiDialog(context);
                      }
                    }
                  });
                }
              }
            });
          }
        });
      }
    });
    // await _checkPermissions().then((isGranted) {
    //   if (isGranted) {
    //     _findHub().then((devices) {
    //       if (devices.isNotEmpty) {
    //         logger.i(devices[0]);
    //         _settingHub(devices[0]).then((hubID) {
    //           if (hubID != '') {
    //             _hubID = hubID;
    //             logger.i(_hubID);
    //             _wifiScan(context);
    //           }
    //         });
    //       }
    //     });
    //   }
    // }).whenComplete(() {
    //   logger.i('completed');
    // });
  }

  Future<List<String>> _findHub() async {
    // List<String> esp32DeviceNames;
    try {
      // setState(() {
      //   // configState = ConfigState.findingHub;
      // });
      final Iterable result =
      await Constants.platform.invokeMethod('findEsp32');
      // esp32DeviceNames = result.cast<String>().toList();
      // print("dart: $esp32DeviceNames");

      return result.cast<String>().toList();

      setState(() {
        // configState = ConfigState.findingHubDone;
      });


      //deviceName = '$result';
    } on PlatformException catch (e) {
      setState(() {
        // configState = ConfigState.findingHubError;
      });
      return [];
    }

    // setState(() {
    //   _esp32DeviceNames = esp32DeviceNames;
    // });
  }

  Future<String> _settingHub(String hubName) async {
    try {
      // setState(() {
      //   // configState = ConfigState.settingMqtt;
      // });

      final String result =
      await Constants.platform.invokeMethod('settingHub', <String, dynamic>{
        "hubName": hubName,
        "accountID": "dn9318dn@gmail.com",
        "serverIp": "14.42.209.174",
        "serverPort": "6002",
        "userID": "mings",
        "userPw": "Sct91234!"
      });

      print('received from java [hubID]: $result');

      return result;

      // setState(() {
      //   // configState = ConfigState.settingMqttDone;
      // });

      // _wifiScan();
    } on PlatformException catch (e) {
      print(e.message);
      return '';
      // setState(() {
      //   // configState = ConfigState.settingMqttError;
      // });
    }
  }

  Future<bool> _wifiScan(BuildContext context) async {
    String strApList;

    try {
      // setState(() {
      //   configState = ConfigState.settingWifiScan;
      // });

      final result = await Constants.platform.invokeMethod('_wifiProvision');
      strApList = result.toString();
      logger.i(strApList);

      List<dynamic> list = json.decode(strApList);

      for (int i = 0; i < list.length; i++) {
        AccessPoint ap = AccessPoint.fromJson(list[i]);
        print(ap.toString());
        accessPoints.add(ap);
      }

      return accessPoints.isNotEmpty ? true : false;




      // setState(() {
      //   configState = ConfigState.settingWifiScanDone;
      //   if (accessPoints.isNotEmpty) {
      //     showWifiDialog(context);
      //   }
      // });
    } on PlatformException catch (e) {
      // setState(() {
      //   configState = ConfigState.settingWifiScanError;
      // });

      logger.e(e.message);
      return false;
    }
  }

  Future<void> _setWifiConfig() async {
    // print("================= _setWifiConfig()");
    try {
      // setState(() {
      //   configState = ConfigState.settingWifi;
      // });

      final String result = await Constants.platform.invokeMethod(
        'setWifiConfig', <String, dynamic>{
        "wifiName": selectedAp.getWifiName(),
        "password": wifiPassword
      });
      print('received from java: $result');

      // setState(() {
      //   configState = ConfigState.settingWifiDone;
      //   setHubIdToPrefs(hubID);
      // });
    } on PlatformException catch (e) {
      // print(e.message);
      // setState(() {
      //   configState = ConfigState.settingWifiError;
      // });
    }
  }

  @override
  void initState() {
    getMyDeviceToken();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {

      RemoteNotification? notification = message.notification;

      if (notification != null) {
        FlutterLocalNotificationsPlugin().show(
          notification.hashCode,
          notification.title,
          notification.body,
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'high_importance_channel',
              'high_importance_notification',
              importance: Importance.max,
            ),
          ),
        );

        setState(() {
          logger.i("Foreground 메시지 수신: ${message.notification!.body!}");
        });
      }
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async => _pairingHub(context),
              child: const Text('find hub')
            ),
          ]
        ),
      ),
    );
  }

  void kShowSnackBar(BuildContext context, String message) {
    if (kDebugMode) print(message);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void showWifiDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return AlertDialog(
                  title: const Text("Select WIFI"),
                  content: ListView.builder(
                      itemCount: accessPoints.length,
                      itemBuilder: (ctx, index) {
                        return ListTile(
                          title: Text(accessPoints[index].getWifiName()!),
                          leading: RssiWidget(accessPoints[index]),
                          trailing: accessPoints[index].getSecurity() == 0
                              ? const Icon(Icons.lock_open)
                              : const Icon(Icons.lock),
                          onTap: () {
                            Navigator.pop(context, accessPoints[index]);
                          },
                        );
                      }
                  ),
                  actions: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); //창 닫기
                      },
                      child: const Text("취소"),
                    ),
                  ],
                );

              });
        }).then((val) {
      if (val != null) {
        selectedAp = val;
        print("selectedAp : $val");
        inputWifiPasswordDialog(context);
      }
    });
  }

  void inputWifiPasswordDialog(BuildContext context) {
    final controller = TextEditingController(text: "");
    bool passwordVisible = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("Input WIFI Password"),
              content: TextFormField(
                obscureText: passwordVisible,
                controller: controller,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: Icon(
                      passwordVisible ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed: () {
                      setDialogState(() => passwordVisible = !passwordVisible);
                    },
                  ),
                  labelText: 'Password',
                  icon: const Padding(
                    padding: EdgeInsets.only(top: 15.0),
                    child: Icon(Icons.lock),
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.pop(context, controller.text);
                  },
                ),
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((val) {
      if (val != null) {
        setState(() {
          wifiPassword = val;
          _setWifiConfig();
        });
      }
    });
  }

  Widget RssiWidget(AccessPoint ap) {
    if (ap.getRssi()! > -50) {
      return const Icon(Icons.wifi);
    } else if (ap.getRssi()! >= -60) {
      return const Icon(Icons.wifi_2_bar);
    } else if (ap.getRssi()! >= -67) {
      return const Icon(Icons.wifi_2_bar);
    } else {
      return const Icon(Icons.wifi_1_bar);
    }
  }
}