import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/components/my_textfield.dart';
import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/utils/string_extensions.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_alert_dialog.dart';
import 'package:flutter_svg/flutter_svg.dart';

class FindEmail extends StatefulWidget {
  const FindEmail({super.key});

  @override
  State<FindEmail> createState() => _FindEmailState();
}

class _FindEmailState extends State<FindEmail> {
  final _formKey = GlobalKey<FormState>();

  bool isProcessing = false;
  String _tel = '';
  String _findedEMail = "";

  final _telController = TextEditingController();
  final FocusNode _telNumberFocusNode = FocusNode();

  @override
  void dispose() {
    super.dispose();
    _telNumberFocusNode.dispose();
    _telController.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Constants.scaffoldBackgroundColor,
        body: SafeArea(
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
                          Text("ID 찾기", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold),),
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
                          Text("전화번호 (회원 등록시 입력한 전화번호)", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040), fontWeight: FontWeight.bold),),
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
                          label: '숫자만 입력해 주세요',
                          keyNumber: 1,
                          suffixIcon: _telController.text.isNotEmpty ?
                          IconButton(
                            icon: SvgPicture.asset("assets/images/textfield_delete.svg"),
                            onPressed: () {
                              _telController.clear();
                              setState(() { });
                            },
                          ) : null,
                          controller: _telController,
                          keyboardType: TextInputType.number,
                          obscureText: false,
                          focusNode: _telNumberFocusNode,
                          onChanged: (val) {
                            setState(() { });
                          },
                          onSaved: (val) {
                            setState(() {
                              _tel = val;
                            });
                          },
                          validator: (val) {
                            String value = val as String;
                            if (value != '') {
                              return val.isValidTelNumberFormat() ? null : '전화번호 형식이 아닙니다.';
                            } else {
                              return null;
                            }

                          },
                        ),
                      )
                  ),

                  SizedBox(height: 30.h),

                  _findedEMail == ""
                      ? const SizedBox()
                      : Padding(
                        padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                        child: Container(
                          height: 120.h,
                          decoration: BoxDecoration(
                            color: Colors.white,//const Color(0xFFF5F5F5),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: Constants.borderColor),
                          ),
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.all(10.0.h),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Flexible(
                                    flex: 1,
                                    fit: FlexFit.tight,
                                    child: Text(_findedEMail, style: TextStyle(fontSize: 18.sp, color: Constants.primaryColor), overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
                                  ),

                                  SizedBox(width: 8.w,),
                                  GestureDetector(
                                    onTap: () { Clipboard.setData(ClipboardData(text: _findedEMail)); },
                                    child: const Icon(Icons.copy, size: 20, color: Colors.black),
                                  ),
                                ],
                              ),
                            )
                          ),
                        ),
                      ),

                  const Spacer(),

                  _processWidget(),

                  // SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 100),
                ],
              )
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
          onTap: () { _findEmail(context); },
          text: "확인",
        ),
      );
    }
  }

  void _findEmail(BuildContext context) async {
    _formKey.currentState!.save();

    if (_tel == "" || !_tel.isValidPhoneNumberFormat()) {
      _showAlertDialog("오류", "전화번호 형식이 아닙니다.");

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

    final response = await dio.post('/auth/findemail',
        data: jsonEncode({
          "tel": _tel,
        })
    );

    setState(() {
      isProcessing = false;
    });

    if (!context.mounted) return;
    if (response.statusCode == 201) {
      _showAlertDialog("오류", response.data['message']);

    } else if (response.statusCode == 200) {
      setState(() {
        _findedEMail = response.data['message'];
      });
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
