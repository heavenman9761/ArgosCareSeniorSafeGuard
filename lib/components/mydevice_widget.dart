import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/pages/add_sensor_page1.dart';
import 'package:argoscareseniorsafeguard/pages/add_hub_page1.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/models/device.dart';
import 'package:argoscareseniorsafeguard/models/hub.dart';
import 'package:argoscareseniorsafeguard/models/sensor.dart';

class MyDeviceWidget extends ConsumerWidget{
  MyDeviceWidget({super.key});

  bool _existHub = false;
  final List<String> _actionList = ['허브 등록', '센서 등록'];
  int _selectIndex = 0;
  final List<Hub> _hubList = [];

  final ButtonStyle elevatedButtonStyle = ElevatedButton.styleFrom(
      foregroundColor: Colors.white60,
      backgroundColor: Colors.lightBlue, // text color
      elevation: 5, //
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
  );

  Future<List<Device>> _getDeviceList() async {
    DBHelper sd = DBHelper();

    _hubList.clear();

    List<Hub> hubList = await sd.getHubs();
    List<Sensor> sensorList = await sd.getSensors();
    List<Device> deviceList = [];

    for (Hub hub in hubList) {
        Device device = Device(
          deviceID: hub.getHubID(),
          deviceType: hub.getDeviceType(),
          deviceName: hub.getName(),
          displaySunBun: hub.getDisplaySunBun(),
          accountID: "",
          status: "",
          updatedAt: "",
          createdAt: ""
        );
        deviceList.add(device);
        _hubList.add(hub);
    }

    for (Sensor sensor in sensorList) {
      Device device = Device(
          deviceID: sensor.getSensorID(),
          deviceType: sensor.getDeviceType(),
          deviceName: sensor.getName(),
          displaySunBun: sensor.getDisplaySunBun(),
          accountID: "",
          status: "",
          updatedAt: "",
          createdAt: ""
      );
      deviceList.add(device);
    }

    return deviceList;
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
                const Text("기기 조회", style: TextStyle(fontSize: 24.0),),
                ElevatedButton(onPressed: () { _action(context, ref); }, style: elevatedButtonStyle, child: const Text('기기 등록')),
              ]
            )
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
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
                        return const Center(
                          child: Text("등록된 센서가 없습니다.\n기기 등록에서 센서를 등록하세요.", textAlign: TextAlign.center),
                        );
                      }
                      return ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          if (devices[index].getDeviceType() == Constants.DEVICE_TYPE_HUB) {
                            _existHub = true;
                            return myListTile(devices[index], '허브');

                          } else if (devices[index].getDeviceType() == Constants.DEVICE_TYPE_ILLUMINANCE) {
                            return myListTile(devices[index], '조도 센서');

                          } else if (devices[index].getDeviceType() == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
                            return myListTile(devices[index], '온습도 센서');

                          } else if (devices[index].getDeviceType() == Constants.DEVICE_TYPE_SMOKE) {
                            return myListTile(devices[index], '화재 센서');

                          } else if (devices[index].getDeviceType() == Constants.DEVICE_TYPE_EMERGENCY) {
                            return myListTile(devices[index], 'SOS 버튼');

                          } else if (devices[index].getDeviceType() == Constants.DEVICE_TYPE_MOTION) {
                            return myListTile(devices[index], '움직임 감지 센서');

                          } else if (devices[index].getDeviceType() == Constants.DEVICE_TYPE_DOOR) {
                            return myListTile(devices[index], '도어 센서');

                          }
                          return null;
                        }

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
            ),
          ),
          const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Center(
                child: Text(
                  'Wi-Fi를 2.4GHz 주파수로 설정해주세요. \n(5GHz는 지원하지 않습니다.)',
                  textAlign: TextAlign.center
                ),
              ),
              SizedBox(height: 50)
            ])
        ]
    );
  }

  Widget waitWidget() {
    return const CircularProgressIndicator(backgroundColor: Colors.blue);
  }

  Widget myListTile(Device device, String title) {
    return Card(
      child: ListTile(
          tileColor: Colors.white,
          title: Text(title,
              style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey)),
          leading: _getDeviceIcon(device),
          trailing: const Icon(Icons.chevron_right)
      )
    );
  }

  Widget _getDeviceIcon(Device device) {
    if (device.getDeviceType() == Constants.DEVICE_TYPE_HUB) {
      return const Icon(Icons.sensors);
    } else if (device.getDeviceType() == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
      return const Icon(Icons.device_thermostat);
    } else if (device.getDeviceType() == Constants.DEVICE_TYPE_SMOKE) {
      return const Icon(Icons.local_fire_department);
    } else if (device.getDeviceType() == Constants.DEVICE_TYPE_EMERGENCY) {
      return const Icon(Icons.medical_services);
    } else if (device.getDeviceType() == Constants.DEVICE_TYPE_ILLUMINANCE) {
      return const Icon(Icons.light);
    } else if (device.getDeviceType() == Constants.DEVICE_TYPE_MOTION) {
      return const Icon(Icons.directions_run);
    } else if (device.getDeviceType() == Constants.DEVICE_TYPE_DOOR) {
      return const Icon(Icons.meeting_room);
    } else {
      return const Icon(Icons.help);
    }
  }

  void _action(BuildContext context, WidgetRef ref) {
    if (_hubList.isEmpty) {
      _goAddHubPage(context, ref);
    } else {
      if (_hubList.length == 1) {
        _goAddSensePage(context, ref);
      } else {
        showActionDialog(context, ref);
      }
    }
  }

  void _goAddHubPage(BuildContext context, WidgetRef ref) {
    ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.none);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const AddHubPage1();
    }));
  }

  void _goParingPage(BuildContext context, WidgetRef ref) {
    if (_selectIndex == 0) {
      _goAddHubPage(context, ref);
    } else {
      _goAddSensePage(context, ref);
    }
  }

  void _goAddSensePage(BuildContext context, WidgetRef ref) {
    String? deviceID = _hubList[0].getHubID();
    print(deviceID);
    ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.none);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddSensorPage1(deviceID: deviceID!);
    }));
  }

  void showActionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return AlertDialog(
                  title: const Text("기기 선택"),
                  content: SizedBox(
                    width: 150,
                    height: 100,
                    child: ListView.builder(
                        itemCount: _actionList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return RadioListTile<int>(
                            value: index,
                            groupValue: _selectIndex,
                            title: Text(_actionList[index]),
                            onChanged: (value) {
                              setState((){
                                _selectIndex = value??0;
                              });
                            },
                          );
                        }),
                  ),
                  actions: [
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                          });
                        },
                        child: const Text("Cancel")
                    ),
                    ElevatedButton(
                        onPressed: () {
                          setState(() {
                            Navigator.pop(context);
                            _goParingPage(context, ref);
                          });
                        },
                        child: const Text("Ok")
                    ),
                  ],
                );
              });
        });
  }

}