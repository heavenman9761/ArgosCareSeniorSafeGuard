import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';

import 'package:argoscareseniorsafeguard/constants.dart';
import 'package:argoscareseniorsafeguard/models/request_share_infos.dart';
import 'package:argoscareseniorsafeguard/providers/providers.dart';

class ShareManage extends ConsumerStatefulWidget {
  final String userID;

  const ShareManage({super.key, required this.userID});

  @override
  ConsumerState<ShareManage> createState() => _ShareManageState();
}

class _ShareManageState extends ConsumerState<ShareManage> {
  @override
  void initState() {
    super.initState();
  }

  Future<List<RequestShareInfo>> fetchInfo() async {
    List<RequestShareInfo> list = [];
    try {
      final response = await dio.get(
        "/share/${widget.userID}",
      );
      for (var l in response.data) {
        list.add(RequestShareInfo(
            id: l['id'],
            name: l['User']['name'],
            createdAt: l['created']
        ));
      }

      ref.read(requestShareListProviderCount.notifier).state = list.length;
      return list;

    } catch(e) {
      debugPrint(e as String?);
      return list;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Theme.of(context).colorScheme.primary),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white10,
                Colors.white10,
                Colors.black12,
                Colors.black12,
                Colors.black12,
                Colors.black12,
              ],
            )
          ),
        ),
        Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.transparent,//Colors.grey[300],
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.inversePrimary,
            title: const Text(Constants.APP_TITLE),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                header('공유중'),
                shareList(),
                header('공유신청'),
                requestShare(),
              ],
            ),
          )
        )
      ],
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
              Text(sensorName, style: TextStyle(fontSize: deviceFontSize - 2, color: Theme.of(context).colorScheme.onPrimary,),),
            ]
        )
    );
  }

  Widget shareList() {
    return Card(
      color: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Consumer(
        builder: (context, ref, widget) {
          return SizedBox(
            height: ref.watch(requestShareListProviderCount) * 46,
            child: Column(
              children: [
                Flexible(
                  child: FutureBuilder<List<RequestShareInfo>> (
                    future: fetchInfo(),
                    builder: (context, snapshot) {
                      final List<RequestShareInfo>? requestShareInfos = snapshot.data;
                      if (snapshot.connectionState != ConnectionState.done) {
                        return const Center(child: CircularProgressIndicator(),);
                      }

                      if (snapshot.hasError) {
                        return Center( child: Text(snapshot.error.toString()), );
                      }

                      if (snapshot.hasData) {
                        if (requestShareInfos != null) {
                          if (requestShareInfos.isEmpty) {
                            return const Center( child: CircularProgressIndicator(), );
                          }

                          return ListView.builder(
                            itemCount: requestShareInfos.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(requestShareInfos[index].getName()!, style: TextStyle(fontSize: deviceFontSize, color: Theme.of(context).colorScheme.onSurface,)),
                                    SizedBox(
                                      height: 30,
                                      child: FittedBox(
                                        child: CupertinoSwitch(
                                          value: true,
                                          activeColor: CupertinoColors.activeBlue,
                                          onChanged: (bool? value) { },
                                        ),
                                      )
                                    )
                                  ],
                                ),
                              );
                            }
                          );
                        } else {
                          return const SizedBox();
                        }
                      } else {
                        return const SizedBox();
                      }
                    }
                  )
                )
              ],
            ),
          );
        }
      )
    );
  }

  Widget requestShare() {
    return Card(
        color: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
                            backgroundColor: Theme.of(context).colorScheme.secondaryContainer, // text color
                            elevation: 5, //
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))
                        ),
                        onPressed: (){ _inputShareKeyDialog(context); },
                        child: const Text('공유 신청')
                    )
                  ],
                )

              ],
            )
        )
    );
  }

  /*Widget waittingList() {
    return Card(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
        child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('OOO님의 승인 대기 중')
                  ],
                )

              ],
            )
        )
    );
  }*/

  void _inputShareKeyDialog(BuildContext context) {
    final controller = TextEditingController(text: "");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text("Input ShareKey"),
              content: TextFormField(
                autofocus: true,
                controller: controller,
                decoration: InputDecoration(
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.paste_outlined,),
                    onPressed: () async {
                      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
                      String? clipboardText = clipboardData?.text;
                      controller.text = clipboardText!;
                    },
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text("Cancel"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
                TextButton(
                  child: const Text("OK"),
                  onPressed: () {
                    Navigator.pop(context, controller.text);
                  },
                ),
              ],
            );
          },
        );
      },
    ).then((val) async {
      if (val != null) {
        try {
          final res = await dio.post(
            "/share/request_share",
            data: jsonEncode({
              "userID": widget.userID,
              "shareKey": val,
            })
          );
          if (res.statusCode == 200) {
            print('정상적으로 신청되었습니다.\n${res.data['ownerName']} 님의 승인을 기다립니다.');
          } else if (res.statusCode == 201 || res.statusCode == 202) {
            print(res.data['msg']);
          }
        } catch(e) {
          debugPrint(e as String?);
        }
      }
    });
  }
}
