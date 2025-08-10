import 'package:flutter/material.dart';
import 'package:flutterdatabase/models/person.dart';

class FullScheduleTable extends StatefulWidget {
  final Person person;

  const FullScheduleTable({super.key, required this.person});

  @override
  State<FullScheduleTable> createState() => _FullScheduleTableState();
}

class _FullScheduleTableState extends State<FullScheduleTable> {
  late Person person;

  @override
  void initState() {
    super.initState();
    person = widget.person;
    person.loadScheduleData().then((_) => setState(() {}));
  }

  void save() {
    person.sendScheduleData();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    // Use Scaffold with AppBar matching A-Day style
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Full A-G Day Schedule',
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '(Add any cycle meetings, and non-full cycle classes such as HWC and Ind Studies here)',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  border:
                      TableBorder.all(color: const Color(0xff000000), width: 5),
                  defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                  columnWidths: const {
                    0: FlexColumnWidth(1),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(3),
                    3: FlexColumnWidth(3),
                    4: FlexColumnWidth(3),
                    5: FlexColumnWidth(3),
                    6: FlexColumnWidth(3),
                    7: FlexColumnWidth(3),
                  },
                  children: [
                    TableRow(
                      decoration: const BoxDecoration(
                        color: Colors.grey,
                      ),
                      children: [
                        Container(
                          color: Colors.grey,
                          alignment: Alignment.center,
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: const Text(
                            '',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        ...List.generate(
                          7,
                          (index) => Container(
                            alignment: Alignment.center,
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              String.fromCharCode(65 + index), // A to G
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ],
                    ),
                    ...List.generate(8, (i) {
                      List<Widget> rowCells = [
                        TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Container(
                            color: Colors.grey,
                            alignment: Alignment.center,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Text(
                              '${i + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ];

                      for (int j = 0; j < 7; j++) {
                        bool isLastColumn = j == 6;
                        bool isLastTwoRows = i >= 6;

                        rowCells.add(
                          TableCell(
                            verticalAlignment:
                                TableCellVerticalAlignment.middle,
                            child: Container(
                              color: (isLastTwoRows && isLastColumn)
                                  ? Colors.grey.shade400
                                  : Colors.orange,
                              padding: const EdgeInsets.all(4.0),
                              child: Column(
                                children: [
                                  TextFormField(
                                    enabled: !(isLastColumn && isLastTwoRows),
                                    textAlign: TextAlign.center,
                                    initialValue: person
                                        .schedule.periods[i + j * 8].className,
                                    keyboardType: TextInputType.name,
                                    style: const TextStyle(fontSize: 12),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 6.0, horizontal: 8.0),
                                    ),
                                    onChanged: (val) {
                                      person.schedule.periods[i + j * 8]
                                          .className = val;
                                      person.schedule.periods[i + j * 8]
                                          .fullCourse = false;
                                    },
                                    onFieldSubmitted: (val) => save(),
                                  ),
                                  const SizedBox(height: 4.0),
                                  TextFormField(
                                    enabled: !(isLastColumn && isLastTwoRows),
                                    textAlign: TextAlign.center,
                                    initialValue: person
                                        .schedule.periods[i + j * 8].roomName,
                                    keyboardType: TextInputType.name,
                                    style: const TextStyle(fontSize: 12),
                                    decoration: const InputDecoration(
                                      isDense: true,
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 6.0, horizontal: 8.0),
                                    ),
                                    onChanged: (val) {
                                      person.schedule.periods[i + j * 8]
                                          .roomName = val;
                                      person.schedule.periods[i + j * 8]
                                          .fullCourse = false;
                                    },
                                    onFieldSubmitted: (val) => save(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      return TableRow(
                        children: rowCells,
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
