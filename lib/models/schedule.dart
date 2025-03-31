import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import 'package:flutterdatabase/models/period.dart';

var uuid = const Uuid();

class Schedule {
  List<Period> periods;

  Schedule({
    required this.periods,
  });

  Schedule.newSchedule() : this(periods: []);

  Period? getPeriod(String id) {
    for (Period cur in periods) {
      if (cur.id == id) {
        return cur;
      }
    }
    return null;
  }

  void addPeriod() {
    periods.add(Period(uuid.v1()));
  }

  void addAllPeriod() {
    if (periods.isEmpty) {
      periods.clear();
      for (int i = 0; i < 56; i++) {
        periods.add(Period(uuid.v4()));
      }
    }
  }

  void deletePeriods(List<String> ids) {
    for (String id in ids) {
      periods.remove(getPeriod(id));
    }
  }

  // Methods to convert team data to Map
  Map<String, dynamic> toMap() {
    return {
      "periods": periodsToMap(),
    };
  }

  List<Map> periodsToMap() {
    List<Map> periodsMap = [];
    for (int i = 0; i < periods.length; i++) {
      periodsMap.add(periods[i].toMap());
    }
    return periodsMap;
  }

  // Methods to get a Team object from Firestore Map Data
  static Schedule fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    final data = snapshot.data();
    return Schedule(periods: mapToPeriodsList(data?['periods']));
  }

  static List<Period> mapToPeriodsList(List<dynamic> periodMaps) {
    List<Period> thePeriods = [];
    for (var map in periodMaps) {
      thePeriods.add(Period.mapToObject(map));
    }
    return thePeriods;
  }
}
