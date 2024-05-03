import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:argoscareseniorsafeguard/models/sensor.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:argoscareseniorsafeguard/constants.dart';

class SettingAlarm extends ConsumerStatefulWidget {
  const SettingAlarm({super.key, required this.sensorList});
  final List<Sensor> sensorList;

  @override
  ConsumerState<SettingAlarm> createState() => _SettingAlarmState();
}

class _SettingAlarmState extends ConsumerState<SettingAlarm> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(Constants.APP_TITLE),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: "Menu",
              color: Colors.blue,
              onPressed: () {
                _confirmDialog(context);
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Entire(context, ref),
              Expanded(child: ListView.builder(
                  // padding: const EdgeInsets.all(8.0),
                  itemCount: widget.sensorList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Consumer(
                        builder: (context, ref, widget) {
                          return AlarmSetting(context, ref, index);
                        }
                    );
                  }
                )
              )
            ],
          ),
        )
    );
  }

  Widget Entire(BuildContext context, WidgetRef ref) {
     return Card(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('알림', style: TextStyle(fontSize: deviceFontSize),),
              SizedBox(
                height: 30,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: CupertinoSwitch(
                    value: ref.watch(alarmEntireEnableProvider),
                    activeColor: CupertinoColors.activeBlue,
                    onChanged: (bool? value) {
                      ref.read(alarmEntireEnableProvider.notifier).state = value ?? false;
                      ref.read(alarmHumidityEnableProvider.notifier).state = value ?? false;
                      ref.read(alarmEmergencyEnableProvider.notifier).state = value ?? false;
                      ref.read(alarmMotionEnableProvider.notifier).state = value ?? false;
                      ref.read(alarmSmokeEnableProvider.notifier).state = value ?? false;
                      ref.read(alarmIlluminanceEnableProvider.notifier).state = value ?? false;
                      ref.read(alarmDoorEnableProvider.notifier).state = value ?? false;
                    },
                  ),
                )

              ),
            ],
          ),
        )
    );
  }

  Widget Header(String sensorName) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.fiber_manual_record, size: 10.0, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text(sensorName, style: TextStyle(fontSize: deviceFontSize - 2),),
            ]
        )
    );
  }

  Widget AlarmSetting(BuildContext context, WidgetRef ref, int index) {
    return Column(
        children: [
          Header(widget.sensorList[index].getName()!),
          SensorWidget(context, ref, widget.sensorList[index]),
        ]
    );
  }

  Widget SensorWidget(BuildContext context, WidgetRef ref, Sensor sensor) {
    if (sensor.getDeviceType() == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
      return humidityCard(context, ref);

    } else if (sensor.getDeviceType() == Constants.DEVICE_TYPE_ILLUMINANCE) {
      return illuminanceCard(context, ref);

    } else if (sensor.getDeviceType() == Constants.DEVICE_TYPE_MOTION) {
      return motionCard(context, ref);

    } else if (sensor.getDeviceType() == Constants.DEVICE_TYPE_DOOR) {
      return doorCard(context, ref);

    } else if (sensor.getDeviceType() == Constants.DEVICE_TYPE_SMOKE) {
      return smokeCard(context, ref);

    } else if (sensor.getDeviceType() == Constants.DEVICE_TYPE_EMERGENCY) {
      return emergencyCard(context, ref);

    } else {
      return const Text("");
    }
  }

  Widget humidityCard(BuildContext context, WidgetRef ref) {
    return Card(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('알림', style: TextStyle(fontSize: deviceFontSize),),
                  SizedBox(
                    height: 30,
                    child: FittedBox(
                      child: CupertinoSwitch(
                        value: ref.watch(alarmHumidityEnableProvider),
                        activeColor: CupertinoColors.activeBlue,
                        onChanged: (bool? value) {
                          ref
                              .read(alarmHumidityEnableProvider.notifier)
                              .state = value ?? false;
                        },
                      ),
                    )
                  )

                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('시간대 설정', style: TextStyle(fontSize: deviceFontSize),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                            textStyle: TextStyle(fontSize: deviceFontSize),
                            foregroundColor: Colors.black
                        ),
                        onPressed: () async {
                          String st = ref.watch(alarmHumidityStartTimeProvider);
                          TimeOfDay startTime = TimeOfDay(hour:int.parse(st.split(":")[0]),minute: int.parse(st.split(":")[1]));
                          final TimeOfDay? timeOfDay = await showTimePicker(
                            context: context,
                            initialTime: startTime,
                          );
                          if (timeOfDay != null) {
                              String formattedTime = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
                              print(formattedTime);
                              ref.read(alarmHumidityStartTimeProvider.notifier).state = formattedTime;
                          }
                        },
                        child: Text(ref.watch(alarmHumidityStartTimeProvider)),
                      ),
                      Text(' ~ ', style: TextStyle(fontSize: deviceFontSize),),
                      TextButton(
                        style: TextButton.styleFrom(
                            textStyle: TextStyle(fontSize: deviceFontSize),
                            foregroundColor: Colors.black
                        ),
                        onPressed: () async {
                          String et = ref.watch(alarmHumidityEndTimeProvider);
                          TimeOfDay endTime = TimeOfDay(hour:int.parse(et.split(":")[0]),minute: int.parse(et.split(":")[1]));
                          final TimeOfDay? timeOfDay = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                          );
                          if (timeOfDay != null) {
                            String formattedTime = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
                            print(formattedTime);
                            ref.read(alarmHumidityEndTimeProvider.notifier).state = formattedTime;
                          }
                        },
                        child: Text(ref.watch(alarmHumidityEndTimeProvider)),
                      ),
                    ],
                  )

                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('습도 범위', style: TextStyle(fontSize: deviceFontSize),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                            textStyle: TextStyle(fontSize: deviceFontSize),
                            foregroundColor: Colors.black
                        ),
                        onPressed: () async {
                          _inputDialog(context, ref.watch(alarmHumidityStartValueProvider), 0);
                        },
                        child: Text('${ref.watch(alarmHumidityStartValueProvider).toString()}%'),
                      ),
                      Text(' ~ ', style: TextStyle(fontSize: deviceFontSize),),
                      TextButton(
                        style: TextButton.styleFrom(
                            textStyle: TextStyle(fontSize: deviceFontSize),
                            foregroundColor: Colors.black
                        ),
                        onPressed: () async {
                          _inputDialog(context, ref.watch(alarmHumidityEndValueProvider), 1);
                        },
                        child: Text('${ref.watch(alarmHumidityEndValueProvider).toString()}%'),
                      ),
                    ],
                  )
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('온도 범위', style: TextStyle(fontSize: deviceFontSize),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                            textStyle: TextStyle(fontSize: deviceFontSize),
                            foregroundColor: Colors.black
                        ),
                        onPressed: () async {
                          _inputDialog(context, ref.watch(alarmTemperatureStartValueProvider), 2);
                        },
                        child: Text('${ref.watch(alarmTemperatureStartValueProvider).toString()}°'),
                      ),
                      Text(' ~ ', style: TextStyle(fontSize: deviceFontSize),),
                      TextButton(
                        style: TextButton.styleFrom(
                            textStyle: TextStyle(fontSize: deviceFontSize),
                            foregroundColor: Colors.black
                        ),
                        onPressed: () async {
                          _inputDialog(context, ref.watch(alarmTemperatureEndValueProvider), 3);
                        },
                        child: Text('${ref.watch(alarmTemperatureEndValueProvider).toString()}°'),
                      ),
                    ],
                  )
                ],
              ),
            ],

          ),
        )
    );
  }

  Widget illuminanceCard(BuildContext context, WidgetRef ref) {
    return Card(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('알림', style: TextStyle(fontSize: deviceFontSize),),
                    SizedBox(
                      height: 30,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: CupertinoSwitch(
                          value: ref.watch(alarmIlluminanceEnableProvider),
                          activeColor: CupertinoColors.activeBlue,
                          onChanged: (bool? value) {
                            ref.read(alarmIlluminanceEnableProvider.notifier).state = value ?? false;
                          },
                        ),
                      ),
                    )

                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('시간대 설정', style: TextStyle(fontSize: deviceFontSize),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(fontSize: deviceFontSize),
                              foregroundColor: Colors.black
                          ),
                          onPressed: () async {
                            String st = ref.watch(alarmIlluminanceStartTimeProvider);
                            TimeOfDay startTime = TimeOfDay(hour:int.parse(st.split(":")[0]),minute: int.parse(st.split(":")[1]));
                            final TimeOfDay? timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (timeOfDay != null) {
                              String formattedTime = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
                              print(formattedTime);
                              ref.read(alarmIlluminanceStartTimeProvider.notifier).state = formattedTime;
                            }
                          },
                          child: Text(ref.watch(alarmIlluminanceStartTimeProvider)),
                        ),
                        Text(' ~ ', style: TextStyle(fontSize: deviceFontSize),),
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(fontSize: deviceFontSize),
                              foregroundColor: Colors.black
                          ),
                          onPressed: () async {
                            String st = ref.watch(alarmIlluminanceEndTimeProvider);
                            TimeOfDay startTime = TimeOfDay(hour:int.parse(st.split(":")[0]),minute: int.parse(st.split(":")[1]));
                            final TimeOfDay? timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (timeOfDay != null) {
                              String formattedTime = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
                              print(formattedTime);
                              ref.read(alarmIlluminanceEndTimeProvider.notifier).state = formattedTime;
                            }
                          },
                          child: Text(ref.watch(alarmIlluminanceEndTimeProvider)),
                        ),
                      ],
                    )

                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('조도 범위', style: TextStyle(fontSize: deviceFontSize),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(fontSize: deviceFontSize),
                              foregroundColor: Colors.black
                          ),
                          onPressed: () async {
                            _inputDialog(context, ref.watch(alarmIlluminanceStartValueProvider), 4);
                          },
                          child: Text(ref.watch(alarmIlluminanceStartValueProvider).toString()),
                        ),
                        Text(' ~ ', style: TextStyle(fontSize: deviceFontSize),),
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(fontSize: deviceFontSize),
                              foregroundColor: Colors.black
                          ),
                          onPressed: () async {
                            _inputDialog(context, ref.watch(alarmIlluminanceEndValueProvider), 5);
                          },
                          child: Text(ref.watch(alarmIlluminanceEndValueProvider).toString()),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            )
        )
    );
  }

  Widget motionCard(BuildContext context, WidgetRef ref) {
    return Card(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('알림', style: TextStyle(fontSize: deviceFontSize),),
                    SizedBox(
                      height: 30,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: CupertinoSwitch(
                          value: ref.watch(alarmMotionEnableProvider),
                          activeColor: CupertinoColors.activeBlue,
                          onChanged: (bool? value) {
                            ref.read(alarmMotionEnableProvider.notifier).state = value ?? false;
                          },
                        ),
                      )
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('시간대 설정', style: TextStyle(fontSize: deviceFontSize),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(fontSize: deviceFontSize),
                              foregroundColor: Colors.black
                          ),
                          onPressed: () async {
                            String st = ref.watch(alarmMotionStartTimeProvider);
                            TimeOfDay startTime = TimeOfDay(hour:int.parse(st.split(":")[0]),minute: int.parse(st.split(":")[1]));
                            final TimeOfDay? timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (timeOfDay != null) {
                              String formattedTime = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
                              print(formattedTime);
                              ref.read(alarmMotionStartTimeProvider.notifier).state = formattedTime;
                            }
                          },
                          child: Text(ref.watch(alarmMotionStartTimeProvider)),
                        ),
                        Text(' ~ ', style: TextStyle(fontSize: deviceFontSize),),
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(fontSize: deviceFontSize),
                              foregroundColor: Colors.black
                          ),
                          onPressed: () async {
                            String st = ref.watch(alarmMotionEndTimeProvider);
                            TimeOfDay startTime = TimeOfDay(hour:int.parse(st.split(":")[0]),minute: int.parse(st.split(":")[1]));
                            final TimeOfDay? timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (timeOfDay != null) {
                              String formattedTime = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
                              print(formattedTime);
                              ref.read(alarmMotionEndTimeProvider.notifier).state = formattedTime;
                            }
                          },
                          child: Text(ref.watch(alarmMotionEndTimeProvider)),
                        ),
                      ],
                    )

                  ],
                ),
              ],
            )
        )
    );
  }

  Widget doorCard(BuildContext context, WidgetRef ref) {
    return Card(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('알림', style: TextStyle(fontSize: deviceFontSize),),
                    SizedBox(
                      height: 30,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: CupertinoSwitch(
                          value: ref.watch(alarmDoorEnableProvider),
                          activeColor: CupertinoColors.activeBlue,
                          onChanged: (bool? value) {
                            ref.read(alarmDoorEnableProvider.notifier).state = value ?? false;
                          },
                        ),
                      )
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('시간대 설정', style: TextStyle(fontSize: deviceFontSize),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(fontSize: deviceFontSize),
                              foregroundColor: Colors.black
                          ),
                          onPressed: () async {
                            String st = ref.watch(alarmDoorStartTimeProvider);
                            TimeOfDay startTime = TimeOfDay(hour:int.parse(st.split(":")[0]),minute: int.parse(st.split(":")[1]));
                            final TimeOfDay? timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (timeOfDay != null) {
                              String formattedTime = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
                              print(formattedTime);
                              ref.read(alarmDoorStartTimeProvider.notifier).state = formattedTime;
                            }
                          },
                          child: Text(ref.watch(alarmDoorStartTimeProvider)),
                        ),
                        Text(' ~ ', style: TextStyle(fontSize: deviceFontSize),),
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(fontSize: deviceFontSize),
                              foregroundColor: Colors.black
                          ),
                          onPressed: () async {
                            String st = ref.watch(alarmDoorEndTimeProvider);
                            TimeOfDay startTime = TimeOfDay(hour:int.parse(st.split(":")[0]),minute: int.parse(st.split(":")[1]));
                            final TimeOfDay? timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (timeOfDay != null) {
                              String formattedTime = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
                              print(formattedTime);
                              ref.read(alarmDoorEndTimeProvider.notifier).state = formattedTime;
                            }
                          },
                          child: Text(ref.watch(alarmDoorEndTimeProvider)),
                        ),
                      ],
                    )

                  ],
                ),
              ],
            )
        )
    );
  }

  Widget smokeCard(BuildContext context, WidgetRef ref) {
    return Card(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('알림', style: TextStyle(fontSize: deviceFontSize),),
                    SizedBox(
                      height: 30,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: CupertinoSwitch(
                          value: ref.watch(alarmSmokeEnableProvider),
                          activeColor: CupertinoColors.activeBlue,
                          onChanged: (bool? value) {
                            ref.read(alarmSmokeEnableProvider.notifier).state = value ?? false;
                          },
                        ),
                      )
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('시간대 설정', style: TextStyle(fontSize: deviceFontSize),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(fontSize: deviceFontSize),
                              foregroundColor: Colors.black
                          ),
                          onPressed: () async {
                            String st = ref.watch(alarmSmokeStartTimeProvider);
                            TimeOfDay startTime = TimeOfDay(hour:int.parse(st.split(":")[0]),minute: int.parse(st.split(":")[1]));
                            final TimeOfDay? timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (timeOfDay != null) {
                              String formattedTime = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
                              print(formattedTime);
                              ref.read(alarmSmokeStartTimeProvider.notifier).state = formattedTime;
                            }
                          },
                          child: Text(ref.watch(alarmSmokeStartTimeProvider)),
                        ),
                        Text(' ~ ', style: TextStyle(fontSize: deviceFontSize),),
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(fontSize: deviceFontSize),
                              foregroundColor: Colors.black
                          ),
                          onPressed: () async {
                            String st = ref.watch(alarmSmokeEndTimeProvider);
                            TimeOfDay startTime = TimeOfDay(hour:int.parse(st.split(":")[0]),minute: int.parse(st.split(":")[1]));
                            final TimeOfDay? timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (timeOfDay != null) {
                              String formattedTime = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
                              print(formattedTime);
                              ref.read(alarmSmokeEndTimeProvider.notifier).state = formattedTime;
                            }
                          },
                          child: Text(ref.watch(alarmSmokeEndTimeProvider)),
                        ),
                      ],
                    )

                  ],
                ),
              ],
            )
        )
    );
  }

  Widget emergencyCard(BuildContext context, WidgetRef ref) {
    return Card(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('알림', style: TextStyle(fontSize: deviceFontSize),),
                    SizedBox(
                      height: 30,
                      child: FittedBox(
                        fit: BoxFit.contain,
                        child: CupertinoSwitch(
                          value: ref.watch(alarmEmergencyEnableProvider),
                          activeColor: CupertinoColors.activeBlue,
                          onChanged: (bool? value) {
                            ref.read(alarmEmergencyEnableProvider.notifier).state = value ?? false;
                          },
                        ),
                      )
                    )
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('시간대 설정', style: TextStyle(fontSize: deviceFontSize),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(fontSize: deviceFontSize),
                              foregroundColor: Colors.black
                          ),
                          onPressed: () async {
                            String st = ref.watch(alarmEmergencyStartTimeProvider);
                            TimeOfDay startTime = TimeOfDay(hour:int.parse(st.split(":")[0]),minute: int.parse(st.split(":")[1]));
                            final TimeOfDay? timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (timeOfDay != null) {
                              String formattedTime = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
                              print(formattedTime);
                              ref.read(alarmEmergencyStartTimeProvider.notifier).state = formattedTime;
                            }
                          },
                          child: Text(ref.watch(alarmEmergencyStartTimeProvider)),
                        ),
                        Text(' ~ ', style: TextStyle(fontSize: deviceFontSize),),
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: TextStyle(fontSize: deviceFontSize),
                              foregroundColor: Colors.black
                          ),
                          onPressed: () async {
                            String st = ref.watch(alarmEmergencyEndTimeProvider);
                            TimeOfDay startTime = TimeOfDay(hour:int.parse(st.split(":")[0]),minute: int.parse(st.split(":")[1]));
                            final TimeOfDay? timeOfDay = await showTimePicker(
                              context: context,
                              initialTime: startTime,
                            );
                            if (timeOfDay != null) {
                              String formattedTime = '${timeOfDay.hour.toString().padLeft(2, '0')}:${timeOfDay.minute.toString().padLeft(2, '0')}';
                              print(formattedTime);
                              ref.read(alarmEmergencyEndTimeProvider.notifier).state = formattedTime;
                            }
                          },
                          child: Text(ref.watch(alarmEmergencyEndTimeProvider)),
                        ),
                      ],
                    )
                  ],
                ),
              ],
            )
        )
    );
  }

  void _inputDialog(BuildContext context, int initValue, int type) {
    final controller = TextEditingController(text: initValue.toString());
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: initValue.toString().length,
    );

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("값 입력"),
              content: TextFormField(
                controller: controller,
                autofocus: true,
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.pop(context, controller.text);
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((val) {
      if (val != null) {
        switch (type) {
          case 0:
            ref.read(alarmHumidityStartValueProvider.notifier).state = int.parse(val);
            return;
          case 1:
            ref.read(alarmHumidityEndValueProvider.notifier).state = int.parse(val);
            return;
          case 2:
            ref.read(alarmTemperatureStartValueProvider.notifier).state = int.parse(val);
            return;
          case 3:
            ref.read(alarmTemperatureEndValueProvider.notifier).state = int.parse(val);
            return;
          case 4:
            ref.read(alarmIlluminanceStartValueProvider.notifier).state = int.parse(val);
            return;
          case 5:
            ref.read(alarmIlluminanceEndValueProvider.notifier).state = int.parse(val);
            return;
        }
      }
    });
  }

  void _confirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("변경사항을 저장할까요?"),
              actions: [
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
              ]
            );
          }
        );
      }
    ).then((val) {
      if (val) {
        _saveSettings();
      }
    });
  }

  @override
  void initState() {
    super.initState();

    _loadSettings();
  }

  void _loadSettings() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();

    ref.read(alarmEntireEnableProvider.notifier).state = pref.getBool("EntireAlarm") ?? true;

    ref.read(alarmHumidityEnableProvider.notifier).state = pref.getBool("HumidityAlarmEnable") ?? true;
    ref.read(alarmHumidityStartTimeProvider.notifier).state = pref.getString("HumidityStartTime") ?? "00:00";
    ref.read(alarmHumidityEndTimeProvider.notifier).state = pref.getString("HumidityEndTime") ?? "23:59";
    ref.read(alarmHumidityStartValueProvider.notifier).state = pref.getInt("HumidityStartValue") ?? 0;
    ref.read(alarmHumidityEndValueProvider.notifier).state = pref.getInt("HumidityEndValue") ?? 100;
    ref.read(alarmTemperatureStartValueProvider.notifier).state = pref.getInt("TemperatureStartValue") ?? -10;
    ref.read(alarmTemperatureEndValueProvider.notifier).state = pref.getInt("TemperatureEndValue") ?? 50;

    ref.read(alarmEmergencyEnableProvider.notifier).state = pref.getBool("EmergencyAlarmEnable") ?? true;
    ref.read(alarmEmergencyStartTimeProvider.notifier).state = pref.getString("EmergencyStartTime") ?? "00:00";
    ref.read(alarmEmergencyEndTimeProvider.notifier).state = pref.getString("EmergencyEndTime") ?? "23:59";

    ref.read(alarmMotionEnableProvider.notifier).state = pref.getBool("MotionAlarmEnable") ?? true;
    ref.read(alarmMotionStartTimeProvider.notifier).state = pref.getString("MotionStartTime") ?? "00:00";
    ref.read(alarmMotionEndTimeProvider.notifier).state = pref.getString("MotionEndTime") ?? "23:59";

    ref.read(alarmSmokeEnableProvider.notifier).state = pref.getBool("SmokeAlarmEnable") ?? true;
    ref.read(alarmSmokeStartTimeProvider.notifier).state = pref.getString("SmokeStartTime") ?? "00:00";
    ref.read(alarmSmokeEndTimeProvider.notifier).state = pref.getString("SmokeEndTime") ?? "23:59";

    ref.read(alarmIlluminanceEnableProvider.notifier).state = pref.getBool("IlluminanceAlarmEnable") ?? true;
    ref.read(alarmIlluminanceStartTimeProvider.notifier).state = pref.getString("IlluminanceStartTime") ?? "00:00";
    ref.read(alarmIlluminanceEndTimeProvider.notifier).state = pref.getString("IlluminanceEndTime") ?? "23:59";
    ref.read(alarmIlluminanceStartValueProvider.notifier).state = pref.getInt("IlluminanceStartValue") ?? 1;
    ref.read(alarmIlluminanceEndValueProvider.notifier).state = pref.getInt("IlluminanceEndValue") ?? 10;

    ref.read(alarmDoorEnableProvider.notifier).state = pref.getBool("DoorAlarmEnable") ?? true;
    ref.read(alarmDoorStartTimeProvider.notifier).state = pref.getString("DoorStartTime") ?? "00:00";
    ref.read(alarmDoorEndTimeProvider.notifier).state = pref.getString("DoorEndTime") ?? "23:59";
  }

  void _saveSettings() async {
    const storage = FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );
    final userID = await storage.read(key: 'ID');

    final SharedPreferences pref = await SharedPreferences.getInstance();

    pref.setBool("EntireAlarm", ref.watch(alarmEntireEnableProvider));

    pref.setBool("HumidityAlarmEnable", ref.watch(alarmHumidityEnableProvider));
    pref.setString("HumidityStartTime", ref.watch(alarmHumidityStartTimeProvider));
    pref.setString("HumidityEndTime", ref.watch(alarmHumidityEndTimeProvider));
    pref.setInt("HumidityStartValue", ref.watch(alarmHumidityStartValueProvider));
    pref.setInt("HumidityEndValue", ref.watch(alarmHumidityEndValueProvider));
    pref.setInt("TemperatureStartValue", ref.watch(alarmTemperatureStartValueProvider));
    pref.setInt("TemperatureEndValue", ref.watch(alarmTemperatureEndValueProvider));

    pref.setBool("EmergencyAlarmEnable", ref.watch(alarmEmergencyEnableProvider));
    pref.setString("EmergencyStartTime", ref.watch(alarmEmergencyStartTimeProvider));
    pref.setString("EmergencyEndTime", ref.watch(alarmEmergencyEndTimeProvider));

    pref.setBool("MotionAlarmEnable", ref.watch(alarmMotionEnableProvider));
    pref.setString("MotionStartTime", ref.watch(alarmMotionStartTimeProvider));
    pref.setString("MotionEndTime", ref.watch(alarmMotionEndTimeProvider));

    pref.setBool("SmokeAlarmEnable", ref.watch(alarmSmokeEnableProvider));
    pref.setString("SmokeStartTime", ref.watch(alarmSmokeStartTimeProvider));
    pref.setString("SmokeEndTime", ref.watch(alarmSmokeEndTimeProvider));

    pref.setBool("IlluminanceAlarmEnable", ref.watch(alarmIlluminanceEnableProvider));
    pref.setString("IlluminanceStartTime", ref.watch(alarmIlluminanceStartTimeProvider));
    pref.setString("IlluminanceEndTime", ref.watch(alarmIlluminanceEndTimeProvider));
    pref.setInt("IlluminanceStartValue", ref.watch(alarmIlluminanceStartValueProvider));
    pref.setInt("IlluminanceEndValue", ref.watch(alarmIlluminanceEndValueProvider));

    pref.setBool("DoorAlarmEnable", ref.watch(alarmDoorEnableProvider));
    pref.setString("DoorStartTime", ref.watch(alarmDoorStartTimeProvider));
    pref.setString("DoorEndTime", ref.watch(alarmDoorEndTimeProvider));

    final response = await dio.post(
      "/devices/set_alarm",
      data: jsonEncode({
        "userID": userID,

        "entireAlarm": ref.watch(alarmEntireEnableProvider),

        "humidityAlarmEnable": ref.watch(alarmHumidityEnableProvider),
        "humidityStartTime": ref.watch(alarmHumidityStartTimeProvider),
        "humidityEndTime": ref.watch(alarmHumidityEndTimeProvider),
        "humidityStartValue": ref.watch(alarmHumidityStartValueProvider),
        "humidityEndValue": ref.watch(alarmHumidityEndValueProvider),
        "temperatureStartValue": ref.watch(alarmTemperatureStartValueProvider),
        "temperatureEndValue": ref.watch(alarmTemperatureEndValueProvider),

        "emergencyAlarmEnable": ref.watch(alarmEmergencyEnableProvider),
        "emergencyStartTime": ref.watch(alarmEmergencyStartTimeProvider),
        "emergencyEndTime": ref.watch(alarmEmergencyEndTimeProvider),

        "motionAlarmEnable": ref.watch(alarmMotionEnableProvider),
        "motionStartTime": ref.watch(alarmMotionStartTimeProvider),
        "motionEndTime": ref.watch(alarmMotionEndTimeProvider),

        "smokeAlarmEnable": ref.watch(alarmSmokeEnableProvider),
        "smokeStartTime": ref.watch(alarmSmokeStartTimeProvider),
        "smokeEndTime": ref.watch(alarmSmokeEndTimeProvider),

        "illuminanceAlarmEnable": ref.watch(alarmIlluminanceEnableProvider),
        "illuminanceStartTime": ref.watch(alarmIlluminanceStartTimeProvider),
        "illuminanceEndTime": ref.watch(alarmIlluminanceEndTimeProvider),
        "illuminanceStartValue": ref.watch(alarmIlluminanceStartValueProvider),
        "illuminanceEndValue": ref.watch(alarmIlluminanceEndValueProvider),

        "doorAlarmEnable": ref.watch(alarmDoorEnableProvider),
        "doorStartTime": ref.watch(alarmDoorStartTimeProvider),
        "doorEndTime": ref.watch(alarmDoorEndTimeProvider),
      })
    );
  }
}
