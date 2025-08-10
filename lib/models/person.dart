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
  bool wantsClasses = true;

  // Class Preferences
  bool wantsPeriodHeadings = false;
  bool wantsColors = false;
  bool wantsFreePeriods = false;

  // School Day Preferences
  bool wantsAdvisory = false;
  bool wantsMM = false;
  bool wantsBreaks = false;
  bool wantsASM = false;
  bool wantsExams = false;
  bool wantsClubs = false;

  // Calendar Day Preferences
  bool wantsLetterDays = false;
  bool wantsPlanner = false;

  // Faculty/Staff Preferences
  bool wantsFacultyStaff = false;
  bool wantsMeetingPeriods = false;

  Person({required this.uid});

  var periodColors = [0, 1, 2, 3, 4, 5, 6, 7];
  var periodColorNames = [
    "Red",
    "Royal",
    "Yellow",
    "Teal",
    "Green",
    "Orange",
    "Pink",
    "Purple",
    "null"
  ];

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
        schedule.periods[i].colorId = periodColors[i];
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

    if (wantsClasses) {
      // Initialize yearPeriods with empty Period objects
      for (int i = 0; i < 56; i++) {
        yearPeriods.add(Period.withData(
          id: schedule.periods[i].id,
          className: schedule.periods[i].className,
          roomName: schedule.periods[i].roomName,
          fullCourse: schedule.periods[i].fullCourse,
          colorId: schedule.periods[i].colorId,
          startDate: [],
          startTime: [],
          endDate: [],
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
              // Make sure we are in the first 54 periods &
              // Check that we have a class or want free periods
              if (periodIndex < yearPeriods.length &&
                  (yearPeriods[periodIndex].className != "" ||
                      wantsFreePeriods)) {
                String periodHeading =
                    letterDays[letterDayIndex] + period.toString();
                if (wantsPeriodHeadings) {
                  yearPeriods[periodIndex].className = schedule
                          .periods[periodIndex].className.isEmpty
                      ? periodHeading
                      : '$periodHeading - ${schedule.periods[periodIndex].className}';
                } else {
                  yearPeriods[periodIndex].className =
                      schedule.periods[periodIndex].className;
                }
                yearPeriods[periodIndex].startDate.add(dates[rows]);
                yearPeriods[periodIndex].startTime.add(startTimes[rows]);
                yearPeriods[periodIndex].endDate.add(dates[rows]);
                yearPeriods[periodIndex].endTime.add(endTimes[rows]);
              }
            }
          }
        }
      }
    }

    if (!wantsColors) {
      // If colors are not wanted, set colorId to null for all periods
      for (var period in yearPeriods) {
        period.colorId = null;
      }
    }

    // Add additional period types based on user preferences
    if (wantsAdvisory) await addExtraEvents('Advisory', 'assets/adv.csv');
    if (wantsMM) await addExtraEvents('Morning Meeting', 'assets/mm.csv');
    if (wantsBreaks) await addExtraEvents('Break', 'assets/breaks.csv');
    if (wantsASM) await addExtraEvents('ASM', 'assets/asm.csv');
    if (wantsExams) await addExtraEvents('Exams', 'assets/exams.csv');
    if (wantsClubs) await addExtraEvents('Clubs', 'assets/clubs.csv');

    if (wantsLetterDays) {
      await addExtraEvents('Letter Days', 'assets/days.csv');
    }
    if (wantsPlanner) await addExtraEvents('Planner', 'assets/planner.csv');

    if (wantsFacultyStaff) {
      await addExtraEvents('Faculty/Staff', 'assets/facultystaff.csv');
    }
    if (wantsMeetingPeriods) {
      await addExtraEvents('Meeting Periods', 'assets/meetingperiods.csv');
    }

    // Export the filled year periods to a CSV file
    exportPeriodsToCSV(yearPeriods);
    // exportPeriodsToICS(yearPeriods);
  }

  // Adds a new type of period from a CSV file
  Future<void> addExtraEvents(String className, String file) async {
    List<String> subjects = await loadColumnFromCSV(file, 0);
    List<String> startDates = await loadColumnFromCSV(file, 1);
    List<String> startTimes = await loadColumnFromCSV(file, 2);
    List<String> endDates = await loadColumnFromCSV(file, 3);
    List<String> endTimes = await loadColumnFromCSV(file, 4);
    subjects.removeAt(0); // Remove header
    startDates.removeAt(0); // Remove header
    startTimes.removeAt(0); // Remove header
    endDates.removeAt(0); // Remove header
    endTimes.removeAt(0); // Remove header

    for (int i = 0; i < startDates.length; i++) {
      // Create a new Period object for each event
      yearPeriods.add(Period.withData(
        id: uuid.v4(),
        className: subjects[i],
        roomName: '',
        fullCourse: false,
        startDate: [startDates[i]],
        startTime: [startTimes[i]],
        endDate: [endDates[i]],
        endTime: [endTimes[i]],
      ));
    }
  }

  // Updates the schedule for double periods based on user input
  void updateDoubles(bool wasChecked, int periodNum) {
    if (periodNum == 5) return; // Skip if the period is 5
    schedule.periods[periodNum].colorId = periodColors[periodNum];
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
    schedule.addAllPeriod(); // Ensure all periods are added
    updatePeriodsADay(); // Update periods to reflect any changes
    final docRef = firestoreDB.collection("users").doc(uid).withConverter(
          fromFirestore: Schedule.fromFirestore,
          toFirestore: (Schedule schedule, _) => schedule.toMap(),
        );
    final docSnap = await docRef.get();
    // Load schedule data if it exists; otherwise initialize and save a new template
    final data = docSnap.data();
    if (data != null) {
      schedule = data;
    } else {
      // No existing schedule, set up a fresh template
      schedule = Schedule.newSchedule();
      // Persist the new default schedule to Firestore for this user
      await docRef.set(schedule);
    }
    // Re-apply any derived updates (ensure colorId is populated)
    updatePeriodsADay();
    // Now schedule.periods have correct colorId for later export
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

  // Exports the yearPeriods data to a CSV file in the format required by the Google Apps Script web app
  void exportPeriodsToCSV(List<Period> yearPeriods) {
    if (!wantsColors) {
      List<List<String>> rows = [];
      rows.add([
        'Subject',
        'Start Date',
        'Start Time',
        'End Date',
        'End Time',
        'Location'
      ]);
      for (var period in yearPeriods) {
        for (int i = 0; i < period.startDate.length; i++) {
          rows.add([
            period.className,
            period.startDate[i],
            period.startTime[i],
            period.endDate[i],
            period.endTime[i],
            period.roomName
          ]);
        }
      }
      String csvData = const ListToCsvConverter().convert(rows);
      final bytes = utf8.encode(csvData);
      final blob = html.Blob([bytes]);
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..target = 'blank'
        ..download = 'Schedule.csv';
      html.document.body?.append(anchor);
      anchor.click();
      html.Url.revokeObjectUrl(url);
      anchor.remove();
    } else {
      // Separate files per color
      Map<int, List<Period>> colorGroups = {};
      for (var period in yearPeriods) {
        // Only include colors with actual scheduled events
        if (period.colorId != null && period.startDate.isNotEmpty) {
          colorGroups.putIfAbsent(period.colorId!, () => []).add(period);
        }
      }
      colorGroups.forEach((colorId, periods) {
        // Look up the name from the int colorId
        String colorNameForFile =
            (colorId >= 0 && colorId < periodColorNames.length)
                ? periodColorNames[colorId]
                : colorId.toString();
        List<List<String>> rows = [];
        rows.add([
          'Subject',
          'Start Date',
          'Start Time',
          'End Date',
          'End Time',
          'Location'
        ]);
        for (var p in periods) {
          for (int i = 0; i < p.startDate.length; i++) {
            rows.add([
              p.className,
              p.startDate[i],
              p.startTime[i],
              p.endDate[i],
              p.endTime[i],
              p.roomName
            ]);
          }
        }
        String csvData = const ListToCsvConverter().convert(rows);
        final bytes = utf8.encode(csvData);
        final blob = html.Blob([bytes]);
        final url = html.Url.createObjectUrlFromBlob(blob);
        final anchor = html.AnchorElement(href: url)
          ..target = 'blank'
          ..download = 'Schedule_Color_$colorNameForFile.csv';
        html.document.body?.append(anchor);
        anchor.click();
        html.Url.revokeObjectUrl(url);
        anchor.remove();
      });
      // Also export events with no colorId as a separate file
      var otherEvents = yearPeriods
          .where((p) => p.colorId == null && p.startDate.isNotEmpty)
          .toList();
      if (otherEvents.isNotEmpty) {
        List<List<String>> otherRows = [];
        otherRows.add([
          'Subject',
          'Start Date',
          'Start Time',
          'End Date',
          'End Time',
          'Location'
        ]);
        for (var p in otherEvents) {
          for (int i = 0; i < p.startDate.length; i++) {
            otherRows.add([
              p.className,
              p.startDate[i],
              p.startTime[i],
              p.endDate[i],
              p.endTime[i],
              p.roomName
            ]);
          }
        }
        String otherCsv = const ListToCsvConverter().convert(otherRows);
        final otherBytes = utf8.encode(otherCsv);
        final otherBlob = html.Blob([otherBytes]);
        final otherUrl = html.Url.createObjectUrlFromBlob(otherBlob);
        final otherAnchor = html.AnchorElement(href: otherUrl)
          ..target = 'blank'
          ..download = 'OtherEvents.csv';
        html.document.body?.append(otherAnchor);
        otherAnchor.click();
        html.Url.revokeObjectUrl(otherUrl);
        otherAnchor.remove();
      }
    }
  }
}
