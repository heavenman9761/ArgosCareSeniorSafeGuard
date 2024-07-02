import 'dart:convert';

import 'package:argoscareseniorsafeguard/pages/profile/airplane_mode.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:remedi_kopo/remedi_kopo.dart';
import 'package:intl/intl.dart';

import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/components/my_textfield.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_alert_dialog.dart';
import 'package:argoscareseniorsafeguard/models/airplaneday.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/models/airplanetime.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_alert_dialog.dart';

class AirPlaneMode extends StatefulWidget {
  const AirPlaneMode({super.key, required this.userID});
  final String userID;

  @override
  State<AirPlaneMode> createState() => _AirPlaneModeState();
}

class _AirPlaneModeState extends State<AirPlaneMode> {
  int _itemCount = 0;

  bool _enable = gAirPlaneEnable;

  bool _sun_toggle = false;
  bool _mon_toggle = false;
  bool _tue_toggle = false;
  bool _wed_toggle = false;
  bool _thu_toggle = false;
  bool _fri_toggle = false;
  bool _sat_toggle = false;


  String _start_ampm = "";
  int _start_ampm_index = 0;
  String _start_hour = "";
  int _start_hour_index = 0;
  String _start_minute = "";
  int _start_minute_index = 0;

  String _end_ampm = "";
  int _end_ampm_index = 0;
  String _end_hour = "";
  int _end_hour_index = 0;
  String _end_minute = "";
  int _end_minute_index = 0;

  List<AirplaneTime> _gAirPlaneTimeList = [];

