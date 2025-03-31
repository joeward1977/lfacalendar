import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterdatabase/main.dart';
import 'package:flutterdatabase/models/period.dart';
import 'package:flutterdatabase/models/schedule.dart';

class DatabaseService {
  List<Period> allPeriods = [];
  List<Schedule> allSchedules = [];

  DatabaseService();

  // Populate list of all teams from Firestore
  Future scheduleListFromSnapshot() async {
    QuerySnapshot snapshot = await firestoreDB.collection("users").get();
    allSchedules = snapshot.docs.map((theMap) {
      return Schedule(periods: Schedule.mapToPeriodsList(theMap['periods']));
    }).toList();
  }

  // Populate list of all players from everyteam
  Future getAllPeriods() async {
    allPeriods = [];
    await scheduleListFromSnapshot();
    for (Schedule curSchedule in allSchedules) {
      allPeriods.addAll(curSchedule.periods);
    }
  }
}
