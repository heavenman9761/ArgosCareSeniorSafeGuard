import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/pages/add_sensor_page1.dart';
import 'package:argoscareseniorsafeguard/pages/add_hub_page1.dart';
import 'package:argoscareseniorsafeguard/pages/device_detail_view.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/models/device.dart';
import 'package:argoscareseniorsafeguard/models/hub.dart';
import 'package:argoscareseniorsafeguard/models/sensor.dart';

class MyDeviceWidget extends ConsumerStatefulWidget {
  const MyDeviceWidget({super.key, required this.userID});
  final String userID;

  @override
  ConsumerState<MyDeviceWidget> createState() => _MyDeviceWidgetState();
}

class _MyDeviceWidgetState extends ConsumerState<MyDeviceWidget> {
  bool _existHub = false;
  final List<String> _actionList = ['허브 등록', '센서 등록'];
  int _selectIndex = 0;
  final List<Hub> _hubList = [];

  Future<List<Device>> _getDeviceList() async {
    DBHelper sd = DBHelper();

    _hubList.clear();

    List<Hub> hubList = await sd.getHubs();
    List<Sensor> sensorList = await sd.getSensors(widget.userID);
    List<Device> deviceList = [];

    for (Hub hub in hubList) {
      Device device = Device(
          deviceID: hub.getHubID(),
          deviceType: hub.getDeviceType(),
          deviceName: hub.getName(),
          displaySunBun: hub.getDisplaySunBun(),
          userID: "",
          status: "",
          updatedAt: hub.getUpdatedAt(),
          createdAt: hub.getCreatedAt()
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
          userID: "",
          status: "",
          updatedAt: sensor.getUpdatedAt(),
          createdAt: sensor.getCreatedAt()
      );
      deviceList.add(device);
    }

    return deviceList;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        children: [
          Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("기기 조회", style: TextStyle(fontSize: 24.0),),
                    ElevatedButton(onPressed: () { _action(context, ref); }, style: Constants.elevatedButtonStyle, child: const Text('기기 등록')),
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
                              return myListTile(context, devices[index]);

                            } else if (devices[index].getDeviceType() == Constants.DEVICE_TYPE_ILLUMINANCE) {
                              return myListTile(context, devices[index]);

                            } else if (devices[index].getDeviceType() == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
                              return myListTile(context, devices[index]);

                            } else if (devices[index].getDeviceType() == Constants.DEVICE_TYPE_SMOKE) {
                              return myListTile(context, devices[index]);

                            } else if (devices[index].getDeviceType() == Constants.DEVICE_TYPE_EMERGENCY) {
                              return myListTile(context, devices[index]);

                            } else if (devices[index].getDeviceType() == Constants.DEVICE_TYPE_MOTION) {
                              return myListTile(context, devices[index]);

                            } else if (devices[index].getDeviceType() == Constants.DEVICE_TYPE_DOOR) {
                              return myListTile(context, devices[index]);

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
        ]
    );
  }

  Widget waitWidget() {
    return const CircularProgressIndicator(backgroundColor: Colors.blue);
  }

  Widget myListTile(BuildContext context, Device device) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            _getDeviceIcon(device),
            const SizedBox(width: 10, height: 40),
            Text(device.getDeviceName()!, style: TextStyle(fontSize: deviceFontSize,)),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  GestureDetector(
                    onTap: () { _goDeviceDetailView(context, device); },
                    child: const Icon(Icons.chevron_right, size: 20, color: Colors.black),
                  ),
                ],
              ),
            )
          ],
        )
      )
    );
  }

  void _goDeviceDetailView(BuildContext context, Device device) {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return DeviceDetailView(device: device, userID: widget.userID);
    })).then((value) {
      setState(() {

      });
    });
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

  void _goParingPage(BuildContext context, WidgetRef ref) {
    if (_selectIndex == 0) {
      _goAddHubPage(context, ref);
    } else {
      _goAddSensePage(context, ref);
    }
  }

  void _goAddHubPage(BuildContext context, WidgetRef ref) {
    ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.none);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const AddHubPage1();
    })).then((value) {
      setState(() {

      });
    });
  }

  void _goAddSensePage(BuildContext context, WidgetRef ref) {
    String? deviceID = _hubList[0].getHubID();
    print(deviceID);
    ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.none);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AddSensorPage1(deviceID: deviceID!);
    })).then((value) {
      setState(() {

      });
    });
  }

  void showActionDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      barrierDismissible: false,
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
          }
        );
      }
    );
  }
}
