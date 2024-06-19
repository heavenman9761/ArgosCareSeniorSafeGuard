import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:argoscareseniorsafeguard/components/door_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/motion_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/illuminance_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/humidity_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/smoke_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/emergency_card_widget.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
// import 'package:argoscareseniorsafeguard/database/db.dart';
// import 'package:argoscareseniorsafeguard/models/sensor.dart';
// import 'package:argoscareseniorsafeguard/models/hub.dart';
import 'package:argoscareseniorsafeguard/models/hub_infos.dart';
import 'package:argoscareseniorsafeguard/models/sensor_infos.dart';
import 'package:argoscareseniorsafeguard/pages/pairing_hub.dart';

class HomeWidget extends ConsumerWidget {
  const HomeWidget({super.key, required this.userName, required this.userID});

  final String userName;
  final String userID;

  Widget waitWidget() {
    return const CircularProgressIndicator(backgroundColor: Colors.blue);
  }

  /*Future<List<Device>> _getDeviceList() async {
    List<Device> deviceList = [];

    DBHelper sd = DBHelper();
    deviceList = await sd.getDevices();
    return deviceList;
  }*/

  Future<List<SensorInfo>> _getSensorList() async {
    // DBHelper sd = DBHelper();
    //
    // List<Sensor> sensorList = await sd.getSensors(userID);

    List<HubInfo> hubList = [];
    List<SensorInfo> sensorList = [];

    if (userID != '') {
      final response = await dio.get(
        "/devices/$userID",
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
  }

  Widget _locationInfo(BuildContext context, int index) {
    late SvgPicture picture;
    late String title;
    late Color color;
    if (index == 0) {
      picture = SvgPicture.asset('assets/images/entrance.svg', width: 48.w, height: 48.h,);
      color = Constants.dividerColor;
      title = AppLocalizations.of(context)!.location_entrance;
    } else if (index == 1) {
      picture = SvgPicture.asset('assets/images/refrigerator.svg', width: 48.w, height: 48.h,);
      color = const Color(0xFFF7B63A);
      title = AppLocalizations.of(context)!.location_refrigerator;
    } else if (index == 2) {
      picture = SvgPicture.asset('assets/images/toilet.svg', width: 48.w, height: 48.h,);
      color = Constants.dividerColor;
      title = AppLocalizations.of(context)!.location_toilet;
    } else if (index == 3) {
      color = Constants.dividerColor;
      picture = SvgPicture.asset('assets/images/emergency.svg', width: 48.w, height: 48.h,);
      title = AppLocalizations.of(context)!.location_emergency;
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Row(
          children: [
            picture,
            SizedBox(width: 12.w,),
            Text(title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.alarm, size: 16.h, color: color,),
            SizedBox(width: 5.w),
            Text("2시간 30분 경과", style: TextStyle(fontSize: 12.sp, color: color), ),
          ],
        ),
        Row(
          children: [
            Icon(Icons.access_time, size: 16.h, color: Constants.dividerColor),
            SizedBox(width: 5.w),
            Text("06.14 (금) 14:30", style: TextStyle(fontSize: 12.sp, color: Constants.dividerColor), ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Constants.scaffoldBackgroundColor,
      body: Stack(
        children: [
          Positioned( //타이틀바
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
                            Row(
                              children: [
                                Container(
                                    width: 132.w,
                                    height: 36.h,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF404040).withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Row(
                                      children: [
                                        SizedBox(width: 16.w,),
                                        Text(AppLocalizations.of(context)!.jaesil_state_unknown, style: TextStyle(fontSize: 12.sp, color: Colors.white), ),
                                        SizedBox(width: 4.w,),
                                        SvgPicture.asset('assets/images/jaesil_unknown.svg', width: 20.w, height: 20.h,)
                                      ],
                                    )
                                )
                              ],
                            )
                          ],
                        )
                    ),
                  ),
                  Positioned(
                      top: 52.h,
                      right: 20.w,
                      height: 80.h,
                      width: 80.h,
                      child: SvgPicture.asset('assets/images/parent_unknown.svg', width: 80.w, height: 80.h,)
                  )
                ]
            ),
          ),
          Positioned( //타이틀 제외한 전체 영역
            top: 200.h,
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: Constants.scaffoldBackgroundColor,//Colors.white,
            ),
          ),
          Positioned( //피보호자 상태
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
                child: Padding(
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
                              debugPrint('icon press');
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                )
            ),
          ),
          Positioned( //최신 알림
            top: 264.h,
            left: 20.w,
            right: 20.w,
            height: 96.h,
            // width: 320.w,
            child: SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: gHubList.isEmpty
                  ? InkWell(
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
                                          Text("06.14 (Sun) 14:30", style: TextStyle(fontSize: 12.sp, color: Constants.primaryColor), ),
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
                  : Card(
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
                                    width: 108.w,
                                    height: 28.h,
                                    decoration: BoxDecoration(
                                      color: Constants.primaryColor.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text("06.14 (금) 14:30", style: TextStyle(fontSize: 12.sp, color: Constants.primaryColor), ),
                                      ],
                                    )
                                )
                              ],
                            ),
                            SizedBox(height: 18.h),
                            // Row(
                            //   children: [
                            //     SvgPicture.asset('assets/images/hub_small.svg', width: 16.w, height: 16.h,),
                            //     SizedBox(width: 8.w,),
                            //     Text("허브 연결을 확인해 주세요", style: TextStyle(fontSize: 12.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
                            //   ],
                            // )
                          ],
                        )
                        ,
                      ),
                    ),
            ),
          ),
          Positioned(
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
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
          /*Positioned( //장소별 알림 영역
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
                  itemCount: 4,
                  itemBuilder: (BuildContext context, int index) {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: Constants.borderColor,
                            width: 1
                        ),
                        color: Colors.white,
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
                      child: Padding(
                          padding: EdgeInsets.all(10.0.h),
                          child: _locationInfo(context, index)
                      ),
                    );
                  },
                )
            ),
          )*/
        ],
      )
    );
  }
  /*Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(outPadding),
        child: Column(
          children: [
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("안녕하세요 ${userName}님,",
                    //style: const TextStyle(fontSize: 20.0),
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.account_circle, size: 48.0),
                    tooltip: "Menu",
                    color: Theme.of(context).colorScheme.onPrimary,//Colors.grey,
                    onPressed: () {
                      debugPrint('icon press');
                    },
                  ),
                ]
            ),
            Expanded(
              child: FutureBuilder<List<SensorInfo>>(
                future: _getSensorList(),
                builder: (context, snapshot) {
                  final List<SensorInfo>? sensors = snapshot.data;
                  if (snapshot.connectionState != ConnectionState.done) {
                    return Center(
                      child: waitWidget(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(snapshot.error.toString()),
                    );
                  }
                  if (snapshot.hasData) {
                    if (sensors != null) {
                      if (sensors.isEmpty) {
                        return Center(
                          child: Text("등록된 센서가 없습니다.\n내 기기 탭에서 센서를 등록하세요.",
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                          ),
                        );
                      } else {
                        return ListView.builder(
                          itemCount: sensors.length,
                          itemBuilder: (context, index) {
                            *//*if (devices[index].deviceType == Constants.DEVICE_TYPE_HUB) {
                          return CardWidget(deviceName: devices[index].getName()!);
                        } else *//*if (sensors[index].deviceType == Constants.DEVICE_TYPE_DOOR) {
                              return DoorCardWidget(deviceName: sensors[index].getName()!);

                            } else if (sensors[index].deviceType == Constants.DEVICE_TYPE_ILLUMINANCE) {
                              return IlluminanceCardWidget(deviceName: sensors[index].getName()!);

                            } else if (sensors[index].deviceType == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
                              return HumidityCardWidget(deviceName: sensors[index].getName()!);

                            } else if (sensors[index].deviceType == Constants.DEVICE_TYPE_SMOKE) {
                              return SmokeCardWidget(deviceName: sensors[index].getName()!);

                            } else if (sensors[index].deviceType == Constants.DEVICE_TYPE_EMERGENCY) {
                              return EmergencyCardWidget(deviceName: sensors[index].getName()!);

                            } else if (sensors[index].deviceType == Constants.DEVICE_TYPE_MOTION) {
                              return MotionCardWidget(deviceName: sensors[index].getName()!);

                            } else {
                              return null;
                            }
                          },
                        );

                        // return ReorderableListView.builder(
                        //     itemBuilder: (context, index) {
                        //       return Padding(
                        //         key: Key('$index'),
                        //         padding: const EdgeInsets.all(0.0),
                        //         child: Container(
                        //           child: _getSensorWidget(sensors[index])
                        //         ),
                        //       );
                        //     },
                        //     itemCount: sensors.length,
                        //     onReorder: (oldIndex, newIndex) {
                        //       _updateSensorOrder(oldIndex, newIndex);
                        //     }
                        // );
                      }
                    } else {
                      return Center(
                        child: waitWidget(),
                      );
                    }
                  } else {
                    return Center(
                      child: waitWidget(),
                    );
                  }
                },
              ),
            )
          ],
        )
      )
    );
  }*/

  Widget _getSensorWidget(SensorInfo sensor) {
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
  }

  void goPairingHub(BuildContext context) {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) {
          return const PairingHub();
        }));
  }

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
}