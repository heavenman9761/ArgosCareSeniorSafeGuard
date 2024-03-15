import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/models/accesspoint.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/mqtt/mqtt.dart';

class AddHubPage2 extends ConsumerStatefulWidget {
  const AddHubPage2({super.key});

  @override
  ConsumerState<AddHubPage2> createState() => _AddHubPage2State();
}

class _AddHubPage2State extends ConsumerState<AddHubPage2> {
  ConfigState configState = ConfigState.none;
  String _hubID = "";
  List<AccessPoint> accessPoints = <AccessPoint>[];
  late AccessPoint selectedAp;
  String wifiPassword = "";
  bool _hasError = false;

  final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
    foregroundColor: Colors.white60,
    backgroundColor: Colors.lightBlue, // text color
    elevation: 5, //
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
  );

  // Future<void> setHubIdToPrefs(String value) async {
  //   try {
  //     final SharedPreferences pref = await SharedPreferences.getInstance();
  //
  //     pref.setString('deviceID', value).then((bool success) {
  //       if (success) {
  //         _manager.subScribeTo('result/$value');
  //         logger.i('subscribed to result/$value');
  //       }
  //     });
  //   } catch (error) {
  //     logger.e(error);
  //   }
  // }

  @override
  void initState() {
    super.initState();

    setState(() {
      configState = ConfigState.none;
      _pairingHub(context);
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _pairingHub(BuildContext context) async {
    await _checkPermissions().catchError((onError) {
      return false;
    }).then((isGranted) {
      if (isGranted) {
        _findHub().catchError((onError){
          _hasError = true;
          return [];
        }).then((devices) {
          if (devices.isNotEmpty && !_hasError) {
            _settingHub(devices[0]).catchError((onError){
              _hasError = true;
              return '';
            }).then((hubID) {
              if (hubID != '' && !_hasError) {
                _hubID = hubID;
                logger.i(_hubID);
                if (!_hasError) {
                  _wifiScan(context).catchError((onError) => _hasError = true).then((isAccessPoint) {
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
      } else {
        setState(() {
          configState = ConfigState.findingHubPermissionError;
        });
      }
    });
  }

  Future<bool> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,

    ].request();

    logger.i('location ${statuses[Permission.location]}');
    logger.i('bluetooth ${statuses[Permission.bluetooth]}');
    logger.i('bluetoothAdvertise ${statuses[Permission.bluetoothAdvertise]}');
    logger.i('bluetoothConnect ${statuses[Permission.bluetoothConnect]}');
    logger.i('bluetoothScan ${statuses[Permission.bluetoothScan]}');

    if (statuses.values.every((element) => element.isGranted)) {
      return true;
    }
    return false;
  }

  Future<List<String>> _findHub() async {
    try {
      setState(() {
        configState = ConfigState.findingHub;
      });
      final Iterable result =
          await Constants.platform.invokeMethod('findEsp32');

      setState(() {
        configState = ConfigState.findingHubDone;
      });

      return result.cast<String>().toList();

    } on PlatformException catch (e) {
      logger.e(e);
      setState(() {
        configState = ConfigState.findingHubError;
      });

      return [];
    }
  }

  Future<String> _settingHub(String hubName) async {
    try {
      setState(() {
        configState = ConfigState.settingMqtt;
      });

      final String result =
          await Constants.platform.invokeMethod('settingHub', <String, dynamic>{
        "hubName": hubName,
        "accountID": Constants.ACCOUNT_ID,
        "serverIp": "14.42.209.174",
        "serverPort": "6002",
        "userID": "mings",
        "userPw": "Sct91234!"
      });

      debugPrint('received from java [hubID]: $result');

      setState(() {
        configState = ConfigState.settingMqttDone;
      });

      return result;
    } on PlatformException catch (e) {
      debugPrint(e.message);
      setState(() {
        configState = ConfigState.settingMqttError;
      });
      return '';

    }
  }

  Future<bool> _wifiScan(BuildContext context) async {
    String strApList;

    try {
      setState(() {
        configState = ConfigState.settingWifiScan;
      });

      final result = await Constants.platform.invokeMethod('_wifiProvision');
      strApList = result.toString();

      List<dynamic> list = json.decode(strApList);

      for (int i = 0; i < list.length; i++) {
        AccessPoint ap = AccessPoint.fromJson(list[i]);
        debugPrint(ap.toString());
        accessPoints.add(ap);
      }

      setState(() {
        configState = ConfigState.settingWifiScanDone;
      });

      return accessPoints.isNotEmpty ? true : false;
    } on PlatformException catch (e) {
      setState(() {
        configState = ConfigState.settingWifiScanError;
      });

      logger.e(e.message);

      return false;
    }
  }

  Future<void> _setWifiConfig() async {
    try {
      setState(() {
        configState = ConfigState.settingWifi;
      });

      logger.i("_setWifiConfig() $wifiPassword ${selectedAp.toString()}");

      final String result = await Constants.platform.invokeMethod(
          'setWifiConfig', <String, dynamic>{
        "wifiName": selectedAp.getWifiName(),
        "password": wifiPassword
      });

      logger.i('received from java: $result');

      setState(() {
        configState = ConfigState.settingWifiDone;
        ref.read(resultTopicProvider.notifier).state = 'result/$_hubID';
        ref.read(requestTopicProvider.notifier).state = 'request/$_hubID';

        if (ref.watch(mqttCurrentStateProvider) == MqttConnectionState.connected) {
          mqttAddSubscribeTo(ref.watch(resultTopicProvider));
          mqttAddSubscribeTo(ref.watch(requestTopicProvider));
        }
      });

    } on PlatformException catch (e) {
      logger.e(e.message);

      setState(() {
        configState = ConfigState.settingWifiError;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('허브 추가'),
          centerTitle: true,
        ),
        body: Center(child: controlUI()));
  }

  Widget controlUI() {
    if (configState == ConfigState.findingHub) {
      return const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 20,),
          Text("허브를 찾고 있습니다.")
        ],
      );
    } else {
      if (_hubID == '') {
        if (configState == ConfigState.findingHubDone) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed:() async => _pairingHub(context), style: elevatedButtonStyle, child: const Text('다시 시도')),
              const SizedBox(height: 20,),
              const Text("허브를 찾을 수 없습니다.\n다시 시도해보시기 바랍니다.")
          ]);
        } else if (configState == ConfigState.findingHubError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed:() async => _pairingHub(context), style: elevatedButtonStyle, child: const Text('다시 시도')),
              const SizedBox(height: 20,),
              const Text("오류가 발생 했습니다.\n다시 시도해보시기 바랍니다.")
          ]);
        } else if (configState == ConfigState.findingHubPermissionError) {
          return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(onPressed:() async => _pairingHub(context), style: elevatedButtonStyle, child: const Text('다시 시도')),
                const SizedBox(height: 20,),
                const Text("사용 권한을 부여해주시고\n다시 시도해보시기 바랍니다.")
              ]);
        } else {
          return const Text('');
        }
      } else {
        if (configState == ConfigState.findingHubError
            || configState == ConfigState.settingMqttError
            || configState == ConfigState.settingWifiScanError
            || configState == ConfigState.settingWifiError) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed:() async => _pairingHub(context), style: elevatedButtonStyle, child: const Text('다시 시도')),
              const SizedBox(height: 20,),
              const Text("오류가 발생 했습니다.\n다시 시도해보시기 바랍니다.")
          ]);
        } else if (configState == ConfigState.findingHubDone) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20,),
              Text('설정 중 입니다.')
            ],
          );
        } else if (configState == ConfigState.settingMqtt
            || configState == ConfigState.settingMqttDone
            || configState == ConfigState.settingWifiScan
            || configState == ConfigState.settingWifiScanDone
            || configState == ConfigState.settingWifi) {
          return const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 20,),
              Text('설정 중 입니다.')
            ],
          );
        } else if (configState == ConfigState.settingWifiDone) {
          return lastWidget();
        } else {
          return const Text('');
        }
      }
      //
    }
  }

  Widget lastWidget()
  {
    return const Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text('설정이 완료되었습니다.')
      ],
    );
  }

  Widget rssiWidget(AccessPoint ap) {
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
                          leading: rssiWidget(accessPoints[index]),
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
        debugPrint("selectedAp : $val");
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
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.pop(context, controller.text);
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
}
