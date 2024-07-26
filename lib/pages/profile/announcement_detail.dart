import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:argoscareseniorsafeguard/models/announcement.dart';
import 'package:intl/intl.dart';

class AnnouncementDetail extends StatefulWidget {
  const AnnouncementDetail({super.key, required this.announcement});
  final AnnouncementInfo announcement;

  @override
  State<AnnouncementDetail> createState() => _AnnouncementDetailState();
}

class _AnnouncementDetailState extends State<AnnouncementDetail> {
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
                    Expanded(
                      child: SizedBox(
                          width: double.infinity,
                          child: Text(
                                  widget.announcement.getTitle()!,
                                  style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis
                                ),
                        )
                      ),
                  ],
                ),
              ),
            ),

            SizedBox(
              // color: Colors.blueAccent,
              height: 17.h,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(DateFormat('MM.dd (E) HH:mm','ko').format(DateTime.parse(widget.announcement.getCreatedAt()!)),
                        style: TextStyle(fontSize: 12.sp, color: Constants.dividerColor), ),
                  ],
                ),
              ),
            ),

            SizedBox(
              // color: Colors.blueAccent,
              height: 20.h,
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                child: Center(
                  child: Container(
                    height: 1.h,
                    width: double.infinity,
                    color: Constants.borderColor
                  ),
                )
              ),
            ),

            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                child: Container(
                  color: Constants.borderColor,
                  height: double.infinity,
                  width: double.infinity,
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        widget.announcement.getContent()!,
                        style: TextStyle(fontSize: 14.sp, color: Colors.black),
                      ),
                    )
                  )
                ),
              ),
            ),

            SizedBox(height: 16.h)
          ],
        ),
      )
    );
  }
}
