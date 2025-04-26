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

  // Updates the periods based on the band configuration
  void updatePeriodsADay() {
    for (int i = 0; i < bands.length; i++) {
      for (int j = 0; j < bands[0].length; j++) {
        if (schedule.periods[i].fullCourse) {
          schedule.periods[bands[i][j]] = schedule.periods[i];
        }
      }
    }
  }

  // Fills the yearPeriods list with data from the CSV files
  void fillYearPeriods() async {
    yearPeriods.clear();
    List<String> periodNumbers = await readClassColumn(0);
    List<String> dates = await readClassColumn(1);
    List<String> startTimes = await readClassColumn(2);
    List<String> endTimes = await readClassColumn(4);
    List<String> letterDays = ['A', 'B', 'C', 'D', 'E', 'F', 'G'];

    // Initialize yearPeriods with empty Period objects
    for (int i = 0; i < 56; i++) {
      yearPeriods.add(Period.withData(
        id: schedule.periods[i].id,
        className: schedule.periods[i].className,
        roomName: schedule.periods[i].roomName,
        fullCourse: schedule.periods[i].fullCourse,
        date: [],
        startTime: [],
        endTime: [],
      ));
    }

    // Populate yearPeriods with actual data from the CSV
    // Loop through the rows on the csv file
    for (int rows = 0; rows < periodNumbers.length; rows++) {
      if (['Advisory', 'Morning Meeting', 'Break', 'All School Meeting']
          .contains(periodNumbers[rows])) {
        continue; // Skip these special period types
      }
      // Loop through the A-G letter days
      for (int letterDayIndex = 0;
          letterDayIndex < letterDays.length;
          letterDayIndex++) {
        // Loop through the period 1 to 8
        for (int period = 1; period <= 8; period++) {
          // Check if the row is the correct letter day and period
          if (periodNumbers[rows] ==
              letterDays[letterDayIndex] + period.toString()) {
            int periodIndex = letterDayIndex * 8 + (period - 1);
            // Make sure we are in the first 54 periods
            if (periodIndex < yearPeriods.length) {
              String periodHeading =
                  letterDays[letterDayIndex] + period.toString();
              if (wantsPeriodHeadings) {
                yearPeriods[periodIndex].className = schedule
                        .periods[periodIndex].className.isEmpty
                    ? periodHeading
                    : '$periodHeading - ${schedule.periods[periodIndex].className}';
              }
              yearPeriods[periodIndex].date.add(dates[rows]);
              yearPeriods[periodIndex].startTime.add(startTimes[rows]);
              yearPeriods[periodIndex].endTime.add(endTimes[rows]);
            }
          }
        }
      }
    }

    // Add additional period types based on user preferences
    if (wantsAdvisory) await addPeriodType('Advisory', 'assets/adv.csv');
    if (wantsMM) await addPeriodType('Morning Meeting', 'assets/mm.csv');
    if (wantsBreaks) await addPeriodType('Break', 'assets/breaks.csv');
    if (wantsASM) await addPeriodType('All School Meeting', 'assets/asm.csv');

    // Export the filled year periods to a CSV file
    exportPeriodsToCSV(yearPeriods);
  }

  // Adds a new type of period from a CSV file
  Future<void> addPeriodType(String className, String file) async {
    List<String> dates = await loadColumnFromCSV(file, 1);
    List<String> startTimes = await loadColumnFromCSV(file, 2);
    List<String> endTimes = await loadColumnFromCSV(file, 4);
    dates.removeAt(0); // Remove header
    startTimes.removeAt(0); // Remove header
    endTimes.removeAt(0); // Remove header

    yearPeriods.add(Period.withData(
      id: uuid.v4(),
      className: className,
      roomName: '',
      fullCourse: false,
      date: dates,
      startTime: startTimes,
      endTime: endTimes,
    ));
  }

  // Updates the schedule for double periods based on user input
  void updateDoubles(bool wasChecked, int periodNum) {
    if (periodNum == 5) return; // Skip if the period is 5
    schedule.periods[doubles[periodNum]] =
        wasChecked ? schedule.periods[periodNum] : schedule.periods[55];
    updatePeriodsADay(); // Update the periods after modification
  }

  // Initializes the schedule with new Period objects
  void newSchedule(id) {
    for (int i = 0; i < 56; i++) {
      schedule.periods[i] = Period(id);
    }
  }

  // Sends the current schedule data to Firestore
  void sendScheduleData() async {
    final docRef = firestoreDB
        .collection("users")
        .withConverter(
          fromFirestore: Schedule.fromFirestore,
          toFirestore: (Schedule schedule, options) => schedule.toMap(),
        )
        .doc(uid);
    await docRef.set(schedule);
  }

  // Loads the schedule data from Firestore
  Future loadScheduleData() async {
    print("Loading schedule data...");
    schedule.addAllPeriod(); // Ensure all periods are added
    updatePeriodsADay(); // Update periods to reflect any changes
    final docRef = firestoreDB.collection("users").doc(uid).withConverter(
          fromFirestore: Schedule.fromFirestore,
          toFirestore: (Schedule schedule, _) => schedule.toMap(),
        );
    final docSnap = await docRef.get();
    schedule = docSnap.data()!; // Update the schedule with data from Firestore
  }

  // Loads a specific column from a CSV file
  Future<List<String>> loadColumnFromCSV(
      String fileName, int columnIndex) async {
    final csvData = await rootBundle.loadString(fileName);
    List<List<dynamic>> rows = const CsvToListConverter().convert(csvData);
    List<String> columnData = [];
    for (var row in rows) {
      if (row.length > columnIndex) {
        columnData.add(row[columnIndex].toString());
      }
    }
    return columnData; // Return the extracted column data
  }

  // Reads a specific class column from the classes CSV file
  Future<List<String>> readClassColumn(int c) async {
    return await loadColumnFromCSV('assets/classes.csv', c);
  }

  // Exports the yearPeriods data to a CSV file
  void exportPeriodsToCSV(List<Period> yearPeriods) {
    List<List<String>> rows = [];

    // Add header row
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

    // Add each period's data to the rows
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

    // Convert rows to CSV format
    String csvData = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csvData); // Encode CSV data in UTF-8
    final blob =
        html.Blob([bytes]); // Create a downloadable Blob from the CSV data
    final url =
        html.Url.createObjectUrlFromBlob(blob); // Create a URL for the Blob

    // Create a hidden anchor element to trigger the download
    final anchor = html.AnchorElement(href: url)
      ..target = 'blank'
      ..download = 'PeriodsSchedule.csv';

    // Append the anchor to the document body and trigger the download
    html.document.body?.append(anchor);
    anchor.click();

    // Clean up by revoking the URL and removing the anchor
    html.Url.revokeObjectUrl(url);
    anchor.remove();
  }
}
