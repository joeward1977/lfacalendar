import 'package:flutterdatabase/main.dart';
import 'package:flutterdatabase/models/period.dart';
import 'package:flutterdatabase/models/schedule.dart';
import 'package:csv/csv.dart';
import 'package:universal_html/html.dart' as html hide Text;
import 'dart:convert' show utf8;
import 'package:flutter/services.dart' show rootBundle;

class Person {
  final String uid;
  late Schedule schedule = Schedule.newSchedule();
  List<Period> yearPeriods = [];
  List<bool> dubs = [false, false, false, false, false, false, false, false];
  bool wantsFreePeriods = false;
  bool wantsAdvisory = false;
  bool wantsMM = false;
  bool wantsASM = false;
  bool wantsBreaks = false;
  bool wantsPeriodHeadings = false;

  Person({required this.uid});
  List<List<int>> bands = [
    [0, 9, 16, 30, 46, 49],
    [1, 8, 18, 38, 47, 52],
    [2, 22, 28, 33, 40, 50],
    [3, 11, 20, 36, 42, 53],
    [4, 12, 21, 29, 34, 44],
    [5, 13, 19, 27, 45, 51],
    [6, 10, 24, 37, 41, 25],
    [7, 14, 17, 26, 32, 48],
  ];

  List<int> doubles = [31, 39, 23, 43, 35, -1, 25, 15];

  void updatePeriods() {
    for (int i = 0; i < bands.length; i++) {
      for (int j = 0; j < bands[0].length; j++) {
        schedule.periods[bands[i][j]] = schedule.periods[i];
      }
    }
  }

  void fillYearPeriods() async {
    yearPeriods.clear();
    List<String> periodNumbers = await readClassColumn(0);
    List<String> dates = await readClassColumn(1);
    List<String> startTimes = await readClassColumn(2);
    List<String> endTimes = await readClassColumn(4);
    List<String> letterDays = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];
    for (int i = 0; i < 56; i++) {
      yearPeriods.add(Period.withData(
        id: schedule.periods[i].id,
        className: schedule.periods[i].className,
        roomName: schedule.periods[i].roomName,
        date: [],
        startTime: [],
        endTime: [],
      ));
    }

