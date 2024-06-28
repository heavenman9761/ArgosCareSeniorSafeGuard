import 'dart:async';

import 'package:argoscareseniorsafeguard/models/event_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/pages/home/report.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/models/sensor_infos.dart';
import 'package:argoscareseniorsafeguard/models/location_infos.dart';
import 'package:argoscareseniorsafeguard/models/sensor_event.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';

class LocationWidget extends ConsumerStatefulWidget {
  const LocationWidget({super.key, required this.title, required this.picture, required this.color, required this.locationIndex});

  final SvgPicture picture;
  final String title;
  final Color color;
  final int locationIndex;

  @override
  ConsumerState<LocationWidget> createState() => _LocationWidgetState();
}

class _LocationWidgetState extends ConsumerState<LocationWidget> {
  String _elapsedTime = "로딩중";
  String _recentTime = "로딩중";
  Timer? _timer;
  bool _longTime = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _stopTimer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startTimer();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(sensorEventProvider, (previous, next) {
      // logger.i('current event: ${ref.watch(sensorEventProvider)}');

      final List<SensorInfo> sensorList = gLocationList[widget.locationIndex].getSensors()!;

      for (int i = 0; i < sensorList.length; i++) {
        if (ref.watch(sensorEventProvider)!.getDeviceID()! == sensorList[i].getSensorID()) {
          _getRecentTime();
        }
      }

    });
    return InkWell(
        onTap: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) {
                return Report(locationIndex: widget.locationIndex);
              }));
        },
        child: Container(
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      widget.picture,
                      SizedBox(width: 12.w,),
                      Text(widget.title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
                    ],
                  ),
                  Row(
                    children: [
                      _longTime
                        ? Icon(Icons.alarm, size: 16.h, color: const Color(0xFFF7B63A),)
                        : Icon(Icons.alarm, size: 16.h, color: widget.color,),
                      SizedBox(width: 5.w),
                      _longTime
                          ? Text(_elapsedTime, style: TextStyle(fontSize: 12.sp, color: const Color(0xFFF7B63A)), )
                          : Text(_elapsedTime, style: TextStyle(fontSize: 12.sp, color: widget.color), ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 16.h, color: Constants.dividerColor),
                      SizedBox(width: 5.w),
                      Text(_recentTime, style: TextStyle(fontSize: 12.sp, color: Constants.dividerColor), ),
                    ],
                  ),
                ],
              )
          ),
        )
    );
  }

  void _startTimer() {
    _getElapsedTime();
    _getRecentTime();

    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      _getElapsedTime();
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _getElapsedTime() async {
    DBHelper sd = DBHelper();

    final List<SensorInfo> sensorList = gLocationList[widget.locationIndex].getSensors()!;
    List<SensorEvent> eventList = [];

    for (int i = 0; i < sensorList.length; i++) {
      List<SensorEvent> l = await sd.getSensorEventsByDeviceOnlyOne(sensorList[i].getSensorID()!);
      if (l.isNotEmpty) {
        eventList.add(l[0]);
      }
    }

    if (eventList.isNotEmpty) {
      eventList.sort((a,b) {
        return b.getCreatedAt()!.compareTo(a.getCreatedAt()!);
      });

      var now = DateTime.now();
      var eventTime = DateTime.parse(eventList[0].getCreatedAt()!);
      int difference = int.parse(now.difference(eventTime).inSeconds.toString()); //시간차를 초단위로 구한다.

      int min = (difference / 60).round();

      if (min < 1) {
        _longTime = false;
        _elapsedTime = "방금 전";

      } else if (min > 1 && min < 5) {
        _longTime = false;
        _elapsedTime = "조금 전";

      } else if (min > 5 && min < 60) {
        _longTime = false;
        _elapsedTime = '$min 분 전';

      } else if (min > 60) {
        _longTime = true;
        if (min > 60 && min < 60*24) {
          int hour = (min / 60).round();
          _elapsedTime = '$hour 시간 전';

        } else {
          int day = (min / 1440).round();
          _elapsedTime = '$day 일 전';

        }
      }
    } else {
      _elapsedTime = "정보 없음";
    }

    setState(() {

    });
  }

  void _getRecentTime() async {
    if (ref.watch(sensorEventProvider) == null) {
      DBHelper sd = DBHelper();

      final List<SensorInfo> sensorList = gLocationList[widget.locationIndex].getSensors()!;
      List<SensorEvent> eventList = [];

      for (int i = 0; i < sensorList.length; i++) {
        List<SensorEvent> l = await sd.getSensorEventsByDeviceOnlyOne(sensorList[i].getSensorID()!);
        if (l.isNotEmpty) {
          eventList.add(l[0]);
        }
      }

      if (eventList.isNotEmpty) {
        eventList.sort((a,b) {
          return b.getCreatedAt()!.compareTo(a.getCreatedAt()!);
        });

        final recentTime = DateTime.parse(eventList[0].getCreatedAt()!);
        _recentTime = DateFormat('MM.dd(E) HH:mm', 'ko').format(recentTime);
      } else {
        _recentTime = "정보 없음";
      }



    } else {
      final recentTime = DateTime.parse(ref.watch(sensorEventProvider)!.getCreatedAt()!);
      String formatDate = DateFormat('MM.dd(E) HH:mm', 'ko').format(recentTime);
      setState(() {
        _recentTime = formatDate;
      });

      _getElapsedTime();
    }
  }

}
