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
  String _title = '';
  String _wifiName = '';
  bool passwordVisible = true;

  final controller = TextEditingController(text: "");
  @override
  void initState()
  {
    super.initState();
    _title = widget.title;
    _wifiName = widget.wifiName;
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
          SizedBox(height: 40.h,),

          Text(_title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),),

          SizedBox(height: 8.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(width: 24.w,),
              Text(_wifiName, style: TextStyle(fontSize: 14.sp), textAlign: TextAlign.start,),
            ],
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 4, 8),
            child: TextFormField(
              autofocus: true,
              obscureText: passwordVisible,
              controller: controller,
              style:TextStyle(fontSize:12.sp),
              decoration: InputDecoration(
                fillColor: Colors.white,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2.0),
                  borderSide: const BorderSide(
                    color: Constants.scaffoldBackgroundColor,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2.0),
                  borderSide: const BorderSide(
                    color: Constants.scaffoldBackgroundColor,
                    width: 1.0,
                  ),
                ),
                border: const OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 15.0.h),
                suffixIcon: IconButton(
                  icon: Icon(passwordVisible ? Icons.visibility : Icons.visibility_off, size: 15.h, ),
                  onPressed: () {
                    setState(() => passwordVisible = !passwordVisible);
                  },
                ),
                // labelText: 'Password',
                // icon: const Padding(
                //   padding: EdgeInsets.only(top: 15.0),
                //   child: Icon(Icons.lock, size: 15,),
                // ),
              ),
            ),
          ),
          SizedBox(height: 37.h),

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
              ],
            ),
          )
        ],
      ),
    );
  }
}