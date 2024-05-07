import 'dart:convert';

import 'package:argoscareseniorsafeguard/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/components/my_textfield.dart';
import 'package:argoscareseniorsafeguard/components/square_tile.dart';
import 'package:argoscareseniorsafeguard/pages/home_page.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/auth/auth_dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:argoscareseniorsafeguard/utils/string_extensions.dart';
import 'package:argoscareseniorsafeguard/main.dart';

import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final List<String> _languageList = ['한국어', 'English'];
  String _selectedLanguage = '한국어';

  final _formKey = GlobalKey<FormState>();

  String email = '';
  String password = '';
  bool isLogging = false;
  bool passwordVisible = true;
  late String userID;

  final _mailController = TextEditingController(text: "dn9318dn@gmail.com");

  @override
  void initState() {
    super.initState();
    loadLocale();
  }

  void loadLocale() async {
    var prefs = await SharedPreferences.getInstance();
    setState(() {
      String localeStr = prefs.getString('languageCode') ?? 'ko';

      if (localeStr == "ko") { _selectedLanguage = "한국어"; }
      else if (localeStr == "en") { _selectedLanguage = "English"; }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _mailController.dispose();
  }

  Future<void> _saveUserInfo(var storage, var loginResponse) async {
    await storage.write(key: 'ID', value: loginResponse.data['user']['id']);
    await storage.write(key: 'EMAIL', value: loginResponse.data['user']['email']);
    await storage.write(key: 'PASSWORD', value: password);

    final alarmResponse = await dio.get(
        "/devices/get_alarm/$userID"
    );

    final SharedPreferences pref = await SharedPreferences.getInstance();

    pref.setString("name", loginResponse.data['user']['name']);
    pref.setString("protectPeople", loginResponse.data['user']['protectPeople']);
    pref.setString("addr_zip", loginResponse.data['user']['addr_zip']);
    pref.setString("addr", loginResponse.data['user']['addr']);
    pref.setString("mobilephone", loginResponse.data['user']['mobilephone']);
    pref.setString("tel", loginResponse.data['user']['tel']);
    pref.setString("snsId", loginResponse.data['user']['snsId']);
    pref.setString("provider", loginResponse.data['user']['provider']);
    pref.setBool("admin", loginResponse.data['user']['admin']);
    pref.setString("shareKey", loginResponse.data['user']['shareKey']);

    pref.setBool("EntireAlarm", alarmResponse.data['entireAlarm']);

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
    pref.setString("DoorEndTime", alarmResponse.data['doorEndTime']);
  }

  // sign user in method
  void signUserIn(BuildContext context) async {
    // setState(() {
    //   MainApp.setLocale(context, const Locale("ko", ""));
    //   print(AppLocalizations.of(context)!.login_button);
    // });
    // return;
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

        final token = response.data['token'];
        const storage = FlutterSecureStorage(
          iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        );
        await storage.write(key: 'ACCESS_TOKEN', value: token);

        final loginResponse = await dio.get(
            "/auth/me"
        );

        final String userName = loginResponse.data['user']['name'];
        userID = loginResponse.data['user']['id'];

        _saveUserInfo(storage, loginResponse);

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
          return HomePage(title: Constants.APP_TITLE, userName: userName, userID: userID);
        },
        ));

      } catch (e) {
        debugPrint(e.toString());
        _failureDialog(context);
        setState(() {
          isLogging = false;
        });
      }
    }
  }

  void _failureDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.login_button),
              content: Text(AppLocalizations.of(context)!.login_failure_message),
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

  Widget loginWidget(BuildContext context) {

    if (isLogging) {
      return const CircularProgressIndicator();
    } else {
      return MyButton(
          onTap: () async {
            signUserIn(context);
          },
          text: AppLocalizations.of(context)!.login_button//"Sign in",
      );
    }
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
                  Flexible(
                      fit: FlexFit.tight,
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              const SizedBox(height: 50),
                              DropdownButton<String>(
                                value: _selectedLanguage,
                                icon: const Icon(Icons.expand_more),
                                underline: const SizedBox.shrink(),
                                onChanged: (String? value) {
                                  setState(() {
                                    _selectedLanguage = value!;
                                    if (value == "한국어") { MainApp.setLocale(context, const Locale("ko", "")); }
                                    else if (value == "English") { MainApp.setLocale(context, const Locale("en", "")); }

                                  });
                                },
                                items: _languageList.map((value) {
                                  return DropdownMenuItem(
                                      value: value,
                                      child: Text(value)
                                  );
                                },
                                ).toList(),
                              ),
                            ],
                          ),
                          // logo
                          const Icon(
                            Icons.lock,
                            size: 100,
                          ),

                          const SizedBox(height: 30),

                          // welcome back, you've been missed!
                          Text(
                            AppLocalizations.of(context)!.login_welcome,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 16,
                            ),
                          ),

                          const SizedBox(height: 18),
                        ],
                      )
                  ),
                  Flexible(
                      fit: FlexFit.tight,
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
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
                            initialValue: '121212',
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

                          const SizedBox(height: 10),

                          // forgot password?
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                TextButton(
                                  child: Text(AppLocalizations.of(context)!.login_register, style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold,)),
                                  onPressed: () {
                                    Navigator.push(context,
                                        MaterialPageRoute(builder: (context) {
                                          return const RegisterPage();
                                        })
                                    );
                                  },
                                ),
                                Flexible(
                                    fit: FlexFit.tight,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(AppLocalizations.of(context)!.login_forgot, style: TextStyle(color: Colors.grey[600]), ),
                                      ],
                                    ),
                                )
                              ],
                            ),
                          ),

                          const SizedBox(height: 10),

                          // sign in button
                          loginWidget(context),
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

                          const Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children:  [
                              SquareTile(imagePath: 'assets/images/kakao.png'),
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
}
