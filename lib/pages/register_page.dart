import 'dart:convert';
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

import 'package:argoscareseniorsafeguard/utils/string_extensions.dart';
import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/components/my_textfield.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/pages/phone_certification.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

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
  String _parentName = '';
  int _parentAge = 0;
  String _parentPhone = '';

  final _nameController = TextEditingController();
  final _mailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _telController = TextEditingController();
  final _smsController = TextEditingController();
  final _zipController = TextEditingController();
  final _addrController = TextEditingController();
  final _detailAddrController = TextEditingController();
  final _parentNameController = TextEditingController();
  final _parentAgeController = TextEditingController();
  final _parentPhoneController = TextEditingController();

  final FocusNode _nameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();
  final FocusNode _phoneNumberFocusNode = FocusNode();
  final FocusNode _telNumberFocusNode = FocusNode();
  final FocusNode _zipAddrFocusNode = FocusNode();
  final FocusNode _addrFocusNode = FocusNode();
  final FocusNode _detailAddrFocusNode = FocusNode();
  final FocusNode _parentNameFocusNode = FocusNode();
  final FocusNode _parentAgeFocusNode = FocusNode();
  final FocusNode _parentPhoneFocusNode = FocusNode();

  bool _smsAuthOk = false;
  bool _smsSendCompleted = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String _verificationId = '';

  String _deviceId = 'Unknown';
  final _mobileDeviceIdentifierPlugin = MobileDeviceIdentifier();

  int _parentSex = 0;

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
    _parentNameFocusNode.dispose();
    _parentAgeFocusNode.dispose();
    _parentPhoneFocusNode.dispose();

    _nameController.dispose();
    _mailController.dispose();
    _phoneController.dispose();
    _telController.dispose();
    _smsController.dispose();
    _zipController.dispose();
    _addrController.dispose();
    _detailAddrController.dispose();
    _parentNameController.dispose();
    _parentAgeController.dispose();
    _parentPhoneController.dispose();
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
    final isValid = _formKey.currentState!.validate();

    if (!_smsAuthOk) {
      _failureDialog(context, "회원 가입", "휴대폰 인증이 완료 되지 않았습니다.\n휴대폰 인증을 완료 하여 주 십시요.");
      FocusScope.of(context).requestFocus(_phoneNumberFocusNode);
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
              "tel": _tel,
              "addr_zip": _addrzip,
              "addr": _addr,
              "addr_detail": _detailAddr,
              "admin": false,
              "deviceID": _deviceId,
              "parentName": _parentName,
              "parentAge": _parentAge,
              "parentPhone": _parentPhone,
              "parentSex": _parentSex
            })
        );

        if (!context.mounted) return;
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
    ref.listen(phoneCertificationProvider, (previous, next) {
      _smsAuthOk = ref.watch(phoneCertificationProvider);
    });
    return Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('보호자 가입'),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('아이디', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey, fontWeight: FontWeight.bold) ),
                          ],
                        ),

                        renderTextFormField(
                          context: context,
                          autofocus: true,
                          label: '이메일 주소',
                          keyNumber: 1,
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

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('비밀번호', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey, fontWeight: FontWeight.bold) ),
                          ],
                        ),

                        renderTextFormField(
                          context: context,
                          label: '비밀 번호',
                          keyNumber: 2,
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

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('비밀번호 확인', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey, fontWeight: FontWeight.bold) ),
                          ],
                        ),

                        renderTextFormField(
                          context: context,
                          label: '비밀 번호 확인',
                          keyNumber: 3,
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
                          keyNumber: 4,
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
                              return '이름은 두글자 이상 입력해 주셔야 합니다.';
                            }
              
                            return null;
                          },
                        ),
              
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('휴대폰 번호', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey, fontWeight: FontWeight.bold) ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                                child: renderTextFormField(
                                  context: context,
                                  label: '숫자만 입력해 주세요',
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

                            _smsAuthOk ? const SizedBox()
                                : TextButton(
                                    child: const Text("본인 인증"),
                                    onPressed: () async {
                                      if (_phoneController.text.isValidPhoneNumberFormat()) {
                                        _phoneCertification(context, _phoneController.text);
                                      } else  {

                                      }
                                /*setState(() {
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

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('전화 번호(선택)', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey, fontWeight: FontWeight.bold) ),
                          ],
                        ),

                        renderTextFormField(
                          context: context,
                          label: '숫자만 입력해 주세요',
                          keyNumber: 6,
                          icon: const Icon(Icons.phone, color: Colors.grey,),
                          suffixIcon: _telController.text.isNotEmpty ?
                          IconButton(
                            icon: const Icon(Icons.clear),
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

                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text('주소(선택)', style: Theme.of(context).textTheme.bodySmall!.copyWith(color: Colors.grey, fontWeight: FontWeight.bold) ),
                          ],
                        ),

                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Expanded(
                                child: renderTextFormField(
                                  context: context,
                                  label: '우편 번호',
                                  keyNumber: 7,
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
                              TextButton(
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
                              )
                            ]
                        ),

                        const SizedBox(height: 10),

                        renderTextFormField(
                          context: context,
                          label: '주소',
                          keyNumber: 8,
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
              
                        const SizedBox(height: 10),

                        renderTextFormField(
                          context: context,
                          label: '상세주소',
                          keyNumber: 9,
                          icon: const Icon(Icons.home_work_outlined, color: Colors.grey,),
                          suffixIcon: _detailAddrController.text.isNotEmpty ?
                          IconButton(
                            icon: const Icon(Icons.clear),
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
              
                        const SizedBox(height: 20),

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
