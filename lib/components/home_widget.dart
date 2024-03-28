import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:argoscareseniorsafeguard/components/door_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/motion_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/illuminance_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/humidity_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/smoke_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/emergency_card_widget.dart';
import 'package:argoscareseniorsafeguard/components/card_widget.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/models/device.dart';
import 'package:argoscareseniorsafeguard/models/sensor.dart';
import 'package:argoscareseniorsafeguard/models/hub.dart';

class HomeWidget extends ConsumerWidget{
  HomeWidget({super.key, required this.userName});

  final String userName;

  final List<Hub> _hubList = [];

  /*final _locationList = ['모두', '우리집', '회사'];
  var _selectedLocation = '모두';*/

  Widget waitWidget() {
    return const CircularProgressIndicator(backgroundColor: Colors.blue);
  }

  /*Future<List<Device>> _getDeviceList() async {
    List<Device> deviceList = [];

    DBHelper sd = DBHelper();
    deviceList = await sd.getDevices();
    return deviceList;
  }*/

  Future<List<Sensor>> _getSensorList() async {
    DBHelper sd = DBHelper();

    List<Sensor> sensorList = await sd.getSensors();

    return sensorList;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("안녕하세요 ${userName}님,",
                    style: const TextStyle(fontSize: 20.0),),
                  IconButton(
                    icon: const Icon(Icons.account_circle, size: 48.0),
                    tooltip: "Menu",
                    color: Colors.grey,
                    onPressed: () {
                      debugPrint('icon press');
                    },
                  ),
                  /*DropdownButton(
                    underline: const SizedBox.shrink(),
                    items: _locationList.map(
                        (value) {
                          return DropdownMenuItem(
                              value: value,
                              child: Text(value)
                          );
                        },
                    ).toList(),
                    value: _selectedLocation,
                    onChanged: (value) {
                        _selectedLocation = value!;
                    }
                  )*/
                ]
            )
        ),
        Expanded(
          child: FutureBuilder<List<Sensor>>(
            future: _getSensorList(),
            builder: (context, snapshot) {
              final List<Sensor>? devices = snapshot.data;
              if (snapshot.connectionState != ConnectionState.done) {
                return Center(
                  child: waitWidget(),
                );
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(snapshot.error.toString()),
                );
              }
              if (snapshot.hasData) {
                if (devices != null) {
                  if (devices.isEmpty) {
                    return const Center(
                      child: Text("등록된 센서가 없습니다.\n내 기기 탭에서 센서를 등록하세요.", textAlign: TextAlign.center),
                    );
                  } else {
                    return ListView.builder(
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        /*if (devices[index].deviceType == Constants.DEVICE_TYPE_HUB) {
                          return CardWidget(deviceName: devices[index].getName()!);
                        } else */if (devices[index].deviceType == Constants.DEVICE_TYPE_DOOR) {
                          return DoorCardWidget(deviceName: devices[index].getName()!);
                        } else if (devices[index].deviceType == Constants.DEVICE_TYPE_ILLUMINANCE) {
                          return IlluminanceCardWidget(deviceName: devices[index].getName()!);
                        } else if (devices[index].deviceType == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
                          return HumidityCardWidget(deviceName: devices[index].getName()!);
                        } else if (devices[index].deviceType == Constants.DEVICE_TYPE_SMOKE) {
                          return SmokeCardWidget(deviceName: devices[index].getName()!);
                        } else if (devices[index].deviceType == Constants.DEVICE_TYPE_EMERGENCY) {
                          return EmergencyCardWidget(deviceName: devices[index].getName()!);
                        } else if (devices[index].deviceType == Constants.DEVICE_TYPE_MOTION) {
                          return MotionCardWidget(deviceName: devices[index].getName()!);
                        } else {
                          return null;
                        }
                      },
                    );
                  }
                } else {
                  return Center(
                    child: waitWidget(),
                  );
                }
              } else {
                return Center(
                  child: waitWidget(),
                );
              }
            },
          ),
        )
      ],
    );
  }
}