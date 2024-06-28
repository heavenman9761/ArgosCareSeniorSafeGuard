import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:argoscareseniorsafeguard/constants.dart';

class CustomConfirmDialog extends StatefulWidget {
  const CustomConfirmDialog({super.key, required this.title, required this.message});

  final String title;
  final String message;

  @override
  State<CustomConfirmDialog> createState() => _CustomConfirmDialogState();
}

class _CustomConfirmDialogState extends State<CustomConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 218,
      decoration: BoxDecoration(
        color: Constants.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          const SizedBox(height: 30,),

          SizedBox(
            height: 18,
            child: Text(widget.title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),),
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 42,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(width: 24,),
                Text(widget.message, style: TextStyle(fontSize: 14.sp), textAlign: TextAlign.start,),
              ],
            ),
          ),

          const SizedBox(height: 60),

          Container(
            height: 50,
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: GestureDetector(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Constants.primaryColor,
                        border: Border(right: BorderSide(color: Colors.grey, width: 1),),
                        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
                      ),
                      child: Center(
                        child: Text(AppLocalizations.of(context)!.cancel, style: TextStyle(fontSize: 14.sp, color: Colors.white),),
                      ),
                    ),
                    onTap: () {
                      Navigator.of(context).pop('cancel'); // replace with your own functions
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
                        borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
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
          ),
        ],
      ),
    );
  }
}
