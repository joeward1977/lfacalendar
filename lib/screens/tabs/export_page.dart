import 'package:flutter/material.dart';
import 'package:flutterdatabase/models/person.dart';

class ExportPage extends StatefulWidget {
  final Person person;

  const ExportPage({super.key, required this.person});

  @override
  State<ExportPage> createState() => ExportPageState();
}

class ExportPageState extends State<ExportPage> {
  late Person person;

  @override
  void initState() {
    person = widget.person;
    person.loadScheduleData().then((result) => {setState(() {})});
    super.initState();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Export CSV"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ElevatedButton(
            child: const Text("Download File"),
            onPressed: () {
              person.fillYearPeriods();
            },
          ),
          Row(children: [
            const Text("Exclude Free Periods?: "),
            Checkbox(
                value: person.wantsFreePeriods,
                onChanged: (val) {
                  person.wantsFreePeriods = !person.wantsFreePeriods;
                  setState(() {});
                })
          ]),
          Row(children: [
            const Text("Include Period Headings? "),
            Checkbox(
                value: person.wantsPeriodHeadings,
                onChanged: (val) {
                  person.wantsPeriodHeadings = !person.wantsPeriodHeadings;
                  setState(() {});
                })
          ]),
          Row(children: [
            const Text("Include Advisory: "),
            Checkbox(
                value: person.wantsAdvisory,
                onChanged: (val) {
                  person.wantsAdvisory = !person.wantsAdvisory;
                  setState(() {});
                })
          ]),
          Row(children: [
            const Text("Include ASM: "),
            Checkbox(
                value: person.wantsASM,
                onChanged: (val) {
                  person.wantsASM = !person.wantsASM;
                  setState(() {});
                })
          ]),
          Row(children: [
            const Text("Include Breaks: "),
            Checkbox(
                value: person.wantsBreaks,
                onChanged: (val) {
                  person.wantsBreaks = !person.wantsBreaks;
                  setState(() {});
                })
          ]),
          Row(children: [
            const Text("Include MM: "),
            Checkbox(
                value: person.wantsMM,
                onChanged: (val) {
                  person.wantsMM = !person.wantsMM;
                  setState(() {});
                })
          ]),
        ],
      ),
    );
  }
}
