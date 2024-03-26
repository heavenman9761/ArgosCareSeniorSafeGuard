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

class HomeWidget extends ConsumerWidget{
  HomeWidget({super.key, required this.userName});

  final String userName;

  late List<Device> _deviceList = [];

  Widget waitWidget() {
    return const CircularProgressIndicator(backgroundColor: Colors.blue);
  }

  Future<List<Device>> _getDeviceList() async {
    DBHelper sd = DBHelper();
    _deviceList = await sd.getDevices();
    return _deviceList;
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
                ]
            )
        ),
        Expanded(
          child: FutureBuilder<List<Device>>(
            future: _getDeviceList(),
            builder: (context, snapshot) {
              final List<Device>? devices = snapshot.data;
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
                    return Center(
                      child: waitWidget(),
                    );
                  }
                  return ListView.builder(
                    itemCount: devices.length,
                    itemBuilder: (context, index) {
                      if (devices[index].deviceType == Constants.DEVICE_TYPE_HUB) {
                        return CardWidget(deviceName: devices[index].getDeviceName()!);
                      } else if (devices[index].deviceType == Constants.DEVICE_TYPE_DOOR) {
                        return DoorCardWidget(deviceName: devices[index].getDeviceName()!);
                      } else if (devices[index].deviceType == Constants.DEVICE_TYPE_ILLUMINANCE) {
                        return IlluminanceCardWidget(deviceName: devices[index].getDeviceName()!);
                      } else if (devices[index].deviceType == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
                        return HumidityCardWidget(deviceName: devices[index].getDeviceName()!);
                      } else if (devices[index].deviceType == Constants.DEVICE_TYPE_SMOKE) {
                        return SmokeCardWidget(deviceName: devices[index].getDeviceName()!);
                      } else if (devices[index].deviceType == Constants.DEVICE_TYPE_EMERGENCY) {
                        return EmergencyCardWidget(deviceName: devices[index].getDeviceName()!);
                      } else if (devices[index].deviceType == Constants.DEVICE_TYPE_MOTION) {
                        return MotionCardWidget(deviceName: devices[index].getDeviceName()!);
                      } else {
                        return null;
                      }
                    },
                  );

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