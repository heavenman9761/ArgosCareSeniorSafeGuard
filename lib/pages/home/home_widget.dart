import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/pages/mydevice/pairing_hub.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/pages/home/location_widget.dart';
import 'package:argoscareseniorsafeguard/pages/home/recent_alarm_widget.dart';
import 'package:argoscareseniorsafeguard/pages/home/jaesil_widget.dart';
import 'package:argoscareseniorsafeguard/pages/profile/parent_edit.dart';

class HomeWidget extends ConsumerStatefulWidget {
  const HomeWidget({super.key, required this.userName, required this.userID});
  final String userID;
  final String userName;

  @override
  ConsumerState<HomeWidget> createState() => _HomeWidgetState();
}

class _HomeWidgetState extends ConsumerState<HomeWidget> {
  int _drawedLocationIndex = -1;
  bool _isInit = true;
  bool _hasCallSupport = false;

  @override
  void initState() {
    super.initState();

    SchedulerBinding.instance.addPostFrameCallback((_) {
      getLastAlarm();
    });

    canLaunchUrl(Uri(scheme: 'tel', path: gParentInfo['parentPhone'])).then((bool result) {
      setState(() {
        if (gParentInfo['parentPhone'].length == 11) {
          _hasCallSupport = result;
        } else {
          _hasCallSupport = false;
        }
      });
    });
  }

  Future<void> getLastAlarm() async {
    ref.read(alarmProvider.notifier).doChangeState(gLastAlarm);
    ref.read(jaeSilStateProvider.notifier).doChangeState(JaeSilStateEnum.values[gLastAlarm.getJaeSilStatus()!]);
  }

  @override
  Widget build(BuildContext context) {
    _drawedLocationIndex = -1;      // -> 안하면 위젯이 사라진다.
    return Scaffold(
      backgroundColor: Constants.scaffoldBackgroundColor,
      body: Stack(
        children: [
          _getTitleBar(),

          _getParentStatus(),

          gHubList.isEmpty ? _getHubConnectWidget() : _getRecentNotice(),

          gSensorList.isEmpty ? _getSensorConnectWidget() : _getLocationAlarm()
        ],
      )
    );
  }

