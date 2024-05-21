import 'package:flutter/material.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/models/device.dart';
import 'package:argoscareseniorsafeguard/models/hub.dart';
import 'package:argoscareseniorsafeguard/models/sensor.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/pages/alarms_detail_view.dart';
import 'package:intl/intl.dart';

class AlarmsView extends StatefulWidget {
  const AlarmsView({super.key, required this.userID});

  final String userID;

  @override
  State<AlarmsView> createState() => _NotisViewState();
}

class _NotisViewState extends State<AlarmsView> {
  Future<List<Device>> _getDeviceList() async {
    DBHelper sd = DBHelper();

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
          updatedAt: "",
          createdAt: ""
      );
      deviceList.add(device);
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
          updatedAt: "",
          createdAt: ""
      );
      deviceList.add(device);
    }

    return deviceList;
  }

  Widget _getDeviceIcon(Device device) {
    if (device.getDeviceType() == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
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

  void _goDetailView(Device device) {
    var now = DateTime.now();
    var formatter = DateFormat('yyyy-MM-dd');
    String formattedDate = formatter.format(now);

    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return AlarmDetailView(userID: widget.userID, device: device, date: formattedDate);
    }));
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
        body: Column(
          children: [
            const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.fiber_manual_record, size: 10.0, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text("오늘", style: TextStyle(fontSize: 16.0),),
                    ]
                )
            ),
            Expanded(
              child: FutureBuilder<List<Device>>(
                future: _getDeviceList(),
                builder: (context, snapshot) {
                  final List<Device>? devices = snapshot.data;
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(
                      child: CircularProgressIndicator(),
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
                          child: CircularProgressIndicator(),
                        );
                      }
                      return ListView.builder(
                        itemCount: devices.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                            child: Card(
                              color: Colors.white,
                              surfaceTintColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                              child: InkWell(borderRadius: BorderRadius.circular(8.0),
                                onTap: () {
                                  _goDetailView(devices[index]);
                                },
                                child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8.0),
                                      color: Colors.transparent,
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                                      child: ListTile(
                                        title: Text(devices[index].getDeviceName()!,
                                        style: const TextStyle(
                                            fontSize: 20.0,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.grey)),
                                        leading: _getDeviceIcon(devices[index]),
                                        trailing: const Icon(Icons.chevron_right),//Row(
                                        //   mainAxisAlignment: MainAxisAlignment.end,
                                        //   mainAxisSize: MainAxisSize.min,
                                        //   children: [
                                        //     IconButton(
                                        //       icon: const Icon(Icons.chevron_right),
                                        //       onPressed: () {
                                        //         debugPrint("===========");
                                        //       },
                                        //     )
                                        //   ],
                                        // ),
                                      )
                                    )
                                ),
                              ),
                            ),
                          );
                        },
                      );

                    } else {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  } else {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                },
              ),
            )
          ],
        )
    );
  }
}
