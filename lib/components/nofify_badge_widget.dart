import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:badges/badges.dart' as badges;

import 'package:argoscareseniorsafeguard/providers/providers.dart';
import 'package:argoscareseniorsafeguard/pages/alarms_view.dart';

class NotifyBadgeWidget extends ConsumerStatefulWidget {
  const NotifyBadgeWidget({super.key});

  @override
  ConsumerState<NotifyBadgeWidget> createState() => _NotifyBadgeWidgetState();
}

class _NotifyBadgeWidgetState extends ConsumerState<NotifyBadgeWidget> {
  @override
  Widget build(BuildContext context) {
    return Consumer(
        builder:(context, ref, widget) {
          final showBadge = ref.watch(alarmReceivedProvider);
          return badges.Badge(
            badgeContent: const Icon(Icons.check, color: Colors.white, size: 5),
            showBadge: showBadge,
            position: badges.BadgePosition.topEnd(top: 0, end: 5),
            child: IconButton(
              icon: const Icon(Icons.notifications_none_outlined, size: 30),
              color: Colors.grey,
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return const AlarmsView();
                })).then((value) {
                    ref.read(alarmReceivedProvider.notifier).state = false;
                });
              },
            ),
          );
        },
      );
  }
}
