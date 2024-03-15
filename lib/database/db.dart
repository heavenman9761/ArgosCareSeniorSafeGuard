import 'dart:ffi';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:argoscareseniorsafeguard/models/device.dart';
import 'package:argoscareseniorsafeguard/models/hub.dart';
import 'package:argoscareseniorsafeguard/models/sensor.dart';
import 'package:argoscareseniorsafeguard/models/sensor_event.dart';
import 'package:argoscareseniorsafeguard/constants.dart';

const String databaseName = 'ArgosCareSeniorSafeGuard.db';
const String tableNameDevices = 'devices';
const String tableNameHubs = 'hubs';
const String tableNameSensors = 'sensors';
const String tableNameSensorEvents = 'sensorEvents';

class DBHelper {
  var _db;

  Future<Database> get database async {
    if (_db != null) return _db;

    _db = openDatabase(join(await getDatabasesPath(), databaseName),
        onCreate: (db, version) => _createDb(db), version: 1);
    return _db;
  }

  static void _createDb(Database db) async {
    await db.execute(
      "CREATE TABLE $tableNameDevices ("
        "deviceID TEXT PRIMARY KEY, "
        "deviceType TEXT, "
        "deviceName TEXT, "
        "displaySunBun INTEGER,"
        "accountID TEXT, "
        "state TEXT, "
        "updateTime TEXT, "
        "createTime TEXT"
      ")",
    );

    await db.execute(
      "CREATE TABLE $tableNameHubs ("
        "hubID TEXT PRIMARY KEY, "
        "deviceName TEXT, "
        "displaySunBun INTEGER,"
        "state TEXT, "
        "updateTime TEXT, "
        "createTime TEXT"
      ")",
    );

    await db.execute(
      "CREATE TABLE $tableNameSensors ("
        "sensorID TEXT PRIMARY KEY, "
        "hubID TEXT, "
        "deviceType TEXT, "
        "deviceName TEXT, "
        "displaySunBun INTEGER,"
        "state TEXT, "
        "updateTime TEXT, "
        "createTime TEXT"
      ")",
    );

    await db.execute(
      "CREATE TABLE $tableNameSensorEvents ("
        "id INTEGER PRIMARY KEY AUTOINCREMENT, "
        "hubID TEXT, "
        "deviceID TEXT, "
        "deviceType TEXT, "
        "event TEXT, "
        "state TEXT, "
        "updateTime TEXT, "
        "createTime TEXT"
      ")",
    );
  }

  //--------> devices table handling
  Future<void> insertDevice(Device device) async {
    final db = await database;

    await db.insert(
      tableNameDevices,
      device.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Device>> getDevices() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameDevices, orderBy: 'displaySunBun ASC');

    return List.generate(maps.length, (i) {
      return Device(
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        deviceName: maps[i]['deviceName'],
        displaySunBun: maps[i]['displaySunBun'],
        accountID: maps[i]['accountID'],
        state: maps[i]['state'],
        updateTime: maps[i]['updateTime'],
        createTime: maps[i]['createTime'],
      );
    });
  }

  Future<List<Device>> getDeviceOfHubs() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameDevices, where: 'deviceType = ?', whereArgs: [Constants.DEVICE_TYPE_HUB]);

    return List.generate(maps.length, (i) {
      return Device(
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        deviceName: maps[i]['deviceName'],
        displaySunBun: maps[i]['displaySunBun'],
        accountID: maps[i]['accountID'],
        state: maps[i]['state'],
        updateTime: maps[i]['updateTime'],
        createTime: maps[i]['createTime'],
      );
    });
  }

  Future<List<Device>> getDeviceExpectHubs() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameDevices, where: 'deviceType <> ?', whereArgs: [Constants.DEVICE_TYPE_HUB]);

    return List.generate(maps.length, (i) {
      return Device(
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        deviceName: maps[i]['deviceName'],
        displaySunBun: maps[i]['displaySunBun'],
        accountID: maps[i]['accountID'],
        state: maps[i]['state'],
        updateTime: maps[i]['updateTime'],
        createTime: maps[i]['createTime'],
      );
    });
  }

  Future<void> updateDevice(Device device) async {
    final db = await database;

    await db.update(
      tableNameDevices,
      device.toMap(),
      where: "deviceID = ?",
      whereArgs: [device.deviceID],
    );
  }

  Future<void> deleteDevice(String deviceID) async {
    final db = await database;

    await db.delete(
      tableNameDevices,
      where: "deviceID = ?",
      whereArgs: [deviceID],
    );
  }

  Future<List<Device>> findDevice(String deviceID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameDevices, where: 'deviceID = ?', whereArgs: [deviceID]);

    return List.generate(maps.length, (i) {
      return Device(
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        deviceName: maps[i]['deviceName'],
        displaySunBun: maps[i]['displaySunBun'],
        accountID: maps[i]['accountID'],
        state: maps[i]['state'],
        updateTime: maps[i]['updateTime'],
        createTime: maps[i]['createTime'],
      );
    });
  }

  Future<List<Device>> findDeviceBySensor(String deviceType) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameDevices, where: 'deviceType = ?', whereArgs: [deviceType]);

    return List.generate(maps.length, (i) {
      return Device(
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        deviceName: maps[i]['deviceName'],
        displaySunBun: maps[i]['displaySunBun'],
        accountID: maps[i]['accountID'],
        state: maps[i]['state'],
        updateTime: maps[i]['updateTime'],
        createTime: maps[i]['createTime'],
      );
    });
  }

  Future<int?> getDeviceCountByType(String deviceType) async {
    final db = await database;
    var x = await db.rawQuery("SELECT COUNT (*) from $tableNameDevices WHERE deviceType = '$deviceType'");
    int? count = Sqflite.firstIntValue(x);
    return count;
  }

  Future<int?> getDeviceCount() async {
    final db = await database;
    var x = await db.rawQuery('SELECT COUNT (*) from $tableNameDevices');
    int? count = Sqflite.firstIntValue(x);
    return count;
  }

  //--------> hubs table handling

  Future<void> insertHub(Hub hub) async {
    final db = await database;

    await db.insert(
      tableNameHubs,
      hub.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Hub>> getHubs() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameHubs);

    return List.generate(maps.length, (i) {
      return Hub(
        hubID: maps[i]['hubID'],
        deviceName: maps[i]['deviceName'],
        displaySunBun: maps[i]['displaySunBun'],
        state: maps[i]['state'],
        updateTime: maps[i]['updateTime'],
        createTime: maps[i]['createTime'],
      );
    });
  }

  Future<void> updateHub(Hub hub) async {
    final db = await database;

    await db.update(
      tableNameHubs,
      hub.toMap(),
      where: "deviceID = ?",
      whereArgs: [hub.hubID],
    );
  }

  Future<void> deleteHub(String hubID) async {
    final db = await database;

    await db.delete(
      tableNameHubs,
      where: "deviceID = ?",
      whereArgs: [hubID],
    );
  }

  Future<List<Hub>> findHub(String hubID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameHubs, where: 'hubID = ?', whereArgs: [hubID]);

    return List.generate(maps.length, (i) {
      return Hub(
        hubID: maps[i]['hubID'],
        deviceName: maps[i]['deviceName'],
        displaySunBun: maps[i]['displaySunBun'],
        state: maps[i]['state'],
        updateTime: maps[i]['updateTime'],
        createTime: maps[i]['createTime'],
      );
    });
  }

