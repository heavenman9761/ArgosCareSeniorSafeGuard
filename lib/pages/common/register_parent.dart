import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/components/my_textfield.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_alert_dialog.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_confirm_dialog.dart';

class RegisterParent extends StatefulWidget {
  const RegisterParent({
    super.key,
    required this.email,
    required this.name,
    required this.password,
    required this.mobilePhone,
    required this.tel,
    required this.addrzip,
    required this.addr,
    required this.detailAddr,
    required this.deviceID,
    required this.optionalCheck
  });

  final String email;
  final String name;
  final String password;
  final String mobilePhone;
  final String tel;
  final String addrzip;
  final String addr;
  final String detailAddr;
  final String deviceID;
  final bool optionalCheck;

  @override
  State<RegisterParent> createState() => _RegisterParentState();
}

class _RegisterParentState extends State<RegisterParent> {
  String _parentName = "";
  final _nameController = TextEditingController();
  final FocusNode _nameFocusNode = FocusNode();

  String _parentPhone = "";
  final _phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();

  bool _male = false;
  bool _female = false;

  String _year = Constants.yearText[0];
  int _yearIndex = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();

    _nameFocusNode.dispose();
    _nameController.dispose();
    _phoneFocusNode.dispose();
    _phoneController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Constants.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Column(
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
                          Text("대상자 등록", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold),),
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
                          Text("이름", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040), fontWeight: FontWeight.bold),),
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
                        child: renderTextFormField(
                          context: context,
                          label: '실명을 붙여서 입력해 주세요',
                          keyNumber: 4,
                          suffixIcon: _nameController.text.isNotEmpty ?
                          IconButton(
                            icon: SvgPicture.asset("assets/images/textfield_delete.svg"),
                            onPressed: () {
                              _nameController.clear();
                              setState(() { });
                            },
                          ) : null,
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          obscureText: false,
                          focusNode: _nameFocusNode,
                          onChanged: (val) {
                            setState(() { });
                          },
                          onSaved: (val) {
                            setState(() {
                              _parentName = val;
                            });
                          },
                          validator: (val) {
                            if (val.length < 1) {
                              return '이름은 필수 사항 입니다.';
                            }

                            if (val.length < 2) {
                              return '이름은 두 글자 이상 입력해 주셔야 합니다.';
                            }

                            return null;
                          },
                        ),
                      )
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
                          Text("성별", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040), fontWeight: FontWeight.bold),),
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
                          children: [
                            Flexible(
                              flex: 1,
                              child: Container(
                                height: 60.h,
                                decoration: BoxDecoration(
                                    color: Constants.scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFF0F0F0))
                                ),
                                child: Row(
                                  children: [
                                    Checkbox(
                                      value: _male,
                                      splashRadius: 24,
                                      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(2),
                                      ),
                                      side: const BorderSide(color: Color(0xFFCBCBCB)),
                                      onChanged: (value) {
                                        setState(() {
                                          _male = value!;
                                          _female = !value;
                                        });
                                      },

                                    ),
                                    const Spacer(),
                                    Text("남", style: TextStyle(fontSize: 14.sp, color: const Color(0xFFCBCBCB)),),
                                    SizedBox(width: 16.w,)
                                  ],
                                ),
                              )
                            ),
                            SizedBox(width: 16.w,),
                            Flexible(
                                flex: 1,
                                child: Container(
                                  height: 60.h,
                                  decoration: BoxDecoration(
                                    color: Constants.scaffoldBackgroundColor,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFFF0F0F0))
                                  ),
                                  child: Row(
                                    children: [
                                      Checkbox(
                                        value: _female,
                                        splashRadius: 24,
                                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(2),
                                        ),
                                        side: const BorderSide(color: Color(0xFFCBCBCB)),
                                        onChanged: (value) {
                                          setState(() {
                                            _female = value!;
                                            _male = !value;
                                          });
                                        },

                                      ),
                                      const Spacer(),
                                      Text("여", style: TextStyle(fontSize: 14.sp, color: const Color(0xFFCBCBCB)),),
                                      SizedBox(width: 16.w,)
                                    ],
                                  ),
                                )
                            ),
                          ],
                        ),
                      )
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
                          Text("생년", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040), fontWeight: FontWeight.bold),),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(
                    // color: Colors.blueAccent,
                      height: 60.h,
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                        child: Container(
                          height: 60.h,
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: Constants.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: const Color(0xFFF0F0F0))
                          ),
                          child: Row(
                            children: [
                              SizedBox(width: 16.w),
                              _yearIndex > -1 ? Text(Constants.yearText[_yearIndex]) : const Text(""),
                              const Spacer(),
                              // SvgPicture.asset("assets/images/select_number.svg", width: 24.w, height: 24.h),
                              IconButton(
                                constraints: const BoxConstraints(maxHeight: 48, maxWidth: 48),
                                splashRadius: 10,
                                padding: EdgeInsets.zero,
                                icon: SvgPicture.asset('assets/images/select_number.svg', width: 24.w, height: 24.h,),
                                onPressed: () {
                                  _showModalSheet(context);
                                },
                              ),
                              // SizedBox(width: 16.w)
                            ],
                          ),
                        ),
                      )
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
                          Text("휴대폰 번호(선택)", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040), fontWeight: FontWeight.bold),),
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
                        child: renderTextFormField(
                          context: context,
                          label: "'-' 없이 숫자만 입력",
                          keyNumber: 4,
                          suffixIcon: _phoneController.text.isNotEmpty ?
                          IconButton(
                            icon: SvgPicture.asset("assets/images/textfield_delete.svg"),
                            onPressed: () {
                              _phoneController.clear();
                              setState(() { });
                            },
                          ) : null,
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          obscureText: false,
                          focusNode: _phoneFocusNode,
                          onChanged: (val) {
                            setState(() { });
                          },
                          onSaved: (val) {
                            setState(() {
                              _parentPhone = val;
                            });
                          },
                        ),
                      )
                  ),

                  SizedBox(height: 52.h,),

                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                    child: MyButton2(
                      onTap: () {
                        _register(context);
                      },
                      text: "나중에 등록",
                    ),
                  ),

                  SizedBox(height: 16.h,),

                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 20.h),
                    child: MyButton(
                      onTap: () {
                        _registerWithParent(context);
                      },
                      text: "확인",
                    ),
                  ),

                  SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 100),
                ],
              ),
            ),
          ),
        ),
      )
    );
  }

  void _showModalSheet(BuildContext context) {
    showModalBottomSheet<void>(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        isDismissible: false,
        enableDrag: false,
        builder: (BuildContext context) {
          return StatefulBuilder(builder: (BuildContext context, StateSetter bottomState) {
            return Container(
              height: 356.h,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20.0.h),
                  topRight: Radius.circular(20.0.h),
                ),
                color: Constants.scaffoldBackgroundColor,
              ),
              child: Center(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          SizedBox(height: 40.h),
                          IconButton(
                              onPressed: () {
                                bottomState(() {
                                  setState(() {
                                    _yearIndex = -1;
                                  });
                                });

                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.close),
                              color: Colors.black
                          )
                        ],
                      ),
                      SizedBox(height: 20.h, child: Text(_year, style: TextStyle(fontSize: 16.sp),)),
                      SizedBox(
                        height: 220.h,
                        width: 320.w,
                        child: CupertinoPicker.builder(
                            itemExtent: 44,
                            scrollController: FixedExtentScrollController(initialItem: 0),
                            childCount: Constants.yearText.length,
                            onSelectedItemChanged: (i) {
                              bottomState(() {
                                setState(() {
                                  _year = Constants.yearText[i];
                                  _yearIndex = i;
                                });
                              });

                            },
                            itemBuilder: (context, index) {
                              return Center(child: Text(Constants.yearText[index], style: TextStyle(fontSize: 20.sp),));
                            }),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0.h),
                        child: MyButton(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          text: "확인",
                        ),
                      ),
                    ]
                ),
              ),
            );
          });
        }
    );
  }

  void _registerWithParent(BuildContext context) async {
    if (_nameController.text == "") {
      _showAlertDialog("오류", "대상자 이름을 입력해 주세요.");
      return;
    }

    if (!_female && !_male) {
      _showAlertDialog("오류", "대상자 성별을 체크해주세요.");
      return;
    }

    if (_yearIndex == -1) {
      _showAlertDialog("오류", "대상자 생년을 입력해 주세요.");
      return;
    }

    try {
      var uri = kReleaseMode ? Constants.BASE_URL_RELEASE : Constants.BASE_URL_DEBUG;
      BaseOptions options = BaseOptions(
        baseUrl: uri,
      );
      var dio = Dio(options);

      final response = await dio.post('/auth/signup',
          data: jsonEncode({
            "email": widget.email,
            "name": widget.name,
            "password": widget.password,
            "mobilephone": widget.mobilePhone,
            "tel": widget.tel,
            "addr_zip": widget.addrzip,
            "addr": widget.addr,
            "addr_detail": widget.detailAddr,
            "admin": false,
            "deviceID": widget.deviceID,
            "parentName": _nameController.text,
            "parentAge": Constants.ages[_yearIndex],
            "parentPhone": _phoneController.text,
            "parentSex": _male ? 1 : 2,
            "optionalCheck": widget.optionalCheck
          })
      );

      if (response.statusCode == 201) {
        _showAlertDialog("확인", response.data['message']);
      } else {
        if (!context.mounted) return;
        _complete(context);
      }
    } catch (e) {
      _showAlertDialog("오류", "회원 가입이 실패 했습니다.\n관리자에게 확인 바랍니다.");
    }
  }

  void _register(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Constants.scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: EdgeInsets.all(20.w),
            child: const CustomConfirmDialog(title: "확인", message: "대상자없이 회원가입 하시겠습니까?"),
          );
        }
    ).then((val) async {
      if (val == 'Ok') {
        try {
          var uri = kReleaseMode ? Constants.BASE_URL_RELEASE : Constants.BASE_URL_DEBUG;
          BaseOptions options = BaseOptions(
            baseUrl: uri,
          );
          var dio = Dio(options);

          final response = await dio.post('/auth/signup',
              data: jsonEncode({
                "email": widget.email,
                "name": widget.name,
                "password": widget.password,
                "mobilephone": widget.mobilePhone,
                "tel": widget.tel,
                "addr_zip": widget.addrzip,
                "addr": widget.addr,
                "addr_detail": widget.detailAddr,
                "admin": false,
                "deviceID": widget.deviceID,
                "parentName": "",
                "parentAge": 0,
                "parentPhone": "",
                "parentSex": -1,
                "optionalCheck": widget.optionalCheck
              })
          );

          if (response.statusCode == 201) {
            _showAlertDialog("확인", response.data['message']);
          } else {
            if (!context.mounted) return;
            _complete(context);

          }
        } catch (e) {
          _showAlertDialog("오류", "회원 가입이 실패 했습니다.\n관리자에게 확인 바랍니다.");
        }
      }
    });

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

  void _complete(BuildContext context) {
    if (!context.mounted) return;
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Constants.scaffoldBackgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            insetPadding: EdgeInsets.all(20.w),
            child: const CustomAlertDialog(title: "확인", message: "회원 가입이 완료되었습니다."),
          );
        }
    ).then((val) {
      if (!context.mounted) return;
      Navigator.pop(context); //
      Navigator.pop(context); //
      Navigator.pop(context); //
    });
  }
}
