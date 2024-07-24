import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';

import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/models/accesspoint.dart';
import 'package:argoscareseniorsafeguard/mqtt/mqtt.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_password_dialog.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_wifilist_dialog.dart';

/*class DeviceConnectionEvent{
  final int eventType;
  Map data;

  int getEventType() {
    return eventType;
  }

  Map getData() {
    return data;
  }

  void setData(value) {
    data = value;
  }

  DeviceConnectionEvent({
    required this.eventType,
    required this.data
  });

}*/

class PairingHub extends ConsumerStatefulWidget {
  const PairingHub({super.key});

  @override
  ConsumerState<PairingHub> createState() => _PairingHubState();
}

class _PairingHubState extends ConsumerState<PairingHub> {
  String _hubID = "";
  List<AccessPoint> accessPoints = <AccessPoint>[];
  late AccessPoint selectedAp;
  String wifiPassword = "";
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        return Scaffold(
            resizeToAvoidBottomInset: false,
            backgroundColor: Constants.scaffoldBackgroundColor,
            body: SafeArea(
                child: Padding(
                    padding: EdgeInsets.all(20.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                            height: 24.0.h,
                            width: 24.0.w,
                            child: IconButton(
                              padding: const EdgeInsets.all(0.0),
                              icon: Icon(Icons.close, size: 24.0.h),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            )
                        ),
                        Container(
                          height: 76.h,
                          width: double.infinity,
                          color: Colors.transparent,
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(AppLocalizations.of(context)!.paring_hub_title, style: TextStyle(fontSize: Constants.titleFontSize.sp, color: Colors.black, fontWeight: FontWeight.bold),)
                              ]
                          ),
                        ),
                        Center(
                            child: SizedBox(
                              width: 96.w,
                              height: 76.h,
                              child: const Image(image: AssetImage('assets/images/hub.png'),),
                            )
                        ),
                        SizedBox(height: 36.h),
                        _showGuide1(1),
                        SizedBox(height: 12.h),
                        _showGuide1(2),
                        SizedBox(height: 12.h),
                        _showGuide1(3),
                        SizedBox(height: 12.h),
                        _showGuide1(4),
                        const Spacer(),
                        MyButton(
                          text: AppLocalizations.of(context)!.paring_hub_title,
                          onTap: () async {
                            _showFindHubModalSheet(context);
                          },
                        ),
                      ],
                    )
                )
            )
        );
      },
    );
  }

  Widget _showGuide1(int index) {
    late RichText richText;
    if (index == 1) {
      richText = RichText(
          text: TextSpan(
              text: AppLocalizations.of(context)!.paring_hub_guide1_1,
              style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                  text: AppLocalizations.of(context)!.paring_hub_guide1_2,
                  style: TextStyle(fontSize: 14.sp, color: Constants.primaryColor, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: AppLocalizations.of(context)!.paring_hub_guide1_3,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ]
          )
      );
    }
    else if (index == 2) {
      richText = RichText(
          text: TextSpan(
              text: AppLocalizations.of(context)!.paring_hub_guide2_1,
              style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                  text: AppLocalizations.of(context)!.paring_hub_guide2_2,
                  style: TextStyle(fontSize: 14.sp, color: Constants.primaryColor, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: AppLocalizations.of(context)!.paring_hub_guide2_3,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ]
          )
      );
    }
    else if (index == 3) {
      richText = RichText(
          text: TextSpan(
              text: AppLocalizations.of(context)!.paring_hub_guide3_1,
              style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                  text: AppLocalizations.of(context)!.paring_hub_guide3_2,
                  style: TextStyle(fontSize: 14.sp, color: const Color(0xFF585DD5), fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: AppLocalizations.of(context)!.paring_hub_guide3_3,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ]
          )
      );
    }
    else if (index == 4) {
      richText = RichText(
          text: TextSpan(
              text: AppLocalizations.of(context)!.paring_hub_guide4_1,
              style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),
              children: <TextSpan>[
                TextSpan(
                  text: AppLocalizations.of(context)!.paring_hub_guide4_2,
                  style: TextStyle(fontSize: 14.sp, color: Constants.primaryColor, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: AppLocalizations.of(context)!.paring_hub_guide4_3,
                  style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ]
          )
      );
    }

    return Container(
      width: double.infinity,
      height: 60.h,
      decoration: BoxDecoration(
        border: Border.all(
            color: Constants.borderColor,
            width: 1
        ),
        color: Colors.white, //Constants.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 1), // changes position of shadow
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: 16.w),
          Container(
              width: 24.w, height: 24.h,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFF5F5F5), width: 1),
                borderRadius: BorderRadius.circular(8),
                color: Constants.borderColor,
              ),
              child: Center(
                  child: Text(index.toString(), style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),)
              )
          ),
          SizedBox(width: 14.w),
          //Text(message, style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),)
          richText,
        ],
      ),
    );
  }

  void _showFindHubModalSheet(BuildContext context) {
    _pairingHub(context);

    showModalBottomSheet<void>(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        isDismissible: false,
        enableDrag: false,
        builder: (BuildContext context) {
          return Consumer(
              builder: (context, ref, child) {
                return PopScope(
                    canPop: false,
                    onPopInvoked: (bool didPop) {
                      if (didPop) {
                        print('showModalBottomSheet(): canPop: true');
                        return;
                      } else {
                        print('showModalBottomSheet(): canPop: false');
                        return;
                      }
                    },
                    child: Container(
                        height: 356.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.rectangle,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(20.0.h),
                            topRight: Radius.circular(20.0.h),
                          ),
                          color: Constants.scaffoldBackgroundColor,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            mainAxisSize: MainAxisSize.max,
                            children: <Widget>[
                              _getSheetCloseButton(ref),

                              SizedBox(height: 12.h),

                              _getSheetTitle(ref),

                              SizedBox(height: 11.h),

                              _getSheetMessage(ref),

                              SizedBox(height: 50.h,),

                              _getSheetImage(ref),

                              const Spacer(),

                              _getSheetRetryButton(ref)

                            ],
                          ),
                        )
                    )
                );
              }
          );
        }
    );
  }

  Future<void> _pairingHub(BuildContext context) async {
    await _checkPermissions().catchError((onError) {
      return false;
    }).then((isGranted) {
      if (isGranted) {
        _findHub().catchError((onError) {
          _hasError = true;
          return <String>[];
        }).then((devices) {
          if (devices.isNotEmpty && !_hasError) {
            _settingHub(devices[0]).catchError((onError) {
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
                      }/* else {
                        if (accessPoints.isEmpty) {
                          ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.wifiListEmpty);
                        }
                      }*/
                    });
                  }
                }
              }
            });
          } else {
            if (ref.watch(findHubStateProvider) == FindHubState.bluetoothNotEnabledError
              || ref.watch(findHubStateProvider) == FindHubState.wifiNotEnabledError) {

            } else {
              ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.findingHubEmpty);
            }
          }
        });
      } else {
        ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.findingHubPermissionError);
      }
    });
  }

  Widget _getSheetCloseButton(WidgetRef ref) {
    bool view = false;
    if (ref.watch(findHubStateProvider) == FindHubState.findingHub
        || ref.watch(findHubStateProvider) == FindHubState.settingMqtt
        || ref.watch(findHubStateProvider) == FindHubState.settingMqttDone
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiScan
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiScanDone
        || ref.watch(findHubStateProvider) == FindHubState.settingWifi
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiDone) {
      view = false;
    } else {
      view = true;
    }

    if (view) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 50.h,
            child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                color: Colors.black
            ),
          ),

        ],
      );
    } else {
      return SizedBox(height: 50.h);
    }
  }

  Widget _getSheetTitle(WidgetRef ref) {
    late String title;
    if (ref.watch(findHubStateProvider) == FindHubState.findingHub
        || ref.watch(findHubStateProvider) == FindHubState.settingMqtt
        || ref.watch(findHubStateProvider) == FindHubState.settingMqttDone
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiScan
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiScanDone
        || ref.watch(findHubStateProvider) == FindHubState.settingWifi
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiDone) {
      title = AppLocalizations.of(context)!.paring_hub_sheet_title_search;
    } else if (ref.watch(findHubStateProvider) == FindHubState.findingHubEmpty
        || ref.watch(findHubStateProvider) == FindHubState.findingHubDone) {
      title = AppLocalizations.of(context)!.paring_hub_sheet_title_result;
    } else if (ref.watch(findHubStateProvider) == FindHubState.findingHubPermissionError) {
      title = AppLocalizations.of(context)!.paring_hub_sheet_title_permission_error;
    } else if (ref.watch(findHubStateProvider) == FindHubState.findingHubError
        || ref.watch(findHubStateProvider) == FindHubState.settingMqttError
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiScanError
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiError
        || ref.watch(findHubStateProvider) == FindHubState.bluetoothNotEnabledError
        || ref.watch(findHubStateProvider) == FindHubState.wifiNotEnabledError
        || ref.watch(findHubStateProvider) == FindHubState.wifiListEmpty
        || ref.watch(findHubStateProvider) == FindHubState.wifiAuthError) {
      title = AppLocalizations.of(context)!.paring_hub_sheet_title_error;
    } else if (ref.watch(findHubStateProvider) == FindHubState.stopByUser) {
      title = "취소";
    } else {
      title = '';
    }

    return Text(
      title,
      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget _getSheetMessage(WidgetRef ref) {
    late String message;
    if (ref.watch(findHubStateProvider) == FindHubState.findingHub) {
      message = AppLocalizations.of(context)!.paring_hub_searching;

    } else if (ref.watch(findHubStateProvider) == FindHubState.findingHubEmpty) {
      message = AppLocalizations.of(context)!.paring_hub_searching_not_find;

    } else if (ref.watch(findHubStateProvider) == FindHubState.findingHubPermissionError) {
      message = AppLocalizations.of(context)!.paring_hub_searching_allow_permission;

    } else if (ref.watch(findHubStateProvider) == FindHubState.findingHubError
        || ref.watch(findHubStateProvider) == FindHubState.settingMqttError
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiScanError
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiError) {
      message = AppLocalizations.of(context)!.paring_hub_searching_error;

    } else if (ref.watch(findHubStateProvider) == FindHubState.bluetoothNotEnabledError) {
      message = AppLocalizations.of(context)!.paring_hub_searching_bluetooth_not_enabled_error;

    } else if (ref.watch(findHubStateProvider) == FindHubState.wifiNotEnabledError) {
      message = AppLocalizations.of(context)!.paring_hub_searching_wifi_not_enabled_error;

    } else if (ref.watch(findHubStateProvider) == FindHubState.findingHubDone) {
      message = AppLocalizations.of(context)!.paring_hub_searching_found;

    } else if (ref.watch(findHubStateProvider) == FindHubState.settingMqtt) {
      message = AppLocalizations.of(context)!.paring_hub_searching_setting;

    } else if (ref.watch(findHubStateProvider) == FindHubState.settingMqttDone) {
      message = AppLocalizations.of(context)!.paring_hub_searching_setting_done;

    } else if (ref.watch(findHubStateProvider) == FindHubState.settingWifiScan
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiScanDone
        || ref.watch(findHubStateProvider) == FindHubState.settingWifi) {
      message = AppLocalizations.of(context)!.paring_hub_searching_setting_wifi;

    } else if (ref.watch(findHubStateProvider) == FindHubState.settingWifiDone) {
      message = AppLocalizations.of(context)!.paring_hub_searching_done;

    } else if (ref.watch(findHubStateProvider) == FindHubState.stopByUser) {
      message = "허브검색이 취소되었습니다.";

    } else if (ref.watch(findHubStateProvider) == FindHubState.wifiListEmpty) {
      message = '사용할 수 있는 wifi 가 없습니다. 허브의 Pairing 버튼을 10초간 누른 후 재시도 하시기 바랍니다.';

    } else if (ref.watch(findHubStateProvider) == FindHubState.wifiAuthError) {
      message = 'wifi 비빌번호가 틀립니다. 허브의 Pairing 버튼을 10초간 누른 후 재시도 하시기 바랍니다.';

    } else {
      message = '';
    }

    return Text(
      message,
      style: TextStyle(fontSize: 16.sp, color: Constants.dividerColor),
      textAlign: TextAlign.center,
    );
  }

  Widget _getSheetImage(WidgetRef ref) {
    if (ref.watch(findHubStateProvider) == FindHubState.findingHub
        || ref.watch(findHubStateProvider) == FindHubState.settingMqtt
        || ref.watch(findHubStateProvider) == FindHubState.settingMqttDone
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiScan
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiScanDone
        || ref.watch(findHubStateProvider) == FindHubState.settingWifi) {
      return Lottie.asset('assets/animations/processing.json', width: 100.w, height: 80.h);

    } else if (ref.watch(findHubStateProvider) == FindHubState.findingHubPermissionError
        || ref.watch(findHubStateProvider) == FindHubState.findingHubError
        || ref.watch(findHubStateProvider) == FindHubState.findingHubError
        || ref.watch(findHubStateProvider) == FindHubState.settingMqttError
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiScanError
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiError
        || ref.watch(findHubStateProvider) == FindHubState.bluetoothNotEnabledError
        || ref.watch(findHubStateProvider) == FindHubState.wifiNotEnabledError
        || ref.watch(findHubStateProvider) == FindHubState.findingHubEmpty
        || ref.watch(findHubStateProvider) == FindHubState.stopByUser
        || ref.watch(findHubStateProvider) == FindHubState.wifiListEmpty
        || ref.watch(findHubStateProvider) == FindHubState.wifiAuthError) {
      return SizedBox(
          width: 96.w,
          height: 76.h,
          child: Stack(
            children: [
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: 96.w,
                    height: 76.h,
                    child: const Image(image: AssetImage('assets/images/not_find_hub.png'),),
                  )
              ),
              Positioned(
                  top: 0, right: 0,
                  child: SizedBox(
                    width: 32.w,
                    height: 32.h,
                    child: SvgPicture.asset('assets/images/error.svg', width: 32.w, height: 32.h,),
                  )
              ),
            ],
          )
      );
    } else if (ref.watch(findHubStateProvider) == FindHubState.findingHubDone
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiDone) {
      return SizedBox(
          width: 96.w,
          height: 76.h,
          child: Stack(
            children: [
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: 96.w,
                    height: 76.h,
                    child: const Image(image: AssetImage('assets/images/hub.png'),),
                  )
              ),
              Positioned(
                  top: 0, right: 0,
                  child: SizedBox(
                    width: 32.w,
                    height: 32.h,
                    child: SvgPicture.asset('assets/images/done.svg', width: 32.w, height: 32.h,),
                  )
              ),
            ],
          )
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _getSheetRetryButton(WidgetRef ref) {
    if (ref.watch(findHubStateProvider) == FindHubState.findingHubEmpty
        || ref.watch(findHubStateProvider) == FindHubState.findingHubPermissionError
        || ref.watch(findHubStateProvider) == FindHubState.findingHubError
        || ref.watch(findHubStateProvider) == FindHubState.findingHubError
        || ref.watch(findHubStateProvider) == FindHubState.settingMqttError
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiScanError
        || ref.watch(findHubStateProvider) == FindHubState.bluetoothNotEnabledError
        || ref.watch(findHubStateProvider) == FindHubState.wifiNotEnabledError
        || ref.watch(findHubStateProvider) == FindHubState.settingWifiError) {
      return Padding(
        padding: EdgeInsets.all(20.h),
        child: MyButton(
          onTap: () {
            _pairingHub(context);
          },
          text: AppLocalizations.of(context)!.paring_hub_retry_search,
        ),
      );
    } else {
      return const SizedBox();
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
      ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.findingHub);

      final Iterable result = await Constants.platform.invokeMethod('findEsp32');

      ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.findingHubDone);
      return result.cast<String>().toList();
      print(result);
    } on PlatformException catch (e) {
      logger.e(e.message);
      if (e.message == "Bluetooth is disabled.") {
        ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.bluetoothNotEnabledError);

      } else if (e.message == "Wifi manager is disabled.") {
        ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.wifiNotEnabledError);

      } else {
        ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.findingHubError);
      }


      return [];
    }
  }

  Future<String> _settingHub(String hubName) async {
    try {
      ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.settingMqtt);

      const storage = FlutterSecureStorage(
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );
      final email = await storage.read(key: 'EMAIL');

      final String result =
      await Constants.platform.invokeMethod('settingHub', <String, dynamic>{
        "hubName": hubName,
        "accountID": email,
        "serverIp": kReleaseMode ? Constants.MQTT_HOST_RELEASE : Constants.MQTT_HOST_DEBUG,
        "serverPort": kReleaseMode ? Constants.MQTT_PORT_RELEASE.toString() : Constants.MQTT_PORT_DEBUG.toString(),
        "userID": kReleaseMode ? Constants.MQTT_ID_RELEASE : Constants.MQTT_ID_DEBUG, //mqtt 계정
        "userPw": kReleaseMode ? Constants.MQTT_PASSWORD_RELEASE : Constants.MQTT_PASSWORD_DEBUG
      });

      debugPrint('received from java [hubID]: $result');

      ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.settingMqttDone);

      return result;
    } on PlatformException catch (e) {
      debugPrint(e.message);
      ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.settingMqttError);
      return '';
    }
  }

  Future<bool> _wifiScan(BuildContext context) async {
    String strApList;

    try {
      ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.settingWifiScan);

      final result = await Constants.platform.invokeMethod('_wifiProvision');
      strApList = result.toString();

      List<dynamic> list = json.decode(strApList);
      accessPoints.clear();

      if (list.isNotEmpty) {
        for (int i = 0; i < list.length; i++) {
          AccessPoint ap = AccessPoint.fromJson(list[i]);
          debugPrint(ap.toString());
          accessPoints.add(ap);
        }
      } else {
        print("리스트 없음");
      }


      ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.settingWifiScanDone);

      return accessPoints.isNotEmpty ? true : false;
    } on PlatformException catch (e) {
      logger.e(e.message);
      if (e.message == 'APList is Empty') {
        ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.wifiListEmpty);
      }
      return false;
    }
  }

  Future<void> _setWifiConfig() async {
    try {
      ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.settingWifi);

      logger.i("_setWifiConfig() $wifiPassword ${selectedAp.toString()}");

      final String result = await Constants.platform.invokeMethod(
          'setWifiConfig', <String, dynamic>{
        "wifiName": selectedAp.getWifiName(),
        "password": selectedAp.getPassword()
      });

      logger.i('received from java: $result');

      ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.settingWifiDone);
      ref
          .read(resultTopicProvider.notifier)
          .state = 'result/$_hubID';
      ref
          .read(requestTopicProvider.notifier)
          .state = 'request/$_hubID';

      if (ref.watch(mqttCurrentStateProvider) == MqttConnectionState.connected) {
        mqttAddSubscribeTo(ref.watch(resultTopicProvider));
        // mqttAddSubscribeTo(ref.watch(requestTopicProvider));
      }
    } on PlatformException catch (e) {
      logger.e(e.message);
      if (e.message == "Wi-Fi Authentication failed.") {
        ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.wifiAuthError);
      } else {
        ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.settingWifiError);
      }
    }
  }

  bool tempRegiHubIdToServer(String hubID) {
    try {
      mqttPublish('regHub', jsonEncode({
        "hubID": hubID
      }));
      return true;
    } catch (e) {
      return false;
    }
  }

  void showWifiDialog(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Constants.scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: EdgeInsets.all(20.w),
            child: CustomWifiListDialog(title: AppLocalizations.of(context)!.paring_hub_select_wifi, accessPoints: accessPoints),
          );
        }
    ).then((val) {
      if (val != 'Cancel') {
        selectedAp = val;
        debugPrint("selectedAp : $val");
        _setWifiConfig();
      }else {
        _stopSettingHub();
      }
    });
  }

  Future<void> _stopSettingHub() async {
    try {
      ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.stopByUser);

      final String result = await Constants.platform.invokeMethod('stopByUser');

    } on PlatformException catch (e) {
      print(e);
    }
  }
}