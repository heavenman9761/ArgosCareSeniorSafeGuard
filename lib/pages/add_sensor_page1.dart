import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/mqtt/mqtt.dart';

class AddSensorPage1 extends ConsumerStatefulWidget {
  const AddSensorPage1({super.key, required this.deviceID});

  final String deviceID;

  @override
  ConsumerState<AddSensorPage1> createState() => _AddSensorPage1State();
}

class _AddSensorPage1State extends ConsumerState<AddSensorPage1> {
  bool _finding = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('센서 추가'),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                descriptWidget(),
                const SizedBox(height: 20,),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white60,
                      backgroundColor: Colors.lightBlue, // text color
                      elevation: 5, //
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                  ),
                  onPressed: (){
                    if (!_finding) {
                      _finding = true;
                      final topic = ref.watch(commandTopicProvider);
                      mqttSendCommand(topic, MqttCommand.mcParing, widget.deviceID);
                    } else {
                      Navigator.pop(context);
                    }
                  },//findHub,
                  child: !_finding ? const Text('검색') : const Text('검색 취소')
                )
              ],
            )
          )
        ),
    );
  }

  Widget descriptWidget() {
    if (_finding) {
      return const CircularProgressIndicator();
    } else {
      return const Text('센서의 Pairing 버튼을 길게 눌러 파란색 LED가 빠르게 점등할 수 있도록 해 주세요');
    }
  }
}
