import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:argoscareseniorsafeguard/pages/setting_alarm.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/models/sensor.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/pages/profile.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:argoscareseniorsafeguard/pages/share_manage.dart';
import 'package:argoscareseniorsafeguard/pages/profile/parent_edit.dart';
import 'package:argoscareseniorsafeguard/pages/profile/profile_edit.dart';
import 'package:argoscareseniorsafeguard/pages/profile/airplane_mode.dart';
import 'package:argoscareseniorsafeguard/pages/profile/onboarding_first.dart';

class ProfileWidget extends StatefulWidget {
  final String userID;
  final String userName;
  final String userMail;

  const ProfileWidget({super.key, required this.userName, required this.userID, required this.userMail});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final List<String> _languageList = ['한국어', 'English'];
  String _selectedLanguage = '한국어';
  bool _allowAlarm = true;
  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  void asyncInit() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      String localeStr = prefs.getString('languageCode') ?? 'ko';
      _allowAlarm = prefs.getBool('allowAlarm') ?? true;

      if (localeStr == "ko") { _selectedLanguage = "한국어"; }
      else if (localeStr == "en") { _selectedLanguage = "English"; }
    });

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
            SizedBox(
            // color: Colors.blueAccent,
            height: 52.h,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(AppLocalizations.of(context)!.app_title, style: TextStyle(fontSize: 16.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
                ],
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
                    Text("내 정보", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: SizedBox(
                  child: SingleChildScrollView(
                      child: Column(
                        children: [
                          _showCategory("프로필", Icon(Icons.account_circle_outlined, size: 16.h,)),
              
                          Padding( //보호자
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                            child: Container(
                              // color: Colors.blueAccent,
                                height: 88.h,
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
                                        SvgPicture.asset('assets/images/parent_unknown.svg', width: 52.w, height: 52.h),
              
                                        SizedBox(width: 16.w),
              
                                        Expanded(
                                          child: SizedBox(
                                            height: double.infinity,
                                            width: double.infinity,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("보호자", style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
                                                    const Spacer(),
                                                    SizedBox(
                                                        width: 48.w,
                                                        height: 28.h,
                                                        // color: Colors.redAccent,
                                                        child: OutlinedButton( // OutlinedButton
                                                          style: OutlinedButton.styleFrom(
                                                            foregroundColor: Constants.primaryColor,
                                                            backgroundColor: Constants.scaffoldBackgroundColor,
                                                            elevation: 1, //
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                                                            minimumSize: Size(48.w, 28.h),
                                                            maximumSize: Size(48.w, 28.h),
                                                            padding: const EdgeInsets.all(0),
                                                            side: const BorderSide(width: 1.0, color: Constants.primaryColor),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                              return ProfileEdit(userID: widget.userID);
                                                            })).then((onValue) {
                                                              setState(() {

                                                              });
                                                            });
                                                          },
                                                          child: Text('편집', style: TextStyle(fontSize: 12.sp, color: Constants.primaryColor), ),)
                                                    )
                                                  ],
                                                ),
              
                                                SizedBox(height: 4.h,),
              
                                                Text('${widget.userName}(${widget.userMail})', style: TextStyle(fontSize: 12.sp, color: Constants.dividerColor), overflow: TextOverflow.ellipsis),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                )
                            ),
                          ),

                          SizedBox(height: 16.h),
              
                          Padding( //대상자
                            padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                            child: Container(
                              // color: Colors.blueAccent,
                                height: 88.h,
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
                                        //Image(image: const AssetImage('assets/images/parent_male.png'), width: 52.w, height: 52.h,),
                                        gParentInfo['parentSex'] == -1
                                            ? SvgPicture.asset('assets/images/parent_unknown.svg', width: 52.w, height: 52.h,)
                                            : (gParentInfo['parentSex'] == 1
                                                  ? Image(image: AssetImage('assets/images/parent_male.png'), width: 52.w, height: 52.h,)
                                                  : Image(image: AssetImage('assets/images/parent_female.png'), width: 52.w, height: 52.h,)
                                              ),
              
                                        SizedBox(width: 16.w),
              
                                        Expanded(
                                          child: SizedBox(
                                            height: double.infinity,
                                            width: double.infinity,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.start,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text("대상자", style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
                                                    const Spacer(),
                                                    SizedBox(
                                                        width: 48.w,
                                                        height: 28.h,
                                                        // color: Colors.redAccent,
                                                        child: OutlinedButton( // OutlinedButton
                                                          style: OutlinedButton.styleFrom(
                                                            foregroundColor: Constants.primaryColor,
                                                            backgroundColor: Constants.scaffoldBackgroundColor,
                                                            elevation: 1, //
                                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                                                            minimumSize: Size(48.w, 28.h),
                                                            maximumSize: Size(48.w, 28.h),
                                                            padding: const EdgeInsets.all(0),
                                                            side: const BorderSide(width: 1.0, color: Constants.primaryColor),
                                                          ),
                                                          onPressed: () {
                                                            Navigator.push(context, MaterialPageRoute(builder: (context) {
                                                              return ParentEdit(userID: widget.userID);
                                                            })).then((onValue) {
                                                              setState(() {

                                                              });
                                                            });
                                                          },
                                                          child: Text('편집', style: TextStyle(fontSize: 12.sp, color: Constants.primaryColor), ),)
                                                    )
                                                  ],
                                                ),
              
                                                SizedBox(height: 4.h,),
              
                                                Text(
                                                    "${gParentInfo['parentName']} | ${gParentInfo['parentSex'] == 1 ? '남' : '여'} | ${gParentInfo['parentAge']}세 | ${gParentInfo['parentPhone']}",
                                                    style: TextStyle(fontSize: 12.sp, color: Constants.dividerColor),
                                                    overflow: TextOverflow.ellipsis
                                                ),
                                              ],
                                            ),
                                          ),
                                        )
                                      ],
                                    )
                                )
                            ),
                          ),

                          _showCategory("알림설정", SvgPicture.asset('assets/images/alarm_small.svg', width: 16.w, height: 16.h,)),

                          _showDetail("알림", SizedBox(
                              height: 25.h,
                              width: 45.w,
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: CupertinoSwitch(
                                  value: _allowAlarm,
                                  activeColor: Constants.primaryColor,
                                  onChanged: (bool? value) async {
                                    final SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setBool('allowAlarm', value!);
                                    _allowAlarm = value;
                                    setState(() {

                                    });
                                  },
                                ),
                              )
                          )),

                          SizedBox(height: 16.h),
              
                          _showDetail("방해금지모드", SizedBox(
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
                                  return AirPlaneMode(userID: widget.userID);
                                }));
                              },
                            ),
                          )),

                          _showCategory("요금제", SvgPicture.asset('assets/images/rateplan_small.svg', width: 16.w, height: 16.h,)),

                          _showDetail("요금제", SizedBox(
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
                          )),
              
                          _showCategory("장치공유", SvgPicture.asset('assets/images/share_small.svg', width: 16.w, height: 16.h,)),

                          _showDetail("장치공유", SizedBox(
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
                          )),

                          _showCategory("앱설정", Icon(Icons.phone_android, size: 16.h)),

                          _showDetail("공지사항", SizedBox(
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
                          )),
              
                          SizedBox(height: 16.h,),

                          _showDetail("서비스 소개", SizedBox(
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
                          )),
              
                          SizedBox(height: 16.h,),

                          _showDetail("이용안내", SizedBox(
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
                                  return const OnFirstBoardingPage();
                                }));
                              },
                            ),
                          )),

                          SizedBox(height: 16.h,),

                          _showDetail("이용약관", SizedBox(
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
                          )),

                          SizedBox(height: 16.h,),

                          _showDetail("버전정보", SizedBox(
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
                          )),

                          SizedBox(height: 16.h,),

                          _showDetail("로그아웃", SizedBox(
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
                          )),

                          SizedBox(height: 16.h,),

                          _showDetail("회원탈퇴", SizedBox(
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
                          )),

                          SizedBox(height: 16.h,),
                        ],
                      )
                  )
              ),
            )
          ],
        )
      ),
    );
  }

  Widget _showCategory(String title, Widget image) {
    return SizedBox(
      // color: Colors.redAccent,
        height: 40.h,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
          child: Row(
            children: [
              image,
              SizedBox(width: 4.w,),
              Text(title, style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040)), ),
            ],
          ),
        )
    );
  }

  Widget _showDetail(String title, Widget control) {
    return Padding( //알림
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      child: Container(
        // color: Colors.blueAccent,
          height: 60.h,
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
                  Text(title, style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold), ),

                  Expanded(
                    child: SizedBox(
                      height: double.infinity,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          control
                        ],
                      ),
                    ),
                  )
                ],
              )
          )
      ),
    );
  }

  Future<List<Sensor>> _getSensorList() async {
    DBHelper sd = DBHelper();
    return await sd.getSensors(widget.userID);
  }

  void _goSettingAlarm(BuildContext context) async {
    List<Sensor> list = await _getSensorList();
    if (!context.mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SettingAlarm(userID: widget.userID, sensorList: list);
    }));
  }

  void _goShareManage(BuildContext context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ShareManage(userID: widget.userID);
    }));
  }

  void _goProfile(BuildContext context) async {
    List<Sensor> list = await _getSensorList();
    if (!context.mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const Profile();
    }));
  }
}