import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:argoscareseniorsafeguard/utils/string_extensions.dart';
import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/components/my_textfield.dart';
import 'package:dio/dio.dart';
import 'package:argoscareseniorsafeguard/constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _email = '';
  String _password = '';
  String _confirmPassword = '';
  String _mobilephone = '';
  String _addrzip = '';
  String _addr = '';
  bool _passwordVisible = true;
  bool _confirmPasswordVisible = true;

  final _nameController = TextEditingController();
  final _mailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _smsController = TextEditingController();
  final _zipController = TextEditingController();
  final _addrController = TextEditingController();

  bool _smsAuthOk = false;
  bool _smsSendCompleted = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = '';

  @override
  void initState(){
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _nameController.dispose();
    _mailController.dispose();
    _phoneController.dispose();
    _smsController.dispose();
    _zipController.dispose();
    _addrController.dispose();
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
    final isValid = _formKey.currentState!.validate();

    if (!_smsAuthOk) {
      _failureDialog(context, "회원 가입", "휴대폰 인증이 완료 되지 않았습니다.\n휴대폰 인증을 완료 하여 주 십시요.");
    }

    if (isValid && _smsAuthOk) {
      _formKey.currentState!.save();
      try {
        var uri = Constants.BASE_URL;
        BaseOptions options = BaseOptions(
          baseUrl: uri,
        );
        var dio = Dio(options);

        final response = await dio.post('/auth/signup',
            data: jsonEncode({
              "email": _email,
              "name": _name,
              "password": _password,
              "mobilephone": _mobilephone,
              "addr_zip": _addrzip,
              "addr": _addr,
              "admin": false
            })
        );
        if (response.statusCode == 201) {
          _successDialog(context, response.data['message']);
        } else {
          _successDialog(context, "회원 가입이 완료되었습니다.\n로그인을 진행해 주세요.");
        }
      } catch (e) {
        _failureDialog(context, '회원 가입', "회원 가입이 실패 했습니다.\n관리자에게 확인 바랍니다.");
      }
    } else {
      debugPrint("validateController() false");
    }
  }

  void _failureDialog(BuildContext context, String title, String message) {
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(Constants.APP_TITLE),
          centerTitle: true,
        ),
        body: SingleChildScrollView (
            physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: MediaQuery.of(context).size.width,
              minHeight: MediaQuery.of(context).size.height,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Form(
                  key: _formKey,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        renderTextFormField(
                          context: context,
                          label: '이름',
                          autofocus: true,
                          keyNumber: 1,
                          icon: const Icon(Icons.account_circle, color: Colors.grey,),
                          suffixIcon: _nameController.text.isNotEmpty ?
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _nameController.clear();
                                setState(() { });
                              },
                            ) : null,
                          controller: _nameController,
                          keyboardType: TextInputType.name,
                          obscureText: false,
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
                              return '이름은 두글자 이상 입력해 주셔야 합니다.';
                            }
              
                            return null;
                          },
                        ),
              
                        const SizedBox(height: 10),
              
                        renderTextFormField(
                          context: context,
                          label: '이메일 주소',
                          keyNumber: 2,
                          icon: const Icon(Icons.mail, color: Colors.grey,),
                          suffixIcon: _mailController.text.isNotEmpty ?
                            IconButton(
                              icon: const Icon(Icons.clear),
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
              
                        const SizedBox(height: 10),
              
                        renderTextFormField(
                          context: context,
                          label: '비밀 번호',
                          keyNumber: 3,
                          icon: const Icon(Icons.lock, color: Colors.grey,),
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
              
                        const SizedBox(height: 10),
              
                        renderTextFormField(
                          context: context,
                          label: '비밀 번호 확인',
                          keyNumber: 4,
                          icon: const Icon(Icons.lock, color: Colors.grey,),
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
              
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: renderTextFormField(
                                context: context,
                                label: '휴대폰',
                                keyNumber: 5,
                                icon: const Icon(Icons.phone_android, color: Colors.grey,),
                                suffixIcon: _phoneController.text.isNotEmpty ?
                                  IconButton(
                                    icon: const Icon(Icons.clear),
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

                            _smsAuthOk ? const SizedBox()
                                : TextButton(
                                    child: const Text("SMS 전송"),
                                    onPressed: () async {
                                      setState(() {
                                        _smsSendCompleted = true;
                                      });
                                      /*if (_phoneController.text.isValidPhoneNumberFormat()) {
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
                                      }*/

                                    },
                                ),
                          ],
                        ),

                        (!_smsSendCompleted || _smsAuthOk) ? const SizedBox() : const SizedBox(height: 10),

                        (!_smsSendCompleted || _smsAuthOk) ? const SizedBox()
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: renderTextFormField(
                                      context: context,
                                      label: '인증 문자',
                                      icon: const Icon(Icons.message, color: Colors.grey,),
                                      suffixIcon: _smsController.text.isNotEmpty ?
                                      IconButton(
                                        icon: const Icon(Icons.clear),
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

                                  TextButton(
                                    child: const Text("본인 인증"),
                                    onPressed: () {
                                      setState(() {
                                        _smsSendCompleted = true;
                                        _smsAuthOk = true;
                                      });
                                      /*PhoneAuthCredential phoneAuthCredential =
                                      PhoneAuthProvider.credential(
                                          verificationId: _verificationId, smsCode: _smsController.text);

                                      _signInWithPhoneAuthCredential(phoneAuthCredential);*/
                                    },
                                  ),
                                ],
                              ),

                        const SizedBox(height: 10),
              
                        renderTextFormField(
                          context: context,
                          label: '우편 번호',
                          keyNumber: 6,
                          icon: const Icon(Icons.home_work_outlined, color: Colors.grey,),
                          suffixIcon: _zipController.text.isNotEmpty ?
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _zipController.clear();
                                setState(() { });
                              },
                            ) : null,
                          controller: _zipController,
                          keyboardType: TextInputType.number,
                          obscureText: false,
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

                        const SizedBox(height: 10),
              
                        renderTextFormField(
                          context: context,
                          label: '주소',
                          keyNumber: 7,
                          icon: const Icon(Icons.home_work_outlined, color: Colors.grey,),
                          suffixIcon: _addrController.text.isNotEmpty ?
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _addrController.clear();
                                setState(() { });
                              },
                            ) : null,
                          controller: _addrController,
                          keyboardType: TextInputType.streetAddress,
                          obscureText: false,
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
              
                        const SizedBox(height: 10),
              
                        MyButton(
                          onTap: () { _register(context); },
                          text: "Register",
                        ),

                        SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 100),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        )
    );
  }
}
