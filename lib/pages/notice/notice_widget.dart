import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:argoscareseniorsafeguard/constants.dart';

class NoticeWidget extends StatefulWidget {
  const NoticeWidget({super.key, required this.userName, required this.userID});

  final String userName;
  final String userID;

  @override
  State<NoticeWidget> createState() => _NoticeWidgetState();
}

class _NoticeWidgetState extends State<NoticeWidget> {
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
              _getDate("오늘 2024.06.19"),
              _getEvent(),
              _getEvent(),
              _getDate("2024.06.18"),
              _getEvent(),
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
            const Spacer(),
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
            )

          ],
        ),
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

  Widget _getDate(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
          width: 140.w,
          height: 28.h,
          decoration: BoxDecoration(
            color: Constants.secondaryColor,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              SvgPicture.asset('assets/images/calendar_small.svg', width: 20.w, height: 20.h,),
              SizedBox(width: 4.w,),
              Text(title, style: TextStyle(fontSize: 12.sp, color: Color(0xFF404040)), ),
              SizedBox(width: 4.w,),

            ],
          )
      ),
    );
  }

  Widget _getEvent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: Container(
        // color: Colors.blueAccent,
          height: 80.h,
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
          child: Padding(
              padding: EdgeInsets.all(16.0.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("허브 연결을 확인해 주세요", style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
                      SizedBox(height: 7.h,),
                      Text("06.10(월) 14:30", style: TextStyle(fontSize: 12.sp, color: Constants.dividerColor), ),
                    ],
                  ),
                  const Spacer(),
                  SizedBox(
                    width: 24.w,
                    height: 24.h,
                    // color: Colors.redAccent,
                    child: IconButton(
                      constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                      padding: EdgeInsets.zero,
                      color: Constants.dividerColor,
                      icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                      onPressed: () {
                        debugPrint('icon press');
                      },
                    ),
                  )
                ],
              )
          )
      ),
    );
  }
}
