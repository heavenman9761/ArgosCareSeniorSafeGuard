import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:argoscareseniorsafeguard/models/accesspoint.dart';
import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/dialogs/custom_password_dialog.dart';

class CustomWifiListDialog extends StatefulWidget {
  const CustomWifiListDialog({super.key, required this.title, this.accessPoints});
  final String title;
  final List<AccessPoint>? accessPoints;

  @override
  State<CustomWifiListDialog> createState() => _CustomWifiListDialogState();
}

class _CustomWifiListDialogState extends State<CustomWifiListDialog> {
  @override
  void initState()
  {
    super.initState();
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 430.h,
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

                    SizedBox(height: 12.h,),

                    Expanded(
                      child: SizedBox(
                        height: 280.h,
                        child: ListView.builder(
                          itemCount: widget.accessPoints?.length,
                          shrinkWrap: true,
                          itemBuilder: (ctx, index) {
                            return Padding(
                              padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 8.h),
                              child: InkWell(
                                onTap: () {
                                  showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        backgroundColor: Constants.scaffoldBackgroundColor,
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                        insetPadding: EdgeInsets.all(20.w),
                                        child: CustomPasswordDialog(title: AppLocalizations.of(context)!.paring_hub_input_wifi_password, wifiName: widget.accessPoints?[index].getWifiName() ?? ''),
                                      );
                                    }
                                  ).then((val) {
                                    if (val != 'Cancel') {
                                      widget.accessPoints?[index].setPassword(val);
                                      Navigator.pop(context, widget.accessPoints?[index]);
                                    }
                                  });
                                },
                                child: Column(
                                  children: [
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        rssiWidget(widget.accessPoints?[index]),
                                        SizedBox(width: 10.w,),
                                        Expanded(child: Text(widget.accessPoints?[index].getWifiName() ?? '', style: TextStyle(fontSize: 14.sp),)),
                                        widget.accessPoints?[index].getSecurity() == 0
                                          ? Icon(Icons.lock_open, size: 15.h)
                                          : Icon(Icons.lock, size: 15.h),
                                      ]
                                    ),
                                    SizedBox(height: 3.h),
                                    Container(height: 1, width: double.infinity, color: Constants.borderColor)
                                  ],
                                )
                              ),
                            );
                          }
                        ),
                      ),
                    )
                  ],
                ),
              ),
            )
          ),
          SizedBox(
            height: 50.h,
            child: GestureDetector(
              child: Container(
                decoration: const BoxDecoration(
                  color: Constants.primaryColor,
                  border: Border(right: BorderSide(color: Colors.grey, width: 1),),
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20)),
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
        ],
      ),
    );
  }

  Widget rssiWidget(AccessPoint? ap) {
    if (ap!.getRssi()! > -50) {
      return Icon(Icons.wifi, size: 15.h);
    } else if (ap.getRssi()! >= -60) {
      return Icon(Icons.wifi_2_bar, size: 15.h);
    } else if (ap.getRssi()! >= -67) {
      return Icon(Icons.wifi_2_bar, size: 15.h);
    } else {
      return Icon(Icons.wifi_1_bar, size: 15.h);
    }
  }
}