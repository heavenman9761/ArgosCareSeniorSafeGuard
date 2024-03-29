import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:argoscareseniorsafeguard/models/device.dart';
import 'package:argoscareseniorsafeguard/models/sensor_event.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:intl/intl.dart';

class AlarmDetailView extends StatefulWidget {
  const AlarmDetailView({super.key, required this.device, required this.date});

  final Device device;
  final String date;

  @override
  State<AlarmDetailView> createState() => _AlarmDetailViewState();
}

class _AlarmDetailViewState extends State<AlarmDetailView> {
  Future<List<SensorEvent>> _getEventList() async {
    DBHelper sd = DBHelper();
    List<SensorEvent> sensorEventList = await sd.getSensorEventsByDeviceType(widget.device.getDeviceType()!, widget.date);

    return sensorEventList;
  }

  @override
  void initState() {
    super.initState();
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
        body: Column(
          children: [
            const Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.fiber_manual_record, size: 10.0, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text("현황", style: TextStyle(fontSize: 16.0),),
                    ]
                )
            ),
            Expanded(
              child: FutureBuilder<List<SensorEvent>>(
                future: _getEventList(),
                builder: (context, snapshot) {
                  final List<SensorEvent>? Events = snapshot.data;
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
                    if (Events != null) {
                      if (Events.isEmpty) {
                        return const Center(
                          child: Text("이벤트가 없습니다.", textAlign: TextAlign.center),
                        );
                      }
                      return ListView.builder(
                        itemCount: Events.length,
                        itemBuilder: (context, index) {
                          return myListTile(Events[index]);
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

  String removeJsonAndArray(String text) {
    if (text.startsWith('[') || text.startsWith('{')) {
      text = text.substring(1, text.length - 1);
      if (text.startsWith('[') || text.startsWith('{')) {
        text = removeJsonAndArray(text);
      }
    }
    return text;
  }

  Widget myListTile(SensorEvent event) {
    String? stringJson = event.getStatus();
    stringJson = removeJsonAndArray(stringJson!);
    var dataSp = stringJson.split(',');

    Map<String, String> mapData = {};
    for (var element in dataSp) {
      mapData[element.split(':')[0].trim()] = element.split(':')[1].trim();
    }
    String time = event.getCreatedAt()!.split('.')[0];

    String description = '';
    if (event.getDeviceType() == Constants.DEVICE_TYPE_EMERGENCY) {
      description = '$time에 SOS 호출이 있었습니다.';

    } else if (event.getDeviceType() == Constants.DEVICE_TYPE_SMOKE) {
      if (mapData['fire'] == '1') {
        description = '$time에 화재 감지 신호가 있었습니다.';
      }

    } else if (event.getDeviceType() == Constants.DEVICE_TYPE_DOOR) {
      if (mapData['door'] == '1') {
        description = '$time에 문이 열렸습니다.';
      } else {
        description = '$time부터 문이 닫혔습니다.';
      }

    } else if (event.getDeviceType() == Constants.DEVICE_TYPE_MOTION) {
      if (mapData['motion'] == '1') {
        description = '$time에 움직임이 감지되었습니다.';
      } else {
        description = '$time부터 움직임이 감지되지 않습니다.';
      }

    } else if (event.getDeviceType() == Constants.DEVICE_TYPE_ILLUMINANCE) {
      description = "$time 조도: ${mapData['illuminance']}";

    } else if (event.getDeviceType() == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
      var fahrenheit = int.parse(mapData['temp']!);
      var celsius  = (fahrenheit - 32) * 5 / 9;

      NumberFormat format = NumberFormat("#0.0");
      String strCelsius = format.format(celsius);

      description = "$time 습도: ${mapData['hum']}%, 온도: $strCelsius";

    }

    return Card(
        child: ListTile(
            tileColor: Colors.white,
            title: Text(description,
                style: const TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.grey)),
            // trailing: const Icon(Icons.chevron_right)
        )
    );
  }
}
