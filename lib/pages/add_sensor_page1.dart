import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/mqtt/mqtt.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:argoscareseniorsafeguard/models/location_infos.dart';

class AddSensorPage1 extends ConsumerStatefulWidget {
  const AddSensorPage1({super.key, required this.deviceID, required this.userID});

  final String deviceID;
  final String userID;

  @override
  ConsumerState<AddSensorPage1> createState() => _AddSensorPage1State();
}

class _AddSensorPage1State extends ConsumerState<AddSensorPage1> {
  bool _isRunning = false;
  TextEditingController controller = TextEditingController();

  String _locationName = '';
  final _formKey = GlobalKey<FormState>();
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
    if (_locationName == '') {
      _locationName = ref.watch(currentLocationProvider)!.getName()!;
      controller.text = _locationName;
    }
  }

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    ref.listen(findHubStateProvider, (previous, next) {
      logger.i('current state: ${ref.watch(findHubStateProvider)}');
      if (ref.watch(findHubStateProvider) == ConfigState.findingSensor) {
        _showFindSensorModalSheet();

      } else if (ref.watch(findHubStateProvider) == ConfigState.findingSensorDone) {
        _stopTimer();
        Navigator.pop(context);

      } else if (ref.watch(findHubStateProvider) == ConfigState.findingSensorError) {
        Navigator.pop(context);

      }
    });

    return Stack(
      children: [
        Container(color: Theme
            .of(context)
            .colorScheme
            .primary),
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
                      minWidth: MediaQuery
                          .of(context)
                          .size
                          .width,
                      minHeight: MediaQuery
                          .of(context)
                          .size
                          .height,
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
                                        color: Theme
                                            .of(context)
                                            .colorScheme
                                            .onPrimary
                                    )
                                  ],
                                ),

                                const SizedBox(height: 20),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .titleLarge!
                                          .copyWith(color: Theme
                                          .of(context)
                                          .colorScheme
                                          .onPrimary, fontWeight: FontWeight.bold),
                                      '센서 등록',
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .titleMedium!
                                          .copyWith(color: Theme
                                          .of(context)
                                          .colorScheme
                                          .onPrimary),
                                      '설치하실 센서를 등록해 주세요.',
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 20),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(color: Theme
                                          .of(context)
                                          .colorScheme
                                          .onPrimary),
                                      '장소 명',
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Form(
                                  key: _formKey,
                                  child: TextFormField(
                                    style: TextStyle(color: Theme
                                        .of(context)
                                        .colorScheme
                                        .primary, fontSize: 16),
                                    controller: controller,
                                    key: const ValueKey(1),
                                    readOnly: ref.watch(currentLocationProvider)!.getType()! == 'customer' ? false : true,//widget.location != null,
                                    onSaved: (val) {
                                      setState(() {
                                        _locationName = val!;
                                      });
                                    },
                                    // onChanged: (val) {
                                    //   setState(() {
                                    //     String newName = val;
                                    //     print(newName);
                                    //     print(controller.text);
                                    //     // ref.watch(currentLocationProvider)!.setName(controller.text);
                                    //   });
                                    // },
                                    decoration: InputDecoration(
                                      border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(6)
                                      ),
                                      isDense: false,
                                      contentPadding: const EdgeInsets.all(8),
                                      fillColor: Theme
                                          .of(context)
                                          .colorScheme
                                          .onPrimary,
                                      filled: true,
                                      hintStyle: TextStyle(color: Theme
                                          .of(context)
                                          .colorScheme
                                          .tertiary, fontSize: 14),
                                      hintText: '장소 명을 입력해 주세요.',
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      style: Theme
                                          .of(context)
                                          .textTheme
                                          .titleSmall!
                                          .copyWith(color: Theme
                                          .of(context)
                                          .colorScheme
                                          .onPrimary),
                                      '검색된 센서',
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10,),

                                _showGuideWidget(),

                                Container(
                                    height: 100,
                                    width: double.infinity,
                                    color: Theme
                                        .of(context)
                                        .colorScheme
                                        .primaryContainer,
                                    child: Column(
                                      children: [
                                        ListView.builder(
                                          shrinkWrap: true,
                                          scrollDirection: Axis.vertical,
                                          padding: const EdgeInsets.all(8),
                                          //itemCount: ref.watch(SensorList.provider).length,
                                            itemCount: ref.watch(currentLocationProvider)!.getSensors()!.length,//widget.location!.sensors!.length,
                                          itemBuilder: (BuildContext context, int index) {
                                            return Container(
                                              height: 20,
                                              color: Theme.of(context).colorScheme.primaryContainer,
                                              //child: Text(ref.watch(SensorList.provider)[index].getName()!)
                                              child: _getSensorName(index)
                                            );
                                          }
                                        ),
                                      ],
                                    )
                                ),

                                const SizedBox(height: 20,),

                                Text(
                                  '센서의 Pairing 버튼을 길게 눌러 LED가 빠르게 점등할 수 있도록 해 주세요',
                                  textAlign: TextAlign.center,
                                  style: Theme
                                      .of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(color: Theme
                                      .of(context)
                                      .colorScheme
                                      .onPrimary),
                                ),

                                const SizedBox(height: 20,),

                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Theme
                                          .of(context)
                                          .colorScheme
                                          .secondaryContainer,
                                      foregroundColor: Theme
                                          .of(context)
                                          .colorScheme
                                          .onSecondaryContainer,
                                      elevation: 5, //
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                                  ),
                                  child: const Text('검색'),
                                  onPressed: () {
                                    // if (gCurrentLocation.getType() == 'entrance' || gCurrentLocation.getType() == 'refrigerator' || gCurrentLocation.getType() == 'toilet') {
                                    //   print("${gCurrentLocation.getRequireDoorSensorCount()!} ${gCurrentLocation.getDetectedDoorSensorCount()!} ${gCurrentLocation.getRequireMotionSensorCount()!} ${gCurrentLocation.getDetectedMotionSensorCount()!}");
                                    //   if ((gCurrentLocation.getRequireDoorSensorCount()! > gCurrentLocation.getDetectedDoorSensorCount()!) ||
                                    //       gCurrentLocation.getRequireMotionSensorCount()! > gCurrentLocation.getDetectedMotionSensorCount()!) {
                                    //     _startPairing(context, ref);
                                    //   }
                                    // } else {
                                    //   _startPairing(context, ref);
                                    // }
                                    if (ref.watch(currentLocationProvider)!.getType()! != 'emergency' && ref.watch(currentLocationProvider)!.getType()! != 'customer') {
                                      if (ref.watch(currentLocationProvider)!.getRequireDoorSensorCount()! > ref.watch(currentLocationProvider)!.getDetectedDoorSensorCount()! ||
                                          ref.watch(currentLocationProvider)!.getRequireDoorSensorCount()! > ref.watch(currentLocationProvider)!.getDetectedDoorSensorCount()!) {
                                        _startPairing(context, ref);
                                      }
                                    } else {
                                      _startPairing(context, ref);
                                    }

                                  },
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

  Widget _showGuideWidget() {
    if (ref.watch(currentLocationProvider)!.getType()! == 'emergency') {
      return Column(
        children: [
          Container(
              height: 50,
              width: double.infinity,
              color: Theme
                  .of(context)
                  .colorScheme
                  .primaryContainer,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "*(필수) SOS 버튼 1개 이상",
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: Theme
                        .of(context)
                        .colorScheme
                        .onPrimaryContainer),
                  ),
                ],
              )
          ),

          const SizedBox(height: 20,),
        ],
      );
    } else if (ref.watch(currentLocationProvider)!.getType()! == 'customer') {
      return const SizedBox();

    } else {
      return Column(
        children: [
          Container(
              height: 50,
              width: double.infinity,
              color: Theme
                  .of(context)
                  .colorScheme
                  .primaryContainer,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "*(필수) 문열림센서 ${ref.watch(currentLocationProvider)!.getRequireDoorSensorCount()}개, 움직임센서 ${ref.watch(currentLocationProvider)!.getRequireMotionSensorCount()}개",
                    style: Theme
                        .of(context)
                        .textTheme
                        .titleSmall!
                        .copyWith(color: Theme
                        .of(context)
                        .colorScheme
                        .onPrimaryContainer),
                  ),
                ],
              )
          ),

          const SizedBox(height: 20,),
        ],
      );
    }

  }

  Widget _getSensorName(int index) {
    //return Text(widget.location!.getSensors()![index].getName()!);
    return Text(ref.watch(currentLocationProvider)!.getSensors()![index].getName()!);
  }

  void _startPairing(BuildContext context, WidgetRef ref) async {
    if (controller.text == "장소 추가" || controller.text == '') {
      _failureDialog(context, "장소명 입력", "장소명을 먼저 입력해 주세요.");
    } else {
      if (ref.watch(currentLocationProvider)!.getType()! == 'customer') {
        final isValid = _formKey.currentState!.validate();
        if (isValid) {
          _formKey.currentState!.save();

          if (ref.watch(currentLocationProvider)!.getName()! == '장소 추가') {
            ref.watch(currentLocationProvider)!.setName(_locationName);

            try { //기존 장소명을 수정하고 새로운 장소 추가 Location을 등록한다.
              final response = await dio.post(
                  "/devices/add_new_location",
                  data: jsonEncode({
                    "updateName": _locationName,
                    "oldLocationID": ref.watch(currentLocationProvider)!.getID()!,
                    "name": '장소 추가',
                    "userID": widget.userID,
                    "displaySunBun": gLocationList.length
                  })
              );
              gLocationList.add(
                  LocationInfo(
                      id: response.data[0]['id'],
                      name: response.data[0]['name'],
                      userID: response.data[0]['userID'],
                      type: response.data[0]['type'],
                      displaySunBun: response.data[0]['displaySunBun'],
                      requireMotionSensorCount: response.data[0]['requireMotionSensorCount'],
                      detectedMotionSensorCount: response.data[0]['detectedMotionSensorCount'],
                      requireDoorSensorCount: response.data[0]['requireDoorSensorCount'],
                      detectedDoorSensorCount: response.data[0]['detectedDoorSensorCount'],
                      createdAt: response.data[0]['createdAt'],
                      updatedAt: response.data[0]['updatedAt'],
                      sensors: []
                  )
              );
            } catch(e) {
              debugPrint(e as String?);
            }
          }

        } else {
          _failureDialog(context, "장소명 입력", "장소명이 잘못되었습니다.");
        }
      }
      ref.read(findHubStateProvider.notifier).doChangeState(ConfigState.findingSensor);
      mqttSendCommand(MqttCommand.mcParing, widget.deviceID);

      _startTimer();
    }
  }

  void _failureDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text(title),
              content: Text(message),
              actions: <Widget>[
                TextButton(
                  child: const Text("확인"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showFindSensorModalSheet() {
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
                  color: Theme
                      .of(context)
                      .colorScheme
                      .primaryContainer,
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
                                color: Theme
                                    .of(context)
                                    .colorScheme
                                    .primary
                            )
                          ],
                        ),
                        const SizedBox(height: 20),
                        SpinKitRipple(
                          color: Theme
                              .of(context)
                              .colorScheme
                              .onPrimaryContainer,
                          size: 100,
                        ),

                        const SizedBox(height: 40),

                        Text(
                          "센서를 찾고 있습니다.",
                          textAlign: TextAlign.center,
                          style: Theme
                              .of(context)
                              .textTheme
                              .bodyMedium!
                              .copyWith(color: Theme
                              .of(context)
                              .colorScheme
                              .onPrimaryContainer),
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
}
