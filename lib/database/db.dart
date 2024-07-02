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
import 'package:argoscareseniorsafeguard/models/airplaneday.dart';
import 'package:argoscareseniorsafeguard/models/airplanetime.dart';
import 'package:uuid/uuid.dart';
import 'package:intl/intl.dart';

const String databaseName = 'ArgosCareSeniorSafeGuard.db';
const String tableNameDevices = 'devices';
const String tableNameHubs = 'hubs';
const String tableNameSensors = 'sensors';
const String tableNameSensorEvents = 'sensorEvents';
const String tableNameLocations = 'locations';
const String tableNameRooms = 'rooms';

const String tableNameAirPlaneDay = 'airplaneDay';
const String tableNameAirPlaneTime = 'airplaneTime';

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
          "userID TEXT, "
          "status TEXT, "
          "shared BOOLEAN, "
          "ownerID TEXT, "
          "ownerName TEXT, "
          "createdAt TEXT, "
          "updatedAt TEXT"
          ")",
    );

    await db.execute(
      "CREATE TABLE $tableNameHubs ("
          "id TEXT PRIMARY KEY, "
          "hubID TEXT, "
          "name TEXT, "
          "userID TEXT, "
          "displaySunBun INTEGER, "
          "category TEXT, "
          "deviceType TEXT, "
          "hasSubDevices BOOLEAN, "
          "modelName TEXT, "
          "online BOOLEAN, "
          "status TEXT, "
          "battery INTEGER, "
          "isUse BOOLEAN, "
          "shared BOOLEAN, "
          "ownerID TEXT, "
          "ownerName TEXT, "
          "createdAt TEXT, "
          "updatedAt TEXT "
          ")",
    );

    await db.execute(
      "CREATE TABLE $tableNameSensors ("
          "id TEXT PRIMARY KEY, "
          "sensorID TEXT, "
          "name TEXT, "
          "userID TEXT, "
          "displaySunBun INTEGER, "
          "category TEXT,"
          "deviceType TEXT, "
          "modelName TEXT, "
          "online BOOLEAN, "
          "status TEXT, "
          "battery INTEGER, "
          "isUse BOOLEAN, "
          "shared BOOLEAN, "
          "ownerID TEXT, "
          "ownerName TEXT, "
          "createdAt TEXT, "
          "updatedAt TEXT, "
          "hubID TEXT"
          ")",
    );

    await db.execute(
      "CREATE TABLE $tableNameSensorEvents ("
          "id TEXT PRIMARY KEY, "
          "hubID TEXT, "
          "userID TEXT, "
          "deviceID TEXT, "
          "deviceType TEXT, "
          "event TEXT, "
          "status TEXT, "
          "humi INTEGER, "
          "temp REAL, "
          "shared BOOLEAN, "
          "ownerID TEXT, "
          "ownerName TEXT, "
          "createdAt TEXT, "
          "updatedAt TEXT"
          ")",
    );

    await db.execute(
      "CREATE TABLE $tableNameLocations ("
          "id TEXT PRIMARY KEY, "
          "name TEXT, "
          "userID TEXT, "
          "sensorID TEXT, "
          "shared BOOLEAN, "
          "ownerID TEXT, "
          "ownerName TEXT, "
          "createdAt TEXT, "
          "updatedAt TEXT"
          ")",
    );

    await db.execute(
      "CREATE TABLE $tableNameRooms ("
          "id TEXT PRIMARY KEY, "
          "name TEXT, "
          "userID TEXT, "
          "locationID TEXT, "
          "shared BOOLEAN, "
          "ownerID TEXT, "
          "ownerName TEXT, "
          "createdAt TEXT, "
          "updatedAt TEXT"
          ")",
    );

    await db.execute(
      "CREATE TABLE $tableNameAirPlaneDay ("
          "id TEXT PRIMARY KEY, "
          "dayName TEXT, "
          "enable BOOLEAN"
          ")",
    );

    await db.execute(
      "CREATE TABLE $tableNameAirPlaneTime ("
          "id TEXT PRIMARY KEY, "
          "startTime TEXT, "
          "endTime TEXT, "
          "createdAt TEXT"
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

  Future<List<Device>> getDevices(String userID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameDevices, where: 'userID = ?', whereArgs: [userID], orderBy: 'displaySunBun ASC');

    return List.generate(maps.length, (i) {
      return Device(
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        deviceName: maps[i]['deviceName'],
        displaySunBun: maps[i]['displaySunBun'],
        userID: maps[i]['userID'],
        status: maps[i]['status'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
      );
    });
  }

  Future<List<Device>> getDeviceOfHubs(String userID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameDevices, where: 'userID = ? AND deviceType = ?', whereArgs: [userID, Constants.DEVICE_TYPE_HUB]);

    return List.generate(maps.length, (i) {
      return Device(
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        deviceName: maps[i]['deviceName'],
        displaySunBun: maps[i]['displaySunBun'],
        userID: maps[i]['userID'],
        status: maps[i]['status'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
      );
    });
  }

  Future<List<Device>> getDeviceExpectHubs(String userID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameDevices, where: 'userID = ? AND deviceType <> ?', whereArgs: [userID, Constants.DEVICE_TYPE_HUB]);

    return List.generate(maps.length, (i) {
      return Device(
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        deviceName: maps[i]['deviceName'],
        displaySunBun: maps[i]['displaySunBun'],
        userID: maps[i]['userID'],
        status: maps[i]['status'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
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

  Future<List<Device>> findDevice(String userID, String deviceID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameDevices, where: 'userID = ? AND deviceID = ?', whereArgs: [userID, deviceID]);

    return List.generate(maps.length, (i) {
      return Device(
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        deviceName: maps[i]['deviceName'],
        displaySunBun: maps[i]['displaySunBun'],
        userID: maps[i]['userID'],
        status: maps[i]['status'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
      );
    });
  }

  Future<List<Device>> findDeviceBySensor(String userID, String deviceType) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameDevices, where: 'userID = ? AND deviceType = ?', whereArgs: [userID, deviceType]);

    return List.generate(maps.length, (i) {
      return Device(
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        deviceName: maps[i]['deviceName'],
        displaySunBun: maps[i]['displaySunBun'],
        userID: maps[i]['userID'],
        status: maps[i]['status'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
      );
    });
  }

  Future<List<Map<String, dynamic>>> getDeviceByGroup(String userID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameDevices, where: 'userID = ?',
        whereArgs: [userID],
        columns: ['deviceType'],
        groupBy: 'deviceType',
        orderBy: 'createdAt ASC');

    return maps;
  }

  Future<int?> getDeviceCountByType(String userID, String deviceType) async {
    final db = await database;
    var x = await db.rawQuery("SELECT COUNT (*) from $tableNameDevices WHERE userID = '$userID' AND deviceType = '$deviceType'");
    int? count = Sqflite.firstIntValue(x);
    return count;
  }

  Future<int?> getDeviceCount(String userID) async {
    final db = await database;
    var x = await db.rawQuery("SELECT COUNT (*) from $tableNameDevices WHERE userID = '$userID'");
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
        userID: maps[i]['userID'],
        displaySunBun: maps[i]['displaySunBun'],
        category: maps[i]['category'],
        deviceType: maps[i]['deviceType'],
        hasSubDevices: maps[i]['hasSubDevices'],
        modelName: maps[i]['modelName'],
        online: maps[i]['online'],
        status: maps[i]['status'],
        battery: maps[i]['battery'],
        isUse: maps[i]['isUse'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
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

  Future<List<Hub>> findHub(String userID, String hubID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameHubs, where: 'hubID = ? AND userID = ?', whereArgs: [hubID, userID]);

    return List.generate(maps.length, (i) {
      return Hub(
        id: maps[i]['id'],
        hubID: maps[i]['hubID'],
        name: maps[i]['name'],
        userID: maps[i]['userID'],
        displaySunBun: maps[i]['displaySunBun'],
        category: maps[i]['category'],
        deviceType: maps[i]['deviceType'],
        hasSubDevices: maps[i]['hasSubDevices'],
        modelName: maps[i]['modelName'],
        online: maps[i]['online'],
        status: maps[i]['status'],
        battery: maps[i]['battery'],
        isUse: maps[i]['isUse'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
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

  Future<List<Sensor>> getSensors(String userID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameSensors, where: 'userID = ?', whereArgs: [userID]);

    return List.generate(maps.length, (i) {
      return Sensor(
        id: maps[i]['id'],
        sensorID: maps[i]['sensorID'],
        name: maps[i]['name'],
        userID: maps[i]['userID'],
        displaySunBun: maps[i]['displaySunBun'],
        category: maps[i]['category'],
        deviceType: maps[i]['deviceType'],
        modelName: maps[i]['modelName'],
        online: maps[i]['online'],
        status: maps[i]['status'],
        battery: maps[i]['battery'],
        isUse: maps[i]['isUse'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
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

  Future<List<Sensor>> findSensor(String userID, String sensorID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameSensors, where: 'userID = ? AND sensorID = ?', whereArgs: [userID, sensorID]);

    return List.generate(maps.length, (i) {
      return Sensor(
        id: maps[i]['id'],
        sensorID: maps[i]['sensorID'],
        name: maps[i]['name'],
        userID: maps[i]['userID'],
        displaySunBun: maps[i]['displaySunBun'],
        category: maps[i]['category'],
        deviceType: maps[i]['deviceType'],
        modelName: maps[i]['modelName'],
        online: maps[i]['online'],
        status: maps[i]['status'],
        battery: maps[i]['battery'],
        isUse: maps[i]['isUse'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
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

  Future<List<SensorEvent>> getSensorEvents(String userID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameSensorEvents, where: 'userID = ? ', whereArgs: [userID]);

    return List.generate(maps.length, (i) {
      return SensorEvent(
        id: maps[i]['id'],
        hubID: maps[i]['hubID'],
        userID: maps[i]['userID'],
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        event: maps[i]['event'],
        status: maps[i]['status'],
        humi: maps[i]['humi'],
        temp: maps[i]['temp'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
      );
    });
  }

  Future<List<SensorEvent>> getSensorEventsByDeviceType(String userID, String deviceType, String date) async {
    final db = await database;

    String start = '$date 00:00:00.000000';
    String end = '$date 23:59:59.999999';

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameSensorEvents, where: 'userID = ? AND deviceType = ? AND createdAt >= ? AND createdAt <= ?', whereArgs: [userID, deviceType, start, end], orderBy: 'createdAt DESC');

    return List.generate(maps.length, (i) {
      return SensorEvent(
        id: maps[i]['id'],
        hubID: maps[i]['hubID'],
        userID: maps[i]['userID'],
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        event: maps[i]['event'],
        status: maps[i]['status'],
        humi: maps[i]['humi'],
        temp: maps[i]['temp'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
      );
    });
  }

  Future<List<SensorEvent>> getSensorEventsByDate(String userID, String date) async {
    final db = await database;

    String start = '$date 00:00:00.000000';
    String end = '$date 23:59:59.999999';

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameSensorEvents, where: 'userID = ? AND createdAt >= ? AND createdAt <= ?', whereArgs: [userID, start, end], orderBy: 'createdAt DESC');

    return List.generate(maps.length, (i) {
      return SensorEvent(
        id: maps[i]['id'],
        hubID: maps[i]['hubID'],
        userID: maps[i]['userID'],
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        event: maps[i]['event'],
        status: maps[i]['status'],
        humi: maps[i]['humi'],
        temp: maps[i]['temp'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
      );
    });
  }

  Future<List<SensorEvent>> getSensorEventsByDeviceOnlyOne(String deviceID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameSensorEvents, where: 'deviceID = ?', whereArgs: [deviceID], orderBy: 'createdAt DESC', limit: 1);

    return List.generate(maps.length, (i) {
      return SensorEvent(
        id: maps[i]['id'],
        hubID: maps[i]['hubID'],
        userID: maps[i]['userID'],
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        event: maps[i]['event'],
        status: maps[i]['status'],
        humi: maps[i]['humi'],
        temp: maps[i]['temp'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
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

  Future<List<SensorEvent>> findSensorEvent(Int id, String userID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameSensorEvents, where: 'id = ? AND userID = ?', whereArgs: [id, userID]);

    return List.generate(maps.length, (i) {
      return SensorEvent(
        id: maps[i]['id'],
        hubID: maps[i]['hubID'],
        userID: maps[i]['userID'],
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        event: maps[i]['event'],
        status: maps[i]['status'],
        humi: maps[i]['humi'],
        temp: maps[i]['temp'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
        updatedAt: maps[i]['updatedAt'],
        createdAt: maps[i]['createdAt'],
      );
    });
  }

  Future <List<SensorEvent>> findSensorLast(String userID, String deviceType) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameSensorEvents, where: 'userID = ? AND deviceType = ?', whereArgs: [userID, deviceType], limit: 1);

    return List.generate(maps.length, (i) {
      return SensorEvent(
        id: maps[i]['id'],
        hubID: maps[i]['hubID'],
        userID: maps[i]['userID'],
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        event: maps[i]['event'],
        status: maps[i]['status'],
        humi: maps[i]['humi'],
        temp: maps[i]['temp'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
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

  Future<List<Location>> getLocations(String userID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameLocations, where: 'userID = ?', whereArgs: [userID]);

    return List.generate(maps.length, (i) {
      return Location(
        id: maps[i]['id'],
        name: maps[i]['name'],
        userID: maps[i]['userID'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
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

  Future<List<Location>> findLocation(Int id, String userID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameLocations, where: 'id = ? AND userID = ?', whereArgs: [id, userID]);

    return List.generate(maps.length, (i) {
      return Location(
          id: maps[i]['id'],
          name: maps[i]['name'],
          userID: maps[i]['userID'],
          shared: maps[i]['shared'],
          ownerID: maps[i]['ownerID'],
          ownerName: maps[i]['ownerName'],
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

  Future<List<Room>> getRoom(String userID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameRooms, where: 'userID = ?', whereArgs: [userID]);

    return List.generate(maps.length, (i) {
      return Room(
        id: maps[i]['id'],
        name: maps[i]['name'],
        userID: maps[i]['userID'],
        shared: maps[i]['shared'],
        ownerID: maps[i]['ownerID'],
        ownerName: maps[i]['ownerName'],
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

  Future<List<Room>> findRoom(Int id, String userID) async {
    final db = await database;

    final List<Map<String, dynamic>> maps =
    await db.query(tableNameRooms, where: 'id = ? AND userID = ?', whereArgs: [id, userID]);

    return List.generate(maps.length, (i) {
      return Room(
          id: maps[i]['id'],
          name: maps[i]['name'],
          userID: maps[i]['userID'],
          shared: maps[i]['shared'],
          ownerID: maps[i]['ownerID'],
          ownerName: maps[i]['ownerName'],
          locationID: maps[i]['locationID'],
          createdAt: maps[i]['createdAt'],
          updatedAt: maps[i]['updatedAt']
      );
    });
  }

  //=====================================

  Future<List<EventList>> getEventList2(String date, List<String> sensors) async {
    final db = await database;

    String start = '$date 00:00:00.000000';
    String end = '$date 23:59:59.999999';

    String where = "";
    for (String id in sensors) {
      where = "$where OR deviceID = '$id'";
    }
    where = "$where AND createdAt >= '$start' AND createdAt <= '$end'";
    where = where.substring(4);

    //첫번째 " AND"앞에 ")" 넣기
    where = where.replaceFirst(" AND", ") AND");
    String sql = "SELECT * FROM sensorEvents WHERE ($where ORDER BY createdAt DESC";

    List<Map<String, dynamic>> maps = await db.rawQuery(
        sql
    );

    return List.generate(maps.length, (i) {
      return EventList(
        hubID: maps[i]['hubID'],
        userID: maps[i]['userID'],
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        event: maps[i]['event'],
        status: maps[i]['status'],
        createdAt: maps[i]['createdAt'],
        name: maps[i]['name'],
      );
    });
  }

  Future<List<EventList>> getEventList3(String date) async {
    final db = await database;

    String start = '$date 00:00:00.000000';
    String end = '$date 23:59:59.999999';

    String sql = "SELECT * FROM sensorEvents WHERE createdAt >= '$start' AND createdAt <= '$end' ORDER BY createdAt DESC";

    List<Map<String, dynamic>> maps = await db.rawQuery(
        sql
    );

    return List.generate(maps.length, (i) {
      return EventList(
        hubID: maps[i]['hubID'],
        userID: maps[i]['userID'],
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        event: maps[i]['event'],
        status: maps[i]['status'],
        createdAt: maps[i]['createdAt'],
        name: maps[i]['name'],
      );
    });
  }


  Future<List<EventList>> getEventList(String date, String userID) async {
    final db = await database;

    String start = '$date 00:00:00.000000';
    String end = '$date 23:59:59.999999';

    List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT "
            "sensorEvents.userID, sensorEvents.hubID, sensorEvents.deviceID, sensorEvents.deviceType, sensorEvents.event, sensorEvents.status, sensorEvents.createdAt, sensors.Name FROM sensorEvents "
            "INNER JOIN sensors ON sensorEvents.deviceID = sensors.sensorID "
            "WHERE sensorEvents.createdAt >= '$start' AND sensorEvents.createdAt <= '$end' AND sensorEvents.userID = '$userID' "
            "ORDER BY sensorEvents.createdAt DESC"
    );

    return List.generate(maps.length, (i) {
      return EventList(
        hubID: maps[i]['hubID'],
        userID: maps[i]['userID'],
        deviceID: maps[i]['deviceID'],
        deviceType: maps[i]['deviceType'],
        event: maps[i]['event'],
        status: maps[i]['status'],
        createdAt: maps[i]['createdAt'],
        name: maps[i]['name'],
      );
    });
  }

  Future<void> initAirplaneDayTable() async {
    final db = await database;

    var result = await db.rawQuery('SELECT COUNT(*) FROM $tableNameAirPlaneDay');
    int? count = Sqflite.firstIntValue(result);
    if (count == 0) {
      var uuid = const Uuid();
      await db.rawInsert("INSERT INTO $tableNameAirPlaneDay(id, dayName, enable) VALUES('${uuid.v4()}', 'Sun', FALSE)");
      await db.rawInsert("INSERT INTO $tableNameAirPlaneDay(id, dayName, enable) VALUES('${uuid.v4()}', 'Mon', FALSE)");
      await db.rawInsert("INSERT INTO $tableNameAirPlaneDay(id, dayName, enable) VALUES('${uuid.v4()}', 'Tue', FALSE)");
      await db.rawInsert("INSERT INTO $tableNameAirPlaneDay(id, dayName, enable) VALUES('${uuid.v4()}', 'Wed', FALSE)");
      await db.rawInsert("INSERT INTO $tableNameAirPlaneDay(id, dayName, enable) VALUES('${uuid.v4()}', 'Thu', FALSE)");
      await db.rawInsert("INSERT INTO $tableNameAirPlaneDay(id, dayName, enable) VALUES('${uuid.v4()}', 'Fri', FALSE)");
      await db.rawInsert("INSERT INTO $tableNameAirPlaneDay(id, dayName, enable) VALUES('${uuid.v4()}', 'Sat', FALSE)");
    }
  }

  Future<void> updateAirplaneDayTable(bool sun, bool mon, bool tue, bool wed, bool thu, bool fri, bool sat) async {
    final db = await database;

    await db.rawUpdate("UPDATE $tableNameAirPlaneDay SET enable = ? WHERE dayName = 'Sun'", [sun ? 1 : 0]);
    await db.rawUpdate("UPDATE $tableNameAirPlaneDay SET enable = ? WHERE dayName = 'Mon'", [mon ? 1 : 0]);
    await db.rawUpdate("UPDATE $tableNameAirPlaneDay SET enable = ? WHERE dayName = 'Tue'", [tue ? 1 : 0]);
    await db.rawUpdate("UPDATE $tableNameAirPlaneDay SET enable = ? WHERE dayName = 'Wed'", [wed ? 1 : 0]);
    await db.rawUpdate("UPDATE $tableNameAirPlaneDay SET enable = ? WHERE dayName = 'Thu'", [thu ? 1 : 0]);
    await db.rawUpdate("UPDATE $tableNameAirPlaneDay SET enable = ? WHERE dayName = 'Fri'", [fri ? 1 : 0]);
    await db.rawUpdate("UPDATE $tableNameAirPlaneDay SET enable = ? WHERE dayName = 'Sat'", [sat ? 1 : 0]);
  }

  Future<List<AirplaneDay>> getAirplaneDays() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameAirPlaneDay);

    return List.generate(maps.length, (i) {
      return AirplaneDay(
        id: maps[i]['id'],
        dayName: maps[i]['dayName'],
        enable: maps[i]['enable'],
      );
    });
  }

  Future<void> insertAirplaneTime(String startTime, String endTime) async {
    final db = await database;

    String now = DateFormat("yyyy-MM-dd hh:mm:ss").format(DateTime.now());
    var uuid = const Uuid();
    await db.rawInsert("INSERT INTO $tableNameAirPlaneTime(id, startTime, endTime, createdAt) VALUES('${uuid.v4()}', '$startTime', '$endTime', '$now')");
  }

  Future<List<AirplaneTime>> getAirplaneTimes() async {
    final db = await database;

    final List<Map<String, dynamic>> maps = await db.query(tableNameAirPlaneTime, orderBy: 'createdAt ASC');

    return List.generate(maps.length, (i) {
      return AirplaneTime(
        id: maps[i]['id'],
        startTime: maps[i]['startTime'],
        endTime: maps[i]['endTime'],
        createdAt: maps[i]['createdAt']
      );
    });
  }

  Future<List<AirplaneTime>> deleteAirplaneTimeTable(String id) async {
    final db = await database;

    await db.delete(tableNameAirPlaneTime, where: 'id = ?', whereArgs: [id]);

    final List<Map<String, dynamic>> maps = await db.query(tableNameAirPlaneTime);

    return List.generate(maps.length, (i) {
      return AirplaneTime(
          id: maps[i]['id'],
          startTime: maps[i]['startTime'],
          endTime: maps[i]['endTime'],
          createdAt: maps[i]['createdAt']
      );
    });
  }

  Future<void> emptyAirplaneTimeTable() async {
    final db = await database;

    await db.rawDelete('DELETE from $tableNameAirPlaneTime');
  }
}
