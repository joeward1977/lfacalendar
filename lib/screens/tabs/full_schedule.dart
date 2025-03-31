import 'package:flutter/material.dart';
import 'package:flutterdatabase/models/person.dart';

class FullScheduleTable extends StatefulWidget {
  final Person person;

  const FullScheduleTable({super.key, required this.person});

  @override
  FullScheduleTableState createState() => FullScheduleTableState();
}

class FullScheduleTableState extends State<FullScheduleTable> {
  late Person person;
  // Variables for helping with the data table of players
  List<String> selectedPeriods = [];

  @override
  void initState() {
    super.initState();
    person = widget.person;
    person.loadScheduleData().then((result) => {setState(() {})});
  }

  void save() {
    person.sendScheduleData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    for (int i = 0; i < person.schedule.periods.length; i++) {
      person.schedule.periods[i].className;
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
          child: Table(
            border: TableBorder.all(color: const Color(0xff000000), width: 5),
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: [
              for (int i = 0; i < 8; i++)
                TableRow(
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                  ),
                  children: [
                    for (int j = 0; j < 7; j++)
                      TableCell(
                        verticalAlignment: TableCellVerticalAlignment.middle,
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              TextFormField(
                                initialValue: person
                                    .schedule.periods[i + j * 8].className,
                                keyboardType: TextInputType.name,
                                onChanged: (val) {
                                  person.schedule.periods[i + j * 8].className =
                                      val;
                                },
                                onFieldSubmitted: (val) => save(),
                              ),
                              const SizedBox(
                                  height: 8.0), // Space between fields
                              TextFormField(
                                initialValue:
                                    person.schedule.periods[i + j * 8].roomName,
                                keyboardType: TextInputType.name,
                                onChanged: (val) {
                                  person.schedule.periods[i + j * 8].roomName =
                                      val;
                                },
                                onFieldSubmitted: (val) => save(),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
