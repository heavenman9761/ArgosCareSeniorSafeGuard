import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:argoscareseniorsafeguard/pages/setting_alarm.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/models/sensor.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/pages/profile.dart';
import 'package:argoscareseniorsafeguard/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:argoscareseniorsafeguard/pages/share_manage.dart';

class ProfileWidget extends StatefulWidget {
  final String userID;

  const ProfileWidget({super.key, required this.userID});

  @override
  State<ProfileWidget> createState() => _ProfileWidgetState();
}

class _ProfileWidgetState extends State<ProfileWidget> {
  final List<String> _languageList = ['한국어', 'English'];
  String _selectedLanguage = '한국어';

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
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
          children: [
            Card(
              color: Colors.white,
              surfaceTintColor: Colors.transparent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 10),
                        Text(AppLocalizations.of(context)!.profile_profile, style: TextStyle(fontSize: deviceFontSize),),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("관리", style: TextStyle(fontSize: deviceFontSize -2, color: Colors.grey)),
                              const SizedBox(width: 10, height: 50),
                              GestureDetector(
                                onTap: () { _goProfile(context); },
                                child: const Icon(Icons.chevron_right, size: 20, color: Colors.black),
                              ),
                              const SizedBox(width: 10)
                            ],
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 10),
                        Text("대상자 이름", style: TextStyle(fontSize: deviceFontSize),),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("이름을 입력해주세요", style: TextStyle(fontSize: deviceFontSize - 2, color: Colors.grey)),
                              const SizedBox(width: 10, height: 50),
                              GestureDetector(
                                onTap: null,
                                child: const Icon(Icons.chevron_right, size: 20, color: Colors.black),
                              ),
                              const SizedBox(width: 10)
                            ],
                          ),
                        )

                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 10),
                        Text("보호자 이름", style: TextStyle(fontSize: deviceFontSize),),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("이름을 입력해주세요", style: TextStyle(fontSize: deviceFontSize - 2, color: Colors.grey)),
                              const SizedBox(width: 10, height: 50),
                              GestureDetector(
                                onTap: null,
                                child: const Icon(Icons.chevron_right, size: 20, color: Colors.black),
                              ),
                              const SizedBox(width: 10)
                            ],
                          ),
                        )

                      ],
                    ),
                  ]
              ),
            ),

            const SizedBox(height: 10),
            Card(
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 10),
                        Text("알림 관리", style: TextStyle(fontSize: deviceFontSize),),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("알림 관리", style: TextStyle(fontSize: deviceFontSize - 2, color: Colors.grey)),
                              const SizedBox(width: 10, height: 50),
                              GestureDetector(
                                onTap: () { _goSettingAlarm(context); },
                                child: const Icon(Icons.chevron_right, size: 20, color: Colors.black),
                              ),
                              const SizedBox(width: 10)
                            ],
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 10),
                        Text("공유자 관리", style: TextStyle(fontSize: deviceFontSize),),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("공유자 추가", style: TextStyle(fontSize: deviceFontSize - 2, color: Colors.grey)),
                              const SizedBox(width: 10, height: 50),
                              GestureDetector(
                                onTap: () { _goShareManage(context); },
                                child: const Icon(Icons.chevron_right, size: 20, color: Colors.black),
                              ),
                              const SizedBox(width: 10)
                            ],
                          ),
                        )
                      ],
                    ),
                  ],
                )
            ),

            const SizedBox(height: 10),
            Card(
                color: Colors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 10),
                        Text("현재 버전", style: TextStyle(fontSize: deviceFontSize),),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("Version 0.1.0", style: TextStyle(fontSize: deviceFontSize - 2, color: Colors.grey)),
                              const SizedBox(width: 10, height: 50),
                              GestureDetector(
                                onTap: () { _goSettingAlarm(context); },
                                child: const Icon(Icons.chevron_right, size: 20, color: Colors.black),
                              ),
                              const SizedBox(width: 10)
                            ],
                          ),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(width: 10),
                        Text("언어 선택", style: TextStyle(fontSize: deviceFontSize),),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
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
                              const SizedBox(width: 10, height: 50),
                            ],
                          ),
                        )
                      ],
                    ),

                  ],
                )
            ),

          ]
      ),
    );
  }

  Future<List<Sensor>> _getSensorList() async {
    DBHelper sd = DBHelper();
    return await sd.getSensors(widget.userID);
  }

  void _goSettingAlarm(BuildContext context) async {
    List<Sensor> list = await _getSensorList();
    if (!context.mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SettingAlarm(userID: widget.userID, sensorList: list);
    }));
  }

  void _goShareManage(BuildContext context) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return ShareManage(userID: widget.userID);
    }));
  }

  void _goProfile(BuildContext context) async {
    List<Sensor> list = await _getSensorList();
    if (!context.mounted) return;
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const Profile();
    }));
  }
}