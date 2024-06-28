// import 'package:argoscareseniorsafeguard/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/pages/add_sensor_page1.dart';
import 'package:argoscareseniorsafeguard/pages/add_hub_page1.dart';
import 'package:argoscareseniorsafeguard/pages/device_detail_view.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/models/device.dart';
import 'package:argoscareseniorsafeguard/models/hub.dart';
import 'package:argoscareseniorsafeguard/models/sensor.dart';
import 'package:argoscareseniorsafeguard/models/sensor_infos.dart';
import 'package:argoscareseniorsafeguard/models/location_infos.dart';
import 'package:argoscareseniorsafeguard/components/my_container.dart';
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
  /*final List<String> _actionList = ['허브 등록', '센서 등록'];
  int _selectIndex = 0;
  final List<Hub> _hubList = [];*/

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
                    Text(AppLocalizations.of(context)!.app_title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
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
                      Text("내 기기", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
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

                            })).then((onValue) => setState(() {

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
                                Text("허브", style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
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
                                : Text("연결됨", style: TextStyle(fontSize: 12.sp, color: Constants.primaryColor, ), ),
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
                                    ? Text("허브를 설치해 주세요.", style: TextStyle(fontSize: 12.sp, color: Constants.dividerColor, fontWeight: FontWeight.bold), )
                                    : Text('${gHubList[0].getCreatedAt()!.substring(0, 10)} 설치', style: TextStyle(fontSize: 12.sp, color: Constants.dividerColor), ),

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

    for (var s in sensorList) {
      if (s.getDeviceType() == "door_sensor") { //emergency_button
        doorSensor = s;
        existDoorSensor = true;
      } else if (s.getDeviceType() == "motion_sensor") {
        motionSensor = s;
        existMotionSensor = true;
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
                    Text(title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
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
                          })).then((onValue) => setState(() {
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
                        Text("문열림 센서", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor), ),
                        const Spacer(),
                        SvgPicture.asset("assets/images/battery_state_high.svg", width: 24.w, height: 24.h),
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
                        Text("문열림 센서를 연결해주세요.", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor), ),
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
                        Text("움직임 센서", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor), ),
                        const Spacer(),
                        SvgPicture.asset("assets/images/battery_state_high.svg", width: 24.w, height: 24.h),
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
                        Text("움직임 센서를 연결해주세요.", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor), ),
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

    late SensorInfo doorSensor;
    List<SensorInfo> sensorList = gLocationList[index].getSensors()!;

    bool existDoorSensor = false;
    if (sensorList.isNotEmpty && sensorList[0].getDeviceType() == "door_sensor") {
      existDoorSensor = true;
      doorSensor = sensorList[0];
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
                    Text(title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
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
                          })).then((onValue) => setState(() {
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
                        Text("문열림 센서", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor), ),
                        const Spacer(),
                        SvgPicture.asset("assets/images/battery_state_high.svg", width: 24.w, height: 24.h),
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
                        Text("문열림 센서를 연결해주세요.", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor), ),
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

    bool existMotionSensor = false;
    if (sensorList.isNotEmpty && sensorList[0].getDeviceType() == "motion_sensor") {
      existMotionSensor = true;
      motionSensor = sensorList[0];
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
                    Text(title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
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
                          })).then((onValue) => setState(() {
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
                        Text("움직임 센서", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor), ),
                        const Spacer(),
                        SvgPicture.asset("assets/images/battery_state_high.svg", width: 24.w, height: 24.h),
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
                        Text("움직임 센서를 연결해주세요.", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor), ),
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

    bool existSosSensor = false;
    if (sensorList.isNotEmpty && sensorList[0].getDeviceType() == "emergency_button") {
      existSosSensor = true;
      sosSensor = sensorList[0];
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
                    Text(title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
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
                          })).then((onValue) => setState(() {
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
                  child: existSosSensor
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(width: 16.w,),
                        SvgPicture.asset("assets/images/door_sensor_small.svg", width: 16.w, height: 16.h),
                        SizedBox(width: 16.w,),
                        Text("SOS 센서", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor), ),
                        const Spacer(),
                        SvgPicture.asset("assets/images/battery_state_high.svg", width: 24.w, height: 24.h),
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
                        Text("SOS 센서를 연결해주세요.", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor), ),
                      ]
                  )
              ),
            ],
          )
      ),
    );
  }

  Widget _getCustomLocation(int index) {
    SvgPicture picture = SvgPicture.asset('assets/images/new_location.svg', width: 28.w, height: 28.h,);
    String title = gLocationList[index].getName()!;
    double height = 120.h;

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
                    Text(title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
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
                          })).then((onValue) => setState(() {
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
                        Text("문열림 이나 움직임 센서를 연결해주세요.", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor), ),
                      ]
                  )
              ),
            ],
          )
      ),
    );
  }

  /*Widget waitWidget() {
    return const CircularProgressIndicator(backgroundColor: Colors.blue);
  }*/

  /*Widget myListTile(BuildContext context, Device device) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _getDeviceIcon(device),
            const SizedBox(width: 10, height: 40),
            Text(device.getDeviceName()!, style: TextStyle(fontSize: deviceFontSize,)),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () { _goDeviceDetailView(context, device); },
                    child: const Icon(Icons.chevron_right, size: 20, color: Colors.black),
                  ),
                ],
              ),
            )
          ],
        )
      )
    );
  }*/

  /*void _goDeviceDetailView(BuildContext context, Device device) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return DeviceDetailView(device: device, userID: widget.userID);
    })).then((value) {
      setState(() {

      });
    });
  }*/

  /*Widget _getDeviceIcon(Device device) {
    if (device.getDeviceType() == Constants.DEVICE_TYPE_HUB) {
      return const Icon(Icons.sensors);
    } else if (device.getDeviceType() == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
      return const Icon(Icons.device_thermostat);
    } else if (device.getDeviceType() == Constants.DEVICE_TYPE_SMOKE) {
      return const Icon(Icons.local_fire_department);
    } else if (device.getDeviceType() == Constants.DEVICE_TYPE_EMERGENCY) {
      return const Icon(Icons.medical_services);
    } else if (device.getDeviceType() == Constants.DEVICE_TYPE_ILLUMINANCE) {
      return const Icon(Icons.light);
    } else if (device.getDeviceType() == Constants.DEVICE_TYPE_MOTION) {
      return const Icon(Icons.directions_run);
    } else if (device.getDeviceType() == Constants.DEVICE_TYPE_DOOR) {
      return const Icon(Icons.meeting_room);
    } else {
      return const Icon(Icons.help);
    }
  }*/

  /*void _action(BuildContext context, WidgetRef ref) {
    if (_hubList.isEmpty) {
      _goAddHubPage(context, ref);
    } else {
      if (_hubList.length == 1) {
        _goAddSensePage(context, ref);
      } else {
        showActionDialog(context, ref);
      }
    }
  }*/

  /*void _goParingPage(BuildContext context, WidgetRef ref) {
    if (_selectIndex == 0) {
      _goAddHubPage(context, ref);
    } else {
      _goAddSensePage(context, ref);
    }
  }*/

  /*void _goAddHubPage(BuildContext context, WidgetRef ref) {
    ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.none);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const AddHubPage1();
    })).then((value) {
      setState(() {

      });
    });
    // _showFindHubModalSheet();
  }*/

  /*void _showFindHubModalSheet() {
    showModalBottomSheet<void>(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        isDismissible: false,
        enableDrag: false,
        builder: (BuildContext context) {
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
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(outPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              color: Theme.of(context).colorScheme.primary
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Pairing 버튼을 10초간 길게 누르세요\n'
                            '삐 소리가 연속적으로 5번 울립니다.\n'
                            'LED가 보라색으로 변합니다.\n'
                            '모두 준비되면 [허브 검색]을 탭하세요',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            elevation: 5, //
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        child: const Text('허브 검색'),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),
              ),
            )
          );
        }
    );
  }*/

  /*void _goAddSensePage(BuildContext context, WidgetRef ref, LocationInfo? location) {
    ref.read(currentLocationProvider.notifier).doChangeState(location!);
    ref.read(findHubStateProvider.notifier).doChangeState(FindHubState.none);

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddSensorPage1(deviceID: gHubList[0].getHubID()!, userID: widget.userID,);
      *//*if (location == null) {
        return AddSensorPage1(deviceID: deviceID!);
      } else {
        //gCurrentLocation = location;
        // ref.read(currentLocationProvider.notifier).changeData(location);

        return AddSensorPage1(deviceID: deviceID!);
      }*//*

    })).then((value) {
      setState(() {

      });
    });
  }*/

  /*void showActionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text("기기 선택"),
              content: SizedBox(
                width: 150,
                height: 100,
                child: ListView.builder(
                    itemCount: _actionList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return RadioListTile<int>(
                        value: index,
                        groupValue: _selectIndex,
                        title: Text(_actionList[index]),
                        onChanged: (value) {
                          setState((){
                            _selectIndex = value??0;
                          });
                        },
                      );
                    }),
              ),
              actions: [
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                      });
                    },
                    child: const Text("Cancel")
                ),
                ElevatedButton(
                    onPressed: () {
                      setState(() {
                        Navigator.pop(context);
                        _goParingPage(context, ref);
                      });
                    },
                    child: const Text("Ok")
                ),
              ],
            );
          }
        );
      }
    );
  }*/

  /*Widget _getCards(BuildContext context, WidgetRef ref, int index) {
    bool enable = false;
    late LocationInfo location;

    location = gLocationList[index];
    if (location.getType()! == 'emergency' || location.getType()! == 'customer') {
      enable = true;
    } else {
      if ((location.getRequireDoorSensorCount()! > location.getDetectedDoorSensorCount()!) || location.getRequireMotionSensorCount()! > location.getDetectedMotionSensorCount()!)  {
        enable = true;
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          location.getName()!,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer,),
        ),
        const SizedBox(height: outPadding),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: enable ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSecondaryContainer,//Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: enable ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondaryContainer, // text color
                    elevation: 5, //
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: enable
                    ? () { _goAddSensePage(context, ref, gLocationList[index]); }
                    : null,
                child: const Text('등록')
            )
          ],
        )
      ],
    );
  }*/

  /*Widget _topCard(BuildContext context, WidgetRef ref) {
    String title = gHubList.isEmpty ? '허브가 등록되지 않았습니다.' : '허브';
    String buttonTitle = gHubList.isEmpty ? '허브 등록' : '등록됨';

    return MyContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                  title,
                ),
              ],
            ),

            const SizedBox(height: outPadding),

            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: gHubList.isEmpty ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSecondaryContainer,
                          backgroundColor: gHubList.isEmpty ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondaryContainer, // text color
                          elevation: 5, //
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      onPressed: gHubList.isEmpty ?  () => _goAddHubPage(context, ref) : null,
                      child: Text(buttonTitle)
                  )

                ],
            ),

            const SizedBox(height: 10,),
          ],
        ),
    );
  }*/
}

