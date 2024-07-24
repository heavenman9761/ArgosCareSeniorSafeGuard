import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';

import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/components/my_textfield.dart';
import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/utils/string_extensions.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_alert_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FindPassword extends StatefulWidget {
  const FindPassword({super.key});

  @override
  State<FindPassword> createState() => _FindPasswordState();
}

class _FindPasswordState extends State<FindPassword> {
  final _formKey = GlobalKey<FormState>();

  bool isProcessing = false;

  String _email = '';
  String _newPassword = '';
  String _confirmNewPassword = '';

  bool _newPasswordVisible = true;
  bool _confirmNewPasswordVisible = true;

  final _mailController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _mailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Constants.scaffoldBackgroundColor,
        body: SafeArea(
          child: SingleChildScrollView (
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox (
              constraints: BoxConstraints(
                  minWidth: MediaQuery.of(context).size.width,
                  minHeight: MediaQuery.of(context).size.height
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
                                  Text("비밀번호 찾기", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold),),
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
                          SizedBox(
                            // color: Colors.blueAccent,
                            height: 60.h,
                            width: double.infinity,
                            child: Padding(
                              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                              child: renderTextFormField(
                                context: context,
                                autofocus: true,
                                label: '이메일 계정',
                                keyNumber: 1,
                                suffixIcon: _mailController.text.isNotEmpty ?
                                IconButton(
                                  icon: SvgPicture.asset("assets/images/textfield_delete.svg"),
                                  onPressed: () {
                                    _mailController.clear();
                                    setState(() { });
                                  },
                                ) : null,
                                controller: _mailController,
                                keyboardType: TextInputType.emailAddress,
                                obscureText: false,
                                onChanged: (val) {
                                  setState(() { });
                                },
                                onSaved: (val) {
                                  setState(() {
                                    _email = val;
                                  });

                                },
                                validator: (val) {
                                  if (val.length < 1) {
                                    return '이메일은 필수 사항 입니다.';
                                  }
                                  String value = val as String;
                                  return val.isValidEmailFormat() ? null : '이메일 형식이 아닙니다.';
                                },
                              ),
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
                                  Text("새로운 비밀번호", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040), fontWeight: FontWeight.bold),),
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
                                label: '비밀 번호 6~12자, 숫자만',
                                keyNumber: 2,
                                suffixIcon: IconButton(
                                  icon: Icon( _newPasswordVisible ? Icons.visibility : Icons.visibility_off, ),
                                  onPressed: () {
                                    setState(() {
                                      _newPasswordVisible = !_newPasswordVisible;
                                    });
                                  },
                                ),
                                keyboardType: TextInputType.text,
                                obscureText: _newPasswordVisible,
                                onSaved: (val) {
                                  setState(() {
                                    _newPassword = val;
                                  });
                                },
                                onChanged: (val) {
                                  _newPassword = val;
                                },
                                validator: (val) {
                                  if (val.length < 6 || val.length > 12) {
                                    return '비밀번호는 6글자 이상 12글자 이하로 입력해 주셔야합니다.';
                                  }

                                  return (val as String).isValidOnlyNumber() ? null : '비밀번호는 숫자로 이루어진 6 ~ 12 자리입니다.';
                                },
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
                                  Text("새로운 비밀번호 확인", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040), fontWeight: FontWeight.bold),),
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
                                label: '비밀 번호 6~12자, 숫자만',
                                keyNumber: 3,
                                suffixIcon: IconButton(
                                  icon: Icon( _confirmNewPasswordVisible ? Icons.visibility : Icons.visibility_off, ),
                                  onPressed: () {
                                    setState(() {
                                      _confirmNewPasswordVisible = !_confirmNewPasswordVisible;
                                    });
                                  },
                                ),
                                keyboardType: TextInputType.text,
                                obscureText: _confirmNewPasswordVisible,
                                onChanged: (val) {
                                  _confirmNewPassword = val;
                                },
                                onSaved: (val) {
                                  _confirmNewPassword = val;
                                },
                                validator: (val) {
                                  if (val.length < 6 || val.length > 12) {
                                    return '비밀번호는 6글자 이상 12글자 이하로 입력해 주셔야합니다.';
                                  }

                                  String value = val as String;
                                  if (_confirmNewPassword != value) {
                                    return "패스워드확인이 올바르지 않습니다.";
                                  } else {
                                    return null;
                                  }
                                },
                              ),
                            ),
                          ),

                          SizedBox(height: 12.h),

                          _processWidget(),

                          SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 100),
                        ],
                      )
                  )
              ),
            ),
          ),
        )
    );
  }

  Widget _processWidget() {
    if (isProcessing) {
      return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
        child: const CircularProgressIndicator(),
      );
    } else {
      return Padding(
        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
        child: MyButton(
          onTap: () { _changePassword(context); },
          text: "확인",
        ),
      );
    }
  }

  void _changePassword(BuildContext context) async {
    _formKey.currentState!.save();

    if (_email == "" || !_email.isValidEmailFormat()) {
      _showAlertDialog("오류", "이메일 형식이 아닙니다.");

      return;
    }

    if (_newPassword.length < 6 || _newPassword.length > 12) {
      _showAlertDialog("오류", "비밀 번호는 6글자 이상 12글자 이하로 입력해 주셔야 합니다.");
      return;
    }

    if (_newPassword != _confirmNewPassword) {
      _showAlertDialog("오류", "비밀번호 확인이 틀립니다.");
      return;
    }

    setState(() {
      isProcessing = true;
    });

    var uri = kReleaseMode ? Constants.BASE_URL_RELEASE : Constants.BASE_URL_DEBUG;
    BaseOptions options = BaseOptions(
      baseUrl: uri,
    );
    var dio = Dio(options);

    final response = await dio.post('/auth/findpassword',
        data: jsonEncode({
          "usermail": _email,
          "newpassword": _newPassword,
        })
    );

    setState(() {
      isProcessing = false;
    });

    if (!context.mounted) return;
    if (response.statusCode == 201) {
      _showAlertDialog("오류", response.data['message']);
    } else {
      _showAlertDialog("확인", "비밀번호 변경 신청이 완료되었습니다.");
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
}
