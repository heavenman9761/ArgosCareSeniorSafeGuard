import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:lottie/lottie.dart';

import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/mqtt/mqtt.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:argoscareseniorsafeguard/models/location_infos.dart';
import 'package:argoscareseniorsafeguard/models/sensor_infos.dart';
import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/pages/mydevice/add_sensor_second.dart';

class AddSensorSecond extends ConsumerStatefulWidget {
  final String userName;
  final String userID;
  final String hubID;

  const AddSensorSecond({super.key,
    required this.userName, required this.userID, required this.hubID});

  @override
  ConsumerState<AddSensorSecond> createState() => _AddSensorSecondState();
}

class _AddSensorSecondState extends ConsumerState<AddSensorSecond> {
  bool _isRunning = false;
  Timer? _timer;

  @override
  void deactivate() {
    _timer?.cancel();
    super.deactivate();
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) {
      ref.read(findSensorStateProvider.notifier).doChangeState(FindSensorState.findingSensorEmpty);
    });
  }

  void _stopTimer() {
    _isRunning = false;
    _timer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        ref.listen(findSensorStateProvider, (previous, next) {
          logger.i('current state: ${ref.watch(findSensorStateProvider)}');
          if (ref.watch(findSensorStateProvider) == FindSensorState.findingSensor) {

          } else if (ref.watch(findSensorStateProvider) == FindSensorState.findingSensorDone) {
            _stopTimer();
            Navigator.pop(context); //ModalSheet가 닫힌다.
            Navigator.pop(context); //이전페이지로 돌아간다.

          } else if (ref.watch(findSensorStateProvider) == FindSensorState.findingSensorEmpty) {
            // Navigator.pop(context);

          }
        });
        return Scaffold(
            backgroundColor: Constants.scaffoldBackgroundColor,
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox( //이전 페이지 버튼
                    // color: Colors.blueAccent,
                    height: 52.h,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            // color: Colors.redAccent,
                            child: IconButton(
                              constraints: BoxConstraints(maxHeight: 48.h, maxWidth: 48.w),
                              padding: EdgeInsets.zero,
                              color: Colors.black,
                              icon: const Icon(Icons.arrow_back),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),

                  SizedBox(
                    // color: Colors.blueAccent,
                    height: 76.h,
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text("${ref.watch(currentLocationProvider)!.getName()!} 기기 등록", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
                        ],
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h,),

                  SvgPicture.asset("assets/images/add_sensor.svg", width: 76.w, height: 56.h),

                  SizedBox(height: 40.h,),

                  _showGuide(1),

                  SizedBox(height: 16.h,),

                  _showGuide(2),

                  const Spacer(),

                  Padding(
                    padding: EdgeInsets.all(20.0.w),
                    child: MyButton(
                      text: "센서검색",
                      onTap: () {
                        ref.read(findSensorStateProvider.notifier).doChangeState(FindSensorState.findingSensor);
                        mqttSendCommand(MqttCommand.mcParing, widget.hubID);
                        _showFindSensorModalSheet(context);
                      },
                    ),
                  ),
                ],
              ),
            )
        );
      }
    );

  }

  Widget _showGuide(int index) {
    String message = '';
    if (index == 1) {
      message = "센서의 Pairing 버튼을 길게 눌러 LED가 빠르게 점등할 수 있도록 해주세요.";
    } else if (index == 2) {
      message = "모두 준비되면 '검색'을 탭하세요.";
    }
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
      child: Container(
        width: double.infinity,
        height: 80.h,
        decoration: BoxDecoration(
          border: Border.all(
              color: Constants.borderColor,
              width: 1
          ),
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(width: 16.w),
            Container(
                width: 24.w, height: 24.h,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFF5F5F5), width: 1),
                  borderRadius: BorderRadius.circular(8),
                  color: Constants.borderColor,
                ),
                child: Center(
                    child: Text(index.toString(), style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),)
                )
            ),
            SizedBox(width: 14.w),
            // Text(message, style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),  overflow: TextOverflow.ellipsis,)
            Expanded(
              child: Container(
                width: double.infinity,
                height: double.infinity,
                // color: Colors.redAccent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(message, style: TextStyle(fontSize: 14.sp, color: Colors.black, fontWeight: FontWeight.bold),  overflow: TextOverflow.ellipsis, maxLines: 2,),
                  ],
                )
              ),
            )
          ],
        ),
      ),
    );
  }

  void _showFindSensorModalSheet(BuildContext context) {
    _startTimer();
    showModalBottomSheet<void>(
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        isDismissible: false,
        enableDrag: false,
        builder: (BuildContext context) {
          return Consumer(
            builder: (context, ref, child) {
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
                    height: 356.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.rectangle,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20.0.h),
                        topRight: Radius.circular(20.0.h),
                      ),
                      color: Constants.scaffoldBackgroundColor,
                    ),
                    child: Center(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          mainAxisSize: MainAxisSize.max,
                          children: <Widget>[
                            _getSheetCloseButton(ref),

                            SizedBox(height: 12.h),

                            _getSheetTitle(ref),

                            SizedBox(height: 11.h),

                            _getSheetMessage(ref),

                            SizedBox(height: 50.h,),

                            _getSheetImage(ref),

                            const Spacer(),

                            _getSheetRetryButton(ref)
                          ]
                      ),
                    ),
                  )
              );
            }
          );

        }
    );
  }

  Widget _getSheetCloseButton(WidgetRef ref) {
    bool view = false;
    if (ref.watch(findSensorStateProvider) == FindSensorState.findingSensor) {
      view = false;
    } else {
      view = true;
    }

    if (view) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 50.h,
            child: IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close),
                color: Colors.black
            ),
          ),

        ],
      );
    } else {
      return SizedBox(height: 50.h);
    }
  }

  Widget _getSheetTitle(WidgetRef ref) {
    late String title;
    if (ref.watch(findSensorStateProvider) == FindSensorState.findingSensor) {
      title = "센서 검색중";//AppLocalizations.of(context)!.paring_hub_sheet_title_search;

    } else if (ref.watch(findSensorStateProvider) == FindSensorState.findingSensorEmpty) {
      title = "센서 검색 완료"; //AppLocalizations.of(context)!.paring_hub_sheet_title_result;

    } else if (ref.watch(findSensorStateProvider) == FindSensorState.findingSensorDone) {
      title = "센서 검색 완료";//AppLocalizations.of(context)!.paring_hub_sheet_title_permission_error;

    } else {
      title = '';
    }

    return Text(
      title,
      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
      textAlign: TextAlign.center,
    );
  }

  Widget _getSheetMessage(WidgetRef ref) {
    late String message;
    if (ref.watch(findSensorStateProvider) == FindSensorState.findingSensor) {
      message = "센서를 검색하고 있습니다.";//AppLocalizations.of(context)!.paring_hub_sheet_title_search;

    } else if (ref.watch(findSensorStateProvider) == FindSensorState.findingSensorEmpty) {
      message = "검색된 센서가 없습니다."; //AppLocalizations.of(context)!.paring_hub_sheet_title_result;

    } else if (ref.watch(findSensorStateProvider) == FindSensorState.findingSensorDone) {
      message = "센서 검색이 완료되었습니다.";//AppLocalizations.of(context)!.paring_hub_sheet_title_permission_error;

    } else {
      message = '';
    }

    return Text(
      message,
      style: TextStyle(fontSize: 16.sp, color: Constants.dividerColor),
      textAlign: TextAlign.center,
    );
  }

  Widget _getSheetImage(WidgetRef ref) {
    if (ref.watch(findSensorStateProvider) == FindSensorState.findingSensor) {
      return Lottie.asset('assets/animations/processing.json', width: 100.w, height: 80.h);

    } else if (ref.watch(findSensorStateProvider) == FindSensorState.findingSensorEmpty) {
      return SizedBox(
          width: 96.w,
          height: 76.h,
          child: Stack(
            children: [
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: 96.w,
                    height: 76.h,
                    child: const Image(image: AssetImage('assets/images/not_find_hub.png'),),
                  )
              ),
              Positioned(
                  top: 0, right: 0,
                  child: SizedBox(
                    width: 32.w,
                    height: 32.h,
                    child: SvgPicture.asset('assets/images/error.svg', width: 32.w, height: 32.h,),
                  )
              ),
            ],
          )
      );
    } else if (ref.watch(findSensorStateProvider) == FindSensorState.findingSensorDone) {
      return SizedBox(
          width: 96.w,
          height: 76.h,
          child: Stack(
            children: [
              Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: SizedBox(
                    width: 96.w,
                    height: 76.h,
                    child: const Image(image: AssetImage('assets/images/hub.png'),),
                  )
              ),
              Positioned(
                  top: 0, right: 0,
                  child: SizedBox(
                    width: 32.w,
                    height: 32.h,
                    child: SvgPicture.asset('assets/images/done.svg', width: 32.w, height: 32.h,),
                  )
              ),
            ],
          )
      );
    } else {
      return const SizedBox();
    }
  }

  Widget _getSheetRetryButton(WidgetRef ref) {
    if (ref.watch(findSensorStateProvider) == FindSensorState.findingSensorEmpty) {
      return Padding(
        padding: EdgeInsets.all(20.h),
        child: MyButton(
          onTap: () {
            ref.read(findSensorStateProvider.notifier).doChangeState(FindSensorState.findingSensor);
            mqttSendCommand(MqttCommand.mcParing, widget.hubID);
          },
          text: "재검색"//AppLocalizations.of(context)!.paring_hub_retry_search,
        ),
      );
    } else {
      return const SizedBox();
    }
  }
}
