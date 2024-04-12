import 'dart:ffi';

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:argoscareseniorsafeguard/constants.dart';

import 'package:argoscareseniorsafeguard/models/device.dart';
import 'package:argoscareseniorsafeguard/models/hub.dart';
import 'package:argoscareseniorsafeguard/models/sensor.dart';
import 'package:argoscareseniorsafeguard/models/sensor_event.dart';
import 'package:argoscareseniorsafeguard/models/location.dart';
import 'package:argoscareseniorsafeguard/models/room.dart';
import 'package:argoscareseniorsafeguard/models/event_list.dart';

const String databaseName = 'ArgosCareSeniorSafeGuard.db';
const String tableNameDevices = 'devices';
const String tableNameHubs = 'hubs';
const String tableNameSensors = 'sensors';
const String tableNameSensorEvents = 'sensorEvents';
const String tableNameLocations = 'locations';
const String tableNameRooms = 'rooms';

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
        "status TEXT, "
        "createdAt TEXT, "
        "updatedAt TEXT"
      ")",
    );

    await db.execute(
      "CREATE TABLE $tableNameHubs ("
        "id TEXT PRIMARY KEY, "
        "hubID TEXT, "
        "name TEXT, "
        "displaySunBun INTEGER, "
        "category TEXT, "
        "deviceType TEXT, "
        "hasSubDevices BOOLEAN, "
        "modelName TEXT, "
        "online BOOLEAN, "
        "status TEXT, "
        "battery INTEGER, "
        "isUse BOOLEAN, "
        "createdAt TEXT, "
        "updatedAt TEXT "
      ")",
    );

    await db.execute(
      "CREATE TABLE $tableNameSensors ("
        "id TEXT PRIMARY KEY, "
        "sensorID TEXT, "
        "name TEXT, "
        "displaySunBun INTEGER, "
        "category TEXT,"
        "deviceType TEXT, "
        "modelName TEXT, "
        "online BOOLEAN, "
        "status TEXT, "
        "battery INTEGER, "
        "isUse BOOLEAN, "
        "createdAt TEXT, "
        "updatedAt TEXT, "
        "hubID TEXT"
      ")",
    );

    await db.execute(
      "CREATE TABLE $tableNameSensorEvents ("
      "id TEXT PRIMARY KEY, "
      "hubID TEXT, "
      "deviceID TEXT, "
      "deviceType TEXT, "
      "event TEXT, "
      "status TEXT, "
      "humi INTEGER, "
      "temp DOUBLE, "
      "createdAt TEXT, "
      "updatedAt TEXT"
      ")",
    );

    await db.execute(
      "CREATE TABLE $tableNameLocations ("
        "id TEXT PRIMARY KEY, "
        "name TEXT, "
        "sensorID TEXT, "
        "createdAt TEXT, "
        "updatedAt TEXT"
      ")",
    );

    await db.execute(
      "CREATE TABLE $tableNameRooms ("
        "id TEXT PRIMARY KEY, "
        "name TEXT, "
        "locationID TEXT, "
        "createdAt TEXT, "
        "updatedAt TEXT"
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
        status: maps[i]['status'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
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
        status: maps[i]['status'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
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
        status: maps[i]['status'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
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
        status: maps[i]['status'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
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
        status: maps[i]['status'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
      );
    });
  }

  Future<List<Map<String, dynamic>>> getDeviceByGroup() async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameDevices, columns: ['deviceType'], groupBy: 'deviceType', orderBy: 'createdAt ASC');

    return maps;
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
        id: maps[i]['id'],
        hubID: maps[i]['hubID'],
        name: maps[i]['name'],
        displaySunBun: maps[i]['displaySunBun'],
        category: maps[i]['category'],
        deviceType: maps[i]['deviceType'],
        hasSubDevices: maps[i]['hasSubDevices'],
        modelName: maps[i]['modelName'],
        online: maps[i]['online'],
        status: maps[i]['status'],
        battery: maps[i]['battery'],
        isUse: maps[i]['isUse'],
        createdAt: maps[i]['createdAt'],
        updatedAt: maps[i]['updatedAt'],

      );
    });
  }

  Future<void> updateHub(Hub hub) async {
    final db = await database;

    await db.update(
      tableNameHubs,
      hub.toMap(),
      where: "hubID = ?",
      whereArgs: [hub.hubID],
    );
  }

  Future<void> deleteHub(String hubID) async {
    final db = await database;

    await db.delete(
      tableNameHubs,
      where: "hubID = ?",
      whereArgs: [hubID],
    );
  }

  Future<List<Hub>> findHub(String hubID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameHubs, where: 'hubID = ?', whereArgs: [hubID]);

    return List.generate(maps.length, (i) {
      return Hub(
        id: maps[i]['id'],
        hubID: maps[i]['hubID'],
        name: maps[i]['name'],
        displaySunBun: maps[i]['displaySunBun'],
        category: maps[i]['category'],
        deviceType: maps[i]['deviceType'],
        hasSubDevices: maps[i]['hasSubDevices'],
        modelName: maps[i]['modelName'],
        online: maps[i]['online'],
        status: maps[i]['status'],
        battery: maps[i]['battery'],
        isUse: maps[i]['isUse'],
        createdAt: maps[i]['createdAt'],
        updatedAt: maps[i]['updatedAt'],
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
        id: maps[i]['id'],
        sensorID: maps[i]['sensorID'],
        name: maps[i]['name'],
        displaySunBun: maps[i]['displaySunBun'],
        category: maps[i]['category'],
        deviceType: maps[i]['deviceType'],
        modelName: maps[i]['modelName'],
        online: maps[i]['online'],
        status: maps[i]['status'],
        battery: maps[i]['battery'],
        isUse: maps[i]['isUse'],
        createdAt: maps[i]['createdAt'],
        updatedAt: maps[i]['updatedAt'],
        hubID: maps[i]['hubID'],
      );
    });
  }

  Future<void> updateSensor(Sensor sensor) async {
    final db = await database;

    await db.update(
      tableNameSensors,
      sensor.toMap(),
      where: "sensorID = ?",
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
    await db.query(tableNameSensors, where: 'sensorID = ?', whereArgs: [sensorID]);

    return List.generate(maps.length, (i) {
      return Sensor(
        id: maps[i]['id'],
        sensorID: maps[i]['sensorID'],
        name: maps[i]['name'],
        displaySunBun: maps[i]['displaySunBun'],
        category: maps[i]['category'],
        deviceType: maps[i]['deviceType'],
        modelName: maps[i]['modelName'],
        online: maps[i]['online'],
        status: maps[i]['status'],
        battery: maps[i]['battery'],
        isUse: maps[i]['isUse'],
        createdAt: maps[i]['createdAt'],
        updatedAt: maps[i]['updatedAt'],
        hubID: maps[i]['hubID'],
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
        status: maps[i]['status'],
        humi: maps[i]['humi'],
        temp: maps[i]['temp'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
      );
    });
  }

  Future<List<SensorEvent>> getSensorEventsByDeviceType(String deviceType, String date) async {
    final db = await database;

    String start = '$date 00:00:00.000000';
    String end = '$date 23:59:59.999999';

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameSensorEvents, where: 'deviceType = ? AND createdAt >= ? AND createdAt <= ?', whereArgs: [deviceType, start, end], orderBy: 'createdAt DESC');

    return List.generate(maps.length, (i) {
      return SensorEvent(
        id: maps[i]['id'],
        hubID: maps[i]['hubID'],
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        event: maps[i]['event'],
        status: maps[i]['status'],
        humi: maps[i]['humi'],
        temp: maps[i]['temp'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
      );
    });
  }

  Future<List<SensorEvent>> getSensorEventsByDate(String date) async {
    final db = await database;

    String start = '$date 00:00:00.000000';
    String end = '$date 23:59:59.999999';

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameSensorEvents, where: 'createdAt >= ? AND createdAt <= ?', whereArgs: [start, end], orderBy: 'createdAt DESC');

    return List.generate(maps.length, (i) {
      return SensorEvent(
        id: maps[i]['id'],
        hubID: maps[i]['hubID'],
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        event: maps[i]['event'],
        status: maps[i]['status'],
        humi: maps[i]['humi'],
        temp: maps[i]['temp'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
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
        status: maps[i]['status'],
        humi: maps[i]['humi'],
        temp: maps[i]['temp'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
      );
    });
  }

  Future <List<SensorEvent>> findSensorLast(String deviceType) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameSensorEvents, where: 'deviceType = ?', whereArgs: [deviceType], limit: 1);

    return List.generate(maps.length, (i) {
      return SensorEvent(
        id: maps[i]['id'],
        hubID: maps[i]['hubID'],
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        event: maps[i]['event'],
        status: maps[i]['status'],
        humi: maps[i]['humi'],
        temp: maps[i]['temp'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
      );
    });
  }


  //--------> locations table handling

  Future<void> insertLocation(Location location) async {
    final db = await database;

    await db.insert(
      tableNameLocations,
      location.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Location>> getLocations() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameLocations);

    return List.generate(maps.length, (i) {
      return Location(
        id: maps[i]['id'],
        name: maps[i]['name'],
        sensorID: maps[i]['sensorID'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
      );
    });
  }

  Future<void> updateLocation(Location location) async {
    final db = await database;

    await db.update(
      tableNameLocations,
      location.toMap(),
      where: "id = ?",
      whereArgs: [location.id],
    );
  }

  Future<void> deleteLocation(Int id) async {
    final db = await database;

    await db.delete(
      tableNameLocations,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<Location>> findLocation(Int id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameLocations, where: 'id = ?', whereArgs: [id]);

    return List.generate(maps.length, (i) {
      return Location(
          id: maps[i]['id'],
          name: maps[i]['name'],
          sensorID: maps[i]['sensorID'],
          createdAt: maps[i]['createdAt'],
          updatedAt: maps[i]['updatedAt']
      );
    });
  }

  //--------> Room table handling

  Future<void> insertRoom(Room room) async {
    final db = await database;

    await db.insert(
      tableNameRooms,
      room.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Room>> getRoom() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameRooms);

    return List.generate(maps.length, (i) {
      return Room(
        id: maps[i]['id'],
        name: maps[i]['name'],
        locationID: maps[i]['locationID'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
      );
    });
  }

  Future<void> updateRoom(Room room) async {
    final db = await database;

    await db.update(
      tableNameRooms,
      room.toMap(),
      where: "id = ?",
      whereArgs: [room.id],
    );
  }

  Future<void> deleteRoom(Int id) async {
    final db = await database;

    await db.delete(
      tableNameRooms,
      where: "id = ?",
      whereArgs: [id],
    );
  }

  Future<List<Room>> findRoom(Int id) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameRooms, where: 'id = ?', whereArgs: [id]);

    return List.generate(maps.length, (i) {
      return Room(
          id: maps[i]['id'],
          name: maps[i]['name'],
          locationID: maps[i]['locationID'],
          createdAt: maps[i]['createdAt'],
          updatedAt: maps[i]['updatedAt']
      );
    });
  }

  //=====================================

  Future<List<EventList>> getEventList(String date) async {
    final db = await database;

    String start = '$date 00:00:00.000000';
    String end = '$date 23:59:59.999999';

    List<Map<String, dynamic>> maps = await db.rawQuery(
      "SELECT "
          "sensorEvents.hubID, sensorEvents.deviceID, sensorEvents.deviceType, sensorEvents.event, sensorEvents.status, sensorEvents.createdAt, sensors.Name FROM sensorEvents "
          "INNER JOIN sensors ON sensorEvents.deviceID = sensors.sensorID "
          "WHERE sensorEvents.createdAt >= '$start' AND sensorEvents.createdAt <= '$end' "
          "ORDER BY sensorEvents.createdAt DESC"
    );

    return List.generate(maps.length, (i) {
      return EventList(
        hubID: maps[i]['hubID'],
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        event: maps[i]['event'],
        status: maps[i]['status'],
        createdAt: maps[i]['createdAt'],
        name: maps[i]['name'],
      );
    });
  }
}
