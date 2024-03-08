import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:argoscareseniorsafeguard/mqtt/MQTTManager.dart';
import 'package:argoscareseniorsafeguard/mqtt/IMQTTController.dart';


final mqttManagerProvider = ChangeNotifierProvider<IMQTTController>((ref) {
  return MQTTManager();
});

final hubNameProvider = StateProvider<String>((ref) {
  return "";
});
