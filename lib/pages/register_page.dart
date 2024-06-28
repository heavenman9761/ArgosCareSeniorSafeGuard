import 'dart:convert';
import 'package:argoscareseniorsafeguard/dialogs/custom_confirm_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:iamport_flutter/model/certification_data.dart';
import 'package:iamport_flutter/model/url_data.dart';
import 'package:dio/dio.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:flutter/services.dart';
import 'package:remedi_kopo/remedi_kopo.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:argoscareseniorsafeguard/utils/string_extensions.dart';
import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/components/my_textfield.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/pages/phone_certification.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_alert_dialog.dart';
import 'package:argoscareseniorsafeguard/pages/register_parent.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key, required this.optionalCheck});
  final bool optionalCheck;

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _mobilephone = '';
  String _tel = '';
  String _addrzip = '';
  String _addr = '';
  String _detailAddr = '';
  bool _passwordVisible = true;
  bool _confirmPasswordVisible = true;

  final _nameController = TextEditingController();
  final _mailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _telController = TextEditingController();
  final _smsController = TextEditingController();
  final _zipController = TextEditingController();
  final _addrController = TextEditingController();
  final _detailAddrController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _telNumberFocusNode = FocusNode();
  final FocusNode _zipAddrFocusNode = FocusNode();
  final FocusNode _addrFocusNode = FocusNode();
  final FocusNode _detailAddrFocusNode = FocusNode();

  bool _smsAuthOk = false;
  bool _smsSendCompleted = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = '';

  String _deviceId = 'Unknown';
  final _mobileDeviceIdentifierPlugin = MobileDeviceIdentifier();

  @override
  void initState(){
    super.initState();

    _initDeviceId();
  }

  @override
  void dispose() {
    super.dispose();

    _nameFocusNode.dispose();
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    _confirmPasswordFocusNode.dispose();
    _phoneNumberFocusNode.dispose();
    _telNumberFocusNode.dispose();
    _zipAddrFocusNode.dispose();
    _addrFocusNode.dispose();
    _detailAddrFocusNode.dispose();

    _nameController.dispose();
    _mailController.dispose();
    _phoneController.dispose();
    _telController.dispose();
    _smsController.dispose();
    _zipController.dispose();
    _addrController.dispose();
    _detailAddrController.dispose();
  }

  Future<void> _initDeviceId() async {
    String deviceId;
    try {
      deviceId = await _mobileDeviceIdentifierPlugin.getDeviceId() ?? 'Unknown platform version';
      // debugPrint('origin: $deviceId');

      deviceId = base64.encode(utf8.encode(deviceId));
      // debugPrint('encoded: $deviceId');

      // String decoded = utf8.decode(base64.decode(deviceId));
      // debugPrint('decoded: $decoded');

    } on PlatformException {
      deviceId = 'Failed to get platform version.';
    }

    if (!mounted) return;
    setState(() {
      _deviceId = deviceId;
    });
  }

  void _signInWithPhoneAuthCredential(PhoneAuthCredential phoneAuthCredential) async {
    try {
      final authCredential = await _auth.signInWithCredential(phoneAuthCredential);
      if(authCredential.user != null){
        debugPrint("인증 완료");
        _smsAuthOk = true;

        await _auth.currentUser?.delete();
        debugPrint("auth 정보 삭제");

        _auth.signOut();
        debugPrint("로그 아웃");
      }

    } on FirebaseAuthException catch (e) {
      setState(() {
        debugPrint("인증 실패");
      });

      await Fluttertoast.showToast(
          msg: e.message!,
          toastLength: Toast.LENGTH_SHORT,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.red,
          fontSize: 16.0
      );
    }
  }

  void _register(BuildContext context) async {
    // final isValid = _formKey.currentState!.validate();

    _smsAuthOk = true;
    if (!_smsAuthOk) {
      _showAlertDialog("오류", "휴대폰 인증이 완료 되지 않았습니다.\n휴대폰 인증을 완료 하여 주 십시요.");
      FocusScope.of(context).requestFocus(_phoneNumberFocusNode);
      return;
    }

    _formKey.currentState!.save();

    if (_email == "" || !_email.isValidEmailFormat()) {
      _showAlertDialog("오류", "이메일 형식이 아닙니다.");

      if (!context.mounted) return;
      FocusScope.of(context).requestFocus(_emailFocusNode);
      return;
    }

    if (_name == "") {
      _showAlertDialog("오류", "이름을 입력해 주세요.");

      if (!context.mounted) return;
      FocusScope.of(context).requestFocus(_nameFocusNode);
      return;
    }

    if (_name.length < 2) {
      _showAlertDialog("오류", "이름은 두 글자 이상 입력해 주셔야 합니다.");

      if (!context.mounted) return;
      FocusScope.of(context).requestFocus(_nameFocusNode);
      return;
    }

    if (_password.length < 6 || _password.length > 12) {
      _showAlertDialog("오류", "비밀 번호는 6글자 이상 12글자 이하로 입력해 주셔야 합니다.");
      if (!context.mounted) return;
      FocusScope.of(context).requestFocus(_passwordFocusNode);
      return;
    }

    if (!_password.isValidOnlyNumber()) {
      _showAlertDialog("오류", "비밀 번호는 숫자로 이 루어진 6 ~ 12 자리 입니다.");
      if (!context.mounted) return;
      FocusScope.of(context).requestFocus(_passwordFocusNode);
      return;
    }

    if (_password != _confirmPassword) {
      _showAlertDialog("오류", "비밀 번호 확인이 올 바르지 않습니다.");
      if (!context.mounted) return;
      FocusScope.of(context).requestFocus(_confirmPasswordFocusNode);
      return;
    }

    if (_mobilephone.length < 10 || !_mobilephone.isValidPhoneNumberFormat()) {
      _showAlertDialog("오류", "휴대폰 형식이 아닙니다.");
      if (!context.mounted) return;
      FocusScope.of(context).requestFocus(_phoneNumberFocusNode);
      return;
    }

    Navigator.push(context,
        MaterialPageRoute(builder: (context) {
          return RegisterParent(email: _email, name: _name, password: _password, mobilePhone: _mobilephone, tel: _tel, addrzip: _addrzip,
            addr: _addr, detailAddr: _detailAddr, deviceID: _deviceId, optionalCheck: widget.optionalCheck);
        }));
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

  /*void _failureDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _successDialog(BuildContext context, String text) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("회원 가입"),
              content: Text(text),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                ),
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((val) {
      if (val == true) {
        Navigator.pop(context);
      }
    });
  }*/

  @override
  Widget build(BuildContext context) {
    ref.listen(phoneCertificationProvider, (previous, next) {
      _smsAuthOk = ref.watch(phoneCertificationProvider);
    });
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
                                Text("보호자 가입", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold),),
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
                              focusNode: _emailFocusNode,
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
                                Text("비밀번호", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040), fontWeight: FontWeight.bold),),
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
                                icon: Icon( _passwordVisible ? Icons.visibility : Icons.visibility_off, ),
                                onPressed: () {
                                  setState(() {
                                    _passwordVisible = !_passwordVisible;
                                  });
                                },
                              ),
                              keyboardType: TextInputType.text,
                              obscureText: _passwordVisible,
                              focusNode: _passwordFocusNode,
                              onChanged: (val) {
                                _confirmPassword = val;
                              },
                              onSaved: (val) {
                                setState(() {
                                  _password = val;
                                });

                              },
                              validator: (val) {
                                if (val.length < 6 || val.length > 12) {
                                  return '비밀 번호는 6글자 이상 12글자 이하로 입력해 주셔야 합니다.';
                                }

                                //return val.isValidPasswordFormatType1() ? null : '비밀번호는 영문(소문자, 대문자), 숫자, 특수문자로 이루어진 6 ~ 12 자리입니다.';
                                return (val as String).isValidOnlyNumber() ? null : '비밀 번호는 숫자로 이 루어진 6 ~ 12 자리 입니다.';
                              },
                            ),
                          )
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
                                Text("비밀번호 확인", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040), fontWeight: FontWeight.bold),),
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
                                  label: '비밀 번호 확인',
                                  keyNumber: 3,
                                  suffixIcon: IconButton(
                                    icon: Icon( _confirmPasswordVisible ? Icons.visibility : Icons.visibility_off, ),
                                    onPressed: () {
                                      setState(() {
                                        _confirmPasswordVisible = !_confirmPasswordVisible;
                                      });
                                    },
                                  ),
                                  keyboardType: TextInputType.text,
                                  obscureText: _confirmPasswordVisible,
                                  focusNode: _confirmPasswordFocusNode,
                                  onSaved: (val) {},
                                  validator: (val) {
                                    if (val.length < 6 || val.length > 12) {
                                      return '비밀 번호 확인은 6글자 이상 12글자 이하로 입력해 주셔야 합니다.';
                                    }

                                    String value = val as String;
                                    if (_confirmPassword != value) {
                                      return "비밀 번호 확인이 올 바르지 않 습니다.";
                                    } else {
                                      return null;
                                    }
                                  },
                                ),
                            )
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
                                      _name = val;
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
                                          label: '숫자만 입력해 주세요',
                                          keyNumber: 5,
                                          suffixIcon: _phoneController.text.isNotEmpty ?
                                          IconButton(
                                            icon: SvgPicture.asset("assets/images/textfield_delete.svg"),
                                            onPressed: () {
                                              _phoneController.clear();
                                              setState(() {
                                                _smsSendCompleted = false;
                                                _smsAuthOk = false;
                                              });
                                            },
                                          ) : null,
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          obscureText: false,
                                          focusNode: _phoneNumberFocusNode,
                                          onChanged: (val) {
                                            setState(() {
                                              _smsSendCompleted = false;
                                              _smsAuthOk = false;
                                            });
                                          },
                                          onSaved: (val) {
                                            setState(() {
                                              _mobilephone = val;
                                            });

                                          },
                                          validator: (val) {
                                            if (val.length < 1) {
                                              return '휴대폰은 필수 사항 입니다.';
                                            }
                                            String value = val as String;
                                            return val.isValidPhoneNumberFormat() ? null : '휴대폰 형식이 아닙니다.';
                                          },
                                        )
                                    ),

                                    _smsAuthOk
                                        ? const SizedBox()
                                        : Row(
                                          children: [
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
                                                    if (_phoneController.text.isValidPhoneNumberFormat()) {
                                                      _phoneCertification(context, _phoneController.text);
                                                    } else  {

                                                    }
                                                  },
                                                  child: Text('본인 인증', style: TextStyle(fontSize: 14.sp, color: Constants.primaryColor), ),)
                                            ),
                                          ],
                                        )
                                    /*TextButton(
                                            child: const Text("본인 인증"),
                                            onPressed: () async {
                                              if (_phoneController.text.isValidPhoneNumberFormat()) {
                                                _phoneCertification(context, _phoneController.text);
                                              } else  {

                                              }
                                        *//*setState(() {
                                        _smsSendCompleted = true;
                                      });
                                      if (_phoneController.text.isValidPhoneNumberFormat()) {
                                        await _auth.verifyPhoneNumber(
                                          timeout: const Duration(seconds: 60),
                                          codeAutoRetrievalTimeout: (String verificationId) {
                                            // Auto-resolution timed out...
                                          },
                                          // phoneNumber: "+821095109760",//"+8210" + _phoneController.text.trim() + _phoneController.text.trim(),
                                          phoneNumber: '+82${_phoneController.text.substring(1)}',
                                          verificationCompleted: (phoneAuthCredential) async {
                                            debugPrint("otp 문자옴");
                                          },
                                          verificationFailed: (verificationFailed) async {
                                            debugPrint(verificationFailed.code);

                                            debugPrint("코드 발송 실패");
                                            setState(() {
                                              // showLoading = false;
                                            });
                                          },
                                          codeSent: (verificationId, resendingToken) async {
                                            debugPrint("코드 발송 성공");

                                            Fluttertoast.showToast(
                                                msg: "${_phoneController.text} 로 인증 코드를 발송 하였습니다. 문자가 올 때까지 잠시만 기다려 주세요.",
                                                toastLength: Toast.LENGTH_SHORT,
                                                timeInSecForIosWeb: 1,
                                                backgroundColor: Colors.green,
                                                fontSize: 12.0
                                            );
                                            setState(() {
                                              _smsSendCompleted = true;
                                              _verificationId = verificationId;
                                            });
                                          },
                                        );
                                      }*//*

                                      },
                                    ),*/
                                  ],
                                ),
                            )
                        ),



                        (!_smsSendCompleted || _smsAuthOk) ? const SizedBox() : SizedBox(height: 12.h),

                        (!_smsSendCompleted || _smsAuthOk)
                            ? const SizedBox()
                            : SizedBox(
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
                                                  label: '인증 문자',
                                                  suffixIcon: _smsController.text.isNotEmpty ?
                                                  IconButton(
                                                    icon: SvgPicture.asset("assets/images/textfield_delete.svg"),
                                                    onPressed: () {
                                                      _smsController.clear();
                                                      setState(() { });
                                                    },
                                                  ) : null,
                                                  controller: _smsController,
                                                  keyboardType: TextInputType.number,
                                                  obscureText: false,
                                                )
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
                                                    setState(() {
                                                      _smsSendCompleted = true;
                                                      _smsAuthOk = true;
                                                    });
                                                    /*PhoneAuthCredential phoneAuthCredential =
                                              PhoneAuthProvider.credential(
                                                  verificationId: _verificationId, smsCode: _smsController.text);

                                              _signInWithPhoneAuthCredential(phoneAuthCredential);*/
                                                  },
                                                  child: Text('본인 인증', style: TextStyle(fontSize: 14.sp, color: Constants.primaryColor), ),)
                                            ),
                                          ],
                                        ),
                                  )
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
                                Text("전화 번호(선택)", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040), fontWeight: FontWeight.bold),),
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
                                  keyNumber: 6,
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
                                          keyNumber: 7,
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
                                          onChanged: (val) {
                                            setState(() { });
                                          },
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
                                      /*TextButton(
                                          child: const Text("주소 검색"),
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
                                          }
                                      )*/
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
                                  keyNumber: 8,
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
                                  onChanged: (val) {
                                    setState(() { });
                                  },
                                  onSaved: (val) {
                                    setState(() {
                                      _addr = val;
                                    });
                                  },
                                  validator: (val) {
                                    return null;
                                  },
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
                                  label: '상세주소',
                                  keyNumber: 9,
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
                                  onChanged: (val) {
                                    setState(() { });
                                  },
                                  onSaved: (val) {
                                    setState(() {
                                      _detailAddr = val;
                                    });
                                  },
                                  validator: (val) {
                                    return null;
                                  },
                                ),
                            )
                        ),

                        /*const SizedBox(height: 20),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('피보호자 등록', style: Theme.of(context).textTheme.bodyLarge!.copyWith(color: Colors.grey, fontWeight: FontWeight.bold) ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('이름', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey, fontWeight: FontWeight.bold) ),
                          ],
                        ),

                        renderTextFormField(
                          context: context,
                          label: '실명을 붙여서 입력해 주세요',
                          keyNumber: 10,
                          icon: const Icon(Icons.account_circle, color: Colors.grey,),
                          suffixIcon: _parentNameController.text.isNotEmpty ?
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _parentNameController.clear();
                              setState(() { });
                            },
                          ) : null,
                          controller: _parentNameController,
                          keyboardType: TextInputType.name,
                          obscureText: false,
                          focusNode: _parentNameFocusNode,
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
                              return '이름은 두글자 이상 입력해 주셔야 합니다.';
                            }

                            return null;
                          },
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('성별(선택)', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey, fontWeight: FontWeight.bold) ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Radio(value: 0, groupValue: _parentSex, onChanged: (int? value) {
                                    setState(() {
                                      _parentSex = value!;
                                    });
                                  }),
                                  Expanded(child: Text('선택 안함', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey, fontWeight: FontWeight.bold) ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Radio(value: 1, groupValue: _parentSex, onChanged: (int? value) {
                                    setState(() {
                                      _parentSex = value!;
                                    });
                                  }),
                                  Expanded(child: Text('남성', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey, fontWeight: FontWeight.bold) ),
                                  )
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  Radio(value: 2, groupValue: _parentSex, onChanged: (int? value) {
                                    setState(() {
                                      _parentSex = value!;
                                    });
                                  }),
                                  Expanded(child: Text('여성', style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.grey, fontWeight: FontWeight.bold) ))
                                ],
                              ),

                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('나이(선택)', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey, fontWeight: FontWeight.bold) ),
                          ],
                        ),

                        renderTextFormField(
                          context: context,
                          label: '숫자만 입력해 주세요',
                          keyNumber: 11,
                          icon: const Icon(Icons.calendar_month, color: Colors.grey,),
                          suffixIcon: _parentAgeController.text.isNotEmpty ?
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _parentAgeController.clear();
                              setState(() { });
                            },
                          ) : null,
                          controller: _parentAgeController,
                          keyboardType: TextInputType.number,
                          obscureText: false,
                          focusNode: _parentAgeFocusNode,
                          onChanged: (val) {
                            setState(() { });
                          },
                          onSaved: (val) {
                            setState(() {
                              _parentAge = int.parse(val);
                            });
                          },
                          validator: (val) {
                            String value = val as String;
                            return val.isValidOnlyNumberForAge() ? null : '나이 형식이 아닙니다.';
                          },
                        ),

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('휴대폰 번호(선택)', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey, fontWeight: FontWeight.bold) ),
                          ],
                        ),

                        renderTextFormField(
                          context: context,
                          label: '숫자만 입력해 주세요.',
                          keyNumber: 12,
                          icon: const Icon(Icons.phone_android, color: Colors.grey,),
                          suffixIcon: _parentPhoneController.text.isNotEmpty ?
                          IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _parentPhoneController.clear();
                              setState(() { });
                            },
                          ) : null,
                          controller: _parentPhoneController,
                          keyboardType: TextInputType.number,
                          obscureText: false,
                          focusNode: _parentPhoneFocusNode,
                          onChanged: (val) {
                            setState(() { });
                          },
                          onSaved: (val) {
                            setState(() {
                              _parentPhone = val;
                            });
                          },
                          validator: (val) {
                            String value = val as String;
                            return val.isValidPhoneNumberFormat() ? null : '휴대폰  형식이 아닙니다.';
                          },
                        ),*/

                        const SizedBox(height: 10),

                        Padding(
                          padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
                          child: MyButton(
                            onTap: () {
                              _register(context);
                            },
                            text: "확인",
                          ),
                        ),

                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 100),
                      ],
                    ),
                  ),
                ),
            )
          ),
        )
    );
  }

  void _phoneCertification(BuildContext context, String phoneNumber) async {
    CertificationData data = CertificationData(
      pg: 'inicis_unified',
      merchantUid: 'mid_${DateTime.now().millisecondsSinceEpoch}',
      mRedirectUrl: UrlData.redirectUrl
    );

    final result = await Navigator.push(context,
        MaterialPageRoute(builder: (context) {
          return PhoneCertification(userCode: 'imp71235150', data: data);
        })
    );

    print("========================================");
    print(result);

    if (result == '인증에 성공하였습니다.') {
      _smsAuthOk = true;
    } else {
      _smsAuthOk = false;
    }

    if (result != null) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
        ..removeCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text('$result')));
    }
  }
}
