import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:argoscareseniorsafeguard/pages/profile/parent_edit.dart';
import 'package:argoscareseniorsafeguard/pages/profile/profile_edit.dart';
import 'package:argoscareseniorsafeguard/pages/profile/airplane_mode.dart';
import 'package:argoscareseniorsafeguard/pages/profile/onboarding_first.dart';
import 'package:argoscareseniorsafeguard/pages/profile/announcement.dart';

import 'package:argoscareseniorsafeguard/dialogs/custom_confirm_dialog.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_alert_dialog.dart';


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
  bool _enableAlarm = false;
  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  void asyncInit() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      String localeStr = prefs.getString('languageCode') ?? 'ko';
      _enableAlarm = prefs.getBool('enableAlarm') ?? true;

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
              
                                                Text('${widget.userName}(${widget.userMail})',
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
                                                    "${gParentInfo['parentName'] == '' ? '성함: ?' : gParentInfo['parentName']} | ${gParentInfo['parentSex'] == -1 ? '성별: ?' : (gParentInfo['parentSex'] == 1 ? '남' : '여')} | ${gParentInfo['parentAge']}세 | ${gParentInfo['parentPhone']}",
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
                                  value: _enableAlarm,
                                  activeColor: Constants.primaryColor,
                                  onChanged: (bool? value) async {
                                    final SharedPreferences pref = await SharedPreferences.getInstance();
                                    pref.setBool('enableAlarm', value!);
                                    _enableAlarm = value;

                                    try {
                                      final response = await dio.post(
                                          "/users/enableAlarm",
                                          data: jsonEncode({
                                            "userID": widget.userID,
                                            "enableAlarm": _enableAlarm,
                                          })
                                      );
                                    } catch(e) {
                                      debugPrint(e as String?);
                                    }

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

                          /*_showCategory("요금제", SvgPicture.asset('assets/images/rateplan_small.svg', width: 16.w, height: 16.h,)),

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
                          )),*/
              
                          // _showCategory("장치공유", SvgPicture.asset('assets/images/share_small.svg', width: 16.w, height: 16.h,)),
                          //
                          // _showDetail("장치공유", SizedBox(
                          //   width: 24.w,
                          //   height: 24.h,
                          //   // color: Colors.redAccent,
                          //   child: IconButton(
                          //     constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                          //     padding: EdgeInsets.zero,
                          //     color: Constants.dividerColor,
                          //     icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                          //     onPressed: () {
                          //       debugPrint('icon press');
                          //     },
                          //   ),
                          // )),

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
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return Announcement(userID: widget.userID);
                                }));
                              },
                            ),
                          )),

                          SizedBox(height: 16.h,),

                          // _showDetail("서비스 소개", SizedBox(
                          //   width: 24.w,
                          //   height: 24.h,
                          //   // color: Colors.redAccent,
                          //   child: IconButton(
                          //     constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                          //     padding: EdgeInsets.zero,
                          //     color: Constants.dividerColor,
                          //     icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                          //     onPressed: () {
                          //       debugPrint('icon press');
                          //     },
                          //   ),
                          // )),
                          //
                          // SizedBox(height: 16.h,),

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

                          // _showDetail("이용약관", SizedBox(
                          //   width: 24.w,
                          //   height: 24.h,
                          //   // color: Colors.redAccent,
                          //   child: IconButton(
                          //     constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                          //     padding: EdgeInsets.zero,
                          //     color: Constants.dividerColor,
                          //     icon: const Icon(Icons.arrow_forward_ios_rounded, size: 18),
                          //     onPressed: () {
                          //       debugPrint('icon press');
                          //     },
                          //   ),
                          // )),
                          //
                          // SizedBox(height: 16.h,),

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
                                showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        backgroundColor: Constants.scaffoldBackgroundColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        insetPadding: EdgeInsets.all(20.w),
                                        child: const CustomAlertDialog(title: "확인", message: "현재버전: 0.0.1"),
                                      );
                                    }
                                );
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
                                _logout(context);
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
                                _unregister(context);
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

  void _logout(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Constants.scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: EdgeInsets.all(20.w),
            child: const CustomConfirmDialog(title: "확인", message: "로그아웃하고 앱을 종료하시겠습니까?"),
          );
        }
    ).then((val) async {
      if (val == 'Ok') {
        try {
          final mobileDeviceIdentifierPlugin = MobileDeviceIdentifier();
          String deviceID = "";
          deviceID = await mobileDeviceIdentifierPlugin.getDeviceId() ?? 'Unknown platform version';
          deviceID = base64.encode(utf8.encode(deviceID));

          await dio.get(
            "/auth/logout/$deviceID",
          );

          _logoutProcess();

        } catch (e) {
          print("logout error");
        }
      }
    });
  }

  void _unregister(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Constants.scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: EdgeInsets.all(20.w),
            child: const CustomConfirmDialog(title: "확인", message: "회원탈퇴를 하면 모든 데이타가 삭제됩니다. 계속하시겠습니까?"),
          );
        }
    ).then((val) async {
      if (val == 'Ok') {
        try {
          await dio.post(
              "/auth/unregister",
              data: jsonEncode({
                "userID": widget.userID,
              })
          );

          _logoutProcess();

        } catch (e) {
          print(e);
        }
      }
    });
  }

  void _logoutProcess() async {
    try {
      const storage = FlutterSecureStorage(
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );
      await storage.delete(key: "ACCESS_TOKEN");
      await storage.delete(key: 'ID');
      await storage.delete(key: 'EMAIL');
      await storage.delete(key: 'PASSWORD');

      Directory appDocumentsDirectory = await getApplicationDocumentsDirectory();
      Directory targetDir = Directory("${appDocumentsDirectory.path}/.cookies");
      await targetDir.delete(recursive: true);
      // await File("${appDocumentsDirectory.path}/.cookies").delete();

      final SharedPreferences pref = await SharedPreferences.getInstance();
      pref.remove('name');
      pref.remove('parentName');
      pref.remove('parentAge');
      pref.remove('parentPhone');
      pref.remove('parentSex');
      pref.remove('addr_zip');
      pref.remove('addr');
      pref.remove('addr_detail');
      pref.remove('mobilephone');
      pref.remove('tel');
      pref.remove('snsId');
      pref.remove('provider');
      pref.remove('admin');
      pref.remove('shareKey');
      pref.remove('isLogin');
      pref.remove("useAirplaneMode");
      pref.remove("enableAlarm");
      pref.remove("useAirplaneMode");
      pref.remove('saveLoginID');

      SystemNavigator.pop();
    } catch (e) {
      print(e);
    }

  }
}