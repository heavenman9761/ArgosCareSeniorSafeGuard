import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:argoscareseniorsafeguard/constants.dart';

class CustomPasswordDialog extends StatefulWidget {
  const CustomPasswordDialog({super.key, required this.title, required this.wifiName});
  final String title;
  final String wifiName;

  @override
  State<CustomPasswordDialog> createState() => _CustomPasswordDialogState();
}

class _CustomPasswordDialogState extends State<CustomPasswordDialog> {
  bool passwordVisible = true;
  final controller = TextEditingController(text: "");

  @override
  void initState()
  {
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 230,
      decoration: BoxDecoration(
        color: Constants.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 12.h),
                child: Column(
                  children: [
                    Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),),

                    SizedBox(height: 12.h),

                    Expanded(
                      child: SizedBox(
                        width: double.infinity,
                        height: 8.h,
                        child: Flexible(child: Text(widget.wifiName, style: TextStyle(fontSize: 14.sp), textAlign: TextAlign.center,)),
                      ),
                    ),

                    Padding(
                      padding: EdgeInsets.fromLTRB(8.w, 8.h, 8.w, 8.h),
                      child: TextFormField(
                        autofocus: true,
                        obscureText: passwordVisible,
                        controller: controller,
                        style:TextStyle(fontSize:12.sp),
                        decoration: InputDecoration(
                          hintText: "wifi password",
                          hintStyle: const TextStyle(color: Constants.dividerColor),
                          fillColor: Colors.white,
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Constants.borderColor,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: const BorderSide(
                              color: Constants.borderColor,
                              width: 1.0,
                            ),
                          ),
                          border: const OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0.h, horizontal: 15.w),
                          suffixIcon: IconButton(
                            icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off, size: 15.h, ),
                            onPressed: () {
                              setState(() => passwordVisible = !passwordVisible);
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ),
          SizedBox(
            height: 50.h,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Constants.primaryColor,
                        border: Border(right: BorderSide(color: Colors.grey, width: 1),),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20),),
                      ),
                      child: Center(
                        child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(fontSize: 14.sp, color: Colors.white),),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop('Cancel'); // replace with your own functions
                    },
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Constants.primaryColor,
                        border: Border(right: BorderSide(color: Colors.grey, width: 1),),
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(20),),
                      ),
                      child: Center(
                        child: Text(AppLocalizations.of(context)!.ok, style: TextStyle(fontSize: 14.sp, color: Colors.white),),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop(controller.text); // replace with your own functions
                    },
                  ),
                ),
              ]
            )
          ),
        ]
      )
    );
  }
}