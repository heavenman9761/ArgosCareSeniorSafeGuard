import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:argoscareseniorsafeguard/pages/setting_alarm.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/models/sensor.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/pages/profile.dart';

class ProfileWidget extends ConsumerWidget{
  const ProfileWidget({super.key, required this.userID});
  final String userID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                    Text("프로필", style: TextStyle(fontSize: deviceFontSize),),
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
                            onTap: null,
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

                ],
              )
          ),

        ]
      ),
    );
  }

  Future<List<Sensor>> _getSensorList() async {
    DBHelper sd = DBHelper();
    return await sd.getSensors(userID);
  }

  void _goSettingAlarm(BuildContext context) async {
    List<Sensor> list = await _getSensorList();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return SettingAlarm(sensorList: list);
    }));
  }

  void _goProfile(BuildContext context) async {
    List<Sensor> list = await _getSensorList();
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return Profile();
    }));
  }
}