    for (int rows = 0; rows < periodNumbers.length; rows++) {
      if (periodNumbers[rows] == 'Advisory' ||
          periodNumbers[rows] == 'Morning Meeting' ||
          periodNumbers[rows] == 'Break' ||
          periodNumbers[rows] == 'All School Meeting') {
        continue;
      }
      for (int letterDayIndex = 0;
          letterDayIndex < letterDays.length;
          letterDayIndex++) {
        for (int period = 1; period <= 8; period++) {
          if (periodNumbers[rows] ==
              letterDays[letterDayIndex] + period.toString()) {
            int periodIndex = letterDayIndex * 8 + (period - 1);
            if (periodIndex < yearPeriods.length) {
              String periodHeading =
                  letterDays[letterDayIndex] + period.toString();
              if (wantsPeriodHeadings == true) {
                if (schedule.periods[periodIndex].className == '') {
                  yearPeriods[periodIndex].className = periodHeading;
                } else {
                  yearPeriods[periodIndex].className =
                      '$periodHeading - ${schedule.periods[periodIndex].className}';
                }
              }
              yearPeriods[periodIndex].date.add(dates[rows]);
              yearPeriods[periodIndex].startTime.add(startTimes[rows]);
              yearPeriods[periodIndex].endTime.add(endTimes[rows]);
            }
          }
        }
      }
    }
    if (wantsAdvisory == true) {
      await addPeriodType('Advisory', 'assets/adv.csv');
    }
    if (wantsMM == true) {
      await addPeriodType('Morning Meeting', 'assets/mm.csv');
    }
    if (wantsBreaks == true) {
      await addPeriodType('Break', 'assets/breaks.csv');
    }
    if (wantsASM == true) {
      await addPeriodType('All School Meeting', 'assets/asm.csv');
    }
    exportPeriodsToCSV(yearPeriods);
  }

  Future<void> addPeriodType(String className, String file) async {
    List<String> dates = await loadColumnFromCSV(file, 1);
    List<String> startTimes = await loadColumnFromCSV(file, 2);
    List<String> endTimes = await loadColumnFromCSV(file, 4);
    dates.removeAt(0);
    startTimes.removeAt(0);
    endTimes.removeAt(0);

    yearPeriods.add(Period.withData(
      id: uuid.v4(),
      className: className,
      roomName: '',
      date: dates,
      startTime: startTimes,
      endTime: endTimes,
    ));
  }

  void updateDoubles(bool wasChecked, int periodNum) {
    if (periodNum == 5) {
      return;
    }
    if (wasChecked) {
      schedule.periods[doubles[periodNum]] = schedule.periods[periodNum];
      updatePeriods();
    } else {
      schedule.periods[doubles[periodNum]] = schedule.periods[55];
      updatePeriods();
    }
  }

  void newSchedule(id) {
    for (int i = 0; i < 56; i++) {
      schedule.periods[i] = Period(id);
    }
  }

  void sendScheduleData() async {
    final docRef = firestoreDB
        .collection("users")
        .withConverter(
          fromFirestore: Schedule.fromFirestore,
          toFirestore: (Schedule schedule, options) => schedule.toMap(),
        )
        .doc(uid);
    await docRef.set(schedule);
    fillYearPeriods();
  }

  Future loadScheduleData() async {
    print("here");
    schedule.addAllPeriod();
    print(schedule.periods[0].className);
    updatePeriods();
    print(schedule.periods[0].className);
    final docRef = firestoreDB.collection("users").doc(uid).withConverter(
          fromFirestore: Schedule.fromFirestore,
          toFirestore: (Schedule schedule, _) => schedule.toMap(),
        );
    final docSnap = await docRef.get();
    schedule = docSnap.data()!;
  }

  Future<List<String>> loadColumnFromCSV(
      String fileName, int columnIndex) async {
    // Load CSV file from assets
    final csvData = await rootBundle.loadString(fileName);

    // Convert CSV data to a List of List of strings
    List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);

    // Extract the specific column
    List<String> columnData = [];
    for (var row in rows) {
      if (row.length > columnIndex) {
        columnData.add(row[columnIndex].toString());
      }
    }
    return columnData;
  }

  Future<List<String>> readClassColumn(int c) async {
    List<String> columnData = await loadColumnFromCSV('assets/classes.csv', c);
    return columnData;
  }

  void exportPeriodsToCSV(List<Period> yearPeriods) {
    List<List<String>> rows = [];

    rows.add([
      'Subject',
      'Start Date',
      'Start Time',
      'End Date',
      'End Time',
      '',
      '',
      'Location',
      ''
    ]);

    for (var period in yearPeriods) {
      for (int i = 0; i < period.date.length; i++) {
        if (!(wantsFreePeriods && period.className.length <= 2)) {
          rows.add([
            period.className,
            period.date[i],
            period.startTime[i],
            period.date[i],
            period.endTime[i],
            '',
            '',
            period.roomName,
            ''
          ]);
        }
      }
    }

    // Convert rows to CSV
    String csvData = const ListToCsvConverter().convert(rows);

    // Encode the CSV data in UTF-8
    final bytes = utf8.encode(csvData);

    // Create a downloadable Blob from the CSV data
    final blob = html.Blob([bytes]);

    // Create a URL for the Blob
    final url = html.Url.createObjectUrlFromBlob(blob);

    // Create a hidden anchor element to trigger the download
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = 'PeriodsSchedule.csv';

    // Append the anchor to the document body
    html.document.body?.append(anchor);

    // Trigger the download by calling click() on the anchor
    anchor.click();

    // Clean up by revoking the URL and removing the anchor
    html.Url.revokeObjectUrl(url);
    anchor.remove();
  }
}
