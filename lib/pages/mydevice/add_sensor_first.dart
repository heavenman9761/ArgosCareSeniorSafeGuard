import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/mqtt/mqtt.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:argoscareseniorsafeguard/models/location_infos.dart';
import 'package:argoscareseniorsafeguard/models/sensor_infos.dart';
import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/pages/mydevice/add_sensor_second.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_alert_dialog.dart';


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

            (ref.watch(currentLocationProvider)!.getType()! == 'customer') ? const Spacer() : const SizedBox(),

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
                              Icon(Icons.sensor_door_outlined, size: 16.w,),
                              SizedBox(width: 5.w),
                              Text("문열림 센서", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
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
                                            debugPrint('icon press');
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
                              Icon(Icons.sensor_door_outlined, size: 16.w,),
                              SizedBox(width: 5.w),
                              Text("움직임 센서", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
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
                                            debugPrint('icon press');
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
                              Icon(Icons.sensor_door_outlined, size: 16.w,),
                              SizedBox(width: 5.w),
                              Text("문열림 센서", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
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
                                        debugPrint('icon press');
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
                              Icon(Icons.sensor_door_outlined, size: 16.w,),
                              SizedBox(width: 5.w),
                              Text("움직임 센서", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF0F0F0F), )),
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
                                                debugPrint('icon press');
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
                                                    debugPrint('icon press');
                                                  },
                                                ),
                                              )
                                            ]
                                        )
                                      ],
                                    ),
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
    return const SizedBox();
  }
}
