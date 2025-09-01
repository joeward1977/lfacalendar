import 'package:flutter/material.dart';
import 'package:flutterdatabase/backend/constants.dart';
import 'package:flutterdatabase/models/person.dart';
import 'package:flutterdatabase/models/period.dart';
import 'package:uuid/uuid.dart';

/// ADayTable displays a schedule table for a given [Person]
class ADayTable extends StatefulWidget {
  final Person person;

  const ADayTable({super.key, required this.person});

  @override
  ADayState createState() => ADayState();
}

class ADayState extends State<ADayTable> {
  late Person person;
  final List<String> selectedPeriods = [];
  final uuid = const Uuid();
  bool isLoading = true;
  // Labels for each A-Day band
  final List<String> bandLabels = [
    'A1 - Red',
    'A2 - Royal',
    'A3 - Yellow',
    'A4 - Teal',
    'A5 - Green',
    'A6 - Orange',
    'A7 - Pink',
    'A8 - Purple',
  ];
  // Tracks whether any cell in the corresponding row (A1–A8) has been edited
  final List<bool> rowEdited = List<bool>.filled(8, false);

  @override
  void initState() {
    super.initState();
    person = widget.person;

    // Load saved schedule data asynchronously, then initialize periods and update UI
    person.loadScheduleData().then((_) {
      person.schedule.addAllPeriod();
      setState(() {
        isLoading = false;
      });
    });
  }

  /// Save any changes to Firestore and update the local schedule state
  void save() {
    for (int i = 0; i < 8; i++) {
      if (rowEdited[i]) {
        person.updateBand(i);
        rowEdited[i] = false; // Reset the edited state after saving
      }
    }
    person.updatePeriodsADay();
    person.sendScheduleData();

    // Print all period IDs and warn if duplicates are found
    final periodIds =
        person.schedule.periods.map((period) => period.id).toList();
    final duplicates = periodIds
        .toSet()
        .where((id) => periodIds.where((x) => x == id).length > 1);
    if (duplicates.isNotEmpty) {
      debugPrint(
          'Warning: Duplicate period IDs found: ${duplicates.join(', ')}');
    }

    setState(() {});
  }

  /// Builds the DataTable widget with styles and data
  SingleChildScrollView _createDataTable(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: ConstrainedBox(
        constraints:
            BoxConstraints(minWidth: MediaQuery.of(context).size.width),
        child: Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8),
          child: DataTable(
            showBottomBorder: true,
            dividerThickness: 1,
            dataRowMinHeight: 40,
            headingRowHeight: 56,
            headingRowColor: WidgetStateProperty.all(headerColor),
            headingTextStyle: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            dataRowColor: WidgetStateProperty.resolveWith<Color?>(
                (Set<WidgetState> states) {
              return states.contains(WidgetState.selected)
                  ? null
                  : Colors.grey[50];
            }),
            columns: _createColumns(),
            rows: _createRows(),
          ),
        ),
      ),
    );
  }

  /// Returns the column headers for the schedule table
  List<DataColumn> _createColumns() {
    return [
      const DataColumn(label: Text('Band')),
      const DataColumn(label: Text('Class Name')),
      const DataColumn(label: Text('Room Name')),
      const DataColumn(label: Text('Double?')),
    ];
  }

  /// Builds each row of the table using the person's schedule
  List<DataRow> _createRows() {
    List<DataRow> data = [];

    // Ensure valid data structure exists
    if (person.schedule.periods.length < 54) {
      debugPrint("New User - initializing full period list.");
      person.schedule.addAllPeriod();
    }

    // Only display first 8 periods for this view
    for (int x = 0; x < 8; x++) {
      Period period = person.schedule.periods[x];
      var name = period.className;
      var room = period.roomName;
      bool full = period.fullCourse;
      if (!full) {
        name = "";
        room = "";
      }

      data.add(DataRow(cells: [
        // Band label cell
        DataCell(Text(bandLabels[x])),
        DataCell(Row(children: [
          Expanded(
            child: TextFormField(
              initialValue: name,
              keyboardType: TextInputType.name,
              onChanged: (val) {
                debugPrint(period.id);
                setState(() {
                  period.className = val;
                  period.fullCourse = true;
                  rowEdited[x] = true; // mark row as changed
                });
              },
              onFieldSubmitted: (_) {},
            ),
          ),
        ])),
        DataCell(Row(children: [
          Expanded(
            child: TextFormField(
              initialValue: room,
              keyboardType: TextInputType.name,
              onChanged: (val) {
                debugPrint(period.id);
                setState(() {
                  period.roomName = val;
                  period.fullCourse = true;
                  rowEdited[x] = true; // mark row as changed
                });
              },
              onFieldSubmitted: (_) {},
            ),
          ),
        ])),
        DataCell(Center(
          child: Checkbox(
            value: person.dubs[x],
            onChanged: (val) {
              setState(() {
                person.dubs[x] = val ?? false;
                rowEdited[x] = true; // mark row as changed
              });
            },
          ),
        )),
      ]));
    }

    return data;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('A-Day Class Schedule'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: OutlinedButton.icon(
              onPressed: save,
              icon: const Icon(Icons.save),
              label: const Text('Save'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          children: [
            Expanded(child: _createDataTable(context)),
          ],
        ),
      ),
    );
  }
}
