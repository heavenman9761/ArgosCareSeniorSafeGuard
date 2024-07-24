import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:argoscareseniorsafeguard/unused//device.dart';
import 'package:argoscareseniorsafeguard/models/sensor_event.dart';
import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:intl/intl.dart';

class AlarmDetailView extends StatefulWidget {
  const AlarmDetailView({super.key, required this.userID, required this.device, required this.date});

  final String userID;
  final Device device;
  final String date;

  @override
  State<AlarmDetailView> createState() => _AlarmDetailViewState();
}

class _AlarmDetailViewState extends State<AlarmDetailView> {
  Future<List<SensorEvent>> _getEventList() async {
    DBHelper sd = DBHelper();
    List<SensorEvent> sensorEventList = await sd.getSensorEventsByDeviceType(widget.userID, widget.device.getDeviceType()!, widget.date);

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

  Widget myListTile(SensorEvent event) {
    String description = analysisSensorEvent(event);

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
