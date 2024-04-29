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

  final _mailController = TextEditingController(text: "dn9318dn@gmail.com");

  @override
  void dispose() {
    super.dispose();
    _mailController.dispose();
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

        await storage.write(key: 'ID', value: loginResponse.data['user']['id']);
        await storage.write(key: 'EMAIL', value: loginResponse.data['user']['email']);
        await storage.write(key: 'PASSWORD', value: password);
        // await storage.write(key: 'NAME', value: loginResponse.data['user']['name']);
        // await storage.write(key: 'ADDR_ZIP', value: loginResponse.data['user']['addr_zip']);
        // await storage.write(key: 'ADDR', value: loginResponse.data['user']['addr']);
        // await storage.write(key: 'MOBILE_PHONE', value: loginResponse.data['user']['mobilephone']);
        // await storage.write(key: 'TEL', value: loginResponse.data['user']['tel']);
        // await storage.write(key: 'SNS_ID', value: loginResponse.data['user']['snsId']);
        // await storage.write(key: 'PROVIDER', value: loginResponse.data['user']['provider']);
        // await storage.write(key: 'ADMiN', value: loginResponse.data['user']['admin'].toString());

        final alarmResponse = await dio.get(
            "/devices/get_alarm/$userID"
        );

        final SharedPreferences pref = await SharedPreferences.getInstance();

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
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("로그인"),
              content: const Text("로그인에 실패했습니다.\n계정을 확인바랍니다."),
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
          text: "Sign in",
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
                          const SizedBox(height: 50),

                          // logo
                          const Icon(
                            Icons.lock,
                            size: 100,
                          ),

                          const SizedBox(height: 30),

                          // welcome back, you've been missed!
                          Text(
                            'Welcome back you\'ve been missed!',
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
                            label: '메일 주소',
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
                                return '이메일은 필수사항입니다.';
                              }
                              return (val as String).isValidEmailFormat() ? null : '이메일 형식이 아닙니다.';
                            },
                          ),

                          const SizedBox(height: 10),

                          renderTextFormField(
                            context: context,
                            label: '비밀 번호',
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
                                return '비밀번호는 6글자 이상 12글자 이하로 입력 해주셔야합니다.';
                              }

                              //return (val as String).isValidPasswordFormatType1() ? null : '비밀번호는 영문(소문자, 대문자), 숫자, 특수문자로 이루어진 6 ~ 12 자리입니다.';
                              return (val as String).isValidOnlyNumber() ? null : '비밀번호는 숫자로 이루어진 6 ~ 12 자리입니다.';
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
                                  child: const Text("Register now", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold,)),
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
                                        Text('Forgot Password?', style: TextStyle(color: Colors.grey[600]), ),
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
                                    'Or continue with',
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
                              SquareTile(imagePath: 'lib/images/google.png'),
                              SquareTile(imagePath: 'lib/images/facebook.png'),
                              SquareTile(imagePath: 'lib/images/twitter.png'),
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
