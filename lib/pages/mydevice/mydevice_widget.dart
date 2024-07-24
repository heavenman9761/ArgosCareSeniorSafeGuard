// import 'package:argoscareseniorsafeguard/main.dart';
import 'dart:convert';

import 'package:argoscareseniorsafeguard/dialogs/custom_confirm_dialog.dart';
import 'package:argoscareseniorsafeguard/models/alarm_infos.dart';
import 'package:argoscareseniorsafeguard/mqtt/mqtt.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:mqtt_client/mqtt_client.dart';

import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/models/sensor_infos.dart';
import 'package:argoscareseniorsafeguard/pages/mydevice/add_sensor_first.dart';
import 'package:argoscareseniorsafeguard/pages/mydevice/add_location_new.dart';
import 'package:argoscareseniorsafeguard/pages/mydevice/pairing_hub.dart';

class MyDeviceWidget extends ConsumerStatefulWidget {
  const MyDeviceWidget({super.key, required this.userName, required this.userID});
  final String userID;
  final String userName;

  @override
  ConsumerState<MyDeviceWidget> createState() => _MyDeviceWidgetState();
}

class _MyDeviceWidgetState extends ConsumerState<MyDeviceWidget> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
          backgroundColor: Constants.scaffoldBackgroundColor,
          body: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  // color: Colors.blueAccent,
                  height: 52.h,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(AppLocalizations.of(context)!.app_title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
                SizedBox(
                  // color: Colors.blueAccent,
                  height: 76.h,
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("내 기기", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                        const Spacer(),
                        SizedBox(
                          width: 24.w,
                          height: 24.h,
                          // color: Colors.redAccent,
                          child: IconButton(
                            constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                            padding: EdgeInsets.zero,
                            color: Constants.primaryColor,
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return AddLocationNew(userName: widget.userName, userID: widget.userID);
                              })).then((onValue) =>
                                  setState(() {

                                  }));
                            },
                          ),
                        )

                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                  child: Container( //허브 정보
                    // color: Colors.blueAccent,
                      height: 120.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            spreadRadius: 1,
                            blurRadius: 10,
                            offset: const Offset(0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                                children: [
                                  SvgPicture.asset('assets/images/hub_small2.svg', width: 28.w, height: 28.h),
                                  SizedBox(width: 8.w,),
                                  Text("허브", style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                                  const Spacer(),
                                  gHubList.isEmpty
                                      ? SizedBox(
                                          width: 24.w,
                                          height: 24.h,
                                          // color: Colors.redAccent,
                                          child: IconButton(
                                            constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                                            padding: EdgeInsets.zero,
                                            color: Constants.primaryColor,
                                            icon: SvgPicture.asset('assets/images/setting.svg', width: 24.w, height: 24.h),
                                            onPressed: () {
                                              Navigator.push(context,
                                                  MaterialPageRoute(builder: (context) {
                                                    return const PairingHub();
                                                  }));
                                            },
                                          )
                                        )
                                      : Text(ref.watch(mqttCurrentStateProvider) == MqttConnectionState.connected ? "연결됨" : "연결않됨",
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              color: ref.watch(mqttCurrentStateProvider) == MqttConnectionState.connected ? Constants.primaryColor : Colors.redAccent,
                                            )
                                        ),
                                  gHubList.isEmpty ? const SizedBox() : SizedBox(width: 10.w),
                                  gHubList.isEmpty
                                      ? const SizedBox()
                                      : SizedBox(
                                        width: 24.w, height: 24.h,
                                        child: TextButton(
                                            onPressed: (){
                                              _delHub();
                                            },
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                            ),
                                            child: Text("제거",
                                              style: TextStyle(fontSize: 12.sp, color: ref.watch(mqttCurrentStateProvider) == MqttConnectionState.connected ? Colors.redAccent : Constants.dividerColor, )
                                            ),
                                          ),
                                      )
                                ]
                            ),
                            const Divider(color: Color(0xFFDAF1DC),),
                            Expanded(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        gHubList.isEmpty
                                            ? Text("허브를 설치해 주세요.", style: TextStyle(fontSize: 12.sp, color: Constants.dividerColor, fontWeight: FontWeight.bold),)
                                            : Text('${gHubList[0].getCreatedAt()!.substring(0, 10)} 설치', style: TextStyle(fontSize: 12.sp, color: Constants.dividerColor),),

                                      ],
                                    )
                                  ],
                                )
                            )
                          ],
                        ),
                      )
                  ),
                ),
                // SizedBox(height: 8.h,),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                  child: SizedBox(
                    // color: Colors.redAccent,
                    height: 370.h,
                    child: ListView.builder(
                        itemCount: gLocationList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return _sensorInfo(context, index);
                        }),
                  ),
                )
              ]
          ),
        )
    );
  }

  Widget _sensorInfo(BuildContext context, int index) {
    if (gLocationList[index].type == "entrance") { //현관
      return _getEntranceWidget(index);
    } else if (gLocationList[index].type == "refrigerator") { //냉장고
      return _getRefrigerator(index);
    } else if (gLocationList[index].type == "toilet") { //화장실
      return _getToilet(index);
    } else if (gLocationList[index].type == "emergency") { //SOS
      return _getEmergency(index);
    } else if (gLocationList[index].type == "customer") { //사용자 추가 장소
      return _getCustomLocation(index);
    } else {
      return const SizedBox();
    }
  }

  Widget _getEntranceWidget(int index) {
    SvgPicture picture = SvgPicture.asset('assets/images/entrance_small.svg', width: 28.w, height: 28.h,);
    String title = AppLocalizations.of(context)!.location_entrance;
    double height = 152.h;

    late SensorInfo doorSensor;
    late SensorInfo motionSensor;
    List<SensorInfo> sensorList = gLocationList[index].getSensors()!;

    bool existDoorSensor = false;
    bool existMotionSensor = false;

    int doorSensorBattery = 0;
    int motionSensorBattery = 0;

    for (var s in sensorList) {
      if (s.getDeviceType() == "door_sensor") { //emergency_button
        doorSensor = s;
        existDoorSensor = true;
        doorSensorBattery = s.getBattery()!;
      } else if (s.getDeviceType() == "motion_sensor") {
        motionSensor = s;
        existMotionSensor = true;
        motionSensorBattery = s.getBattery()!;
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Container( //허브 정보
        // color: Colors.blueAccent,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Constants.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h,),
              Row(
                  children: [
                    SizedBox(width: 16.w,),
                    picture,
                    SizedBox(width: 8.w,),
                    Text(title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                    const Spacer(),
                    SizedBox(
                      width: 24.w,
                      height: 24.h,
                      // color: Colors.redAccent,
                      child: IconButton(
                        constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                        padding: EdgeInsets.zero,
                        color: Constants.primaryColor,
                        icon: SvgPicture.asset('assets/images/setting.svg', width: 24.w, height: 24.h),
                        onPressed: () {
                          ref.read(currentLocationProvider.notifier).doChangeState(gLocationList[index]);
                          ref.read(findSensorStateProvider.notifier).doChangeState(FindSensorState.none);

                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return AddSensorFirst(userName: widget.userName, userID: widget.userID, hubID: gHubList[0].getHubID()!,);
                          })).then((onValue) =>
                              setState(() {
                                setState(() {

                                });
                              }));
                        },
                      ),
                    ),
                    SizedBox(width: 16.w,),
                  ]
              ),
              SizedBox(height: 4.h,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 16.h,),
                  const Expanded(
                    child: Divider(color: Color(0xFFDAF1DC), thickness: 1),
                  ),
                  SizedBox(width: 16.h,),
                ],
              ),
              Expanded(
                  child: existDoorSensor
                      ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 16.w,),
                        SvgPicture.asset("assets/images/door_sensor_small.svg", width: 16.w, height: 16.h),
                        SizedBox(width: 16.w,),
                        Text("문열림 센서", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor),),
                        const Spacer(),
                        doorSensorBattery == 0 ? SvgPicture.asset("assets/images/battery_state_high.svg", width: 24.w, height: 24.h) : SvgPicture.asset(
                            "assets/images/battery_state_low.svg", width: 24.w, height: 24.h),
                        SizedBox(width: 16.w,),
                      ]
                  )
                      : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 16.w,),
                        SvgPicture.asset("assets/images/sensor_info_small.svg", width: 16.w, height: 16.h),
                        SizedBox(width: 16.w,),
                        Text("문열림 센서를 연결해주세요.", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor),),
                      ]
                  )
              ),
              Expanded(
                  child: existMotionSensor
                      ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 16.w,),
                        SvgPicture.asset("assets/images/motion_sensor_small.svg", width: 16.w, height: 16.h),
                        SizedBox(width: 16.w,),
                        Text("움직임 센서", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor),),
                        const Spacer(),
                        motionSensorBattery == 0 ? SvgPicture.asset("assets/images/battery_state_high.svg", width: 24.w, height: 24.h) : SvgPicture.asset(
                            "assets/images/battery_state_low.svg", width: 24.w, height: 24.h),
                        SizedBox(width: 16.w,),
                      ]
                  )
                      : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 16.w,),
                        SvgPicture.asset("assets/images/sensor_info_small.svg", width: 16.w, height: 16.h),
                        SizedBox(width: 16.w,),
                        Text("움직임 센서를 연결해주세요.", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor),),
                      ]
                  )
              )
            ],
          )
      ),
    );
  }

  Widget _getRefrigerator(int index) {
    SvgPicture picture = SvgPicture.asset('assets/images/refrigerator_small.svg', width: 28.w, height: 28.h,);
    String title = AppLocalizations.of(context)!.location_refrigerator;
    double height = 120.h;

    int doorSensorBattery = 0;

    late SensorInfo doorSensor;
    List<SensorInfo> sensorList = gLocationList[index].getSensors()!;

    bool existDoorSensor = false;
    if (sensorList.isNotEmpty && sensorList[0].getDeviceType() == "door_sensor") {
      existDoorSensor = true;
      doorSensor = sensorList[0];
      doorSensorBattery = sensorList[0].getBattery()!;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Container( //허브 정보
        // color: Colors.blueAccent,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Constants.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h,),
              Row(
                  children: [
                    SizedBox(width: 16.w,),
                    picture,
                    SizedBox(width: 8.w,),
                    Text(title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                    const Spacer(),
                    SizedBox(
                      width: 24.w,
                      height: 24.h,
                      // color: Colors.redAccent,
                      child: IconButton(
                        constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                        padding: EdgeInsets.zero,
                        color: Constants.primaryColor,
                        icon: SvgPicture.asset('assets/images/setting.svg', width: 24.w, height: 24.h),
                        onPressed: () {
                          ref.read(currentLocationProvider.notifier).doChangeState(gLocationList[index]);
                          ref.read(findSensorStateProvider.notifier).doChangeState(FindSensorState.none);

                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return AddSensorFirst(userName: widget.userName, userID: widget.userID, hubID: gHubList[0].getHubID()!,);
                          })).then((onValue) =>
                              setState(() {
                                setState(() {

                                });
                              }));
                        },
                      ),
                    ),
                    SizedBox(width: 16.w,),
                  ]
              ),
              SizedBox(height: 4.h,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 16.h,),
                  const Expanded(
                    child: Divider(color: Color(0xFFDAF1DC), thickness: 1),
                  ),
                  SizedBox(width: 16.h,),
                ],
              ),
              Expanded(
                  child: existDoorSensor
                      ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 16.w,),
                        SvgPicture.asset("assets/images/door_sensor_small.svg", width: 16.w, height: 16.h),
                        SizedBox(width: 16.w,),
                        Text("문열림 센서", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor),),
                        const Spacer(),
                        doorSensorBattery == 0 ? SvgPicture.asset("assets/images/battery_state_high.svg", width: 24.w, height: 24.h) : SvgPicture.asset(
                            "assets/images/battery_state_low.svg", width: 24.w, height: 24.h),
                        SizedBox(width: 16.w,),
                      ]
                  )
                      : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 16.w,),
                        SvgPicture.asset("assets/images/sensor_info_small.svg", width: 16.w, height: 16.h),
                        SizedBox(width: 16.w,),
                        Text("문열림 센서를 연결해주세요.", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor),),
                      ]
                  )
              ),
            ],
          )
      ),
    );
  }

  Widget _getToilet(int index) {
    SvgPicture picture = SvgPicture.asset('assets/images/toilet_small.svg', width: 28.w, height: 28.h,);
    String title = AppLocalizations.of(context)!.location_toilet;
    double height = 120.h;

    late SensorInfo motionSensor;
    List<SensorInfo> sensorList = gLocationList[index].getSensors()!;

    int motionSensorBattery = 0;

    bool existMotionSensor = false;
    if (sensorList.isNotEmpty && sensorList[0].getDeviceType() == "motion_sensor") {
      existMotionSensor = true;
      motionSensor = sensorList[0];
      motionSensorBattery = sensorList[0].getBattery()!;
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Container( //허브 정보
        // color: Colors.blueAccent,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Constants.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h,),
              Row(
                  children: [
                    SizedBox(width: 16.w,),
                    picture,
                    SizedBox(width: 8.w,),
                    Text(title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                    const Spacer(),
                    SizedBox(
                      width: 24.w,
                      height: 24.h,
                      // color: Colors.redAccent,
                      child: IconButton(
                        constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                        padding: EdgeInsets.zero,
                        color: Constants.primaryColor,
                        icon: SvgPicture.asset('assets/images/setting.svg', width: 24.w, height: 24.h),
                        onPressed: () {
                          ref.read(currentLocationProvider.notifier).doChangeState(gLocationList[index]);
                          ref.read(findSensorStateProvider.notifier).doChangeState(FindSensorState.none);

                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return AddSensorFirst(userName: widget.userName, userID: widget.userID, hubID: gHubList[0].getHubID()!,);
                          })).then((onValue) =>
                              setState(() {
                                setState(() {

                                });
                              }));
                        },
                      ),
                    ),
                    SizedBox(width: 16.w,),
                  ]
              ),
              SizedBox(height: 4.h,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 16.h,),
                  const Expanded(
                    child: Divider(color: Color(0xFFDAF1DC), thickness: 1),
                  ),
                  SizedBox(width: 16.h,),
                ],
              ),
              Expanded(
                  child: existMotionSensor
                      ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 16.w,),
                        SvgPicture.asset("assets/images/motion_sensor_small.svg", width: 16.w, height: 16.h),
                        SizedBox(width: 16.w,),
                        Text("움직임 센서", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor),),
                        const Spacer(),
                        motionSensorBattery == 0 ? SvgPicture.asset("assets/images/battery_state_high.svg", width: 24.w, height: 24.h) : SvgPicture.asset(
                            "assets/images/battery_state_low.svg", width: 24.w, height: 24.h),
                        SizedBox(width: 16.w,),
                      ]
                  )
                      : Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 16.w,),
                        SvgPicture.asset("assets/images/sensor_info_small.svg", width: 16.w, height: 16.h),
                        SizedBox(width: 16.w,),
                        Text("움직임 센서를 연결해주세요.", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor),),
                      ]
                  )
              ),
            ],
          )
      ),
    );
  }

  Widget _getEmergency(int index) {
    SvgPicture picture = SvgPicture.asset('assets/images/emergency_small.svg', width: 28.w, height: 28.h,);
    String title = AppLocalizations.of(context)!.location_emergency;
    double height = 120.h;

    late SensorInfo sosSensor;
    List<SensorInfo> sensorList = gLocationList[index].getSensors()!;

    int sosButtonBattery = 0;

    bool existSosSensor = false;
    if (sensorList.isNotEmpty && sensorList[0].getDeviceType() == "emergency_button") {
      existSosSensor = true;
      sosSensor = sensorList[0];
      sosButtonBattery = sensorList[0].getBattery()!;
    }

    return sensorList.isEmpty
        ? Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Container( //허브 정보
        // color: Colors.blueAccent,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Constants.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h,),
              Row(
                  children: [
                    SizedBox(width: 16.w,),
                    picture,
                    SizedBox(width: 8.w,),
                    Text(title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                    const Spacer(),
                    SizedBox(
                      width: 24.w,
                      height: 24.h,
                      // color: Colors.redAccent,
                      child: IconButton(
                        constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                        padding: EdgeInsets.zero,
                        color: Constants.primaryColor,
                        icon: SvgPicture.asset('assets/images/setting.svg', width: 24.w, height: 24.h),
                        onPressed: () {
                          ref.read(currentLocationProvider.notifier).doChangeState(gLocationList[index]);
                          ref.read(findSensorStateProvider.notifier).doChangeState(FindSensorState.none);

                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return AddSensorFirst(userName: widget.userName, userID: widget.userID, hubID: gHubList[0].getHubID()!,);
                          })).then((onValue) =>
                              setState(() {
                                setState(() {

                                });
                              }));
                        },
                      ),
                    ),
                    SizedBox(width: 16.w,),
                  ]
              ),
              SizedBox(height: 4.h,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 16.h,),
                  const Expanded(
                    child: Divider(color: Color(0xFFDAF1DC), thickness: 1),
                  ),
                  SizedBox(width: 16.h,),
                ],
              ),
              Expanded(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 16.w,),
                        SvgPicture.asset("assets/images/sensor_info_small.svg", width: 16.w, height: 16.h),
                        SizedBox(width: 16.w,),
                        Text("SOS 센서를 연결해주세요.", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor),),
                      ]
                  )
              )
            ],
          )
      ),
    )
        : Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        child: Container( //허브 정보
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Constants.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: LimitedBox(
              maxHeight: 152.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h,),
                  Row(
                      children: [
                        SizedBox(width: 16.w,),
                        picture,
                        SizedBox(width: 8.w,),
                        Text(title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                        const Spacer(),
                        SizedBox(
                          width: 24.w,
                          height: 24.h,
                          // color: Colors.redAccent,
                          child: IconButton(
                            constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                            padding: EdgeInsets.zero,
                            color: Constants.primaryColor,
                            icon: SvgPicture.asset('assets/images/setting.svg', width: 24.w, height: 24.h),
                            onPressed: () {
                              ref.read(currentLocationProvider.notifier).doChangeState(gLocationList[index]);
                              ref.read(findSensorStateProvider.notifier).doChangeState(FindSensorState.none);

                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return AddSensorFirst(userName: widget.userName, userID: widget.userID, hubID: gHubList[0].getHubID()!,);
                              })).then((onValue) =>
                                  setState(() {
                                    setState(() {

                                    });
                                  }));
                            },
                          ),
                        ),
                        SizedBox(width: 16.w,),
                      ]
                  ),
                  SizedBox(height: 4.h,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 16.h,),
                      const Expanded(
                        child: Divider(color: Color(0xFFDAF1DC), thickness: 1),
                      ),
                      SizedBox(width: 16.h,),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Flexible(
                    child: Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return _getSensor(sensorList, index);
                        },
                        itemCount: sensorList.length,
                      ),
                    ),
                  ),
                ],
              ),
            )
        )
    );
  }

  Widget _getCustomLocation(int index) {
    SvgPicture picture = SvgPicture.asset('assets/images/new_location.svg', width: 28.w, height: 28.h,);
    String title = gLocationList[index].getName()!;
    double height = 120.h;

    List<SensorInfo> sensorList = gLocationList[index].getSensors()!;

    return sensorList.isEmpty
        ? Padding(
      padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: Container( //허브 정보
        // color: Colors.blueAccent,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Constants.borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h,),
              Row(
                  children: [
                    SizedBox(width: 16.w,),
                    picture,
                    SizedBox(width: 8.w,),
                    Text(title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                    const Spacer(),
                    SizedBox(
                      width: 24.w,
                      height: 24.h,
                      // color: Colors.redAccent,
                      child: IconButton(
                        constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                        padding: EdgeInsets.zero,
                        color: Constants.primaryColor,
                        icon: SvgPicture.asset('assets/images/setting.svg', width: 24.w, height: 24.h),
                        onPressed: () {
                          ref.read(currentLocationProvider.notifier).doChangeState(gLocationList[index]);
                          ref.read(findSensorStateProvider.notifier).doChangeState(FindSensorState.none);

                          Navigator.push(context, MaterialPageRoute(builder: (context) {
                            return AddSensorFirst(userName: widget.userName, userID: widget.userID, hubID: gHubList[0].getHubID()!,);
                          })).then((onValue) =>
                              setState(() {
                                setState(() {

                                });
                              }));
                        },
                      ),
                    ),
                    SizedBox(width: 16.w,),
                  ]
              ),
              SizedBox(height: 4.h,),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 16.h,),
                  const Expanded(
                    child: Divider(color: Color(0xFFDAF1DC), thickness: 1),
                  ),
                  SizedBox(width: 16.h,),
                ],
              ),
              Expanded(
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 16.w,),
                        SvgPicture.asset("assets/images/sensor_info_small.svg", width: 16.w, height: 16.h),
                        SizedBox(width: 16.w,),
                        Text("센서를 연결해주세요.", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor),),
                      ]
                  )
              )
            ],
          )
      ),
    )
        : Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        child: Container( //허브 정보
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Constants.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: LimitedBox(
              maxHeight: 152.h,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 16.h,),
                  Row(
                      children: [
                        SizedBox(width: 16.w,),
                        picture,
                        SizedBox(width: 8.w,),
                        Text(title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                        const Spacer(),
                        SizedBox(
                          width: 24.w,
                          height: 24.h,
                          // color: Colors.redAccent,
                          child: IconButton(
                            constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                            padding: EdgeInsets.zero,
                            color: Constants.primaryColor,
                            icon: SvgPicture.asset('assets/images/setting.svg', width: 24.w, height: 24.h),
                            onPressed: () {
                              ref.read(currentLocationProvider.notifier).doChangeState(gLocationList[index]);
                              ref.read(findSensorStateProvider.notifier).doChangeState(FindSensorState.none);

                              Navigator.push(context, MaterialPageRoute(builder: (context) {
                                return AddSensorFirst(userName: widget.userName, userID: widget.userID, hubID: gHubList[0].getHubID()!,);
                              })).then((onValue) =>
                                  setState(() {
                                    setState(() {

                                    });
                                  }));
                            },
                          ),
                        ),
                        SizedBox(width: 16.w,),
                      ]
                  ),
                  SizedBox(height: 4.h,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox(width: 16.h,),
                      const Expanded(
                        child: Divider(color: Color(0xFFDAF1DC), thickness: 1),
                      ),
                      SizedBox(width: 16.h,),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Flexible(
                    child: Container(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemBuilder: (BuildContext context, int index) {
                          return _getSensor(sensorList, index);
                        },
                        itemCount: sensorList.length,
                      ),
                    ),
                  ),
                ],
              ),
            )
        )
    );
  }

  Widget _getSensor(List<SensorInfo> sensorList, int index) {
    SensorInfo sensor = sensorList[index];

    late SvgPicture picture;
    late SvgPicture batteryPicture;
    String title = '';

    batteryPicture = sensor.getBattery()! == 0
        ? SvgPicture.asset("assets/images/battery_state_high.svg", width: 24.w, height: 24.h)
        : SvgPicture.asset("assets/images/battery_state_low.svg", width: 24.w, height: 24.h);

    if (sensor.getDeviceType() == 'door_sensor') {
      picture = SvgPicture.asset("assets/images/door_sensor_small.svg", width: 16.w, height: 16.h);
      title = "문열림 센서";
    } else if (sensor.getDeviceType() == 'motion_sensor') {
      picture = SvgPicture.asset("assets/images/motion_sensor_small.svg", width: 16.w, height: 16.h);
      title = "움직임 센서";
    } else if (sensor.getDeviceType() == 'emergency_button') {
      picture = SvgPicture.asset("assets/images/emergency_small.svg", width: 16.w, height: 16.h);
      title = "SOS 센서";
    }

    return Column(
      children: [
        SizedBox(height: 5.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(width: 16.w,),
            picture,
            SizedBox(width: 16.w,),
            Text(title, style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor),),
            const Spacer(),
            batteryPicture,
            SizedBox(width: 16.w,),
          ]
        ),
      ],
    );
  }

  void _delHub() {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Constants.scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: EdgeInsets.all(20.w),
            child: const CustomConfirmDialog(title: "허브 제거", message:'허브 제거를 하면 모든 센서의 이력이 모두 지워집니다. 그래도 진행하시겠습니까?'),
          );
        }
    ).then((val) async {
      if (val != 'Cancel') {
        mqttSendCommand(MqttCommand.mcInitHub, gHubList[0].getHubID()!);


      }
    });
  }


}