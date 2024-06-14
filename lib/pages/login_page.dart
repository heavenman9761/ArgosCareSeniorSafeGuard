import 'dart:convert';

import 'package:argoscareseniorsafeguard/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:dio/dio.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/components/my_textfield.dart';
import 'package:argoscareseniorsafeguard/components/square_tile.dart';
import 'package:argoscareseniorsafeguard/pages/home_page.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/auth/auth_dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:argoscareseniorsafeguard/utils/string_extensions.dart';
import 'package:argoscareseniorsafeguard/main.dart';
import 'package:argoscareseniorsafeguard/models/location_infos.dart';
import 'package:argoscareseniorsafeguard/models/sensor_infos.dart';
import 'package:argoscareseniorsafeguard/models/hub_infos.dart';
import 'package:argoscareseniorsafeguard/models/share_infos.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  bool isLogging = false;
  bool passwordVisible = true;
  late String userID;
  bool _isSaveID = false;

  String _deviceId = 'Unknown';
  final _mobileDeviceIdentifierPlugin = MobileDeviceIdentifier();

  final _mailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initDeviceId();
    _loadPref();
    // _loadLocale();
  }

  void _loadPref() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    _isSaveID = pref.getBool('saveLoginID') ?? false;
    // _isSaveID ??= false;
    if (_isSaveID) {
      const storage = FlutterSecureStorage(
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

      String email = (await storage.read(key: 'EMAIL')) ?? '';
      String password = (await storage.read(key: 'PASSWORD')) ?? '';

      _mailController.text = email;
      _passwordController.text = password;

      setState(() {

      });
    }
  }

  void _savePref() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool('saveLoginID', _isSaveID);
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

  /*void _loadLocale() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      String localeStr = prefs.getString('languageCode') ?? 'ko';

      if (localeStr == "ko") { _selectedLanguage = "한국어"; }
      else if (localeStr == "en") { _selectedLanguage = "English"; }
    });
  }*/

  @override
  void dispose() {
    super.dispose();
    _mailController.dispose();
    _passwordController.dispose();
  }

  // sign user in method
  void _signUserIn(BuildContext context) async {
    final isValid = _formKey.currentState!.validate();
    if (isValid) {
      setState(() {
        isLogging = true;
      });

      _formKey.currentState!.save();
      try {

        dio = await authDio();

        final response = await dio.post(
            "/auth/signin",
            data: jsonEncode({
              "email": email,
              "password": password
            })
        );

        if (!context.mounted) return;
        _processLogin(context, response);

      } catch (e) {
        debugPrint(e.toString());
        if (!context.mounted) return;
        _failureDialog(context, AppLocalizations.of(context)!.login_button, AppLocalizations.of(context)!.login_failure_message);
        setState(() {
          isLogging = false;
        });
      }
    }
  }

  void _processLogin(BuildContext context, Response response) async {
    final token = response.data['token'];
    const storage = FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    await storage.write(key: 'ACCESS_TOKEN', value: token);

    final loginResponse = await dio.get(
        "/auth/me"
    );

    final String userName = loginResponse.data['name'];
    userID = loginResponse.data['id'];

    await storage.write(key: 'ID', value: loginResponse.data['id']);
    await storage.write(key: 'EMAIL', value: loginResponse.data['email']);
    await storage.write(key: 'PASSWORD', value: password); //세션 종료시 다시 로그인하기 위해 필요

    saveUserInfo(loginResponse);

    if (!context.mounted) return;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) {
          return HomePage(title: Constants.APP_TITLE, userName: userName, userID: userID, requireLogin: false,);
        },
      )
    );
  }

  void _failureDialog(BuildContext context, String title, String msg) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: Text(msg),
              actions: <Widget>[
                TextButton(
                  child: Text(AppLocalizations.of(context)!.ok),
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

  void _iostest() async {
    final int result = await Constants.platform.invokeMethod('getBatteryLevel');
    debugPrint('batteryLevel: $result');
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getDeviceFontSize(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.h),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(height: 14.h),
                  SizedBox(
                    height: 76.h,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // const Text("로그인"),
                        Text(AppLocalizations.of(context)!.login_button, style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 40.h,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // const Text("로그인"),
                        Text(AppLocalizations.of(context)!.login_id, style: TextStyle(fontSize: 12.sp, color: Colors.black, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  renderTextFormField(
                    context: context,
                    label: AppLocalizations.of(context)!.login_email,
                    keyNumber: 1,
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
                    // initialValue: 'dn9318dn@gmail.com',
                    onChanged: (val) {
                      setState(() { });
                    },
                    onSaved: (val) {
                      setState(() {
                        email = val;
                      });

                    },
                    validator: (val) {
                      if (val.length < 1) {
                        return AppLocalizations.of(context)!.login_validation_error1;
                      }
                      return (val as String).isValidEmailFormat() ? null : AppLocalizations.of(context)!.login_validation_error2;
                    },
                  ),
                  SizedBox(height: 12.h,),
                  SizedBox(
                    height: 40.h,
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // const Text("로그인"),
                        Text(AppLocalizations.of(context)!.login_password, style: TextStyle(fontSize: 12.sp, color: Colors.black, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                  renderTextFormField(
                    context: context,
                    label: AppLocalizations.of(context)!.login_password,
                    keyNumber: 2,
                    suffixIcon: IconButton(
                      icon: Icon( passwordVisible ? Icons.visibility : Icons.visibility_off, ),
                      onPressed: () {
                        setState(() {
                          passwordVisible = !passwordVisible;
                        });
                      },
                    ),
                    keyboardType: TextInputType.text,
                    obscureText: passwordVisible,
                    controller: _passwordController,
                    onSaved: (val) {
                      setState(() {
                        password = val;
                      });

                    },
                    validator: (val) {
                      if (val.length < 6) {
                        return AppLocalizations.of(context)!.login_validation_error3;
                      }

                      //return (val as String).isValidPasswordFormatType1() ? null : '비밀번호는 영문(소문자, 대문자), 숫자, 특수문자로 이루어진 6 ~ 12 자리입니다.';
                      return (val as String).isValidOnlyNumber() ? null : AppLocalizations.of(context)!.login_validation_error4;
                    },
                  ),
                  SizedBox(height: 20.h),
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Transform.scale(
                          scale: 1.2,
                          child: Checkbox(
                            value: _isSaveID,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                            side: MaterialStateBorderSide.resolveWith(
                                  (states) => BorderSide(width: 1.0, color: Colors.grey.shade400),
                            ),
                            onChanged: (value) {
                              setState(() {
                                _isSaveID = value!;
                                _savePref();
                              });
                            },
                          ),
                        ),

                        Text(AppLocalizations.of(context)!.login_save_login_info, style: const TextStyle(color: Colors.black, )),
                      ]
                  ),
                  SizedBox(height: 20.h),
                  isLogging
                      ? const CircularProgressIndicator()
                      : MyButton(
                          onTap: () async { _signUserIn(context); },
                          text: AppLocalizations.of(context)!.login_button//"Sign in",
                      ),
                  SizedBox(height: 20.h),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        TextButton(onPressed: (){}, child: Text(AppLocalizations.of(context)!.login_find_id, style: TextStyle(color: Colors.grey[600]), )),
                        TextButton(onPressed: (){}, child: Text(AppLocalizations.of(context)!.login_find_password, style: TextStyle(color: Colors.grey[600]), )),
                        TextButton(
                          child: Text(AppLocalizations.of(context)!.login_register, style: TextStyle(color: Colors.grey[600])),
                          onPressed: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                                  return const RegisterPage();
                                })
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 13.h),
                  Row(
                    children: [
                      const Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Constants.dividerColor,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Text(
                          AppLocalizations.of(context)!.login_snslogin,
                          style: const TextStyle(color: Constants.dividerColor,),
                        ),
                      ),
                      const Expanded(
                        child: Divider(
                          thickness: 0.5,
                          color: Constants.dividerColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 27.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children:  [
                      SquareTile(
                        imagePath: 'assets/images/google.png',
                        onTap: () {
                          _loginGoogle(context);
                        },
                      ),
                      SizedBox(width: 50.w,),
                      SquareTile(
                        imagePath: 'assets/images/kakao.png',
                        onTap: () {
                          _loginKaKao(context);
                        },
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _loginGoogle(BuildContext context) async {

  }

  void _loginKaKao(BuildContext context) async {
    bool isInstalled = await isKakaoTalkInstalled();

    if (!isInstalled) {
      if (!context.mounted) return;
      _failureDialog(context, AppLocalizations.of(context)!.login_kakao, AppLocalizations.of(context)!.login_kakao_not_installed);
      return;
    }

    setState(() {
      isLogging = true;
    });

    try {
      OAuthToken token = await UserApi.instance.loginWithKakaoTalk();
      debugPrint('카카오톡 로그인 성공 ======================');
      debugPrint('accessToken: ${token.accessToken}');
      debugPrint('expiresAt: ${token.expiresAt}');
      debugPrint('refreshToken: ${token.refreshToken}');
      debugPrint('refreshTokenExpiresAt: ${token.refreshTokenExpiresAt}');
      debugPrint('scopes: ${token.scopes}');
      debugPrint('idToken: ${token.idToken}');

      var user = await UserApi.instance.me();

      debugPrint("회원 정보 ======================");
      debugPrint('회원번호(id): ${user.id}');
      debugPrint('connected_at: ${user.connectedAt}');
      debugPrint('nickname: ${user.kakaoAccount?.profile?.nickname}');
      debugPrint('email: ${user.kakaoAccount?.email}');

      dio = await authDio();
      await dio.post(
          "/auth/kakao_signup",
          data: jsonEncode({
            "email": user.id,
            "name": user.kakaoAccount?.profile?.nickname,
            "password": '${user.id}_${user.kakaoAccount?.profile?.nickname}',
            "snsId": user.id,
            "provider": "kakao",
            "admin": false,
            "deviceID": _deviceId
          })
      );

      final response = await dio.post(
          "/auth/signin",
          data: jsonEncode({
            "email": user.id,
            "password": '${user.id}_${user.kakaoAccount?.profile?.nickname}',
          })
      );

      if (!context.mounted) return;
      _processLogin(context, response);

    } catch (error) {
      if (!context.mounted) return;
      _failureDialog(context, AppLocalizations.of(context)!.login_kakao, AppLocalizations.of(context)!.login_kakao_failure_message);
      setState(() {
        isLogging = false;
      });
    }
  }
}
