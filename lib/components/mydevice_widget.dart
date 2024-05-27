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
import 'package:argoscareseniorsafeguard/models/location_infos.dart';
import 'package:argoscareseniorsafeguard/components/my_container.dart';

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
          shared: 0,
          ownerID: '',
          ownerName: '',
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
          shared: 0,
          ownerID: '',
          ownerName: '',
          updatedAt: sensor.getUpdatedAt(),
          createdAt: sensor.getCreatedAt()
      );
      deviceList.add(device);
    }

    return deviceList;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(outPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: outPadding,),

            _topCard(context, ref),

            const SizedBox(height: outPadding,),

            Expanded(
                child: GridView.builder(
                  padding: const EdgeInsets.all(0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: outPadding, crossAxisSpacing: outPadding),
                  itemCount: gLocationList.length + 1,
                  itemBuilder: (BuildContext context, int index) {
                    return MyContainer(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _getCards(context, ref, index),
                          ],
                        ));
                  },
                ))
            /*Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("기기 조회",
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold)
                  ),
                  ElevatedButton(onPressed: () { _action(context, ref); }, style: Constants.elevatedButtonStyle, child: const Text('기기 등록')),
                ]
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(0.0),
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
            ),*/
          ]
        )
      )
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
    /*if (_hubList.isEmpty) {
      _goAddHubPage(context, ref);
    } else {
      if (_hubList.length == 1) {
        _goAddSensePage(context, ref);
      } else {
        showActionDialog(context, ref);
      }
    }*/
  }

  void _goParingPage(BuildContext context, WidgetRef ref) {
    // if (_selectIndex == 0) {
    //   _goAddHubPage(context, ref);
    // } else {
    //   _goAddSensePage(context, ref);
    // }
  }

  void _goAddHubPage(BuildContext context, WidgetRef ref) {
    ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.none);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return const AddHubPage1();
    })).then((value) {
      setState(() {

      });
    });
    // _showFindHubModalSheet();
  }

  void _showFindHubModalSheet() {
    showModalBottomSheet<void>(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        isDismissible: false,
        enableDrag: false,
        builder: (BuildContext context) {
          return PopScope(
            canPop: false,
            onPopInvoked: (bool didPop) {
              if (didPop) {
                print('showModalBottomSheet(): canPop: true');
                return;
              } else {
                print('showModalBottomSheet(): canPop: false');
                return;
              }
            },
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.rectangle,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20.0),
                  topRight: Radius.circular(20.0),
                ),
                color: Theme.of(context).colorScheme.primaryContainer,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(outPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close),
                              color: Theme.of(context).colorScheme.primary
                          )
                        ],
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Pairing 버튼을 10초간 길게 누르세요\n'
                            '삐 소리가 연속적으로 5번 울립니다.\n'
                            'LED가 보라색으로 변합니다.\n'
                            '모두 준비되면 [허브 검색]을 탭하세요',
                        style: Theme.of(context).textTheme.labelLarge!.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.onPrimary,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            elevation: 5, //
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        child: const Text('허브 검색'),
                        onPressed: () => Navigator.pop(context),
                      )
                    ],
                  ),
                ),
              ),
            )
          );
        }
    );
  }

  void _goAddSensePage(BuildContext context, WidgetRef ref, LocationInfo? location) {
    String? deviceID = gHubList[0].getHubID();
    debugPrint(deviceID);

    ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.none);
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      if (location == null) {
        return AddSensorPage1(deviceID: deviceID!);
      } else {
        return AddSensorPage1(deviceID: deviceID!, location: location!);
      }

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

  Widget _getCards(BuildContext context, WidgetRef ref, int index) {
    String title = '';
    bool enable = false;

    if (index == gLocationList.length) {
      title = '장소 추가';
    } else {
      LocationInfo location = gLocationList[index];
      title = location.getName()!;
    }

    if (gHubList.isNotEmpty) {
      if (index != gLocationList.length) {
        LocationInfo location = gLocationList[index];
        if (location.getType()! == 'emergency') {
          enable = true;
        } else {
          if ((location.getRequireDoorSensorCount()! > location.getDetectedDoorSensorCount()!) || location.getRequireMotionSensorCount()! > location.getDetectedMotionSensorCount()!)  {
            enable = true;
          }
        }
      } else {
        enable = true; //장소 추가는 무조건 등록가능 하도록
      }
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer,),
        ),
        const SizedBox(height: outPadding),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: enable ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSecondaryContainer,//Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: enable ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondaryContainer, // text color
                    elevation: 5, //
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                ),
                onPressed: enable
                    ? () {
                      if (index != gLocationList.length) {
                        LocationInfo location = gLocationList[index];
                        _goAddSensePage(context, ref, gLocationList[index]);
                      } else {
                        _goAddSensePage(context, ref, null);
                      }

                    }
                    : null,
                child: const Text('등록')
            )
          ],
        )
      ],
    );
  }

  Widget _topCard(BuildContext context, WidgetRef ref) {
    String title = gHubList.isEmpty ? '허브가 등록되지 않았습니다.' : '허브';
    String buttonTitle = gHubList.isEmpty ? '허브 등록' : '등록됨';

    return MyContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 10,),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                  title,
                ),
              ],
            ),

            const SizedBox(height: outPadding),

            Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          foregroundColor: gHubList.isEmpty ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSecondaryContainer,
                          backgroundColor: gHubList.isEmpty ? Theme.of(context).colorScheme.primary : Theme.of(context).colorScheme.secondaryContainer, // text color
                          elevation: 5, //
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                      ),
                      onPressed: gHubList.isEmpty ?  () => _goAddHubPage(context, ref) : null,
                      child: Text(buttonTitle)
                  )

                ],
            ),

            const SizedBox(height: 10,),
          ],
        ),
    );
  }
}

/*

class _TopCard extends StatelessWidget {
  const _TopCard({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MyContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10,),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '허브가 등록되지 않았습니다.',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
              ),

            ],
          ),
          const SizedBox(height: outPadding),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.onPrimary,
                      backgroundColor: Theme.of(context).colorScheme.primary, // text color
                      elevation: 5, //
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  onPressed: (){
                    _goAddHubPage(context, ref);
                    */
/*Navigator.push(context,
                        MaterialPageRoute(builder: (context) {
                          return const AddHubPage2();
                        }));*//*

                  },//findHub,
                  child: const Text('허브 등록')
              )
            ],
          ),
          const SizedBox(height: 10,),
        ],
      ),
    );
  }
}

*/
