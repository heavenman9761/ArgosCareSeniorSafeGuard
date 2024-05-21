import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

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
  String _hubID = "";
  List<AccessPoint> accessPoints = <AccessPoint>[];
  late AccessPoint selectedAp;
  String wifiPassword = "";
  bool _hasError = false;

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

    ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.none);
    _pairingHub(context);
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
          return <String> [];
        }).then((devices) {
          if (devices.isNotEmpty && !_hasError) {
            _settingHub(devices[0]).catchError((onError){
              _hasError = true;
              return '';
            }).then((hubID) async {
              if (hubID != '' && !_hasError) {
                _hubID = hubID;
                if (!_hasError) {
                  if (tempRegiHubIdToServer(_hubID)) {
                    _wifiScan(context).catchError((onError) => _hasError = true).then((isAccessPoint) {
                      if (isAccessPoint && !_hasError) {
                        if (accessPoints.isNotEmpty) {
                          showWifiDialog(context);
                        }
                      }
                    });
                  }
                }
              }
            });
          } else {
            ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.findingHubEmpty);
          }
        });
      } else {
          ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.findingHubPermissionError);
      }
    });
  }

  bool tempRegiHubIdToServer(String hubID) {
    try {
      mqttPublish('regHub', jsonEncode({
        "hubID": hubID
      }));
      return true;
    } catch(e) {
      return false;
    }
  }

  Future<bool> _checkPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.bluetooth,
      Permission.bluetoothAdvertise,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,

    ].request();

    if (statuses.values.every((element) => element.isGranted)) {
      return true;
    }

    if (statuses.values.any((element) => element.isPermanentlyDenied)) {
      openAppSettings();
      return false;
    }

    if (statuses.values.any((element) => element.isRestricted)) { //ios
      openAppSettings();
      return false;
    }

    return false;
  }

  Future<List<String>> _findHub() async {
    try {
      ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.findingHub);

      final Iterable result =
          await Constants.platform.invokeMethod('findEsp32');

      ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.findingHubDone);

      return result.cast<String>().toList();

    } on PlatformException catch (e) {
      logger.e(e);
      ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.findingHubError);

      return [];
    }
  }

  Future<String> _settingHub(String hubName) async {
    try {
      ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.settingMqtt);

      const storage = FlutterSecureStorage(
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );
      final email = await storage.read(key: 'EMAIL');

      final String result =
          await Constants.platform.invokeMethod('settingHub', <String, dynamic>{
        "hubName": hubName,
        "accountID": email,
        "serverIp": Constants.MQTT_HOST,
        "serverPort": Constants.MQTT_PORT.toString(),
        "userID": Constants.MQTT_ID, //mqtt 계정
        "userPw": Constants.MQTT_PASSWORD
      });

      debugPrint('received from java [hubID]: $result');

      ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.settingMqttDone);

      return result;
    } on PlatformException catch (e) {
      debugPrint(e.message);
      ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.settingMqttError);
      return '';

    }
  }

  Future<bool> _wifiScan(BuildContext context) async {
    String strApList;

    try {
      ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.settingWifiScan);

      final result = await Constants.platform.invokeMethod('_wifiProvision');
      strApList = result.toString();

      List<dynamic> list = json.decode(strApList);

      for (int i = 0; i < list.length; i++) {
        AccessPoint ap = AccessPoint.fromJson(list[i]);
        debugPrint(ap.toString());
        accessPoints.add(ap);
      }

      ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.settingWifiScanDone);

      return accessPoints.isNotEmpty ? true : false;
    } on PlatformException catch (e) {
      setState(() {
        ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.settingWifiScanError);
      });

      logger.e(e.message);

      return false;
    }
  }

  Future<void> _setWifiConfig() async {
    try {
      ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.settingWifi);

      logger.i("_setWifiConfig() $wifiPassword ${selectedAp.toString()}");

      final String result = await Constants.platform.invokeMethod(
          'setWifiConfig', <String, dynamic>{
        "wifiName": selectedAp.getWifiName(),
        "password": wifiPassword
      });

      logger.i('received from java: $result');

      ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.settingWifiDone);
      ref.read(resultTopicProvider.notifier).state = 'result/$_hubID';
      ref.read(requestTopicProvider.notifier).state = 'request/$_hubID';

      if (ref.watch(mqttCurrentStateProvider) == MqttConnectionState.connected) {
        mqttAddSubscribeTo(ref.watch(resultTopicProvider));
        // mqttAddSubscribeTo(ref.watch(requestTopicProvider));
      }

    } on PlatformException catch (e) {
      logger.e(e.message);
      ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.settingWifiError);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(findHubStateProvider, (previous, next) {
      logger.i('current state: ${ref.watch(findHubStateProvider)}');
    });
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
    if (ref.watch(findHubStateProvider) == ConfigState.findingHub) {
      return processWidget("허브를 찾고 있습니다.");

    } else if (ref.watch(findHubStateProvider) == ConfigState.findingHubEmpty) {
      return retryWidget("허브를 찾을 수 없습니다.\n다시 시도해보시기 바랍니다.");

    } else if (ref.watch(findHubStateProvider) == ConfigState.findingHubPermissionError) {
      return retryWidget("사용 권한을 허용하시고\n다시 시도해보시기 바랍니다.");

    } else if (ref.watch(findHubStateProvider) == ConfigState.findingHubError
        || ref.watch(findHubStateProvider) == ConfigState.findingHubError
        || ref.watch(findHubStateProvider) == ConfigState.settingMqttError
        || ref.watch(findHubStateProvider) == ConfigState.settingWifiScanError
        || ref.watch(findHubStateProvider) == ConfigState.settingWifiError) {
      return retryWidget("오류가 발생 했습니다.\n다시 시도해보시기 바랍니다.");

    } else if (ref.watch(findHubStateProvider) == ConfigState.findingHubDone) {
      return processWidget('허브를 찾았습니다.');

    } else if (ref.watch(findHubStateProvider) == ConfigState.settingMqtt) {
      return processWidget('서버 셋팅을 하고 있습니다.');

    } else if (ref.watch(findHubStateProvider) == ConfigState.settingMqttDone) {
      return processWidget('서버 셋팅이 완료되었습니다.');

    } else if (ref.watch(findHubStateProvider) == ConfigState.settingWifiScan
              || ref.watch(findHubStateProvider) == ConfigState.settingWifiScanDone
              || ref.watch(findHubStateProvider) == ConfigState.settingWifi) {
      return processWidget('WIFI 설정 중입니다.');

    } else if (ref.watch(findHubStateProvider) == ConfigState.settingWifiDone) {
      return lastWidget();

    } else {
      return const Text('');
    }
  }

  Widget retryWidget(String msg) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(onPressed: () async => _pairingHub(context), style: Constants.elevatedButtonStyle, child: const Text('다시 시도')),
        const SizedBox(height: 20,),
        Text(msg)
      ]);
  }

  Widget processWidget(String msg)
  {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //const CircularProgressIndicator(),
        const SpinKitRipple(
          color: Colors.blue,
          size: 100,
        ),
        const SizedBox(height: 20,),
        Text(msg),
      ],
    );
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
                  content: SizedBox(
                    height: 300.0,
                    width: 300.0,
                    child: ListView.builder(
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
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("Input WIFI Password"),
              content: TextFormField(
                autofocus: true,
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
