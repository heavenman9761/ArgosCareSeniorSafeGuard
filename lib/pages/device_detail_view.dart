import "package:flutter/material.dart";
import "package:argoscareseniorsafeguard/models/device.dart";
import "package:argoscareseniorsafeguard/models/hub.dart";
import "package:argoscareseniorsafeguard/models/sensor.dart";
import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/constants.dart';

class DeviceDetailView extends StatefulWidget {
  const DeviceDetailView({super.key, required this.device});

  final Device device;

  @override
  State<DeviceDetailView> createState() => _DeviceDetailViewState();
}

class _DeviceDetailViewState extends State<DeviceDetailView> {
  late String? _deviceName;

  @override
  void initState() {
    super.initState();
    _deviceName = widget.device.getDeviceName();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Argos Care'),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                mainAxisSize : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize : MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("디바이스 이름")
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize : MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(_deviceName!),
                              IconButton(onPressed: (){ _inputDeviceNameDialog(context); }, icon: const Icon(Icons.edit), iconSize: 20,)
                            ],
                          ),
                        ),
                      ),
                    )
                  )
                ],
              ),
              Row(
                mainAxisSize : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize : MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("디바이스 ID")
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize : MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(widget.device.getDeviceID()!)
                              ],
                            ),
                          ),
                        ),
                      )
                  )

                ],
              ),
              Row(
                mainAxisSize : MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisSize : MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text("등록일")
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Flexible(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisSize : MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Text(widget.device.getCreateAt()!)
                              ],
                            ),
                          ),
                        ),
                      )
                  )

                ],
              ),
            ]
          ),
        )
    );
  }

  void _inputDeviceNameDialog(BuildContext context) {
    final controller = TextEditingController(text: "");

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("장치 명 입력"),
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
        setState(() {
          _editDevice(val);
        });
      }
    });
  }

  void _editDevice(String newName) async {
    DBHelper sd = DBHelper();

    if (widget.device.getDeviceType() == Constants.DEVICE_TYPE_HUB) {
      List<Hub> hubList = await sd.findHub(widget.device.getDeviceID()!);
      if (hubList.isNotEmpty) {
        Hub hub = Hub(
          id: hubList[0].getID(),
          hubID: hubList[0].getHubID(),
          name: newName,
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
      List<Sensor> sensorList = await sd.findSensor(widget.device.getDeviceID()!);
      if (sensorList.isNotEmpty) {
        Sensor sensor = Sensor(
          id: sensorList[0].getID(),
          sensorID: sensorList[0].getSensorID(),
          name: newName,
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
}
