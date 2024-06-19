import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/mqtt/mqtt.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:argoscareseniorsafeguard/models/location_infos.dart';

class AddLocationFirst extends StatefulWidget {
  const AddLocationFirst({super.key, required this.userName, required this.userID});

  final String userName;
  final String userID;

  @override
  State<AddLocationFirst> createState() => _AddLocationFirstState();
}

class _AddLocationFirstState extends State<AddLocationFirst> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constants.scaffoldBackgroundColor,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container( //이전 페이지 버튼
              // color: Colors.blueAccent,
              height: 52.h,
              child: Padding(
                padding: EdgeInsets.all(20.0.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 24.w,
                      height: 24.h,
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
                    )
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
                    Text("장소(센서) 등록", style: TextStyle(fontSize: 20.sp, color: Colors.black, fontWeight: FontWeight.bold), ),
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
                // key: _formKey,
                child: TextFormField(
                  cursorColor: Colors.black,
                  style: TextStyle(color: Colors.black, fontSize: 14.sp),
                  // controller: controller,
                  key: const ValueKey(1),
                  // readOnly: ref.watch(currentLocationProvider)!.getType()! == 'customer' ? false : true,//widget.location != null,
                  onSaved: (val) {
                    setState(() {
                      // _locationName = val!;
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
                  ),
                ),
              ),
            ),
          ],
        )
      )
    );
  }
}
