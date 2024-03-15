import 'package:flutter/material.dart';
import 'package:argoscareseniorsafeguard/models/device.dart';

class AlarmDetailView extends StatefulWidget {
  const AlarmDetailView({super.key, required this.device});

  final Device device;

  @override
  State<AlarmDetailView> createState() => _AlarmDetailViewState();
}

class _AlarmDetailViewState extends State<AlarmDetailView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: const Text('Argos Care'),
          centerTitle: true,
        ),
        body: const Column(
          children: [
            Padding(
                padding: EdgeInsets.fromLTRB(16, 16, 8, 8),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(Icons.fiber_manual_record, size: 10.0, color: Colors.redAccent),
                      SizedBox(width: 10),
                      Text("현황", style: TextStyle(fontSize: 16.0),),
                    ]
                )
            ),
            // Expanded(
              // child: FutureBuilder<List<Device>>(
              //   future: _getDeviceList(),
              //   builder: (context, snapshot) {
              //     final List<Device>? devices = snapshot.data;
              //     if (snapshot.connectionState != ConnectionState.done) {
              //       return const Center(
              //         child: CircularProgressIndicator(),
              //       );
              //     }
              //     if (snapshot.hasError) {
              //       return Center(
              //         child: Text(snapshot.error.toString()),
              //       );
              //     }
              //     if (snapshot.hasData) {
              //       if (devices != null) {
              //         if (devices.isEmpty) {
              //           return const Center(
              //             child: CircularProgressIndicator(),
              //           );
              //         }
              //         return ListView.builder(
              //           itemCount: devices.length,
              //           itemBuilder: (context, index) {
              //             return Padding(
              //               padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
              //               child: Card(
              //                 color: Colors.white,
              //                 surfaceTintColor: Colors.transparent,
              //                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              //                 child: InkWell(borderRadius: BorderRadius.circular(8.0),
              //                   onTap: () {
              //                     _goDetailView(devices[index]);
              //                   },
              //                   child: Container(
              //                       decoration: BoxDecoration(
              //                         borderRadius: BorderRadius.circular(8.0),
              //                         color: Colors.transparent,
              //                       ),
              //                       child: Padding(
              //                           padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
              //                           child: ListTile(
              //                             title: Text(devices[index].getDeviceName()!,
              //                                 style: const TextStyle(
              //                                     fontSize: 20.0,
              //                                     fontWeight: FontWeight.w700,
              //                                     color: Colors.grey)),
              //                             leading: _getDeviceIcon(devices[index]),
              //                             trailing: const Icon(Icons.chevron_right),//Row(
              //                             //   mainAxisAlignment: MainAxisAlignment.end,
              //                             //   mainAxisSize: MainAxisSize.min,
              //                             //   children: [
              //                             //     IconButton(
              //                             //       icon: const Icon(Icons.chevron_right),
              //                             //       onPressed: () {
              //                             //         debugPrint("===========");
              //                             //       },
              //                             //     )
              //                             //   ],
              //                             // ),
              //                           )
              //                       )
              //                   ),
              //                 ),
              //               ),
              //             );
              //           },
              //         );
              //
              //       } else {
              //         return const Center(
              //           child: CircularProgressIndicator(),
              //         );
              //       }
              //     } else {
              //       return const Center(
              //         child: CircularProgressIndicator(),
              //       );
              //     }
              //   },
              // ),
            // )
          ],
        )
    );
  }
}
