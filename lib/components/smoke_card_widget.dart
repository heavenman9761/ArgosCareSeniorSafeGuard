import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:argoscareseniorsafeguard/providers/providers.dart';

class SmokeCardWidget extends ConsumerWidget {
  const SmokeCardWidget({super.key, required this.deviceName});

  final String deviceName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0)),
        child: InkWell(
          borderRadius: BorderRadius.circular(16.0),
          onTap: () {
            debugPrint('card press');
          },
          child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.0),
                color: Colors.transparent,
              ),
              child: Consumer(
                builder: (context, ref, widget) {
                  final smokeState = ref.watch(smokeSensorStateProvider);
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(deviceName,
                                  style: const TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.grey)),
                              IconButton(
                                icon: const Icon(Icons.more_horiz),
                                tooltip: "Menu",
                                color: Colors.grey,
                                onPressed: () {
                                  debugPrint('icon press');
                                },
                              ),
                            ]
                        ),
                        Text(smokeState, style: const TextStyle(fontSize: 12.0, color: Colors.grey),)
                      ],
                    ),
                  );
                },
              )
          ),
        ),
      ),
    );
  }
}