import 'package:flutter/material.dart';

class SettingAlarm extends StatefulWidget {
  const SettingAlarm({super.key});

  @override
  State<SettingAlarm> createState() => _SettingAlarmState();
}

class _SettingAlarmState extends State<SettingAlarm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Argos Care'),
          centerTitle: true,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("알림 셋팅")
            ],
          ),
        )
    );
  }
}
