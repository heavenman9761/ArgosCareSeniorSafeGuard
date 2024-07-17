import 'dart:convert';

import 'package:argoscareseniorsafeguard/models/alarm_infos.dart';
import 'package:argoscareseniorsafeguard/models/location_infos.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:argoscareseniorsafeguard/utils/calendar_utils.dart';
import 'package:intl/intl.dart';

import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';

class NoticeWidget extends StatefulWidget {
  const NoticeWidget({super.key, required this.userName, required this.userID});

  final String userName;
  final String userID;

  @override
  State<NoticeWidget> createState() => _NoticeWidgetState();
}

class _NoticeWidgetState extends State<NoticeWidget> {
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
    return SafeArea(
      child: Scaffold(
        backgroundColor: Constants.scaffoldBackgroundColor,
        body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _getTitle(),
              _getSubtitle(),
              _getCalendar(),
              _getDate(),
              _getEvent(),
            ]
        ),
      )
    );
  }

  Widget _getSubtitle() {
    return Container(
      // color: Colors.blueAccent,
      height: 76.h,
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("알림", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
            /*const Spacer(),
            SizedBox(
              width: 24.w,
              height: 24.h,
              // color: Colors.redAccent,
              child: IconButton(
                constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                padding: EdgeInsets.zero,
                color: Constants.primaryColor,
                icon: SvgPicture.asset('assets/images/delete.svg', width: 24.w, height: 24.h),
                onPressed: () {
                  debugPrint('icon press');
                },
              ),
            )*/

          ],
        ),
      ),
    );
  }

  Widget _getCalendar() {
    return Padding(
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
                                /*if (_calendarFormat == CalendarFormat.week) {
                                                  _calendarFormat = CalendarFormat.month;
                                                } else if (_calendarFormat == CalendarFormat.month) {
                                                  _calendarFormat = CalendarFormat.week;
                                                }*/
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
    );
  }

  Widget _getTitle() {
    return SizedBox(
      // color: Colors.blueAccent,
      height: 52.h,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(AppLocalizations.of(context)!.app_title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
        ],
      ),
    );
  }

  Widget _getDate() {
    final formatter = DateFormat('MM.dd (E)', 'ko');
    String title = formatter.format(_focusedDay);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
          width: 104.w,
          height: 28.h,
          decoration: BoxDecoration(
            color: Constants.secondaryColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              SvgPicture.asset('assets/images/calendar_small.svg', width: 20.w, height: 20.h,),
              SizedBox(width: 10.w,),
              Text(title, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040)), ),
            ],
          )
      ),
    );
  }

  Widget _getEvent() {
      return Expanded(
        child: Container(
          // color: Colors.redAccent,
          child: Padding(
            padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 8.h),
            child: FutureBuilder<List<AlarmInfo>> (
                future: _getAlarmList(),
                builder: (context, snapshot) {
                  final List<AlarmInfo>? alarmList = snapshot.data;
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
                    if (alarmList != null) {
                      if (alarmList.isEmpty) {
                        return Center(
                          child: Text("데이터가 없습니다.", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor), textAlign: TextAlign.center),
                        );
                      }

                      return ListView.builder(
                        itemCount: alarmList.length,
                        itemBuilder: (context, index) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 80.h,
                                width: double.infinity,
                                padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 8.h),
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
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Row(
                                      children: [
                                        _getImage(alarmList[index].getLocationID()!),
                                        SizedBox(width: 5.w),
                                        Text("${alarmList[index].getAlarm()}", style: TextStyle(fontSize: 14.sp, color: const Color(0xFF040404), fontWeight: FontWeight.bold), ),
                                      ],
                                    ),
                                    Text(_getDateStr(alarmList[index].getCreatedAt()!), style: TextStyle(fontSize: 12.sp, color: Constants.dividerColor), ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8.h)
                            ],
                          );
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
            ),
          ),
        ),
      );
  }

  Widget _getImage(String locationID) {
    for (int i = 0; i < gLocationList.length; i++) {
      LocationInfo location = gLocationList[i];
      if (locationID == location.getID()) {
        if (location.getType() == 'entrance') {
          return SvgPicture.asset('assets/images/entrance.svg', width: 24.w, height: 24.h,);
        } else if (location.getType() == 'refrigerator') {
          return SvgPicture.asset('assets/images/refrigerator.svg', width: 24.w, height: 24.h,);
        } else if (location.getType() == 'toilet') {
          return SvgPicture.asset('assets/images/toilet.svg', width: 24.w, height: 24.h,);
        } else if (location.getType() == 'emergency') {
          return SvgPicture.asset('assets/images/emergency.svg', width: 24.w, height: 24.h,);
        } else {
          return SvgPicture.asset('assets/images/new_location.svg', width: 24.w, height: 24.h,);
        }
      }
    }
    return const SizedBox();
  }

  Future<List<AlarmInfo>> _getAlarmList() async {
    /*String date = DateFormat('yyyy-MM-dd').format(_selectedDay);
    DBHelper sd = DBHelper();

    return await sd.getAlarms(date);*/

    try {
      final response = await dio.post(
          "/users/get_alarmlist",
          data: jsonEncode({
            "userid": widget.userID,
            "startDate": DateFormat('yyyy-MM-dd 00:00:00').format(_focusedDay),
            "endDate": DateFormat('yyyy-MM-dd 23:59:59').format(_focusedDay),
          })
      );

      return (response.data as List)
          .map((x) => AlarmInfo.fromJson(x))
          .toList();

    } catch(e) {
      return [];
    }
  }

  String _getDateStr(String date) {
    var eventTime = DateTime.parse(date);
    return DateFormat('MM.dd(E) HH:mm', 'ko').format(eventTime);
  }
}
