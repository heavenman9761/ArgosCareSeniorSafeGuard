import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/models/announcement.dart';
import 'package:intl/intl.dart';
import 'package:argoscareseniorsafeguard/pages/profile/announcement_detail.dart';

class Announcement extends StatefulWidget {
  const Announcement({super.key, required this.userID});

  final String userID;

  @override
  State<Announcement> createState() => _AnnouncementState();
}

class _AnnouncementState extends State<Announcement> {
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
                      Text("공지 사항", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                    ],
                  ),
                ),
              ),

              Expanded(
                  child: Container(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 8.h),
                      child: FutureBuilder<List<AnnouncementInfo>>(
                        future: _getAnnouncementList(),
                        builder: (context, snapshot) {
                          final List<AnnouncementInfo>? announcementList = snapshot.data;
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
                            if (announcementList != null) {
                              if (announcementList.isEmpty) {
                                return Center(
                                  child: Text("데이터가 없습니다.", style: TextStyle(fontSize: 14.sp, color: Constants.dividerColor), textAlign: TextAlign.center),
                                );
                              }

                              return ListView.builder(
                                itemCount: announcementList.length,
                                itemBuilder: (context, index) {

                                  return Column(
                                    children: [
                                      _showTitle(announcementList[index], SizedBox(
                                        width: 24.w,
                                        height: 24.h,
                                        // color: Colors.redAccent,
                                        child: IconButton(
                                          constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                                          padding: EdgeInsets.zero,
                                          color: Constants.dividerColor,
                                          icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                                              return AnnouncementDetail(announcement: announcementList[index]);
                                            }));
                                          },
                                        ),
                                      )),
                                      SizedBox(height: 16.h)
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
                  )
              )
            ],
          ),
        )
    );
  }

  Future<List<AnnouncementInfo>> _getAnnouncementList() async {
    try {
      final response = await dio.get(
          "/announcement",
      );

      return (response.data as List)
          .map((x) => AnnouncementInfo.fromJson(x))
          .toList();

    } catch(e) {
      return [];
    }
  }

  Widget _showTitle(AnnouncementInfo announcementInfo, Widget control) {
    return Container(
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
              children: [
                Expanded(
                  child: SizedBox(
                    height: double.infinity,
                    width: double.infinity,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(announcementInfo.getTitle()!, style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold), overflow: TextOverflow.ellipsis),
                        SizedBox(height: 5.h),
                        Text(DateFormat('MM.dd (E) HH:mm','ko').format(DateTime.parse(announcementInfo.getCreatedAt()!)),
                          style: TextStyle(fontSize: 12.sp, color: Constants.dividerColor), ),
                      ],
                    ),
                  ),
                ),
                // const Spacer(),
                SizedBox(
                  height: 24.h,
                  width: 24.w,
                  child: control
                ),
              ],
            )

        )
    );
  }

}
