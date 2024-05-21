import "package:argoscareseniorsafeguard/mqtt/mqtt.dart";
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

import "package:argoscareseniorsafeguard/models/device.dart";
import "package:argoscareseniorsafeguard/models/hub.dart";
import "package:argoscareseniorsafeguard/models/sensor.dart";
import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/models/sensor_event.dart';
import 'package:argoscareseniorsafeguard/components/humi_temp_chart.dart';

class DeviceDetailView extends StatefulWidget {
  const DeviceDetailView({super.key, required this.device, required this.userID});

  final String userID;
  final Device device;

  @override
  State<DeviceDetailView> createState() => _DeviceDetailViewState();
}

class _DeviceDetailViewState extends State<DeviceDetailView> {
  late String? _deviceName;
  String _dayOfWeek = '';
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _deviceName = widget.device.getDeviceName();
    _selectedDate = DateTime.now();
    _dayOfWeek = DateFormat('E', 'ko_KR').format(_selectedDate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeDateFormatting(Localizations.localeOf(context).languageCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text(Constants.APP_TITLE),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.fiber_manual_record, size: 10.0, color: Colors.redAccent),
                          const SizedBox(width: 10),
                          Text("일반", style: TextStyle(fontSize: deviceFontSize - 2),),
                        ]
                    )
                ),
                Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text('디바이스 이름', style: TextStyle(fontSize: deviceFontSize),),
                        Flexible(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(width: 5, height: deviceCardHeight),
                              Flexible(
                                flex: 1,
                                fit: FlexFit.tight,
                                child: Text(_deviceName!, style: TextStyle(fontSize: deviceFontSize - 2), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: (){ _inputDeviceNameDialog(context, _deviceName!); },
                                child: const Icon(Icons.edit, size: 20, color: Colors.black),
                              )
                            ],
                          ),
                        )
                      ]
                    ),
                  ),
                ),
                Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('디바이스 ID', style: TextStyle(fontSize: deviceFontSize),),
                          Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(height: deviceCardHeight),
                                  Text(widget.device.getDeviceID()!, style: TextStyle(fontSize: deviceFontSize - 2),),
                                  const SizedBox(width: 10),
                                  GestureDetector(
                                    onTap: (){ _copyDeviceID(widget.device.getDeviceID()!); },
                                    child: const Icon(Icons.copy, size: 20, color: Colors.black),
                                  )
                                ],
                              )
                          )
                        ]
                    ),
                  ),
                ),
                Card(
                  color: Colors.white,
                  surfaceTintColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Text('등록일', style: TextStyle(fontSize: deviceFontSize),),
                          Flexible(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  SizedBox(height: deviceCardHeight),
                                  Text(widget.device.getCreateAt()!.split('.')[0], style: TextStyle(fontSize: deviceFontSize - 2),),
                                ],
                              )
                          )
                        ]
                    ),
                  ),
                ),
                _initDevice(context),
                _restartHub(),
                _selectDivider(),
                SizedBox(
                  height: 500,
                  child: _selectList()
                )
              ]
            ),
          ),

        )
    );
  }

  Future<List<Sensor>> _getSensorList() async {
    DBHelper sd = DBHelper();

    List<Sensor> sensorList = await sd.getSensors(widget.userID);

    return sensorList;
  }

  Widget waitWidget() {
    return const CircularProgressIndicator(backgroundColor: Colors.blue);
  }

  Widget _selectList() {
    if (widget.device.getDeviceType() == Constants.DEVICE_TYPE_HUB) {
      return _sensorList();
    } else if (widget.device.getDeviceType() == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
      return _humiTempWidget();
    } else {
      return _eventList();
    }
  }

  Widget _humiTempWidget() {
    return HumiTempChart();
  }

  Widget _eventCard(SensorEvent event) {
    String description = analysisSimpleSensorEvent(event);

    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Row(
                  children: [
                    Text('발생시간:', style: TextStyle(fontSize: deviceFontSize),),
                    SizedBox(width: 10, height: deviceCardHeight,),
                    Text(event.getCreatedAt()!.split(' ')[1].split('.')[0].substring(0, 5), style: TextStyle(fontSize: deviceFontSize - 2),),
                  ],
                )
              ),
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Text(description, style: TextStyle(fontSize: deviceFontSize - 2), overflow: TextOverflow.ellipsis, textAlign: TextAlign.right,),
              ),
            ]
        ),
      ),
    );
  }

  Widget _eventList() {
    return FutureBuilder<List<SensorEvent>>(
      future: _getEventList(),
      builder: (context, snapshot) {
        final List<SensorEvent>? Events = snapshot.data;
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
          if (Events != null) {
            if (Events.isEmpty) {
              return const Center(
                child: Text("이벤트가 없습니다.", textAlign: TextAlign.center),
              );
            }
            return ListView.builder(
              itemCount: Events.length,
              itemBuilder: (context, index) {
                return _eventCard(Events[index]);
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
    );
  }

  Future<List<SensorEvent>> _getEventList() async {
    DBHelper sd = DBHelper();

    String date = DateFormat('yyyy-MM-dd').format(_selectedDate);
    List<SensorEvent> sensorEventList = await sd.getSensorEventsByDeviceType(widget.userID, widget.device.getDeviceType()!, date);

    return sensorEventList;
  }

  Widget _sensorList() {
    return FutureBuilder<List<Sensor>>(
      future: _getSensorList(),
      builder: (context, snapshot) {
        final List<Sensor>? sensors = snapshot.data;
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
          if (sensors != null) {
            if (sensors.isEmpty) {
              return const Center(
                child: Text("등록된 센서가 없습니다.\n내 기기 탭에서 센서를 등록하세요.", textAlign: TextAlign.center),
              );
            } else {
              return ListView.builder(
                itemCount: sensors.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  return sensorCard(sensors[index]);
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
    );
  }

  Widget _selectDivider() {
    if (widget.device.getDeviceType() == Constants.DEVICE_TYPE_HUB) {
      return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.fiber_manual_record, size: 10.0, color: Colors.redAccent),
                const SizedBox(width: 10),
                Text("연결된 센서", style: TextStyle(fontSize: deviceFontSize - 2),),
              ]
          )
      );
    } else {
      var now = DateTime.now();
      String title = '';
      if (DateFormat('yy-MM-dd').format(_selectedDate) == DateFormat('yy-MM-dd').format(now)) {
        title = '이벤트: 오늘 ($_dayOfWeek)';

      } else {
        String curr = DateFormat('yy-MM-dd').format(_selectedDate);
        title = '이벤트: $curr ($_dayOfWeek)';

      }
      return Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const Icon(Icons.fiber_manual_record, size: 10.0, color: Colors.redAccent),
                const SizedBox(width: 10),
                Text(title, style: TextStyle(fontSize: deviceFontSize - 2),),
                Flexible(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        ElevatedButton(onPressed: () => _selectDate(context), style: Constants.elevatedButtonStyle, child: const Text('날짜 선택')),
                      ],
                    )
                )
              ]
          )
      );
    }
  }

  Future _selectDate(BuildContext context) async {
    final DateTime? selected = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (selected != null) {
      setState(() {
        _selectedDate = selected;
        _dayOfWeek = DateFormat('E', 'ko_KR').format(_selectedDate);
      });
    }
  }

  Widget sensorCard(Sensor sensor) {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Flexible(
                flex: 1,
                fit: FlexFit.tight,
                child: Text(sensor.getName()!, style: TextStyle(fontSize: deviceFontSize), overflow: TextOverflow.clip),
              ),
              Flexible(
                flex: 2,
                fit: FlexFit.tight,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    SizedBox(height: deviceCardHeight),
                    Text(sensor.getSensorID()!, style: TextStyle(fontSize: deviceFontSize - 2)),
                    const SizedBox(width: 10,),
                      GestureDetector(
                        onTap: (){ _copyDeviceID(sensor.getSensorID()!); },
                        child: const Icon(Icons.copy, size: 20, color: Colors.black),
                      )
                  ],
                )
              )
                  ]
        ),
      ),
    );

  }

  Widget _getSensorIcon(Sensor sensor) {
    if (sensor.getDeviceType() == Constants.DEVICE_TYPE_HUB) {
      return const Icon(Icons.sensors);
    } else if (sensor.getDeviceType() == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
      return const Icon(Icons.device_thermostat);
    } else if (sensor.getDeviceType() == Constants.DEVICE_TYPE_SMOKE) {
      return const Icon(Icons.local_fire_department);
    } else if (sensor.getDeviceType() == Constants.DEVICE_TYPE_EMERGENCY) {
      return const Icon(Icons.medical_services);
    } else if (sensor.getDeviceType() == Constants.DEVICE_TYPE_ILLUMINANCE) {
      return const Icon(Icons.light);
    } else if (sensor.getDeviceType() == Constants.DEVICE_TYPE_MOTION) {
      return const Icon(Icons.directions_run);
    } else if (sensor.getDeviceType() == Constants.DEVICE_TYPE_DOOR) {
      return const Icon(Icons.meeting_room);
    } else {
      return const Icon(Icons.help);
    }
  }

  void _copyDeviceID(String deviceID) {
    Clipboard.setData(ClipboardData(text: deviceID));
  }

  Widget _initDevice(BuildContext context) {
    if (widget.device.getDeviceType() == Constants.DEVICE_TYPE_HUB) {
      return Card(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('초기화', style: TextStyle(fontSize: deviceFontSize),),
                Flexible(
                    child: Row(
                      // mainAxisSize : MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 100,
                          height: deviceCardHeight,
                          child: ElevatedButton(
                              onPressed: () { _confirmHubInit(context); },
                              style: Constants.elevatedButtonStyle,
                              child: const Text('초기화')
                          ),
                        )

                      ],
                    )
                )
              ]
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _restartHub() {
    if (widget.device.getDeviceType() == Constants.DEVICE_TYPE_HUB) {
      return Card(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text('재시작', style: TextStyle(fontSize: deviceFontSize),),
                Flexible(
                    child: Row(
                      // mainAxisSize : MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          width: 100,
                          height: deviceCardHeight,
                          child: ElevatedButton(
                              onPressed: () { _confirmHubRestart(context); },
                              style: Constants.elevatedButtonStyle,
                              child: const Text('재시작')
                          ),
                        )
                      ],
                    )
                )
              ]
          ),
        ),
      );
    } else {
      return const SizedBox();
    }
  }

  void _inputDeviceNameDialog(BuildContext context, String deviceName) {
    final controller = TextEditingController(text: deviceName);
    controller.selection = TextSelection(
      baseOffset: 0,
      extentOffset: deviceName.length,
    );
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("장치 명 입력"),
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
        setState(() {
          _editDevice(val);
        });
      }
    });
  }

  void _editDevice(String newName) async {
    DBHelper sd = DBHelper();

    if (widget.device.getDeviceType() == Constants.DEVICE_TYPE_HUB) {
      List<Hub> hubList = await sd.findHub(widget.userID, widget.device.getDeviceID()!);
      if (hubList.isNotEmpty) {
        Hub hub = Hub(
          id: hubList[0].getID(),
          hubID: hubList[0].getHubID(),
          name: newName,
          userID: hubList[0].getUserID(),
          displaySunBun: hubList[0].getDisplaySunBun(),
          category: hubList[0].getCategory(),
          deviceType: hubList[0].getDeviceType(),
          hasSubDevices: hubList[0].getHasSubDevices(),
          modelName: hubList[0].getModelName(),
          online: hubList[0].getOnLine(),
          status: hubList[0].getStatus(),
          battery: hubList[0].getBattery(),
          isUse: hubList[0].getIsUse(),
          createdAt: hubList[0].getCreatedAt(),
          updatedAt: DateTime.now().toString(),
        );
        await sd.updateHub(hub);

        setState(() {
          _deviceName = newName;
        });
      }

    } else {
      List<Sensor> sensorList = await sd.findSensor(widget.userID, widget.device.getDeviceID()!);
      if (sensorList.isNotEmpty) {
        Sensor sensor = Sensor(
          id: sensorList[0].getID(),
          sensorID: sensorList[0].getSensorID(),
          name: newName,
          userID: sensorList[0].getUserID(),
          displaySunBun: sensorList[0].getDisplaySunBun(),
          category: sensorList[0].getCategory(),
          deviceType: sensorList[0].getDeviceType(),
          modelName: sensorList[0].getModelName(),
          online: sensorList[0].getOnline(),
          status: sensorList[0].getStatus(),
          battery: sensorList[0].getBattery(),
          isUse: sensorList[0].getIsUse(),
          createdAt: sensorList[0].getCreatedAt(),
          updatedAt: DateTime.now().toString(),
          hubID: sensorList[0].getHubID(),
        );

        await sd.updateSensor(sensor);

        setState(() {
          _deviceName = newName;
        });
      }
    }
  }

  void _confirmHubInit(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("허브 초기화"),
              content: const Text("허브를 초기화 하시겠습니까?\n초기화를 진행하면 센서를 다시 연결해야 합니다."),
              actions: <Widget>[
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
              ],
            );
          },
        );
      },
    ).then((val) {
      if (val == true) {
        mqttSendCommand(MqttCommand.mcInitHub, widget.device.getDeviceID()!);
      }
    });
  }

  void _confirmHubRestart(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("허브 초기화"),
              content: const Text("허브를 재시작 하시겠습니까?"),
              actions: <Widget>[
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
              ],
            );
          },
        );
      },
    ).then((val) {
      if (val == true) {
        mqttSendCommand(MqttCommand.mcRestartHub, widget.device.getDeviceID()!);
      }
    });
  }
}
