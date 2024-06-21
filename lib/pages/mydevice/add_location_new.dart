import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/models/location_infos.dart';
import 'package:argoscareseniorsafeguard/components/my_button.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_alert_dialog.dart';

class AddLocationNew extends StatefulWidget {
  const AddLocationNew({super.key, required this.userName, required this.userID});

  final String userName;
  final String userID;

  @override
  State<AddLocationNew> createState() => _AddLocationNewState();
}

class _AddLocationNewState extends State<AddLocationNew> {
  TextEditingController controller = TextEditingController();
  String _locationName = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
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
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                        },
                      ),
                    ),

                  ],
                ),
              ),
            ),
            SizedBox(
              // color: Colors.blueAccent,
              height: 76.h,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text("장소 등록", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
                  ],
                ),
              ),
            ),
            SizedBox(
              // color: Colors.redAccent,
                height: 40.h,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Row(
                    children: [
                      Text("장소명", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF404040)), ),
                    ],
                  ),
                )
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 0),
              child: Form(
                key: _formKey,
                child: TextFormField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black, fontSize: 14.sp),
                  controller: controller,
                  key: const ValueKey(1),
                  readOnly: false,

                  onSaved: (val) {
                    setState(() {
                      _locationName = val!;
                    });
                  },
                  onChanged: (val) {
                    setState(() {
                      // String newName = val;
                      // print(newName);
                      // print(controller.text);
                      // ref.watch(currentLocationProvider)!.setName(controller.text);
                    });
                  },
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Constants.borderColor)
                    ),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(6),
                        borderSide: const BorderSide(color: Constants.borderColor)
                    ),
                    isDense: false,
                    contentPadding: const EdgeInsets.all(8),
                    fillColor: Colors.white,
                    filled: true,
                    hintStyle: TextStyle(color: Constants.dividerColor, fontSize: 14.sp),
                    hintText: '장소 명을 입력해 주세요.',
                    suffixIcon: IconButton(
                      icon: SvgPicture.asset("assets/images/textfield_delete.svg", height: 24.h, width: 24.h,),
                      onPressed: () {
                        controller.text = "";
                      },
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(),

            Padding(
              padding: EdgeInsets.all(20.0.h),
              child: MyButton(
                text: "저장",
                onTap: () {
                  _saveNewLocationName(context);
                },
              ),
            ),
          ],
        ),
      )
    );
  }

  void _saveNewLocationName(BuildContext context) async {
    if (controller.text == '') {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) {
            return Dialog(
              backgroundColor: Constants.scaffoldBackgroundColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              insetPadding: EdgeInsets.all(20.w),
              child: const CustomAlertDialog(title: "장소명 입력", message: "장소명을 먼저 입력해 주세요."),
            );
          }
      ).then((val) {
      });

    } else {
      final isValid = _formKey.currentState!.validate();
      if (isValid) {
        _formKey.currentState!.save();

        try { //새로운 장소 추가 Location을 등록한다.
          final response = await dio.post(
              "/devices/add_new_location",
              data: jsonEncode({
                "name": _locationName,
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

          if (!context.mounted) return;
          Navigator.pop(context);

        } catch(e) {
          debugPrint(e as String?);
        }
      }
    }
  }
}