/*

Future<List<Device>> _getDeviceList() async {
    DBHelper sd = DBHelper();

    _hubList.clear();

    List<Hub> hubList = await sd.getHubs();
    List<Sensor> sensorList = await sd.getSensors(widget.userID);
    List<Device> deviceList = [];

    for (Hub hub in hubList) {
      Device device = Device(
          deviceID: hub.getHubID(),
          deviceType: hub.getDeviceType(),
          deviceName: hub.getName(),
          displaySunBun: hub.getDisplaySunBun(),
          userID: "",
          status: "",
          shared: 0,
          ownerID: '',
          ownerName: '',
          updatedAt: hub.getUpdatedAt(),
          createdAt: hub.getCreatedAt()
      );
      deviceList.add(device);
      _hubList.add(hub);
    }

    for (Sensor sensor in sensorList) {
      Device device = Device(
          deviceID: sensor.getSensorID(),
          deviceType: sensor.getDeviceType(),
          deviceName: sensor.getName(),
          displaySunBun: sensor.getDisplaySunBun(),
          userID: "",
          status: "",
          shared: 0,
          ownerID: '',
          ownerName: '',
          updatedAt: sensor.getUpdatedAt(),
          createdAt: sensor.getCreatedAt()
      );
      deviceList.add(device);
    }

    return deviceList;
  }

class _TopCard extends StatelessWidget {
  const _TopCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10,),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '허브가 등록되지 않았습니다.',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),

            ],
          ),
          const SizedBox(height: outPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary, // text color
                      elevation: 5, //
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  onPressed: (){
                    _goAddHubPage(context, ref);
                    */
/*Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return const AddHubPage2();
                        }));*//*

                  },//findHub,
                  child: const Text('허브 등록')
              )
            ],
          ),
          const SizedBox(height: 10,),
        ],
      ),
    );
  }
}

*/
