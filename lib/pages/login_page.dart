import 'dart:convert';

import 'package:argoscareseniorsafeguard/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';
import 'package:dio/dio.dart';
import 'package:mobile_device_identifier/mobile_device_identifier.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
    _isSaveID = pref.getBool('saveLoginID')!;
    if (_isSaveID) {
      const storage = FlutterSecureStorage(
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
      );

      String _eee = (await storage.read(key: 'EMAIL'))!;
      String _ppp = (await storage.read(key: 'PASSWORD'))!;

      _mailController.text = _eee;
      _passwordController.text = _ppp;

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

  void _saveUserInfo(var loginResponse) async {
    gHubList.clear();
    gLocationList.clear();
    gShareInfo.clear();

    final hList = loginResponse.data['Hub_Infos'] as List;
    for (var h in hList) {
      gHubList.add(HubInfo.fromJson(h));
    }

    final lList = loginResponse.data['Location_Infos'] as List;
    for (var l in lList) {
      List<SensorInfo> sl = [];
      for (var s in l['Sensor_Infos']) {
        sl.add(
          SensorInfo.fromJson(s)
        );
      }

      gLocationList.add(
        LocationInfo(
          id: l['id'],
          name: l['name'],
          userID: l['userID'],
          type: l['type'],
          displaySunBun: l['displaySunBun'],
          requireMotionSensorCount: l['requireMotionSensorCount'],
          detectedMotionSensorCount: l['detectedMotionSensorCount'],
          requireDoorSensorCount: l['requireDoorSensorCount'],
          detectedDoorSensorCount: l['detectedDoorSensorCount'],
          createdAt: l['createdAt'],
          updatedAt: l['updatedAt'],
          sensors: sl
        )
      );
    }

    final shList = loginResponse.data['Share_Infos'] as List;
    for (var sh in shList) {
      gShareInfo.add(ShareInfo.fromJson(sh));
    }

    // print(gShareInfo);
    // print(gHubList);
    // print("===================");
    // print(gSensorList);
    // print(gLocationList);
    // print("===================");

    final SharedPreferences pref = await SharedPreferences.getInstance();

    pref.setString("name", loginResponse.data['name']);
    pref.setString("protectPeople", loginResponse.data['protectPeople']);
    pref.setString("addr_zip", loginResponse.data['addr_zip']);
    pref.setString("addr", loginResponse.data['addr']);
    pref.setString("mobilephone", loginResponse.data['mobilephone']);
    pref.setString("tel", loginResponse.data['tel']);
    pref.setString("snsId", loginResponse.data['snsId']);
    pref.setString("provider", loginResponse.data['provider']);
    pref.setBool("admin", loginResponse.data['admin']);
    pref.setString("shareKey", loginResponse.data['shareKey']);

    /*pref.setBool("EntireAlarm", alarmResponse.data['entireAlarm']);

    pref.setBool("HumidityAlarmEnable", alarmResponse.data['humidityAlarmEnable']);
    pref.setString("HumidityStartTime", alarmResponse.data['humidityStartTime']);
    pref.setString("HumidityEndTime", alarmResponse.data['humidityEndTime']);
    pref.setInt("HumidityStartValue", alarmResponse.data['humidityStartValue']);
    pref.setInt("HumidityEndValue", alarmResponse.data['humidityEndValue']);
    pref.setInt("TemperatureStartValue", alarmResponse.data['temperatureStartValue']);
    pref.setInt("TemperatureEndValue", alarmResponse.data['temperatureEndValue']);

    pref.setBool("EmergencyAlarmEnable", alarmResponse.data['emergencyAlarmEnable']);
    pref.setString("EmergencyStartTime", alarmResponse.data['emergencyStartTime']);
    pref.setString("EmergencyEndTime", alarmResponse.data['emergencyEndTime']);

    pref.setBool("MotionAlarmEnable", alarmResponse.data['motionAlarmEnable']);
    pref.setString("MotionStartTime", alarmResponse.data['motionStartTime']);
    pref.setString("MotionEndTime", alarmResponse.data['motionEndTime']);

    pref.setBool("SmokeAlarmEnable", alarmResponse.data['smokeAlarmEnable']);
    pref.setString("SmokeStartTime", alarmResponse.data['smokeStartTime']);
    pref.setString("SmokeEndTime", alarmResponse.data['smokeEndTime']);

    pref.setBool("IlluminanceAlarmEnable", alarmResponse.data['illuminanceAlarmEnable']);
    pref.setString("IlluminanceStartTime", alarmResponse.data['illuminanceStartTime']);
    pref.setString("IlluminanceEndTime", alarmResponse.data['illuminanceEndTime']);
    pref.setInt("IlluminanceStartValue", alarmResponse.data['illuminanceStartValue']);
    pref.setInt("IlluminanceEndValue", alarmResponse.data['illuminanceEndValue']);

    pref.setBool("DoorAlarmEnable", alarmResponse.data['doorAlarmEnable']);
    pref.setString("DoorStartTime", alarmResponse.data['doorStartTime']);
    pref.setString("DoorEndTime", alarmResponse.data['doorEndTime']);*/
  }

  // sign user in method
  void signUserIn(BuildContext context) async {
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

    _saveUserInfo(loginResponse);

    if (!context.mounted) return;
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (context) {
          return HomePage(title: Constants.APP_TITLE, userName: userName, userID: userID);
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
      backgroundColor: Colors.grey[300],
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Center(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Flexible(
                      fit: FlexFit.tight,
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // logo
                          const Icon(
                            Icons.lock,
                            size: 100,
                          ),

                          const SizedBox(height: 30),

                        ],
                      )
                  ),
                  Flexible(
                      fit: FlexFit.tight,
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context)!.login_id,), //아이디
                            ],
                          ),

                          const SizedBox(height: 5,),

                          renderTextFormField(
                            context: context,
                            label: AppLocalizations.of(context)!.login_email,
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

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(AppLocalizations.of(context)!.login_password)
                            ],
                          ),

                          const SizedBox(height: 5,),

                          renderTextFormField(
                            context: context,
                            label: AppLocalizations.of(context)!.login_password,
                            keyNumber: 2,
                            icon: const Icon(Icons.lock, color: Colors.grey,),
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

                          const SizedBox(height: 5),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                  value: _isSaveID,
                                  onChanged: (value) {
                                    setState(() {
                                      _isSaveID = value!;
                                      _savePref();
                                    });
                                  },
                                ),
                                Text(AppLocalizations.of(context)!.login_save_login_info, style: TextStyle(color: Colors.grey[600], )),
                              ]
                            )
                          ),

                          const SizedBox(height: 10),

                          isLogging
                            ? const CircularProgressIndicator()
                            : MyButton(
                                onTap: () async {
                                  signUserIn(context);
                                },
                                text: AppLocalizations.of(context)!.login_button//"Sign in",
                              ),

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
                        ]
                      )
                  ),
                  Flexible(
                      fit: FlexFit.tight,
                      flex: 1,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                           padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Divider(
                                    thickness: 0.5,
                                    color: Colors.grey[400],
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                  child: Text(
                                    AppLocalizations.of(context)!.login_snslogin,
                                    style: TextStyle(color: Colors.grey[700]),
                                  ),
                                ),
                                Expanded(
                                  child: Divider(
                                    thickness: 0.5,
                                    color: Colors.grey[400],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children:  [
                              SquareTile(
                                imagePath: 'assets/images/kakao.png',
                                onTap: () {
                                  _loginKaKao(context);
                                },
                              ),
                              SquareTile(
                                imagePath: 'assets/images/google.png',
                                onTap: () {
                                  _loginGoogle(context);
                                },
                              ),
                            ],
                          ),
                        ],
                      )
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
