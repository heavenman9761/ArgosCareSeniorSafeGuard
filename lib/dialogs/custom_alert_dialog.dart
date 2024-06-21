import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:argoscareseniorsafeguard/constants.dart';

class CustomAlertDialog extends StatefulWidget {
  const CustomAlertDialog({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  State<CustomAlertDialog> createState() => _CustomAlertDialogState();
}

class _CustomAlertDialogState extends State<CustomAlertDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 160,
      decoration: BoxDecoration(
        color: Constants.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          SizedBox(height: 30.h,),

          Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),),

          SizedBox(height: 18.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 24.w,),
              Text(widget.message, style: TextStyle(fontSize: 14.sp), textAlign: TextAlign.start,),
            ],
          ),

          const SizedBox(height: 30),

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
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(20), bottomLeft: Radius.circular(20)),
                      ),
                      child: Center(
                        child: Text(AppLocalizations.of(context)!.ok, style: TextStyle(fontSize: 14.sp, color: Colors.white),),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop('ok'); // replace with your own functions
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
}
