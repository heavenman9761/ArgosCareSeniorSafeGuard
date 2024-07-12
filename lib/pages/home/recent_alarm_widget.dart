import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/models/alarm_infos.dart';

class RecentAlarmWidget extends ConsumerStatefulWidget {
  const RecentAlarmWidget({super.key, required this.userID});
  final String userID;

  @override
  ConsumerState<RecentAlarmWidget> createState() => _RecentAlarmWidgetState();
}

class _RecentAlarmWidgetState extends ConsumerState<RecentAlarmWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: Card(
        color: Constants.secondaryColor,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          Text(AppLocalizations.of(context)!.recent_notice, style: TextStyle(fontSize: 12.sp, color: Colors.white),),
                        ],
                      )
                  ),
                  const Spacer(),
                  Container(
                      width: 115.w,
                      height: 28.h,
                      decoration: BoxDecoration(
                        color: Constants.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_getTime(), style: TextStyle(fontSize: 12.sp, color: Constants.primaryColor),),
                        ],
                      )
                  )
                ],
              ),
              SizedBox(
                height: 16.h,
              ),
              Row(
                children: [
                  SvgPicture.asset('assets/images/clock_small.svg', width: 16.w, height: 16.h,),
                  SizedBox(width: 8.w,),
                  Text(_getText(), style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040)),),
                ],
              )

            ],
          ),
        ),
      ),
    );
  }

  String _getText() {
    if (ref.watch(alarmProvider) != null) {
      AlarmInfo alarmInfo = ref.watch(alarmProvider)!;

      return alarmInfo.getAlarm()!;

    } else {
      return "";
    }
  }

  String _getTime() {
    if (ref.watch(alarmProvider) != null) {
      AlarmInfo alarmInfo = ref.watch(alarmProvider)!;

      DateTime date = DateTime.parse(alarmInfo.getCreatedAt()!);
      return DateFormat('MM.dd(E) HH:mm', 'ko').format(date);

    } else {
      return "";
    }
  }
}