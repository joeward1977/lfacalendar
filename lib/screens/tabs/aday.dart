import 'package:flutter/material.dart';
import 'package:flutterdatabase/backend/constants.dart';
import 'package:flutterdatabase/models/person.dart';
import 'package:flutterdatabase/models/period.dart';
import 'package:uuid/uuid.dart';

class ADayTable extends StatefulWidget {
  final Person person;

  const ADayTable({super.key, required this.person});

  @override
  ADayState createState() => ADayState();
}

class ADayState extends State<ADayTable> {
  late Person person;
  // Variables for helping with the data table of players
  List<String> selectedPeriods = [];
  var uuid = const Uuid();

  @override
  void initState() {
    person = widget.person;
    person.loadScheduleData().then((result) => {setState(() {})});
    person.schedule.addAllPeriod();
    super.initState();
  }

  // Method to save data to Google Firestore
  void save() {
    person.sendScheduleData();
    person.updatePeriods();
    setState(() {});
  }

  /// The following methods create the data table
  /// This method puts it all together and styles the table
  DataTable _createDataTable() {
    return DataTable(
      columns: _createColumns(),
      rows: _createRows(),
      dividerThickness: 3,
      dataRowHeight: 35,
      showBottomBorder: true,
      headingTextStyle: const TextStyle(
          fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
      headingRowColor: WidgetStateProperty.resolveWith((states) => headerColor),
    );
  }

  // This method gets the column headings and makes columns sortable
  List<DataColumn> _createColumns() {
    return [
      const DataColumn(
        label: Text('Class Name'),
      ),
      const DataColumn(
        label: Text('Room Name'),
      ),
      const DataColumn(
        label: Text('Double?'),
      ),
    ];
  }

  // This method put the data into each rom
  List<DataRow> _createRows() {
    List<DataRow> data = [];
    if (person.schedule.periods.length < 54) {
      print("New User");
      person.schedule.addAllPeriod();
    } else {
      print("Old User");
    }
    for (int x = 0; x < 8; x++) {
      Period period = person.schedule.periods[x];
      data.add(DataRow(cells: [
        DataCell(TextFormField(
            controller: TextEditingController(text: period.className),
            keyboardType: TextInputType.name,
            onChanged: (val) =>
                person.schedule.getPeriod(period.id)!.className = val,
            onFieldSubmitted: (val) {
              person.updateDoubles(person.dubs[x], x);
              save();
            })),
        DataCell(TextFormField(
            controller: TextEditingController(text: period.roomName),
            keyboardType: TextInputType.name,
            onChanged: (val) =>
                person.schedule.getPeriod(period.id)!.roomName = val,
            onFieldSubmitted: (val) {
              person.updateDoubles(person.dubs[x], x);
              save();
            })),
        DataCell(Checkbox(
            value: person.dubs[x],
            onChanged: (val) {
              person.dubs[x] = !person.dubs[x];
              person.updateDoubles(person.dubs[x], x);
              save();
            }))
      ]));
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        constraints: const BoxConstraints(maxWidth: 600),
        // The body of the GUI cotains the DataTable in a ListView Widget
        child: ListView(
          children: [FittedBox(child: _createDataTable())],
        ),
      ),
    );
  }
}
