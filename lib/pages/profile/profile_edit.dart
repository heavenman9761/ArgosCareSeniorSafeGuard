import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:remedi_kopo/remedi_kopo.dart';

import 'package:iamport_flutter/model/certification_data.dart';
import 'package:iamport_flutter/model/url_data.dart';
import 'package:argoscareseniorsafeguard/pages/common/phone_certification.dart';

import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/components/my_textfield.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_alert_dialog.dart';
import 'package:argoscareseniorsafeguard/pages/profile/change_password.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key, required this.userID});
  final String userID;

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  final _formKey = GlobalKey<FormState>();

  String _mail = '';
  String _name = '';
  String _mobilePhone = '';
  String _addrzip = '';
  String _addr = '';
  String _detailAddr = '';

  final _zipController = TextEditingController();
  final _addrController = TextEditingController();
  final _detailAddrController = TextEditingController();

  final FocusNode _zipAddrFocusNode = FocusNode();
  final FocusNode _addrFocusNode = FocusNode();
  final FocusNode _detailAddrFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();

    asyncInit();
  }

  @override
  void dispose() {
    super.dispose();

    _zipAddrFocusNode.dispose();
    _addrFocusNode.dispose();
    _detailAddrFocusNode.dispose();

    _zipController.dispose();
    _addrController.dispose();
    _detailAddrController.dispose();
  }

  void asyncInit() async {
    const storage = FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );

    _mail = (await storage.read(key: 'EMAIL'))!;

    final SharedPreferences pref = await SharedPreferences.getInstance();

    _name = pref.getString('name')!;
    _mobilePhone = pref.getString('mobilephone')!;
    _zipController.text = pref.getString('addr_zip')!;
    _addrController.text = pref.getString('addr')!;
    _detailAddrController.text = pref.getString('addr_detail')!;

    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Constants.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView (
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Form(
                key: _formKey,
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
                            Text("보호자 수정", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      // color: Colors.blueAccent,
                      height: 40.h,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("아이디", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040), fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                      child: Container(
                        height: 60.h,
                        width: 320.w,
                        decoration: BoxDecoration(
                          border: Border.all(color: Constants.borderColor),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.transparent,

                        ),
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(16.w, 0, 20.w, 0),
                          child: Row(
                            children: [
                              Text(_mail, style: TextStyle(fontSize: 16.sp),),
                            ],
                          )
                        )
                      ),
                    ),

                    SizedBox(height: 12.h),

                    SizedBox(
                      // color: Colors.blueAccent,
                      height: 40.h,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("이름", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040), fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                      child: Container(
                          height: 60.h,
                          width: 320.w,
                          decoration: BoxDecoration(
                            border: Border.all(color: Constants.borderColor),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.transparent,

                          ),
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(16.w, 0, 20.w, 0),
                              child: Row(
                                children: [
                                  Text(_name, style: TextStyle(fontSize: 16.sp),),
                                ],
                              )
                          )
                      ),
                    ),

                    SizedBox(height: 12.h),

                    SizedBox(
                      // color: Colors.blueAccent,
                      height: 40.h,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("휴대폰 번호", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040), fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                      child: Container(
                          height: 60.h,
                          width: 320.w,
                          decoration: BoxDecoration(
                            border: Border.all(color: Constants.borderColor),
                            borderRadius: BorderRadius.circular(8),
                            color: Colors.transparent,

                          ),
                          child: Padding(
                              padding: EdgeInsets.fromLTRB(16.w, 0, 20.w, 0),
                              child: Row(
                                children: [
                                  Text(_mobilePhone, style: TextStyle(fontSize: 16.sp),),
                                ],
                              )
                          )
                      ),
                    ),

                    SizedBox(height: 12.h),

                    SizedBox(
                      // color: Colors.blueAccent,
                      height: 40.h,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text("주소 (선택)", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040), fontWeight: FontWeight.bold),),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(
                      // color: Colors.blueAccent,
                        height: 60.h,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: renderTextFormField(
                                    context: context,
                                    label: '우편 번호',
                                    keyNumber: 1,
                                    suffixIcon: _zipController.text.isNotEmpty ?
                                    IconButton(
                                      icon: SvgPicture.asset("assets/images/textfield_delete.svg"),
                                      onPressed: () {
                                        _zipController.clear();
                                        setState(() { });
                                      },
                                    ) : null,
                                    controller: _zipController,
                                    keyboardType: TextInputType.number,
                                    obscureText: false,
                                    focusNode: _zipAddrFocusNode,
                                    onSaved: (val) {
                                      setState(() {
                                        _addrzip = val;
                                      });

                                    },
                                    validator: (val) {
                                      return null;
                                    },
                                  ),
                                ),
                                SizedBox(width: 10.w,),
                                SizedBox(
                                    width: 80.w,
                                    height: 40.h,
                                    // color: Colors.redAccent,
                                    child: OutlinedButton( // OutlinedButton
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Constants.primaryColor,
                                        backgroundColor: Constants.scaffoldBackgroundColor,
                                        elevation: 1, //
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                                        minimumSize: Size(48.w, 28.h),
                                        maximumSize: Size(48.w, 28.h),
                                        padding: const EdgeInsets.all(0),
                                        side: const BorderSide(width: 1.0, color: Constants.primaryColor),
                                      ),
                                      onPressed: () async {
                                        KopoModel? model = await Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => RemediKopo(),
                                            )
                                        );

                                        if (model != null) {
                                          final postcode = model.zonecode ?? '';
                                          _zipController.text = postcode;

                                          final address = model.address ?? '';
                                          final buildingName = model.buildingName ?? '';
                                          _addrController.text = '$address $buildingName';
                                        }

                                        if (!context.mounted) return;
                                        FocusScope.of(context).requestFocus(_addrFocusNode);
                                      },
                                      child: Text('주소 검색', style: TextStyle(fontSize: 14.sp, color: Constants.primaryColor), ),)
                                ),


                              ]
                          ),
                        )
                    ),

                    SizedBox(height: 12.h),

                    SizedBox(
                      // color: Colors.blueAccent,
                        height: 60.h,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                          child: renderTextFormField(
                            context: context,
                            label: '주소',
                            keyNumber: 2,
                            suffixIcon: _addrController.text.isNotEmpty ?
                            IconButton(
                              icon: SvgPicture.asset("assets/images/textfield_delete.svg"),
                              onPressed: () {
                                _addrController.clear();
                                setState(() { });
                              },
                            ) : null,
                            controller: _addrController,
                            keyboardType: TextInputType.streetAddress,
                            obscureText: false,
                            focusNode: _addrFocusNode,
                            onSaved: (val) {
                              setState(() {
                                _addr = val;
                              });
                            },
                          ),
                        )
                    ),

                    SizedBox(height: 12.h),

                    Container(
                      // color: Colors.blueAccent,
                        height: 60.h,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                          child: renderTextFormField(
                            context: context,
                            label: '상세주소',
                            keyNumber: 3,
                            suffixIcon: _detailAddrController.text.isNotEmpty ?
                            IconButton(
                              icon: SvgPicture.asset("assets/images/textfield_delete.svg"),
                              onPressed: () {
                                _detailAddrController.clear();
                                setState(() { });
                              },
                            ) : null,
                            controller: _detailAddrController,
                            keyboardType: TextInputType.streetAddress,
                            obscureText: false,
                            focusNode: _detailAddrFocusNode,
                            onSaved: (val) {
                              setState(() {
                                _detailAddr = val;
                              });
                            },
                          ),
                        )
                    ),

                    const SizedBox(height: 10),
                    //


                    // const SizedBox(height: 10),

                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                      child: MyButton(
                        onTap: () {
                          _updateProfile(context);
                        },
                        text: "확인",
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0.h, 20.w, 20.h),
                      child: MyButton(
                        color: Colors.redAccent,
                        onTap: () {
                          _phoneCertification(context);
                        },
                        text: "비밀번호변경",
                      ),
                    ),

                    SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 100),
                  ],
                ),
              )
            )
          ),
        )
      )
    );
  }

  void _updateProfile(BuildContext context) async {
    try {
      _formKey.currentState!.save();

      final response = await dio.post('/users/editprofile',
          data: jsonEncode({
            "userID": widget.userID,
            "addr_zip": _addrzip,
            "addr": _addr,
            "addr_detail": _detailAddr,
          })
      );

      final SharedPreferences pref = await SharedPreferences.getInstance();

      pref.setString("addr_zip", response.data['addr_zip']);
      pref.setString("addr", response.data['addr']);
      pref.setString("addr_detail", response.data['addr_detail']);

      if (!context.mounted) return;
      Navigator.pop(context);

    } catch (e) {
      print(e.toString());
      _showAlertDialog("오류", "보호자 수정이 실패 했습니다.\n관리자에게 확인 바랍니다.");
    }
  }

  void _showAlertDialog(String title, String message) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Constants.scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: EdgeInsets.all(20.w),
            child: CustomAlertDialog(title: title, message: message),
          );
        }
    ).then((val) {
    });
  }

  void _phoneCertification(BuildContext ctx) async {
    // CertificationData data = CertificationData(
    //     pg: 'inicis_unified',
    //     merchantUid: 'mid_${DateTime.now().millisecondsSinceEpoch}',
    //     mRedirectUrl: UrlData.redirectUrl
    // );
    //
    // final result = await Navigator.push(context,
    //     MaterialPageRoute(builder: (ctx) {
    //       return PhoneCertification(userCode: 'imp71235150', data: data);
    //     })
    // );
    //
    // if (!ctx.mounted) return;
    //
    // if (result == '인증에 성공하였습니다.') {
      Navigator.push(ctx,
          MaterialPageRoute(builder: (context) {
            return ChangePassword(userID: widget.userID);
          })
      );
    // } else {
    //   showDialog(
    //       barrierDismissible: false,
    //       context: ctx,
    //       builder: (context) {
    //         return Dialog(
    //           backgroundColor: Constants.scaffoldBackgroundColor,
    //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    //           insetPadding: EdgeInsets.all(20.w),
    //           child: const CustomAlertDialog(title: "본인 인증", message: "본인인증에 실패했습니다."),
    //         );
    //       }
    //   ).then((val) {
    //   });
    // }
  }
}
