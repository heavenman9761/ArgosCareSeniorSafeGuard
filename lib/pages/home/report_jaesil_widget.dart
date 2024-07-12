import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';

import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/constants.dart';

class ReportJaesilWidget extends ConsumerStatefulWidget {
  const ReportJaesilWidget({super.key});

  @override
  ConsumerState<ReportJaesilWidget> createState() => _ReportJaesilWidget();
}

class _ReportJaesilWidget extends ConsumerState<ReportJaesilWidget> {
  @override
  Widget build(BuildContext context) {
    return Container(
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
                          text: "${gParentInfo['parentName']}님은 현재 ",
                          style: TextStyle(fontSize: 14.sp, color: Colors.black,),
                          children: <TextSpan>[
                            TextSpan(
                              text: _getJaeSilText(),//'재실',
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
    )/**/;
  }

  String _getJaeSilText() {
    return ref.watch(jaeSilStateProvider) == JaeSilStateEnum.jsNone
        ? "재실 확인불가"
        : (ref.watch(jaeSilStateProvider) == JaeSilStateEnum.jsIn ? "재실": "외출");
  }
}
