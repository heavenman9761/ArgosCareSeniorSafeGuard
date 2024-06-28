import 'package:argoscareseniorsafeguard/models/sensor_infos.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/utils/calendar_utils.dart';
import 'package:argoscareseniorsafeguard/models/event_list.dart';
import 'package:argoscareseniorsafeguard/models/location_infos.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';

class Report extends StatefulWidget {
  const Report({super.key, required this.locationIndex});

  final int locationIndex;

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  String _currentYearMonth = '';
  final _formatter = DateFormat('yyyy-MM');

  @override
  void initState() {
    super.initState();

    _currentYearMonth = _formatter.format(_focusedDay);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: gLocationList.length,
        initialIndex: widget.locationIndex,
        child: Scaffold(
            backgroundColor: Constants.scaffoldBackgroundColor,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container( //이전 페이지 버튼
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
                    Container( //Tabbar
                      // color: Colors.redAccent,
                      height: 76.h,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            // color: Colors.blueAccent,
                            height: 50.h,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                              child: TabBar(
                                  dividerColor: Colors.transparent,
                                  unselectedLabelColor: Colors.grey,
                                  indicatorColor: Constants.primaryColor,
                                  labelStyle: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14.sp),
                                  indicatorWeight: 3,
                                  // indicator: ShapeDecoration(
                                  //   color: Colors.white,
                                  //   shape: RoundedRectangleBorder(
                                  //     borderRadius: BorderRadius.circular(9),
                                  //   ),
                                  // ),
                                  labelPadding: const EdgeInsets.symmetric(horizontal: 5.0),
                                  // isScrollable: true,
                                  tabs: _getTabs()
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                      child: Container(
                          height: 88.h,
                          decoration: BoxDecoration(
                            color: Constants.borderColor,
                            borderRadius: BorderRadius.circular(10),

                          ),
                          child: Padding(
                            padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 12.h),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                        width: 72.w,
                                        height: 28.h,
                                        decoration: BoxDecoration(
                                          color: Colors.black,
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Row(
                                          children: [
                                            SizedBox(width: 13.w,),
                                            Text("현재상태", style: TextStyle(fontSize: 12.sp, color: Colors.white), ),
                                          ],
                                        )
                                    ),
                                    const Spacer(),
                                    Container(
                                        width: 128.w,
                                        height: 28.h,
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(14),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(DateFormat('MM.dd (E) HH:mm', 'ko').format(DateTime.now()), style: TextStyle(fontSize: 12.sp, color: Colors.black), ),
                                          ],
                                        )
                                    )
                                  ],
                                ),
                                const Spacer(),
                                Row(
                                  children: [
                                    SvgPicture.asset('assets/images/alarm_small_green.svg', width: 16.w, height: 16.h,),
                                    SizedBox(width: 8.w,),
                                    RichText(
                                        text: TextSpan(
                                            text: "홍길동님은 현재 ",
                                            style: TextStyle(fontSize: 14.sp, color: Colors.black,),
                                            children: <TextSpan>[
                                              TextSpan(
                                                text: "재실",
                                                style: TextStyle(fontSize: 14.sp, color: Constants.primaryColor, fontWeight: FontWeight.bold),
                                              ),
                                              TextSpan(
                                                text: " 상태 입니다.",
                                                style: TextStyle(fontSize: 14.sp, color: Colors.black,),
                                              ),
                                            ]
                                        )
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                      child: Container(
                          height:  104.h,//_calendarFormat == CalendarFormat.week ? 104.h : 380.h,
                          width: double.infinity,
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
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

                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TableCalendar(
                                  calendarBuilders: CalendarBuilders(
                                    headerTitleBuilder: (context, day) {
                                      return Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          InkWell(
                                            child: Text(_currentYearMonth, style: TextStyle(fontSize: 15.sp, color: Colors.black),),
                                            // child: Text(_currentYearMonth),
                                            onTap: () {
                                              // setState(() {
                                              //   if (_calendarFormat == CalendarFormat.week) {
                                              //     _calendarFormat = CalendarFormat.month;
                                              //   } else if (_calendarFormat == CalendarFormat.month) {
                                              //     _calendarFormat = CalendarFormat.week;
                                              //   }
                                              // });
                                            },
                                          ),
                                        ],
                                      );
                                    }
                                  ),
                                  locale: 'ko_KR',
                                  firstDay: kFirstDay,
                                  lastDay: kLastDay,
                                  focusedDay: _focusedDay,
                                  calendarFormat: _calendarFormat,

                                  headerStyle: HeaderStyle(
                                    leftChevronPadding: const EdgeInsets.fromLTRB(32, 7, 32, 0),
                                    rightChevronPadding: const EdgeInsets.fromLTRB(32, 7, 32, 0),
                                    headerPadding: const EdgeInsets.all(0) ,
                                    // headerMargin: EdgeInsets.only(bottom: 0),
                                    formatButtonVisible : false,
                                    titleCentered: true,
                                    titleTextStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
                                    // titleTextFormatter: (date, locale) => DateFormat.yMMM(locale).format(date),
                                  ),

                                  calendarStyle: CalendarStyle(
                                    cellMargin : const EdgeInsets.all(8.0),
                                    cellPadding : const EdgeInsets.all(0.0),

                                    defaultTextStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold
                                    ),

                                    todayTextStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold
                                    ),
                                    todayDecoration: const BoxDecoration(
                                      color: Constants.secondaryColor,
                                      shape: BoxShape.circle,
                                    ),

                                    outsideTextStyle: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey
                                    ),

                                    selectedTextStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold
                                    ),
                                    selectedDecoration: const BoxDecoration(
                                      color: Constants.primaryColor,
                                      shape: BoxShape.circle,
                                    ),

                                    weekendTextStyle: TextStyle(
                                        color: Colors.black,
                                        fontSize: 12.sp,
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),

                                  daysOfWeekStyle: DaysOfWeekStyle(
                                    weekdayStyle: TextStyle(
                                        color: const Color(0xFF040404),
                                        fontSize: 10.sp
                                    ),
                                    weekendStyle: TextStyle(
                                        color: const Color(0xFF040404),
                                        fontSize: 10.sp
                                    ),

                                  ),

                                  selectedDayPredicate: (day) {
                                    // Use `selectedDayPredicate` to determine which day is currently selected.
                                    // If this returns true, then `day` will be marked as selected.

                                    // Using `isSameDay` is recommended to disregard
                                    // the time-part of compared DateTime objects.
                                    return isSameDay(_selectedDay, day);
                                  },
                                  onDaySelected: (selectedDay, focusedDay) {
                                    if (!isSameDay(_selectedDay, selectedDay)) {
                                      // Call `setState()` when updating the selected day
                                      setState(() {
                                        _selectedDay = selectedDay;
                                        _focusedDay = focusedDay;
                                        _currentYearMonth = _formatter.format(_focusedDay);
                                      });
                                    }
                                  },
                                  onFormatChanged: (format) {
                                    if (_calendarFormat != format) {
                                      // Call `setState()` when updating calendar format
                                      setState(() {
                                        _calendarFormat = format;
                                      });
                                    }
                                  },
                                  onPageChanged: (focusedDay) {
                                    // No need to call `setState()` here
                                    _focusedDay = focusedDay;
                                    _currentYearMonth = _formatter.format(_focusedDay);
                                  },
                                ),
                              ]
                          )
                      ),
                    ),

                    SizedBox(height: 16.h,),

                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                      child: Row(
                        children: [
                          Container(
                              height: 32.h,
                              width: 104.w,
                              decoration: BoxDecoration(
                                color: Constants.secondaryColor,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  SvgPicture.asset('assets/images/calendar_small.svg', width: 20.w, height: 20.h,),
                                  SizedBox(width: 5.w,),
                                  Text(DateFormat('yyyy.MM.dd', 'ko').format(_focusedDay), style: TextStyle(fontSize: 12.sp, color: Colors.black, ),),
                                ],
                              )
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 4.h,),

                    Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 0.h),
                          child: TabBarView(
                              children: _getTabBarView()
                          ),
                        )
                    )
                  ],
                )
            )
        )
    );
  }

  List<Tab> _getTabs() {
    List<Tab> list = [];
    for (var l in gLocationList) {
      list.add(
        Tab(text: l.getName())
      );
    }
    return list;
  }

  List<Widget> _getTabBarView() {
    List<Widget> list = [];
    for (int locationIndex = 0; locationIndex < gLocationList.length; locationIndex++) {
      list.add(
        Container(
          width: 10,
          color: Constants.scaffoldBackgroundColor,
          child: Column(
            children: [
              Expanded(
                child: FutureBuilder<List<EventList>>(
                  future: _getEventList(locationIndex),
                  builder: (context, snapshot) {
                    final List<EventList>? eventList = snapshot.data;
                    if (snapshot.connectionState != ConnectionState.done) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text(snapshot.error.toString()),
                      );
                    }
                    if (snapshot.hasData) {
                      if (eventList != null) {
                        if (eventList.isEmpty) {
                          return Center(
                            child: Text("데이터가 없습니다.", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor), textAlign: TextAlign.center),
                          );
                        }
                        return ListView.builder(
                          itemCount: eventList.length,
                          itemBuilder: (context, index) {
                            return _getEventWidget(locationIndex, eventList[index], index);//Text(eventList[index].getCreatedAt()!);
                          },
                        );

                      } else {
                        return const Center(
                          child: CircularProgressIndicator(),
                        );
                      }
                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  },
                )
              )
            ]
          ),
        ),
      );
    }
    return list;
  }

  Widget _getEventWidget(int locationIndex, EventList event, int index) {
    return Column(
      children: [
        Row(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 5.h,),
                Container(
                  height: 32.h,
                  width: 96.w,
                  decoration: BoxDecoration(
                    // color: const Color(0xFFF5F5F5),
                    color: Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      index == 0
                          ? SvgPicture.asset('assets/images/done.svg', width: 20.w, height: 20.h,)
                          : SvgPicture.asset('assets/images/done_grey.svg', width: 20.w, height: 20.h,),
                      SizedBox(width: 5.w,),
                      Text(_getTime(event.getCreatedAt()!), style: TextStyle(fontSize: 12.sp, color: Colors.black, ),),
                    ],
                  ),
                ),
                Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0.w),
                      child: SizedBox(
                          height: 48.h,
                          child: Container(height: 48.h, width: 1, color: Colors.grey,)
                      ),
                    )
                  ],
                )
              ],
            ),
            const Spacer(),
            Container(
              height: 84.h,
              width: 200.w,
              decoration: BoxDecoration(
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
                padding: EdgeInsets.all(16.0.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _getEventTitle(event),
                    const Spacer(),
                    Row(
                      children: [
                        _getEventIcon(locationIndex, event),
                        SizedBox(width: 8.w,),
                        _getEventDescription(locationIndex, event)
                      ],
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        SizedBox(height: 4.h,)
      ],
    );
  }

  Widget _getEventTitle(EventList event) {
    Map<String, String> data = _analysisStatus(event.getStatus()!);

    if (event.getDeviceType() == "door_sensor") {
      return Text("입출입 감지", style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold));

    } else if (event.getDeviceType() == "motion_sensor") {
      if (data['motion'] == '1') {
        return Text("움직임 감지", style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold));
      } else {
        return Text("움직임 없음", style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold));
      }

    } else if (event.getDeviceType() == "emergency_button") {
      return Text("SOS", style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold));

    }
    return const SizedBox();
  }

  Widget _getEventIcon(int locationIndex, EventList event) {
    Map<String, String> data = _analysisStatus(event.getStatus()!);

    LocationInfo locationInfo = gLocationList[locationIndex];
    if (locationInfo.getType() == "entrance") {
      if (event.getDeviceType() == "door_sensor") {
        if (data['door_window'] == '1') {
          return SvgPicture.asset('assets/images/entrance_open.svg', width: 20.w, height: 20.h,);
        } else {
          return SvgPicture.asset('assets/images/entrance_close.svg', width: 20.w, height: 20.h,);
        }

      } else if (event.getDeviceType() == "motion_sensor") {
        return SvgPicture.asset('assets/images/entrance_motion.svg', width: 20.w, height: 20.h,);
        /*if (data['motion'] == '1') {
          return SvgPicture.asset('assets/images/entrance_motion.svg', width: 20.w, height: 20.h,);
        } else {
          return SvgPicture.asset('assets/images/entrance_motion_none.svg', width: 20.w, height: 20.h,);
        }*/

      }

    } else if (locationInfo.getType() == "refrigerator") {
      // return SvgPicture.asset('assets/images/refrigerator.svg', width: 20.w, height: 20.h,);
      if (event.getDeviceType() == "door_sensor") {
        if (data['door_window'] == '1') {
          return SvgPicture.asset('assets/images/refrigerator_open.svg', width: 20.w, height: 20.h,);
        } else {
          return SvgPicture.asset('assets/images/refrigerator_close.svg', width: 20.w, height: 20.h,);
        }

      }

    } else if (locationInfo.getType() == "toilet") {
      return SvgPicture.asset('assets/images/toilet_motion.svg', width: 20.w, height: 20.h,);
      /*if (data['motion'] == '1') {
          return SvgPicture.asset('assets/images/toilet_motion.svg', width: 20.w, height: 20.h,);
        } else {
          return SvgPicture.asset('assets/images/toilet_motion_none.svg', width: 20.w, height: 20.h,);
        }*/

    } else if (locationInfo.getType() == "emergency") {
      return SvgPicture.asset('assets/images/emergency_event.svg', width: 20.w, height: 20.h,);

    } else if (locationInfo.getType() == "customer") {
      return SvgPicture.asset('assets/images/new_location.svg', width: 20.w, height: 20.h,);

    }

    return const SizedBox();
  }

  Widget _getEventDescription(int locationIndex, EventList event) {
    Map<String, String> data = _analysisStatus(event.getStatus()!);

    String locationName = gLocationList[locationIndex].getName()!;

    if (locationName != "") {
      if (event.getDeviceType() == "door_sensor") {
        if (data['door_window'] == '1') {
          return Text("$locationName 열림", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor));
        } else {
          return Text("$locationName 닫힘", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor));
        }
      } else if (event.getDeviceType() == "motion_sensor") {
        return Text(locationName, style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor));

      } else if (event.getDeviceType() == "emergency_button") {
        return Text("SOS 요청", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor));
      }
    }

    return const SizedBox();
  }

  String _getTime(String sourTime) {
    final recentTime = DateTime.parse(sourTime);
    String formatDate = DateFormat('aa hh:mm', 'ko').format(recentTime);
    return formatDate;
  }

  Future<List<EventList>> _getEventList(int locationIndex) async {
    String date = DateFormat('yyyy-MM-dd').format(_selectedDay);
    DBHelper sd = DBHelper();

    List<String> sensorIDs = [];
    List<SensorInfo> sensors = gLocationList[locationIndex].getSensors()!;
    for (var s in sensors) {
      sensorIDs.add(s.getSensorID()!);
    }

    if (sensorIDs.isNotEmpty) {
      return await sd.getEventList2(date, sensorIDs);
    } else {
      return [];
    }
  }

  Map<String, String> _analysisStatus(String statusMsg) {
    String status = removeJsonAndArray(statusMsg);

    var dataSp = status.split(',');
    Map<String, String> data = {};
    for (var element in dataSp) {
      data[element.split(':')[0].trim()] = element.split(':')[1].trim();
    }

    return data;
  }
}
