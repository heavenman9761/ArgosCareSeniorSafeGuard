import 'package:flutter/material.dart';
import 'package:timeline_tile/timeline_tile.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:argoscareseniorsafeguard/database/db.dart';
import 'package:argoscareseniorsafeguard/models/event_list.dart';
import 'package:argoscareseniorsafeguard/constants.dart';

class AlarmsView extends StatefulWidget {
  const AlarmsView({super.key});

  @override
  State<AlarmsView> createState() => _AlarmsViewState();
}

class _AlarmsViewState extends State<AlarmsView> {
  String _dayOfWeek = '';
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    _selectedDate = DateTime.now();
    _dayOfWeek = DateFormat('E', 'ko_KR').format(_selectedDate);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    initializeDateFormatting(Localizations.localeOf(context).languageCode);
  }

  Widget _getDateText() {
    var now = DateTime.now();
    if (DateFormat('yyyy-MM-dd').format(_selectedDate) == DateFormat('yyyy-MM-dd').format(now)) {
      return Text('오늘 ($_dayOfWeek)', style: const TextStyle(fontSize: 16.0),);

    } else {
      String curr = DateFormat('yyyy-MM-dd').format(_selectedDate);
      return Text('$curr ($_dayOfWeek)', style: const TextStyle(fontSize: 16.0),);

    }
  }

  Future<List<EventList>> _getEventList() async {
    String date = DateFormat('yyyy-MM-dd').format(_selectedDate);
    DBHelper sd = DBHelper();

    const storage = FlutterSecureStorage(
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    );

    final userID = await storage.read(key:'ID');

    return await sd.getEventList(date, userID!);
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
            Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row (
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          const Icon(Icons.fiber_manual_record, size: 10.0, color: Colors.redAccent),
                          const SizedBox(width: 10),
                          _getDateText(),
                        ],
                      ),
                      Row (
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(onPressed: () => _selectDate(context), style: Constants.elevatedButtonStyle, child: const Text('날짜 선택')),
                        ],
                      )
                    ]
                )
            ),
            Expanded(
              child: FutureBuilder<List<EventList>>(
                future: _getEventList(),
                builder: (context, snapshot) {
                  final List<EventList>? events = snapshot.data;
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
                    if (events != null) {
                      if (events.isEmpty) {
                        return const Center(
                          child: Text("이벤트가 없습니다."),
                        );
                      }
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ListView.builder(
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            return Container(
                              color: Colors.white,
                              child: TimelineTile(
                                alignment: TimelineAlign.manual,
                                lineXY: 0.3,
                                isFirst: index == 0 ? true : false,
                                isLast: index == events.length - 1 ? true : false,
                                indicatorStyle: IndicatorStyle(
                                  width: 40,
                                  indicatorXY: 0.55,
                                  color: _getIconColor(events[index]),
                                  padding: const EdgeInsets.all(8),
                                  iconStyle: IconStyle(
                                    color: Colors.white,
                                    iconData: _getDeviceIcon(events[index])//Icons.medical_services,
                                  ),
                                ),
                                startChild: Container(
                                  constraints: const BoxConstraints(
                                    minHeight: 100,
                                  ),
                                  color: Colors.white,
                                  child: Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row (
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          _getTime(events[index])
                                        ],
                                      ),
                                    ),
                                  )
                                ),
                                endChild: Container (
                                  constraints: const BoxConstraints(
                                    minHeight: 100,
                                  ),
                                  color: Colors.white,
                                    child: Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: Row (
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          children: [
                                            _getDescription(events[index])
                                          ],
                                        ),
                                      ),
                                    )
                                ),
                              )
                            );
                          }
                        ),
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

  Widget _getTime(EventList eventList) {
    String time = eventList.getCreatedAt()!.split(' ')[1].split('.')[0];
    return Text(time);
  }

  Widget _getDescription(EventList eventList) {

    Map<String, String> data = _analysisStatus(eventList.getStatus()!);

    if (eventList.getDeviceType() == Constants.DEVICE_TYPE_EMERGENCY) {
      if (data['switch_detect'] == '1') {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text('${eventList.getName()}', style: const TextStyle(color: Colors.grey))]),
            const SizedBox(height: 10),
            const Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text('SOS 호출이 있었습니다.', style: TextStyle(fontSize: 20),)]),
          ]
        );
      } else {
        return const Text('');
      }

    } else if (eventList.getDeviceType() == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
      var celsius = int.parse(data['temp']!) / 10;

      NumberFormat format = NumberFormat("#0.0");
      String strCelsius = format.format(celsius);

      String msg = '현재 온도는 $strCelsius°, 습도는 ${data['hum']}% 입니다.';
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text('${eventList.getName()}', style: const TextStyle(color: Colors.grey))]),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text(msg, style: const TextStyle(fontSize: 20),)]),
          ]
      );

    } else if (eventList.getDeviceType() == Constants.DEVICE_TYPE_SMOKE) {
      if (data['fire'] == '1') {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text('${eventList.getName()}', style: const TextStyle(color: Colors.grey))]),
              const SizedBox(height: 10),
              const Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text("화재 센서가 작동하였습니다.", style: TextStyle(fontSize: 20),)]),
            ]
        );
      } else {
        return const Text('');
      }

    } else if (eventList.getDeviceType() == Constants.DEVICE_TYPE_ILLUMINANCE) {
      String msg = '현재 조도는 ${data['illuminance']} 입니다.';
      return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text('${eventList.getName()}', style: const TextStyle(color: Colors.grey))]),
            const SizedBox(height: 10),
            Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text(msg, style: const TextStyle(fontSize: 20),)]),
          ]
      );

    } else if (eventList.getDeviceType() == Constants.DEVICE_TYPE_MOTION) {
      if (data['motion'] == '1') {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text('${eventList.getName()}', style: const TextStyle(color: Colors.grey))]),
              const SizedBox(height: 10),
              const Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text('움직임이 감지되었습니다.', style: TextStyle(fontSize: 20),)]),
            ]
        );
      } else {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text('${eventList.getName()}', style: const TextStyle(color: Colors.grey))]),
              const SizedBox(height: 10),
              const Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text('움직임이 없습니다.', style: TextStyle(fontSize: 20),)]),
            ]
        );
      }
    } else if (eventList.getDeviceType() == Constants.DEVICE_TYPE_DOOR) {
      if (data['door'] == '1') {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text('${eventList.getName()}', style: const TextStyle(color: Colors.grey))]),
              const SizedBox(height: 10),
              const Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text('문이 열렸습니다.', style: TextStyle(fontSize: 20),)]),
            ]
        );
      } else {
        return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text('${eventList.getName()}', style: const TextStyle(color: Colors.grey))]),
              const SizedBox(height: 10),
              const Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text('문이 닫혔습니다.', style: TextStyle(fontSize: 20),)]),
            ]
        );
      }
    }

    return const Text('');
  }

  IconData _getDeviceIcon(EventList event) {
    if (event.getDeviceType() == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
      return Icons.device_thermostat;
    } else if (event.getDeviceType() == Constants.DEVICE_TYPE_SMOKE) {
      return Icons.local_fire_department;
    } else if (event.getDeviceType() == Constants.DEVICE_TYPE_EMERGENCY) {
      return Icons.medical_services;
    } else if (event.getDeviceType() == Constants.DEVICE_TYPE_ILLUMINANCE) {
      return Icons.light;
    } else if (event.getDeviceType() == Constants.DEVICE_TYPE_MOTION) {
      Map<String, String> data = _analysisStatus(event.getStatus()!);

      if (data['motion'] == '1') {
        return Icons.directions_run;
      } else  {
        return Icons.man;
      }

    } else if (event.getDeviceType() == Constants.DEVICE_TYPE_DOOR) {
      Map<String, String> data = _analysisStatus(event.getStatus()!);

      if (data['door'] == '1') {
        return Icons.meeting_room;
      } else  {
        return Icons.sensor_door;
      }

    } else {
      return Icons.help;
    }
  }

  Color _getIconColor(EventList event) {
    if (event.getDeviceType() == Constants.DEVICE_TYPE_TEMPERATURE_HUMIDITY) {
      return Colors.grey;
    } else if (event.getDeviceType() == Constants.DEVICE_TYPE_SMOKE) {
      return Colors.grey;
    } else if (event.getDeviceType() == Constants.DEVICE_TYPE_EMERGENCY) {
      return Colors.redAccent;
    } else if (event.getDeviceType() == Constants.DEVICE_TYPE_ILLUMINANCE) {
      return Colors.grey;
    } else if (event.getDeviceType() == Constants.DEVICE_TYPE_MOTION) {
      Map<String, String> data = _analysisStatus(event.getStatus()!);

      if (data['motion'] == '1') {
        return Colors.greenAccent;
      } else  {
        return Colors.redAccent;
      }

    } else if (event.getDeviceType() == Constants.DEVICE_TYPE_DOOR) {
      return Colors.grey;
    } else {
      return Colors.grey;
    }
  }

  Map<String, String> _analysisStatus(String statusMsg) {
    String status = removeJsonAndArray(statusMsg);

    var dataSp = status.split(',');
    Map<String, String> data = {};
    for (var element in dataSp) {
      data[element.split(':')[0].trim()] = element.split(':')[1].trim();
    }

    return data;
  }
}
