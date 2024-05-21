import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:argoscareseniorsafeguard/constants.dart';

class ShareManage extends StatefulWidget {
  final String userID;

  const ShareManage({super.key, required this.userID});

  @override
  State<ShareManage> createState() => _ShareManageState();
}

class _ShareManageState extends State<ShareManage> {
  @override
  void initState() {
    super.initState();
    _loadSharedList();
  }

  void _loadSharedList() async {
    final response = await dio.get(
        "/share/${widget.userID}",
    );
    debugPrint(response.data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.grey[300],
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(Constants.APP_TITLE),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            tooltip: "Menu",
            color: Colors.blue,
            onPressed: () {
              _confirmDialog(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            header('공유중'),
            shareList(),
            // header('승인대기'),
            // waittingList()
          ],
        ),
      )
    );
  }

  Widget header(String sensorName) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 8),
        child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Icon(Icons.fiber_manual_record, size: 10.0, color: Colors.redAccent),
              const SizedBox(width: 10),
              Text(sensorName, style: TextStyle(fontSize: deviceFontSize - 2),),
            ]
        )
    );
  }

  Widget shareList() {
    return Card(
      color: Colors.white,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('홍길동', style: TextStyle(fontSize: deviceFontSize)),
                SizedBox(
                    height: 30,
                    child: FittedBox(
                      child: CupertinoSwitch(
                        value: true,
                        activeColor: CupertinoColors.activeBlue,
                        onChanged: (bool? value) {
                        },
                      ),
                    )
                )
              ],
            )

          ],
        )
      )
    );
  }

  Widget waittingList() {
    return const SizedBox();
  }

  void _confirmDialog(BuildContext context) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setDialogState) {
                return AlertDialog(
                    title: const Text("변경사항을 저장할까요?"),
                    actions: [
                      TextButton(
                        child: const Text("Cancel"),
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                      ),
                      TextButton(
                        child: const Text("OK"),
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                      ),
                    ]
                );
              }
          );
        }
    ).then((val) {
      if (val) {
        _saveSettings();
      }
    });
  }

  void _saveSettings() async {
    // const storage = FlutterSecureStorage(
    //   iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
    //   aOptions: AndroidOptions(encryptedSharedPreferences: true),
    // );
    // final userID = await storage.read(key: 'ID');

    /*final response = await dio.post(
        "/devices/set_alarm",
        data: jsonEncode({
          "userID": widget.userID,
        })
    );*/
  }
}
