import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:argoscareseniorsafeguard/utils/calendar_utils.dart';

class Report extends StatefulWidget {
  const Report({super.key, required this.locationIndex});

  final int locationIndex;

  @override
  State<Report> createState() => _ReportState();
}

class _ReportState extends State<Report> {
  CalendarFormat _calendarFormat = CalendarFormat.week;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

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
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                            padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 12.h),
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
                                            Text("06.14 (Sun) 14:30", style: TextStyle(fontSize: 12.sp, color: Colors.black), ),
                                          ],
                                        )
                                    )
                                  ],
                                ),
                                // SizedBox(height: 9.h),
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
                          height: 104.h,
                          width: double.infinity,
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
                                Expanded(
                                  child: TableCalendar(
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
                                        });
                                      }
                                    },
                                    onFormatChanged: (format) {
                                      print(format);
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
                                    },
                                  ),
                                ),
                              ]
                          )
                      ),
                    ),
                    SizedBox(height: 16.h,),
                    Expanded(
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 16.w),
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
      list.add(Tab(
        text: l.getName()
      ));
    }
    return list;
  }

  List<Widget> _getTabBarView() {
    List<Widget> list = [];
    for (var l in gLocationList) {
      list.add(
        Container(
          width: 10,
          color: const Color.fromRGBO(91, 91, 91, 1),
          child: Center(
            child: Text(
              l.getName()!,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 56,
                  fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }
    return list;
  }
}

/*
const [
Tab(
text: "재실현황",
// height: 20
),
Tab(
text: "현관",
// height: 20
),
Tab(
text: '냉장고',
// height: 20,
),
Tab(
text: '화장실',
// height: 20,
),
Tab(
text: 'SOS',
// height: 20,
),
Tab(
text: '앞문',
// height: 20,
),
]*/
