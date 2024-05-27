import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/mqtt/mqtt.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:argoscareseniorsafeguard/models/location_infos.dart';

class AddSensorPage1 extends ConsumerStatefulWidget {
  const AddSensorPage1({super.key, required this.deviceID, this.location});

  final String deviceID;
  final LocationInfo? location;

  @override
  ConsumerState<AddSensorPage1> createState() => _AddSensorPage1State();
}

class _AddSensorPage1State extends ConsumerState<AddSensorPage1> {
  bool _isRunning = false;
  TextEditingController controller = TextEditingController();

  Timer? _timer;

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
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
    debugPrint('add_sensor_page1() $widget.deviceID');
    if (widget.location != null) {
      debugPrint(widget.location!.getName()!);
      controller.text = widget.location!.getName()!;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(findHubStateProvider, (previous, next) {
      logger.i('current state: ${ref.watch(findHubStateProvider)}');
    });
    return Stack(
      children: [
        Container(color: Theme.of(context).colorScheme.primary),
        Container(
          decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white10,
                  Colors.white10,
                  Colors.black12,
                  Colors.black12,
                  Colors.black12,
                  Colors.black12,
                ],
              )
          ),
        ),
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,
          body: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                  child: Padding(
                      padding: const EdgeInsets.all(outPadding),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close),
                                  color: Theme.of(context).colorScheme.onPrimary
                              )
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                style: Theme.of(context).textTheme.titleLarge!.copyWith(color: Theme.of(context).colorScheme.onPrimary, fontWeight: FontWeight.bold),
                                '센서 등록',
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                style: Theme.of(context).textTheme.titleMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                                '설치하실 센서를 등록해 주세요.',
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                                '장소 명',
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          TextField(
                            style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
                            controller: controller,
                            readOnly: widget.location != null,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6)
                              ),
                              isDense: false,
                              contentPadding: const EdgeInsets.all(8),
                              fillColor: Theme.of(context).colorScheme.onPrimary,
                              filled: true,
                              hintStyle: TextStyle(color: Theme.of(context).colorScheme.tertiary, fontSize: 14),
                              hintText: '장소 명을 입력해 주세요.',
                            ),
                          ),

                          const SizedBox(height: 20),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Text(
                                style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                                '검색된 센서',
                              ),
                            ],
                          ),

                          const SizedBox(height: 10,),

                          Container(
                              height: 50,
                              width: double.infinity,
                              color: Theme.of(context).colorScheme.primaryContainer,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "*(필수) 문열림센서 1개, 움직임센서 1개",
                                    style: Theme.of(context).textTheme.titleSmall!.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                                  ),
                                ],
                              )
                          ),

                          const SizedBox(height: 20,),

                          Container(
                              height: 150,
                              width: double.infinity,
                              color: Colors.transparent,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '센서의 Pairing 버튼을 길게 눌러 LED가 빠르게 점등할 수 있도록 해 주세요',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
                                  ),
                                  const SizedBox(height: 20),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                                        foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                                        elevation: 5, //
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                    ),
                                    child: Text('검색'),
                                    onPressed: () {
                                      print("-----");
                                    },
                                  ),
                                ],
                              )
                          ),
                        ],
                      )
                  )
              )
            )
          )
        )
      ],
    );
  }

  Widget processWidget(BuildContext context) {
    controller.text = widget.location!.getName()!;

    return Column(
      children: [
        widget1(context),
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

  Widget widget1(BuildContext context) {
    if (ref.watch(findHubStateProvider) == ConfigState.findingSensor) {
      _startTimer();
      return SpinKitRipple(
        color: Theme.of(context).colorScheme.onPrimary,
        size: 100,
      );

    } else if (ref.watch(findHubStateProvider) == ConfigState.findingSensorDone) {
      Navigator.pop(context);
      return Text(
          '센서의 Pairing이 완료되었습니다.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
      );

    } else if (ref.watch(findHubStateProvider) == ConfigState.findingSensorError) {
      return Text(
          '센서를 찾지 못했습니다. \n센서의 Pairing 버튼을 길게 눌러 LED가 빠르게 점등할 수 있도록 해 주세요',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
      );

    } else {
      return Text(
          '센서의 Pairing 버튼을 길게 눌러 LED가 빠르게 점등할 수 있도록 해 주세요',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
      );
    }
  }

  Widget widget2() {
    if (ref.watch(findHubStateProvider) == ConfigState.findingSensor) {
      return Text(
          "센서를 찾고 있습니다.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
      );

    } else if (ref.watch(findHubStateProvider) == ConfigState.findingSensorDone) {
      return Text(
          "센서를 찾았습니다.",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium!.copyWith(color: Theme.of(context).colorScheme.onPrimary),
      );

    } else {
      return ElevatedButton(
          style: ElevatedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              backgroundColor: Theme.of(context).colorScheme.primary, // text color
              elevation: 5, //
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
          ),
          onPressed: () {
            ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.findingSensor);
            // final topic = ref.watch(commandTopicProvider);
            mqttSendCommand(MqttCommand.mcParing, widget.deviceID);
          }, //findHub,
          child: const Text('검색')
      );
    }
  }
}
