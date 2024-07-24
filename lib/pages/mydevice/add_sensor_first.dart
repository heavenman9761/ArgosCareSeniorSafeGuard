import 'dart:async';
import 'dart:convert';

import 'package:argoscareseniorsafeguard/dialogs/custom_confirm_dialog.dart';
import 'package:argoscareseniorsafeguard/models/alarm_infos.dart';
import 'package:argoscareseniorsafeguard/models/sensor_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/models/location_infos.dart';
import 'package:argoscareseniorsafeguard/models/sensor_infos.dart';
import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/pages/mydevice/add_sensor_second.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_alert_dialog.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_radiobuttonlist_dialog.dart';


class AddSensorFirst extends ConsumerStatefulWidget {
  const AddSensorFirst({super.key, required this.userName, required this.userID, required this.hubID});

  final String userName;
  final String userID;
  final String hubID;

  @override
  ConsumerState<AddSensorFirst> createState() => _AddSensorFirstState();
}

class _AddSensorFirstState extends ConsumerState<AddSensorFirst> {
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    controller.text = ref.watch(currentLocationProvider)!.getName()!;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox( //이전 페이지 버튼
              // color: Colors.blueAccent,
              height: 52.h,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      // color: Colors.redAccent,
                      child: IconButton(
                        constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                        padding: EdgeInsets.zero,
                        color: Colors.black,
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    )
                  ],
                ),
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
                    Text("센서 등록", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
                  ],
                ),
              ),
            ),
            SizedBox(
              // color: Colors.redAccent,
                height: 40.h,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                  child: Row(
                    children: [
                      Text("장소명", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040)), ),
                    ],
                  ),
                )
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
              child: Container(
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(color: Constants.borderColor),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                          children: [
                            Text(ref.watch(currentLocationProvider)!.getName()!, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF0F0F0F), )),
                          ]
                      ),
                    ],
                  ),
                ),
              ),
            ),


            SizedBox(
              // color: Colors.redAccent,
                height: 40.h,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                  child: Row(
                    children: [
                      Text("센서정보", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040)), ),
                    ],
                  ),
                )
            ),

            _getSensorInfo(),

            _getButton()
          ],
        )
      )
    );
  }

  Widget _addSensorBtn() {
    return Padding(
      padding: EdgeInsets.all(20.0.h),
      child: MyButton(
        text: "센서추가",
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) {
            return AddSensorSecond(userName: widget.userName, userID: widget.userID, hubID: widget.hubID);
          })).then((onValue) => setState(() {
            setState(() {

            });
          }));
        },
      ),
    );
  }

  Widget _getButton() {
    LocationInfo locationInfo = ref.watch(currentLocationProvider)!;
    print(locationInfo);
    if (locationInfo.getType()! == 'emergency' || locationInfo.getType()! == 'customer') {
      return _addSensorBtn();

    } else {
      if (locationInfo.getRequireDoorSensorCount()! > locationInfo.getDetectedDoorSensorCount()! ||
          locationInfo.getRequireMotionSensorCount()! > locationInfo.getDetectedMotionSensorCount()!) {
        return _addSensorBtn();

      } else {  //센서 추가 비활성화
        return Padding(
          padding: EdgeInsets.all(20.0.h),
          child: Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Constants.dividerColor, //const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text("센서추가", style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12.sp,),
              ),
            ),
          )
        );
      }
    }
  }

  Widget _getSensorInfo() {
    LocationInfo locationInfo = ref.watch(currentLocationProvider)!;
    if (locationInfo.getType() == "entrance") {
      return _getEntranceSensorsInfo();

    } else if (locationInfo.getType() == "refrigerator") {
      return _getRefrigeratorSensorsInfo();

    } else if (locationInfo.getType() == "toilet") {
      return _getToiletSensorsInfo();

    } else if (locationInfo.getType() == "emergency") {
      return _getEmergencySensorsInfo();

    } else if (locationInfo.getType() == "customer") {
      return _getCustomerSensorsInfo();

    } else {
      return const SizedBox();
    }
  }

  Widget _getEntranceSensorsInfo() {
    late SensorInfo doorSensor;
    late SensorInfo motionSensor;
    List<SensorInfo> sensorList = ref.watch(currentLocationProvider)!.getSensors()!;

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

    return Expanded(
      child: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                child: Container(
                  height: 125.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Constants.borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                            children: [
                              Icon(Icons.sensor_door_outlined, size: 16.w,),
                              SizedBox(width: 5.w),
                              Text("문열림 센서", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                              existDoorSensor ? const Spacer() : const SizedBox(),
                              existDoorSensor
                              ? SizedBox(
                                  width: 52.w, height: 24.h,
                                  child: TextButton(
                                    onPressed: (){},
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: _showMoveSensorWidget(doorSensor)
                                  ),
                                )
                              : const SizedBox(),
                              existDoorSensor ? SizedBox(width: 10.w) : const SizedBox(),
                              existDoorSensor
                              ? _showRemoveSensorWidget(doorSensor)
                              : const SizedBox(),
                            ]
                        ),

                        const Divider(),
                        Row(
                          children: [
                            SvgPicture.asset("assets/images/install_date_small.svg", width: 16.w, height: 16.h),
                            SizedBox(width: 5.w,),
                            Text("설치일자", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                            const Spacer(),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  existDoorSensor
                                      ? Text(doorSensor.getCreatedAt()!.substring(0, 16), style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), ))
                                      : Text("설치되지 않음", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), ))
                                ]
                            )
                          ],
                        ),
                        SizedBox(height: 10.h,),
                        Row(
                          children: [
                            SvgPicture.asset("assets/images/sensor_info_small.svg", width: 16.w, height: 16.h),
                            SizedBox(width: 5.w,),
                            Text("ID", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                            const Spacer(),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  existDoorSensor
                                    ? Text(doorSensor.getSensorID()!, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), ))
                                    : Text("설치되지 않음", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                                  existDoorSensor ? SizedBox(width: 5.w) : const SizedBox(),
                                  existDoorSensor
                                    ?  SizedBox(
                                        // color: Colors.redAccent,
                                        width: 16.w, height: 16.h,
                                        child: IconButton(
                                          constraints: const BoxConstraints(maxHeight: 16, maxWidth: 16),
                                          splashRadius: 16,
                                          padding: EdgeInsets.zero,
                                          icon: Icon(Icons.copy, size: 16.w,),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(text: doorSensor.getSensorID()!));
                                          },
                                        ),
                                      )
                                    : const SizedBox()
                                ]
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              SizedBox(height: 16.h,),

              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                child: Container(
                  height: 125.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Constants.borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                            children: [
                              Icon(Icons.sensor_door_outlined, size: 16.w,),
                              SizedBox(width: 5.w),
                              Text("움직임 센서", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                              existMotionSensor ? const Spacer() : const SizedBox(),
                              existMotionSensor
                                ? SizedBox(
                                  width: 52.w, height: 24.h,
                                  child: TextButton(
                                    onPressed: (){},
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: _showMoveSensorWidget(motionSensor)
                                  ),
                                )
                              : const SizedBox(),
                              existMotionSensor ? SizedBox(width: 10.w) : const SizedBox(),
                              existMotionSensor
                                ? _showRemoveSensorWidget(motionSensor)
                              : const SizedBox(),
                            ]
                        ),

                        const Divider(),
                        Row(
                          children: [
                            SvgPicture.asset("assets/images/install_date_small.svg", width: 16.w, height: 16.h),
                            SizedBox(width: 5.w,),
                            Text("설치일자", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                            const Spacer(),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  existMotionSensor
                                    ? Text(motionSensor.getCreatedAt()!.substring(0, 16), style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), ))
                                    : Text("설치되지 않음", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), ))
                                ]
                            )
                          ],
                        ),
                        SizedBox(height: 10.h,),
                        Row(
                          children: [
                            SvgPicture.asset("assets/images/sensor_info_small.svg", width: 16.w, height: 16.h),
                            SizedBox(width: 5.w,),
                            Text("ID", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                            const Spacer(),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  existMotionSensor
                                    ? Text(motionSensor.getSensorID()!, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), overflow: TextOverflow.ellipsis, ))
                                    : Text("설치되지 않음", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                                  existMotionSensor ? SizedBox(width: 5.w) : const SizedBox(),
                                  existMotionSensor
                                    ? Container(
                                        // color: Colors.redAccent,
                                        width: 16.w, height: 16.h,
                                        child: IconButton(
                                          constraints: const BoxConstraints(maxHeight: 16, maxWidth: 16),
                                          splashRadius: 16,
                                          padding: EdgeInsets.zero,
                                          icon: Icon(Icons.copy, size: 16.w,),
                                          onPressed: () {
                                            Clipboard.setData(ClipboardData(text: motionSensor.getSensorID()!));
                                          },
                                        ),
                                      )
                                  : const SizedBox()
                                ]
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getRefrigeratorSensorsInfo() {
    late SensorInfo doorSensor;
    List<SensorInfo> sensorList = ref.watch(currentLocationProvider)!.getSensors()!;

    bool existDoorSensor = false;

    for (var s in sensorList) {
      if (s.getDeviceType() == "door_sensor") { //emergency_button
        doorSensor = s;
        existDoorSensor = true;
      }
    }

    return Expanded(
      child: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                child: Container(
                  height: 125.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Constants.borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                            children: [
                              Icon(Icons.sensor_door_outlined, size: 16.w,),
                              SizedBox(width: 5.w),
                              Text("문열림 센서", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                              existDoorSensor ? const Spacer() : const SizedBox(),
                              existDoorSensor
                              ?  SizedBox(
                                  width: 52.w, height: 24.h,
                                  child: TextButton(
                                    onPressed: (){},
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: _showMoveSensorWidget(doorSensor)
                                  ),
                                )
                              : const SizedBox(),
                              existDoorSensor ? SizedBox(width: 10.w) : const SizedBox(),
                              existDoorSensor
                              ?  _showRemoveSensorWidget(doorSensor)
                              : const SizedBox(),
                            ]
                        ),

                        const Divider(),
                        Row(
                          children: [
                            SvgPicture.asset("assets/images/install_date_small.svg", width: 16.w, height: 16.h),
                            SizedBox(width: 5.w,),
                            Text("설치일자", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                            const Spacer(),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  existDoorSensor
                                      ? Text(doorSensor.getCreatedAt()!.substring(0, 16), style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), ))
                                      : Text("설치되지 않음", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), ))
                                ]
                            )
                          ],
                        ),
                        SizedBox(height: 10.h,),
                        Row(
                          children: [
                            SvgPicture.asset("assets/images/sensor_info_small.svg", width: 16.w, height: 16.h),
                            SizedBox(width: 5.w,),
                            Text("ID", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                            const Spacer(),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  existDoorSensor
                                      ? Text(doorSensor.getSensorID()!, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), ))
                                      : Text("설치되지 않음", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                                  existDoorSensor ? SizedBox(width: 5.w) : const SizedBox(),
                                  existDoorSensor
                                  ?  Container(
                                      // color: Colors.redAccent,
                                      width: 16.w, height: 16.h,
                                      child: IconButton(
                                        constraints: const BoxConstraints(maxHeight: 16, maxWidth: 16),
                                        splashRadius: 16,
                                        padding: EdgeInsets.zero,
                                        icon: Icon(Icons.copy, size: 16.w,),
                                        onPressed: () {
                                          Clipboard.setData(ClipboardData(text: doorSensor.getSensorID()!));
                                        },
                                      ),
                                    )
                                  : const SizedBox()
                                ]
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getToiletSensorsInfo() {
    late SensorInfo motionSensor;
    List<SensorInfo> sensorList = ref.watch(currentLocationProvider)!.getSensors()!;

    bool existMotionSensor = false;

    for (var s in sensorList) {
      if (s.getDeviceType() == "motion_sensor") { //emergency_button
        motionSensor = s;
        existMotionSensor = true;
      }
    }

    return Expanded(
      child: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                child: Container(
                  height: 125.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Constants.borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                            children: [
                              Icon(Icons.sensor_door_outlined, size: 16.w,),
                              SizedBox(width: 5.w),
                              Text("움직임 센서", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                              existMotionSensor ? const Spacer() : const SizedBox(),
                              existMotionSensor
                              ? SizedBox(
                                  width: 52.w, height: 24.h,
                                  child: TextButton(
                                    onPressed: (){},
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                    ),
                                    child: _showMoveSensorWidget(motionSensor)
                                  ),
                                )
                              : const SizedBox(),
                              existMotionSensor ? SizedBox(width: 10.w) : const SizedBox(),
                              existMotionSensor
                              ? _showRemoveSensorWidget(motionSensor)
                              : const SizedBox(),
                            ]
                        ),

                        const Divider(),
                        Row(
                          children: [
                            SvgPicture.asset("assets/images/install_date_small.svg", width: 16.w, height: 16.h),
                            SizedBox(width: 5.w,),
                            Text("설치일자", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                            const Spacer(),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  existMotionSensor
                                      ? Text(motionSensor.getCreatedAt()!.substring(0, 16), style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), ))
                                      : Text("설치되지 않음", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), ))
                                ]
                            )
                          ],
                        ),
                        SizedBox(height: 10.h,),
                        Row(
                          children: [
                            SvgPicture.asset("assets/images/sensor_info_small.svg", width: 16.w, height: 16.h),
                            SizedBox(width: 5.w,),
                            Text("ID", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                            const Spacer(),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  existMotionSensor
                                      ? Text(motionSensor.getSensorID()!, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), ))
                                      : Text("설치되지 않음", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                                  existMotionSensor ? SizedBox(width: 5.w) : const SizedBox(),
                                  existMotionSensor
                                      ?  SizedBox(
                                            // color: Colors.redAccent,
                                            width: 16.w, height: 16.h,
                                            child: IconButton(
                                              constraints: const BoxConstraints(maxHeight: 16, maxWidth: 16),
                                              splashRadius: 16,
                                              padding: EdgeInsets.zero,
                                              icon: Icon(Icons.copy, size: 16.w,),
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(text: motionSensor.getSensorID()!));
                                              },
                                            ),
                                          )
                                      : const SizedBox()
                                ]
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getEmergencySensorsInfo() {
    late SensorInfo sosSensor;
    List<SensorInfo> sensorList = ref.watch(currentLocationProvider)!.getSensors()!;
    List<SensorInfo> sosSensors = [];

    for (var s in sensorList) {
      if (s.getDeviceType() == "emergency_button") { //emergency_button
        sosSensors.add(s);
      }
    }

    if (sosSensors.isNotEmpty) {
      return Expanded(
        child: SizedBox(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                  child: Container(
                    height: 350.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Constants.borderColor),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          Row(
                              children: [
                                Icon(Icons.sensor_door_outlined, size: 16.w,),
                                SizedBox(width: 5.w),
                                Text("SOS 센서", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                              ]
                          ),

                          const Divider(),

                          Container(
                            height: 260.h,
                            child: ListView.builder(
                              itemCount: sosSensors.length,
                              itemBuilder: (ctx, index) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                      children: [
                                        SvgPicture.asset("assets/images/install_date_small.svg", width: 16.w, height: 16.h),
                                        SizedBox(width: 5.w,),
                                        Text("설치일자", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                                        const Spacer(),
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(sosSensors[index].getCreatedAt()!.substring(0, 16), style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), ))
                                            ]
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 10.h,),
                                    Row(
                                      children: [
                                        SvgPicture.asset("assets/images/sensor_info_small.svg", width: 16.w, height: 16.h),
                                        SizedBox(width: 5.w,),
                                        Text("ID", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                                        const Spacer(),
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(sosSensors[index].getSensorID()!, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                                              SizedBox(width: 5.w),
                                              Container(
                                                // color: Colors.redAccent,
                                                width: 16.w, height: 16.h,
                                                child: IconButton(
                                                  constraints: const BoxConstraints(maxHeight: 16, maxWidth: 16),
                                                  splashRadius: 16,
                                                  padding: EdgeInsets.zero,
                                                  icon: Icon(Icons.copy, size: 16.w,),
                                                  onPressed: () {
                                                    Clipboard.setData(ClipboardData(text: sosSensors[index].getSensorID()!));
                                                  },
                                                ),
                                              )
                                            ]
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 5.h,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        SizedBox(
                                          width: 52.w, height: 24.h,
                                          child: TextButton(
                                            onPressed: (){},
                                            style: TextButton.styleFrom(
                                              padding: EdgeInsets.zero,
                                            ),
                                            child: _showMoveSensorWidget(sosSensors[index])
                                          ),
                                        ),
                                        SizedBox(width: 10.w),
                                        _showRemoveSensorWidget(sosSensors[index])
                                      ],
                                    ),
                                    SizedBox(height: 10.h,),
                                  ],
                                );
                              }
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return _notExistSosSensors();
    }
  }

  Widget _notExistSosSensors() {
    return Expanded(
      child: SizedBox(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                child: Container(
                  height: 120.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Constants.borderColor),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                            children: [
                              Icon(Icons.emergency, size: 16.w,),
                              SizedBox(width: 5.w),
                              Text("SOS 버튼", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                            ]
                        ),

                        const Divider(),
                        Row(
                          children: [
                            SvgPicture.asset("assets/images/install_date_small.svg", width: 16.w, height: 16.h),
                            SizedBox(width: 5.w,),
                            Text("설치일자", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                            const Spacer(),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("설치되지 않음", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                                ]
                            )
                          ],
                        ),
                        SizedBox(height: 10.h,),
                        Row(
                          children: [
                            SvgPicture.asset("assets/images/sensor_info_small.svg", width: 16.w, height: 16.h),
                            SizedBox(width: 5.w,),
                            Text("ID", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                            const Spacer(),
                            Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Text("설치되지 않음", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                                ]
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCustomerSensorsInfo() {
    List<SensorInfo> sensorList = ref.watch(currentLocationProvider)!.getSensors()!;

    if (sensorList.isNotEmpty) {
      return Expanded(
        child: SizedBox(
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    child: Container(
                      height: 350.h,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Constants.borderColor),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          height: 260.h,
                          child: ListView.builder(
                              itemCount: sensorList.length,
                              itemBuilder: (ctx, index) {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Row(
                                        children: [
                                          Icon(Icons.sensor_door_outlined, size: 16.w,),
                                          SizedBox(width: 5.w),
                                          Text(_getCustomSensorName(sensorList[index]), style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                                        ]
                                    ),

                                    const Divider(),
                                    Row(
                                      children: [
                                        SvgPicture.asset("assets/images/install_date_small.svg", width: 16.w, height: 16.h),
                                        SizedBox(width: 5.w,),
                                        Text("설치일자", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                                        const Spacer(),
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(sensorList[index].getCreatedAt()!.substring(0, 16), style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), ))
                                            ]
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 10.h,),
                                    Row(
                                      children: [
                                        SvgPicture.asset("assets/images/sensor_info_small.svg", width: 16.w, height: 16.h),
                                        SizedBox(width: 5.w,),
                                        Text("ID", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                                        const Spacer(),
                                        Row(
                                            mainAxisAlignment: MainAxisAlignment.end,
                                            children: [
                                              Text(sensorList[index].getSensorID()!, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
                                              SizedBox(width: 5.w),
                                              Container(
                                                // color: Colors.redAccent,
                                                width: 16.w, height: 16.h,
                                                child: IconButton(
                                                  constraints: const BoxConstraints(maxHeight: 16, maxWidth: 16),
                                                  splashRadius: 16,
                                                  padding: EdgeInsets.zero,
                                                  icon: Icon(Icons.copy, size: 16.w,),
                                                  onPressed: () {
                                                    Clipboard.setData(ClipboardData(text: sensorList[index].getSensorID()!));
                                                  },
                                                ),
                                              )
                                            ]
                                        ),

                                      ],
                                    ),
                                    SizedBox(height: 5.h,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        _showMoveSensorWidget(sensorList[index]),

                                        SizedBox(width: 10.w),
                                        _showRemoveSensorWidget(sensorList[index])
                                      ],
                                    ),
                                    SizedBox(height: 10.h)
                                  ],
                                );
                              }
                          ),
                        ),
                      ),
                    )
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return const Spacer();
    }
  }

  Widget _showRemoveSensorWidget(SensorInfo sensor) {
    return SizedBox(
      width: 24.w, height: 24.h,
      child: TextButton(
        onPressed: (){
          showDialog(
              barrierDismissible: false,
              context: context,
              builder: (context) {
                return Dialog(
                  backgroundColor: Constants.scaffoldBackgroundColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  insetPadding: EdgeInsets.all(20.w),
                  child: const CustomConfirmDialog(title: "센서 제거", message:'센서 제거를 하면 해당 센서의 이력이 모두 지워집니다. 그래도 진행하시겠습니까?'),
                );
              }
          ).then((val) async {
            if (val != 'Cancel') {
              try {
                final response = await dio.post(
                    "/devices/removeSensor",
                    data: jsonEncode({
                      "userID": widget.userID,
                      "sensorID": sensor.getID(),
                      "locationID": ref.watch(currentLocationProvider)!.getID(),
                    })
                );

                if (response.statusCode == 200) {
                  _processSuccess(response);

                }
              } catch(e) {
                print(e);
              }
            }
          });
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        child: Text("제거", style: TextStyle(fontSize: 12.sp, color: Colors.redAccent, )
        ),
      ),
    );
  }

  Widget _showMoveSensorWidget(SensorInfo sensor) {
    List<String> list = [];

    if (sensor.getDeviceType()! == 'door_sensor') {
      for (var location in gLocationList) {
        if (location.getType() == 'entrance' || location.getType() == 'refrigerator') {
          if (location.getRequireDoorSensorCount()! > location.getDetectedDoorSensorCount()!) {
            if (ref.watch(currentLocationProvider)!.getType()! != location.getType()!) {
              list.add(location.getName()!);
            }
          }

        } else if (location.getType() == 'customer') {
          if (ref.watch(currentLocationProvider)!.getType()! != location.getType()!) {
            list.add(location.getName()!);
          }

        }
      }

    } else if (sensor.getDeviceType()! == 'motion_sensor') {
      for (var location in gLocationList) {
        if (location.getType() == 'entrance' || location.getType() == 'toilet') {
          if (location.getRequireMotionSensorCount()! > location.getDetectedMotionSensorCount()!) {
            if (ref.watch(currentLocationProvider)!.getType()! != location.getType()!) {
              list.add(location.getName()!);
            }

          }

        } else if (location.getType() == 'customer') {
          if (ref.watch(currentLocationProvider)!.getType()! != location.getType()!) {
            list.add(location.getName()!);
          }

        }
      }

    } else if (sensor.getDeviceType()! == 'emergency_button') {
      for (var location in gLocationList) {
        if (location.getType() == 'emergency' || location.getType() == 'customer') {
          if (ref.watch(currentLocationProvider)!.getType()! != location.getType()!) {
            list.add(location.getName()!);
          }

        }
      }
    }

    return SizedBox(
      width: 52.w, height: 24.h,
      child: TextButton(
        onPressed: (){
          if (list.isNotEmpty) {
            showDialog(
                barrierDismissible: false,
                context: context,
                builder: (context) {
                  return Dialog(
                    backgroundColor: Constants.scaffoldBackgroundColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    insetPadding: EdgeInsets.all(20.w),
                    child: CustomRadioButtonListDialog(title: "위치 이동", sourList: list),
                  );
                }
            ).then((val) {
              if (val != 'Cancel' && val != '') {
                String newLocation = '';
                for (var location in gLocationList) {
                  if (location.getName()! == val) {
                    newLocation = location.getID()!;
                    break;
                  }
                }

                if (newLocation != '') {
                  showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return Dialog(
                          backgroundColor: Constants.scaffoldBackgroundColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          insetPadding: EdgeInsets.all(20.w),
                          child: const CustomConfirmDialog(title: "위치 이동", message:'위치이동을 하면 해당 센서의 이력이 모두 지워집니다.그래도 진행하시겠습니까?'),
                        );
                      }
                  ).then((val) async {
                    if (val != 'Cancel') {
                      try {
                        final response = await dio.post(
                            "/devices/moveSensor",
                            data: jsonEncode({
                              "userID": widget.userID,
                              "sensorID": sensor.getID(),
                              "oldLocationID": ref.watch(currentLocationProvider)!.getID(),
                              "newLocationID": newLocation
                            })
                        );

                        if (response.statusCode == 200) {
                          _processSuccess(response);
                        }
                      } catch(e) {
                        print(e);
                      }
                    }
                  });
                }
              }
            });
          } else {

          }
        },
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
        ),
        child: Text("위치 이동", style: TextStyle(fontSize: 12.sp, color: list.isNotEmpty ? Constants.primaryColor : Constants.dividerColor, )
        ),
      ),
    );
  }

  void _processSuccess(var response) {
    gSensorList.clear();
    gLocationList.clear();

    final lList = response.data['Location_Infos'] as List;
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

      if (al.isNotEmpty) {
        gLastAlarm = AlarmInfo(
          id: al.last.getID(),
          alarm: al.last.getAlarm(),
          jaeSilStatus: al.last.getJaeSilStatus(),
          createdAt: al.last.getCreatedAt(),
          updatedAt: al.last.getUpdatedAt(),
          userID: al.last.getUserID(),
          locationID: al.last.getLocationID(),
        );
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

    for (LocationInfo l in gLocationList) {
      if (l.getName() == controller.text) {
        ref.read(currentLocationProvider.notifier).doChangeState(l);
      }
    }

    setState(() {

    });
  }

  String _getCustomSensorName(SensorInfo sensor) {
    if (sensor.getDeviceType() == 'door_sensor') {
      return "문열림 센서";
    } else if (sensor.getDeviceType() == 'motion_sensor') {
      return "움직임 센서";
    } else if (sensor.getDeviceType() == 'emergency_button') {
      return "SOS 버튼";
    } else {
      return "알 수 없음";
    }
  }
}
