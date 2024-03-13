import 'package:flutter/material.dart';

import 'dart:async';
import 'dart:io';
import 'dart:convert';

import 'package:logger/logger.dart';
import 'package:my_mqtt_exam/providers/Providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:my_mqtt_exam/mqtt/mqtt.dart';

import 'package:mqtt_client/mqtt_client.dart';

var logger = Logger(
  printer: PrettyPrinter(),
);

var loggerNoStack = Logger(
  printer: PrettyPrinter(methodCount: 0),
);


void main() {
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  @override
  void initState() {
    mqttInit(ref, '14.42.209.174', 6002, 'ArgosCareSeniorSafeGuard', 'mings', 'Sct91234!');
    super.initState();
  }

  @override
  void dispose() {
    mqttDisconnect();
    super.dispose();
  }

  void _mqttPublish() {
    if (ref.watch(mqttCurrentStateProvider) == MqttConnectionState.connected) {
      mqttPublish('request/00003494543ebb58', jsonEncode({
        "order": "sensorList",
        "deviceID": '00003494543ebb58',
        "time": 'YYYY-MM-DD'
      }));
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(mqttCurrentTopicProvider, (previous, next) {
      logger.i('current topic: ${ref.watch(mqttCurrentTopicProvider)}');
    });

    ref.listen(mqttCurrentMessageProvier, (previous, next) {
      logger.i('current msg: ${ref.watch(mqttCurrentMessageProvier)}');
    });

    ref.listen(mqttCurrentStateProvider, (previous, next) {
      logger.i('current state: ${ref.watch(mqttCurrentStateProvider)}');
      if (ref.watch(mqttCurrentStateProvider) == MqttConnectionState.connected) {
        mqttAddSubscribeTo('request/00003494543ebb58');
      }
    });

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              ref.watch(mqttCurrentMessageProvier),
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _mqttPublish();
        },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}