//--------> sensors table handling

  Future<void> insertSensor(Sensor sensor) async {
    final db = await database;

    await db.insert(
      tableNameSensors,
      sensor.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Sensor>> getSensors() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameSensors);

    return List.generate(maps.length, (i) {
      return Sensor(
        sensorID: maps[i]['sensorID'],
        hubID: maps[i]['hubID'],
        deviceType: maps[i]['deviceType'],
        deviceName: maps[i]['deviceName'],
        displaySunBun: maps[i]['displaySunBun'],
        state: maps[i]['state'],
        updateTime: maps[i]['updateTime'],
        createTime: maps[i]['createTime'],
      );
    });
  }

  Future<void> updateSensor(Sensor sensor) async {
    final db = await database;

    await db.update(
      tableNameSensors,
      sensor.toMap(),
      where: "deviceID = ?",
      whereArgs: [sensor.sensorID],
    );
  }

  Future<void> deleteSensor(String sensorID) async {
    final db = await database;

    await db.delete(
      tableNameSensors,
      where: "sensorID = ?",
      whereArgs: [sensorID],
    );
  }

  Future<List<Sensor>> findSensor(String sensorID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameSensors, where: 'deviceID = ?', whereArgs: [sensorID]);

    return List.generate(maps.length, (i) {
      return Sensor(
        sensorID: maps[i]['sensorID'],
        hubID: maps[i]['hubID'],
        deviceType: maps[i]['deviceType'],
        deviceName: maps[i]['deviceName'],
        displaySunBun: maps[i]['displaySunBun'],
        state: maps[i]['state'],
        updateTime: maps[i]['updateTime'],
        createTime: maps[i]['createTime'],
      );
    });
  }

//--------> sensor_events table handling

  Future<void> insertSensorEvent(SensorEvent sensorEvent) async {
    final db = await database;

    await db.insert(
      tableNameSensorEvents,
      sensorEvent.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<SensorEvent>> getSensorEvents() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameSensorEvents);

    return List.generate(maps.length, (i) {
      return SensorEvent(
        id: maps[i]['id'],
        hubID: maps[i]['hubID'],
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        event: maps[i]['event'],
        state: maps[i]['state'],
        updateTime: maps[i]['updateTime'],
        createTime: maps[i]['createTime'],
      );
    });
  }

  Future<void> updateSensorEvent(SensorEvent sensorEvent) async {
    final db = await database;

    await db.update(
      tableNameSensorEvents,
      sensorEvent.toMap(),
      where: "id = ?",
      whereArgs: [sensorEvent.id],
    );
  }

  Future<void> deleteSensorEvent(Int id) async {
    final db = await database;

    await db.delete(
      tableNameSensorEvents,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<SensorEvent>> findSensorEvent(Int id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameSensorEvents, where: 'id = ?', whereArgs: [id]);

    return List.generate(maps.length, (i) {
      return SensorEvent(
        id: maps[i]['id'],
        hubID: maps[i]['hubID'],
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        event: maps[i]['event'],
        state: maps[i]['state'],
        updateTime: maps[i]['updateTime'],
        createTime: maps[i]['createTime'],
      );
    });
  }
}
