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
        child: DataTable(
          columns: _createColumns(),
          rows: _createRows(),
          dividerThickness: 3,
          dataRowMinHeight: 35,
          dataRowMaxHeight: 35,
          showBottomBorder: true,
          headingTextStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          headingRowColor: WidgetStateProperty.resolveWith(
            (states) => headerColor,
          ),
        ),
      ),
    );
  }

  /// Returns the column headers for the schedule table
  List<DataColumn> _createColumns() {
    return const [
      DataColumn(label: Text('Class Name')),
      DataColumn(label: Text('Room Name')),
      DataColumn(label: Text('Double?')),
    ];
  }

  /// Builds each row of the table using the person's schedule
  List<DataRow> _createRows() {
    List<DataRow> data = [];

    // Ensure valid data structure exists
    if (person.schedule.periods.length < 54) {
      debugPrint("New User - initializing full period list.");
      person.schedule.addAllPeriod();
    } else {
      debugPrint("Returning User - period list found.");
    }

    // Only display first 8 periods for this view
    for (int x = 0; x < 8; x++) {
      Period period = person.schedule.periods[x];
      debugPrint(period.id);
      var name = period.className;
      var room = period.roomName;
      bool full = period.fullCourse;
      if (!full) {
        name = "";
        room = "";
      }

      data.add(DataRow(cells: [
        DataCell(Row(children: [
          Expanded(
            child: TextFormField(
              initialValue: name,
              keyboardType: TextInputType.name,
              onChanged: (val) {
                debugPrint(period.id);
                period.className = val;
                period.fullCourse = true;
              },
              onFieldSubmitted: (_) {
                person.updateDoubles(person.dubs[x], x);
              },
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
                period.roomName = val;
                period.fullCourse = true;
              },
              onFieldSubmitted: (_) {
                person.updateDoubles(person.dubs[x], x);
              },
            ),
          ),
        ])),
        DataCell(Center(
          child: Checkbox(
            value: person.dubs[x],
            onChanged: (val) {
              setState(() {
                person.dubs[x] = val ?? false;
                person.updateDoubles(person.dubs[x], x);
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
      body: SizedBox.expand(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'A-Day Classes',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: save,
                    child: const Text('Save'),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '(course which meet for the whole cycle)',
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(child: _createDataTable(context)),
            ],
          ),
        ),
      ),
    );
  }
}