  @override
  void initState() {
    super.initState();
    for (AirplaneDay l in gAirPlaneDayList) {
      if (l.getDayName() == 'Sun' && l.getEnable() == 1) {
        _sun_toggle = true;
      }
      if (l.getDayName() == 'Mon' && l.getEnable() == 1) {
        _mon_toggle = true;
      }
      if (l.getDayName() == 'Tue' && l.getEnable() == 1) {
        _tue_toggle = true;
      }
      if (l.getDayName() == 'Wed' && l.getEnable() == 1) {
        _wed_toggle = true;
      }
      if (l.getDayName() == 'Thu' && l.getEnable() == 1) {
        _thu_toggle = true;
      }
      if (l.getDayName() == 'Fri' && l.getEnable() == 1) {
        _fri_toggle = true;
      }
      if (l.getDayName() == 'Sat' && l.getEnable() == 1) {
        _sat_toggle = true;
      }
    }
    setState(() {
      _gAirPlaneTimeList.clear();
      for (var item in gAirPlaneTimeList) {
        _gAirPlaneTimeList.add(AirplaneTime(startTime: item.getStartTime()!, endTime: item.getEndTime()!));
      }

      _start_ampm = Constants.ampm[_start_ampm_index];
      _start_hour = Constants.hourTable[_start_hour_index];
      _start_minute = Constants.minuteTable[_start_minute_index];

      _end_ampm = Constants.ampm[_end_ampm_index];
      _end_hour = Constants.hourTable[_end_hour_index];
      _end_minute = Constants.minuteTable[_end_minute_index];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Constants.scaffoldBackgroundColor,
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox( //이전 페이지 버튼
                // color: Colors.greenAccent,
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
                      Text("방해금지 모드", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                child: Container(
                    height: 60.h,
                    width: 320.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: Constants.borderColor),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
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
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 0),
                        child: Row(
                          children: [
                            Text("사용", style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                            const Spacer(),
                            SizedBox(
                                height: 25.h,
                                width: 45.w,
                                child: FittedBox(
                                  fit: BoxFit.contain,
                                  child: CupertinoSwitch(
                                    value: _enable,
                                    activeColor: Constants.primaryColor,
                                    onChanged: (bool? value) {
                                      _enable = value!;
                                      setState(() {

                                      });
                                    },
                                  ),
                                )
                            )

                          ],
                        )
                    )
                ),
              ),

              SizedBox(height: 16.h),

              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                child: Container(
                    height: 120.h,
                    width: 320.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: Constants.borderColor),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
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
                        padding: EdgeInsets.fromLTRB(16.w, 20.h, 20.w, 20.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("요일", style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                            Container(
                              width: double.infinity,
                              height: 1.h,
                              color: Constants.primaryColor
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _settingOfDays(0),
                                _settingOfDays(1),
                                _settingOfDays(2),
                                _settingOfDays(3),
                                _settingOfDays(4),
                                _settingOfDays(5),
                                _settingOfDays(6),
                              ]
                            )
                          ],
                        )
                    )
                ),
              ),

              SizedBox(height: 16.h),

              _gAirPlaneTimeList.isEmpty
              ? Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                child: Container(
                    height: 60.h,
                    width: 320.w,
                    decoration: BoxDecoration(
                      border: Border.all(color: Constants.borderColor),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
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
                        padding: EdgeInsets.fromLTRB(16.w, 16.h, 20.w, 16.h),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("시간대", style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                                const Spacer(),
                                SizedBox(
                                  width: 24.w, height: 24.h,
                                  child: IconButton(
                                    constraints: BoxConstraints(maxHeight: 24.h, maxWidth: 24.w),
                                    padding: EdgeInsets.zero,
                                    color: Constants.primaryColor,
                                    icon: SvgPicture.asset("assets/images/plus.svg", width: 24.w, height: 24.h,),
                                    onPressed: () {
                                      _showStartTimeBottomSheet(context);
                                    },
                                  ),
                                )
                              ],
                            ),
                          ],
                        )
                      )
                )
              )
              : Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Constants.borderColor),
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 5,
                          blurRadius: 7,
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: LimitedBox(
                      maxHeight: 210.h,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 20.h, 20.w, 20.h),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text("시간대", style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                                const Spacer(),
                                SizedBox(
                                  width: 24.w, height: 24.h,
                                  child: IconButton(
                                    constraints: BoxConstraints(maxHeight: 24.h, maxWidth: 24.w),
                                    padding: EdgeInsets.zero,
                                    color: Constants.primaryColor,
                                    icon: SvgPicture.asset("assets/images/plus.svg", width: 24.w, height: 24.h,),
                                    onPressed: () {
                                      _showStartTimeBottomSheet(context);
                                    },
                                  ),
                                )
                              ],
                            ),
                            SizedBox(height:8.h),
                            Container(
                                width: double.infinity,
                                height: 1.h,
                                color: Constants.primaryColor
                            ),
                            SizedBox(height:8.h),
                            Flexible(
                              child: ListView.builder(
                                shrinkWrap: true,
                                itemBuilder: (BuildContext context, int index) {
                                  return Row(
                                    children: [
                                      //Text('${_gAirPlaneTimeList[index].getStartTime()!} ~ ${_gAirPlaneTimeList[index].getEndTime()!}', style: TextStyle(fontSize: 14.sp), ),
                                      Text(_getTimeText(_gAirPlaneTimeList[index].getStartTime()!, _gAirPlaneTimeList[index].getEndTime()!), style: TextStyle(fontSize: 14.sp), ),
                                      const Spacer(),
                                      SizedBox(
                                        width: 24.w, height: 24.h,
                                        child: IconButton(
                                          constraints: BoxConstraints(maxHeight: 24.h, maxWidth: 24.w),
                                          padding: EdgeInsets.zero,
                                          color: Constants.primaryColor,
                                          icon: SvgPicture.asset("assets/images/minus.svg", width: 24.w, height: 24.h,),
                                          onPressed: () async {
                                            _gAirPlaneTimeList.remove(_gAirPlaneTimeList[index]);

                                            setState(() {

                                            });
                                          },
                                        ),
                                      )
                                    ],
                                  );
                                },
                                itemCount: _gAirPlaneTimeList.length,
                              ),
                            ),
                          ],
                        ),
                      )
                    ),
                  )
              ),

              const Spacer(),

              Padding(
                padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                child: MyButton(
                  onTap: () {
                    _save(context);
                  },
                  text: "확인",
                ),
              ),
            ],
          )
        )
    );
  }

  String _getTimeText(String startTime, String endTime) {
    String start_ampm = startTime.substring(0, 2);
    String start_time = startTime.substring(3, startTime.length);
    String end_ampm = endTime.substring(0, 2);
    String end_time = endTime.substring(3, endTime.length);

    if (start_ampm == '오후' && end_ampm == '오전') {
      return '$startTime ~ 다음날 $endTime';
    } else if (start_ampm == '오후' && end_ampm == '오후') {
      int r = start_time.compareTo(end_time); // 1 => start_time > end_time, -1 => start_time < end_time
      if (r == 1) {
        return '$startTime ~ 다음날 $endTime';
      }
    }

    return '$startTime ~ $endTime';


  }

  void _save(BuildContext context) async {
    DBHelper sd = DBHelper();

    final SharedPreferences pref = await SharedPreferences.getInstance();
    gAirPlaneEnable = _enable;
    pref.setBool("airplaneEnable", gAirPlaneEnable);

    for (AirplaneDay l in gAirPlaneDayList) {
      if (l.getDayName() == 'Sun') {
        l.setEnable(_sun_toggle ? 1 : 0);
      }
      if (l.getDayName() == 'Mon') {
        l.setEnable(_mon_toggle ? 1 : 0);
      }
      if (l.getDayName() == 'Tue') {
        l.setEnable(_tue_toggle ? 1 : 0);
      }
      if (l.getDayName() == 'Wed') {
        l.setEnable(_wed_toggle ? 1 : 0);
      }
      if (l.getDayName() == 'Thu') {
        l.setEnable(_thu_toggle ? 1 : 0);
      }
      if (l.getDayName() == 'Fri') {
        l.setEnable(_fri_toggle ? 1 : 0);
      }
      if (l.getDayName() == 'Sat') {
        l.setEnable(_sat_toggle ? 1 : 0);
      }

      sd.updateAirplaneDayTable(_sun_toggle, _mon_toggle, _tue_toggle, _wed_toggle, _thu_toggle, _fri_toggle, _sat_toggle);
    }

    await sd.emptyAirplaneTimeTable();
    for (var item in _gAirPlaneTimeList) {
      await sd.insertAirplaneTime(item.getStartTime()!, item.getEndTime()!);
    }
    gAirPlaneTimeList.clear();
    gAirPlaneTimeList = await sd.getAirplaneTimes();

    if (!context.mounted) return;
    Navigator.pop(context);
  }

  Widget _settingOfDays(int index) {
    String dayName = '';
    bool toogle = false;
    if (index == 0) {
      dayName = '일';
      toogle = _sun_toggle;
    } else if (index == 1) {
      dayName = '월';
      toogle = _mon_toggle;
    } else if (index == 2) {
      dayName = '화';
      toogle = _tue_toggle;
    } else if (index == 3) {
      dayName = '수';
      toogle = _wed_toggle;
    } else if (index == 4) {
      dayName = '목';
      toogle = _thu_toggle;
    } else if (index == 5) {
      dayName = '금';
      toogle = _fri_toggle;
    } else if (index == 6) {
      dayName = '토';
      toogle = _sat_toggle;
    }

    return InkWell(
        onTap: () {
          toogle = !toogle;
          setState(() {
            if (index == 0) {
              _sun_toggle = toogle;
            } else if (index == 1) {
              _mon_toggle = toogle;
            } else if (index == 2) {
              _tue_toggle = toogle;
            } else if (index == 3) {
              _wed_toggle = toogle;
            } else if (index == 4) {
              _thu_toggle = toogle;
            } else if (index == 5) {
              _fri_toggle = toogle;
            } else if (index == 6) {
              _sat_toggle = toogle;
            }
          });
        },
        child: Container(width: 32.w, height: 32.h,
            decoration: BoxDecoration(
              border: Border.all(color: toogle ? Constants.primaryColor : Constants.borderColor),
              borderRadius: BorderRadius.circular(18.w),
              color: toogle ? Constants.primaryColor : Colors.transparent,
            ),
            child: Center(child: Text(dayName, style: TextStyle(fontSize: 12.sp, color: toogle ? Colors.white : Colors.black, )))
        )
    );
  }

  void _showStartTimeBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        isDismissible: false,
        enableDrag: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter bottomState) {
            return Container(
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
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(height: 40.h),
                            IconButton(
                                onPressed: () {
                                  bottomState(() {
                                    setState(() {
                                    });
                                  });

                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close),
                                color: Colors.black
                            )
                          ],
                        ),
                        SizedBox(height: 20.h, child: Text("시작시간", style: TextStyle(fontSize: 16.sp),)),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: SizedBox(
                                height: 220.h,
                                width: 320.w,
                                child: CupertinoPicker.builder(
                                    itemExtent: 44,
                                    childCount: Constants.ampm.length,
                                    onSelectedItemChanged: (i) {
                                      bottomState(() {
                                        setState(() {
                                          _start_ampm = Constants.ampm[i];
                                          _start_ampm_index = i;
                                        });
                                      });

                                    },
                                    itemBuilder: (context, index) {
                                      return Center(child: Text(Constants.ampm[index], style: TextStyle(fontSize: 20.sp),));
                                    }),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: SizedBox(
                                height: 220.h,
                                width: 320.w,
                                child: CupertinoPicker.builder(
                                    itemExtent: 44,
                                    childCount: Constants.hourTable.length,
                                    onSelectedItemChanged: (i) {
                                      bottomState(() {
                                        setState(() {
                                          _start_hour = Constants.hourTable[i];
                                          _start_hour_index = i;
                                        });
                                      });

                                    },
                                    itemBuilder: (context, index) {
                                      return Center(child: Text(Constants.hourTable[index], style: TextStyle(fontSize: 16.sp),));
                                    }),
                              ),
                            ),
                            Text(":", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                            Flexible(
                              flex: 1,
                              child: SizedBox(
                                height: 220.h,
                                width: 320.w,
                                child: CupertinoPicker.builder(
                                    itemExtent: 44,
                                    childCount: Constants.minuteTable.length,
                                    onSelectedItemChanged: (i) {
                                      bottomState(() {
                                        setState(() {
                                          _start_minute = Constants.minuteTable[i];
                                          _start_minute_index = i;
                                        });
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      return Center(child: Text(Constants.minuteTable[index], style: TextStyle(fontSize: 16.sp),));
                                    }),
                              ),
                            ),

                          ],
                        ),

                        MyButton(
                          onTap: () {

                            Navigator.pop(context);
                            _showEndTimeBottomSheet(context);
                          },
                          text: "다음",
                        ),
                      ]
                  ),
                ),
              ),
            );
          });
        }
    );
  }

  void _showEndTimeBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        isDismissible: false,
        enableDrag: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter bottomState) {
            return Container(
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
                child: Padding(
                  padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            SizedBox(height: 40.h),
                            IconButton(
                                onPressed: () {
                                  bottomState(() {
                                    setState(() {
                                    });
                                  });

                                  Navigator.pop(context);
                                },
                                icon: const Icon(Icons.close),
                                color: Colors.black
                            )
                          ],
                        ),
                        SizedBox(height: 20.h, child: Text("종료시간", style: TextStyle(fontSize: 16.sp),)),
                        Row(
                          children: [
                            Flexible(
                              flex: 1,
                              child: SizedBox(
                                height: 220.h,
                                width: 320.w,
                                child: CupertinoPicker.builder(
                                    itemExtent: 44,
                                    childCount: Constants.ampm.length,
                                    onSelectedItemChanged: (i) {
                                      bottomState(() {
                                        setState(() {
                                          _end_ampm = Constants.ampm[i];
                                          _end_ampm_index = i;
                                        });
                                      });

                                    },
                                    itemBuilder: (context, index) {
                                      return Center(child: Text(Constants.ampm[index], style: TextStyle(fontSize: 20.sp),));
                                    }),
                              ),
                            ),
                            Flexible(
                              flex: 1,
                              child: SizedBox(
                                height: 220.h,
                                width: 320.w,
                                child: CupertinoPicker.builder(
                                    itemExtent: 44,
                                    childCount: Constants.hourTable.length,
                                    onSelectedItemChanged: (i) {
                                      bottomState(() {
                                        setState(() {
                                          _end_hour = Constants.hourTable[i];
                                          _end_hour_index = i;
                                        });
                                      });

                                    },
                                    itemBuilder: (context, index) {
                                      return Center(child: Text(Constants.hourTable[index], style: TextStyle(fontSize: 16.sp),));
                                    }),
                              ),
                            ),
                            Text(":", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold)),
                            Flexible(
                              flex: 1,
                              child: SizedBox(
                                height: 220.h,
                                width: 320.w,
                                child: CupertinoPicker.builder(
                                    itemExtent: 44,
                                    childCount: Constants.minuteTable.length,
                                    onSelectedItemChanged: (i) {
                                      bottomState(() {
                                        setState(() {
                                          _end_minute = Constants.minuteTable[i];
                                          _end_minute_index = i;
                                        });
                                      });
                                    },
                                    itemBuilder: (context, index) {
                                      return Center(child: Text(Constants.minuteTable[index], style: TextStyle(fontSize: 16.sp),));
                                    }),
                              ),
                            ),

                          ],
                        ),

                        MyButton(
                          onTap: () async {
                            /*print('$_start_ampm $_start_hour:$_start_minute');
                            print('$_end_ampm $_end_hour:$_end_minute');*/
                            String startTime = '$_start_ampm $_start_hour:$_start_minute';
                            String endTime = '$_end_ampm $_end_hour:$_end_minute';



                            if (!context.mounted) return;
                            Navigator.pop(context);
                            setState(() {
                              if (startTime == endTime) {
                                _showAlertDialog("오류", "시작 시간과 종료 시간이 같습니다.");
                              } else {
                                _gAirPlaneTimeList.add(
                                    AirplaneTime(startTime: startTime, endTime: endTime)
                                );
                              }
                            });
                          },
                          text: "확인",
                        ),
                      ]
                  ),
                ),
              ),
            );
          });
        }
    );
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Constants.scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: EdgeInsets.all(20.w),
            child: CustomAlertDialog(title: title, message: message),
          );
        }
    ).then((val) {
    });
  }
}
