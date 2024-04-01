import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:argoscareseniorsafeguard/models/sensor.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';

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
          title: const Text('Argos Care'),
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
                  padding: const EdgeInsets.all(8.0),
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Card(
          color: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('알림', style: TextStyle(fontSize: 20),),
                CupertinoSwitch(
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
              ],
            ),
          )
      ),
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
              Text(sensorName, style: const TextStyle(fontSize: 16.0),),
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
                  const Text('알림', style: TextStyle(fontSize: 20),),
                  CupertinoSwitch(
                    value: ref.watch(alarmHumidityEnableProvider),
                    activeColor: CupertinoColors.activeBlue,
                    onChanged: (bool? value) {
                      ref
                          .read(alarmHumidityEnableProvider.notifier)
                          .state = value ?? false;
                    },
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('시간대 설정', style: TextStyle(fontSize: 20),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20),
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
                      const Text(' ~ ', style: TextStyle(fontSize: 20),),
                      TextButton(
                        style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20),
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
                  const Text('습도 범위', style: TextStyle(fontSize: 20),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20),
                            foregroundColor: Colors.black
                        ),
                        onPressed: () async {
                          _inputDialog(context, ref.watch(alarmHumidityStartValueProvider), 0);
                        },
                        child: Text('${ref.watch(alarmHumidityStartValueProvider).toString()}%'),
                      ),
                      const Text(' ~ ', style: TextStyle(fontSize: 20),),
                      TextButton(
                        style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20),
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
                  const Text('온도 범위', style: TextStyle(fontSize: 20),),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20),
                            foregroundColor: Colors.black
                        ),
                        onPressed: () async {
                          _inputDialog(context, ref.watch(alarmTemperatureStartValueProvider), 2);
                        },
                        child: Text('${ref.watch(alarmTemperatureStartValueProvider).toString()}°'),
                      ),
                      const Text(' ~ ', style: TextStyle(fontSize: 20),),
                      TextButton(
                        style: TextButton.styleFrom(
                            textStyle: const TextStyle(fontSize: 20),
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
                    const Text('알림', style: TextStyle(fontSize: 20),),
                    CupertinoSwitch(
                      value: ref.watch(alarmIlluminanceEnableProvider),
                      activeColor: CupertinoColors.activeBlue,
                      onChanged: (bool? value) {
                        ref.read(alarmIlluminanceEnableProvider.notifier).state = value ?? false;
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('시간대 설정', style: TextStyle(fontSize: 20),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
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
                        const Text(' ~ ', style: TextStyle(fontSize: 20),),
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
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
                    const Text('조도 범위', style: TextStyle(fontSize: 20),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
                              foregroundColor: Colors.black
                          ),
                          onPressed: () async {
                            _inputDialog(context, ref.watch(alarmIlluminanceStartValueProvider), 4);
                          },
                          child: Text(ref.watch(alarmIlluminanceStartValueProvider).toString()),
                        ),
                        const Text(' ~ ', style: TextStyle(fontSize: 20),),
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
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
                    const Text('알림', style: TextStyle(fontSize: 20),),
                    CupertinoSwitch(
                      value: ref.watch(alarmMotionEnableProvider),
                      activeColor: CupertinoColors.activeBlue,
                      onChanged: (bool? value) {
                        ref.read(alarmMotionEnableProvider.notifier).state = value ?? false;
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('시간대 설정', style: TextStyle(fontSize: 20),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
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
                        const Text(' ~ ', style: TextStyle(fontSize: 20),),
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
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
                    const Text('알림', style: TextStyle(fontSize: 20),),
                    CupertinoSwitch(
                      value: ref.watch(alarmDoorEnableProvider),
                      activeColor: CupertinoColors.activeBlue,
                      onChanged: (bool? value) {
                        ref.read(alarmDoorEnableProvider.notifier).state = value ?? false;
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('시간대 설정', style: TextStyle(fontSize: 20),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
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
                        const Text(' ~ ', style: TextStyle(fontSize: 20),),
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
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
                    const Text('알림', style: TextStyle(fontSize: 20),),
                    CupertinoSwitch(
                      value: ref.watch(alarmSmokeEnableProvider),
                      activeColor: CupertinoColors.activeBlue,
                      onChanged: (bool? value) {
                        ref.read(alarmSmokeEnableProvider.notifier).state = value ?? false;
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('시간대 설정', style: TextStyle(fontSize: 20),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
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
                        const Text(' ~ ', style: TextStyle(fontSize: 20),),
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
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
                    const Text('알림', style: TextStyle(fontSize: 20),),
                    CupertinoSwitch(
                      value: ref.watch(alarmEmergencyEnableProvider),
                      activeColor: CupertinoColors.activeBlue,
                      onChanged: (bool? value) {
                        ref.read(alarmEmergencyEnableProvider.notifier).state = value ?? false;
                      },
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('시간대 설정', style: TextStyle(fontSize: 20),),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
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
                        const Text(' ~ ', style: TextStyle(fontSize: 20),),
                        TextButton(
                          style: TextButton.styleFrom(
                              textStyle: const TextStyle(fontSize: 20),
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

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("값 입력"),
              content: TextFormField(
                controller: controller,
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
        print(' 저장 ');
      }
    });
  }
}