  Widget _getTitleBar() {
    return Positioned( //타이틀바
      top: 0,
      left: 0,
      right: 0,
      height: 200.h,
      child: Stack(
          children: [
            Container(
              width: double.infinity,
              color: Constants.primaryColor,
              child: Padding(
                  padding: EdgeInsets.all(20.w),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(height: 32.h),
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!.app_title, style: TextStyle(fontSize: 20.sp, color: Colors.white, fontWeight: FontWeight.bold), ),
                        ],
                      ),
                      Row(
                        children: [
                          Text(AppLocalizations.of(context)!.app_subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.white), ),
                        ],
                      ),
                      SizedBox(height: 5.h),
                      const JaeSilWidget(),
                    ],
                  )
              ),
            ),
            Positioned(
                top: 52.h,
                right: 20.w,
                height: 80.h,
                width: 80.h,
                child: gParentInfo['parentSex'] == -1
                  ? SvgPicture.asset('assets/images/parent_unknown.svg', width: 80.w, height: 80.h,)
                  : (gParentInfo['parentSex'] == 1 ? const Image(image: AssetImage('assets/images/parent_male.png'),) : const Image(image: AssetImage('assets/images/parent_female.png'),))
            )
          ]
      ),
    );
  }

  Widget _registerParentWidget() {
    return Padding( //대상자 등록
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppLocalizations.of(context)!.parent_register, style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
                SizedBox(height: 5.h),
                Text(AppLocalizations.of(context)!.parent_unknown_message, style: TextStyle(fontSize: 12.sp, color: Constants.dividerColor), ),
              ]
          ),
          const Spacer(),
          Row(
            children: [
              // SvgPicture.asset('assets/images/register_parent.svg', width: 44.w, height: 44.h,),
              IconButton(
                constraints: const BoxConstraints(maxHeight: 88, maxWidth: 88),
                splashRadius: 44,
                padding: EdgeInsets.zero,
                icon: SvgPicture.asset('assets/images/register_parent.svg', width: 44.w, height: 44.h,),
                onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ParentEdit(userID: widget.userID);
                  })).then((onValue) {
                    setState(() {

                    });
                  });
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _showParentWidget() {
    return Padding( //대상자 등록
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${gParentInfo['parentName']} 님', style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
                SizedBox(height: 5.h),
                Text('대상자 | ${gParentInfo['parentAge']}세 | ${gParentInfo['parentSex'] == 1 ? '남' : '여'} | ${gParentInfo['parentPhone']}', style: TextStyle(fontSize: 12.sp, color: Constants.dividerColor), ),
              ]
          ),
          const Spacer(),
          Row(
            children: [ _getCallButton(), ],
          )
        ],
      ),
    );
  }

  Widget _getCallButton() {
    return IconButton(
      constraints: const BoxConstraints(maxHeight: 88, maxWidth: 88),
      splashRadius: 44,
      padding: EdgeInsets.zero,
      icon: _hasCallSupport ? SvgPicture.asset('assets/images/call.svg', width: 44.w, height: 44.h,) : SvgPicture.asset('assets/images/call_grey.svg', width: 44.w, height: 44.h,),
      onPressed: () async {
        if (_hasCallSupport) {
          final Uri launchUri = Uri(
            scheme: 'tel',
            path: gParentInfo['parentPhone'],
          );
          await launchUrl(launchUri);
        }
      },
    );
  }

  Widget _getParentStatus() {
    return Positioned( //피보호자 상태
      top: 152.h,
      left: 20.w,
      right: 20.w,
      height: 96.h,
      // width: 320.w,
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.2),
                spreadRadius: 5,
                blurRadius: 7,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: gParentInfo['parentName'] == "" ? _registerParentWidget() : _showParentWidget()

      ),
    );
  }

  Widget _getHubConnectWidget() {
    return Positioned(
      top: 264.h,
      left: 20.w,
      right: 20.w,
      height: 96.h,
      // width: 320.w,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: InkWell(
          onTap: () { goPairingHub(context);},
          child: Card(
            color: Constants.secondaryColor,
            child: Padding(
              padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
              child: Column( //허브가 없으면
                children: [
                  Row(
                    children: [
                      Container(
                          width: 72.w,
                          height: 28.h,
                          decoration: BoxDecoration(
                            color: Constants.primaryColor,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 13.w,),
                              Text(AppLocalizations.of(context)!.recent_notice, style: TextStyle(fontSize: 12.sp, color: Colors.white), ),
                            ],
                          )
                      ),
                      const Spacer(),
                      Container(
                          width: 128.w,
                          height: 28.h,
                          decoration: BoxDecoration(
                            color: Constants.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(DateFormat('MM.dd (E) HH:mm', 'ko').format(DateTime.now()), style: TextStyle(fontSize: 12.sp, color: Constants.primaryColor), ),
                            ],
                          )
                      )
                    ],
                  ),
                  SizedBox(height: 18.h),
                  Row(
                    children: [
                      SvgPicture.asset('assets/images/hub_small.svg', width: 16.w, height: 16.h,),
                      SizedBox(width: 8.w,),
                      Text(AppLocalizations.of(context)!.no_hub_message, style: TextStyle(fontSize: 12.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
                    ],
                  )
                ],
              ),
            ),
          ),
        )

      ),
    );
  }

  Widget _getRecentNotice() {
    return Positioned( //최신 알림
      top: 264.h,
      left: 20.w,
      right: 20.w,
      height: 96.h,
      // width: 320.w,
      child: RecentAlarmWidget(userID: widget.userID)
    );
  }

  Widget _getSensorConnectWidget() {
    return Positioned(
      top: 380.h,
      left: 20.w,
      right: 20.w,
      height: 164.h,
      child: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Card(
          color: Constants.borderColor,
          child: Padding(
            padding: EdgeInsets.all(0.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text("내 기기에서", style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
                Text("장소를 추가해 주세요", style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
                Text("센서를 연결해 주세요", style: TextStyle(fontSize: 12.sp, color: Constants.dividerColor), ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Constants.primaryColor,
                      elevation: 0, //
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      minimumSize: Size(120.w, 32.h)
                  ),
                  child: Text('장소 추가하기 >', style: TextStyle(fontSize: 12.sp, color: Colors.white, ), ),
                  onPressed: () {
                    ref.read(homeBottomNavigationProvider.notifier).state = 2;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _getLocationAlarm() {
    return Positioned( //장소별 알림 영역
      top: 380.h,
      left: 20.w,
      right: 20.w,
      bottom: 0,
      child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Constants.scaffoldBackgroundColor,
          child: GridView.builder(
            padding: const EdgeInsets.all(0),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 20.w, crossAxisSpacing: 20.h),
            itemCount: _getAvailableLocationCount(), //gLocationList.length,
            itemBuilder: (BuildContext context, int index) {
              return _locationInfo(context);
            },
          )
      ),
    );
  }

  int _getAvailableLocationCount() {
    int result = 0;
    for (var l in gLocationList) {
      if (l.getType()! == 'entrance' || l.getType()! == 'refrigerator' || l.getType()! == 'toilet') {
        if (l.getRequireDoorSensorCount()! == l.getDetectedDoorSensorCount()! &&
            l.getRequireMotionSensorCount()! == l.getDetectedMotionSensorCount()!) {
          result++;
        }
      }
      if ((l.getType()! == 'emergency' || l.getType()! == 'customer') && l.getSensors()!.isNotEmpty) {
        result++;
      }
    }
    return result;
  }

  Widget _locationInfo(BuildContext context) {
    for (int i = _drawedLocationIndex + 1; i < gLocationList.length; i++) {
      if (gLocationList[i].getType()! == 'entrance' || gLocationList[i].getType()! == 'refrigerator' || gLocationList[i].getType()! == 'toilet') {
        if (gLocationList[i].getRequireDoorSensorCount()! == gLocationList[i].getDetectedDoorSensorCount()! &&
            gLocationList[i].getRequireMotionSensorCount()! == gLocationList[i].getDetectedMotionSensorCount()!) {
          _drawedLocationIndex = i;
          return _displayLocation(context, i);
        }
      }
      if ((gLocationList[i].getType()! == 'emergency' || gLocationList[i].getType()! == 'customer') && gLocationList[i].getSensors()!.isNotEmpty) {
        _drawedLocationIndex = i;
        return _displayLocation(context, i);
      }
    }
    return const SizedBox();
  }

  Widget _displayLocation(BuildContext context, int index) {
    late SvgPicture picture;
    String title = "";

    if (index == 0) {
      picture = SvgPicture.asset('assets/images/entrance.svg', width: 48.w, height: 48.h,);
      title = AppLocalizations.of(context)!.location_entrance;
    } else if (index == 1) {
      picture = SvgPicture.asset('assets/images/refrigerator.svg', width: 48.w, height: 48.h,);
      title = AppLocalizations.of(context)!.location_refrigerator;
    } else if (index == 2) {
      picture = SvgPicture.asset('assets/images/toilet.svg', width: 48.w, height: 48.h,);
      title = AppLocalizations.of(context)!.location_toilet;
    } else if (index == 3) {
      picture = SvgPicture.asset('assets/images/emergency.svg', width: 48.w, height: 48.h,);
      title = AppLocalizations.of(context)!.location_emergency;
    } else {
      picture = SvgPicture.asset('assets/images/new_location.svg', width: 48.w, height: 48.h,);
      title = gLocationList[index].getName()!;
    }

    return LocationWidget(userID: widget.userID, title: title, picture: picture, color: Constants.dividerColor, locationIndex: index);

  }

  void goPairingHub(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
        builder: (context) {
          return const PairingHub();
        })).then((onValue) {
          setState(() {

          });
        });
  }

  /*Widget _getSensorWidget(SensorInfo sensor) {
    if (sensor.deviceType == Constants.DEVICE_TYPE_DOOR) {
      return DoorCardWidget(deviceName: sensor.getName()!);

    } else if (sensor.deviceType == Constants.DEVICE_TYPE_ILLUMINANCE) {
      return IlluminanceCardWidget(deviceName: sensor.getName()!);

    } else if (sensor.deviceType == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
      return HumidityCardWidget(deviceName: sensor.getName()!);

    } else if (sensor.deviceType == Constants.DEVICE_TYPE_SMOKE) {
      return SmokeCardWidget(deviceName: sensor.getName()!);

    } else if (sensor.deviceType == Constants.DEVICE_TYPE_EMERGENCY) {
      return EmergencyCardWidget(deviceName: sensor.getName()!);

    } else if (sensor.deviceType == Constants.DEVICE_TYPE_MOTION) {
      return MotionCardWidget(deviceName: sensor.getName()!);

    }
    return const Text("");
  }*/



  // void _updateSensorOrder(int oldIndex, int newIndex) {
  //   setState(() {
  //     if (oldIndex < newIndex) {
  //       newIndex -= 1;
  //     }
  //
  //     final String tile = myTiles.removeAt(oldIndex);
  //     myTiles.insert(newIndex, tile);
  //   });
  // }

/*Future<List<Device>> _getDeviceList() async {
    List<Device> deviceList = [];

    DBHelper sd = DBHelper();
    deviceList = await sd.getDevices();
    return deviceList;
  }*/

/*Future<List<SensorInfo>> _getSensorList() async {
    // DBHelper sd = DBHelper();
    //
    // List<Sensor> sensorList = await sd.getSensors(userID);

    List<HubInfo> hubList = [];
    List<SensorInfo> sensorList = [];

    if (widget.userID != '') {
      final response = await dio.get(
        "/devices/$widget.userID",
      );

      if (response.statusCode == 200) {
        hubList.clear();
        sensorList.clear();

        final hList = response.data as List;
        for (var h in hList) {
          hubList.add(HubInfo.fromJson(h));

          final sList = h['Sensor_Infos'] as List;
          for (var s in sList) {
            sensorList.add(SensorInfo.fromJson(s));
          }
        }
      }
    }
    return sensorList;
  }*/

  /*Widget waitWidget() {
    return const CircularProgressIndicator(backgroundColor: Colors.blue);
  }*/
}