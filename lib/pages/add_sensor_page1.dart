import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/mqtt/mqtt.dart';
import 'package:argoscareseniorsafeguard/constants.dart';

class AddSensorPage1 extends ConsumerStatefulWidget {
  const AddSensorPage1({super.key, required this.deviceID});

  final String deviceID;

  @override
  ConsumerState<AddSensorPage1> createState() => _AddSensorPage1State();
}

class _AddSensorPage1State extends ConsumerState<AddSensorPage1> {
  bool _isRunning = false;
  Timer? _timer;

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void deactivate() {
    _timer?.cancel();
    super.deactivate();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(findHubStateProvider, (previous, next) {
      logger.i('current state: ${ref.watch(findHubStateProvider)}');
    });
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
                processWidget()
              ],
            )
          )
        ),
    );
  }
  Widget processWidget() {
    return Column(
      children: [
        widget1(),
        const SizedBox(height: 20,),
        widget2()
      ],
    );
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.findingSensorError);
    });
  }

  void _stopTimer() {
    _isRunning = false;
    _timer?.cancel();
  }

  Widget widget1() {
    if (ref.watch(findHubStateProvider) == ConfigState.findingSensor) {
      _startTimer();
      return const CircularProgressIndicator();

    } else if (ref.watch(findHubStateProvider) == ConfigState.findingSensorDone) {
      Navigator.pop(context);
      return const Text('센서의 Pairing이 완료되었습니다.', textAlign: TextAlign.center);

    } else if (ref.watch(findHubStateProvider) == ConfigState.findingSensorError) {
      return const Text(
          '센서를 찾지 못했습니다. \n센서의 Pairing 버튼을 길게 눌러 LED가 빠르게 점등할 수 있도록 해 주세요',
          textAlign: TextAlign.center
      );

    } else {
      return const Text('센서의 Pairing 버튼을 길게 눌러 LED가 빠르게 점등할 수 있도록 해 주세요', textAlign: TextAlign.center);
    }
  }

  Widget widget2() {
    if (ref.watch(findHubStateProvider) == ConfigState.findingSensor) {
      return const Text("센서를 찾고 있습니다.", textAlign: TextAlign.center);

    } else if (ref.watch(findHubStateProvider) == ConfigState.findingSensorDone) {
      return const Text("센서를 찾았습니다.", textAlign: TextAlign.center);

    } else {
      return ElevatedButton(
          style: ElevatedButton.styleFrom(
              foregroundColor: Colors.white60,
              backgroundColor: Colors.lightBlue, // text color
              elevation: 5, //
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          ),
          onPressed: () {
            ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.findingSensor);
            final topic = ref.watch(commandTopicProvider);
            mqttSendCommand(topic, MqttCommand.mcParing, widget.deviceID);
          }, //findHub,
          child: const Text('검색')
      );
    }
  }
}
