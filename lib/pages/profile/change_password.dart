import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/components/my_textfield.dart';
import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/utils/string_extensions.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_alert_dialog.dart';

class ChangePassword extends StatefulWidget {
  final String userID;

  const ChangePassword({super.key, required this.userID});

  @override
  State<ChangePassword> createState() => _ChangePasswordState();
}

class _ChangePasswordState extends State<ChangePassword> {
  final _formKey = GlobalKey<FormState>();

  bool isProcessing = false;

  String _password = '';
  String _newPassword = '';
  String _confirmNewPassword = '';

  bool _passwordVisible = true;
  bool _newPasswordVisible = true;
  bool _confirmNewPasswordVisible = true;

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
                              Text("비밀번호 변경", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold),),
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
                              Text("이전 비밀번호", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040), fontWeight: FontWeight.bold),),
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
                            keyNumber: 1,
                            suffixIcon: IconButton(
                              icon: Icon( _passwordVisible ? Icons.visibility : Icons.visibility_off, ),
                              onPressed: () {
                                setState(() {
                                  _passwordVisible = !_passwordVisible;
                                });
                              },
                            ),
                            keyboardType: TextInputType.text,
                            obscureText: _passwordVisible,
                            onSaved: (val) {
                              setState(() {
                                _password = val;
                              });

                            },
                            validator: (val) {
                              if (val.length < 6 || val.length > 12) {
                                return '비밀번호는 6글자 이상 12글자 이하로 입력해 주셔야합니다.';
                              }

                              //return val.isValidPasswordFormatType1() ? null : '비밀번호는 영문(소문자, 대문자), 숫자, 특수문자로 이루어진 6 ~ 12 자리입니다.';
                              return (val as String).isValidOnlyNumber() ? null : '비밀번호는 숫자로 이루어진 6 ~ 12 자리입니다.';
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
                              _confirmNewPassword = val;
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
                            onSaved: (val) {},
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
    final isValid = _formKey.currentState!.validate();
    if (isValid) {

      setState(() {
        isProcessing = true;
      });
      _formKey.currentState!.save();

      final response = await dio.post('/auth/changepassword',
          data: jsonEncode({
            "userID": widget.userID,
            "oldpassword": _password,
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
