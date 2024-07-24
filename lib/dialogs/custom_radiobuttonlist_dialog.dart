import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'package:argoscareseniorsafeguard/constants.dart';

class CustomRadioButtonListDialog extends StatefulWidget {
  const CustomRadioButtonListDialog({super.key, required this.title, required this.sourList});
  final String title;
  final List<String> sourList;

  @override
  State<CustomRadioButtonListDialog> createState() => _CustomRadioButtonListDialogState();
}

class _CustomRadioButtonListDialogState extends State<CustomRadioButtonListDialog> {
  String _moveLocation = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300.h,
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
                          height: 200.h,
                          child: ListView.builder(
                              itemCount: widget.sourList.length,
                              shrinkWrap: true,
                              itemBuilder: (ctx, index) {
                                return Padding(
                                  padding: EdgeInsets.fromLTRB(16.w, 0.h, 16.w, 0.h),
                                  child: Column(
                                    children: [
                                      RadioListTile(
                                        contentPadding: const EdgeInsets.all(0),
                                        dense: true,
                                        title: Text(widget.sourList[index], style: TextStyle(fontSize: 14.sp),),
                                        value: widget.sourList[index],
                                        groupValue: _moveLocation,
                                        onChanged: (value) {
                                          setState(() {
                                            _moveLocation = value ?? '';
                                          });
                                        },

                                      )
                                    ],
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
                          Navigator.pop(context, _moveLocation, );
                        },
                      ),
                    ),
                  ]
              )
          ),
        ],
      ),
    );
  }
}
