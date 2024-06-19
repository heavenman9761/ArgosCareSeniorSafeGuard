import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:argoscareseniorsafeguard/models/accesspoint.dart';
import 'package:argoscareseniorsafeguard/constants.dart';

class CustomWifiListDialog extends StatefulWidget {
  const CustomWifiListDialog({super.key, required this.title, this.accessPoints});
  final String title;
  final List<AccessPoint>? accessPoints;

  @override
  State<CustomWifiListDialog> createState() => _CustomWifiListDialogState();
}

class _CustomWifiListDialogState extends State<CustomWifiListDialog> {
  String _title = '';

  @override
  void initState()
  {
    super.initState();
    _title = widget.title;
  }

  @override
  void deactivate() {
    super.deactivate();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        color: Constants.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(height: 40.h,),

          Text(_title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),),

          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
            child: SizedBox(
              height: 268,
              // color: Colors.redAccent,
              child: ListView.builder(
                  itemCount: widget.accessPoints?.length,
                  itemBuilder: (ctx, index) {
                    return ListTile(
                      title: Text(widget.accessPoints?[index].getWifiName() ?? '', style: TextStyle(fontSize: 14.sp),),
                      leading: rssiWidget(widget.accessPoints?[index]),//Icon(Icons.wifi, size: 15.h,),
                      trailing: widget.accessPoints?[index].getSecurity() == 0
                          ? Icon(Icons.lock_open, size: 15.h)
                          : Icon(Icons.lock, size: 15.h),
                      onTap: () {
                        Navigator.pop(context, widget.accessPoints?[index]);
                      },
                    );
                  }
              ),
            ),
          ),

          SizedBox(height: 14.h),

          Expanded(
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Constants.primaryColor,
                        border: Border(right: BorderSide(color: Colors.grey, width: 1),),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20),),
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
          )
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