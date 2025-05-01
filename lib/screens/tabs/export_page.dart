import 'package:flutter/material.dart';
import 'package:flutterdatabase/models/person.dart';

/// This page provides options for exporting a user's schedule
/// in CSV format with various configurable filters.
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
    super.initState();
    person = widget.person;

    // Load the user's existing schedule data
    person.loadScheduleData().then((_) {
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Export CSV"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Checkbox to exclude free periods from export
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Include Free Periods?: "),
              Checkbox(
                value: person.wantsFreePeriods,
                onChanged: (val) {
                  person.wantsFreePeriods = !person.wantsFreePeriods;
                  setState(() {});
                },
              )
            ],
          ),

          // Checkbox to include period headings in export
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Include Period Headings? "),
              Checkbox(
                value: person.wantsPeriodHeadings,
                onChanged: (val) {
                  person.wantsPeriodHeadings = !person.wantsPeriodHeadings;
                  setState(() {});
                },
              )
            ],
          ),

          // Checkbox to include advisory periods
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Include Advisory: "),
              Checkbox(
                value: person.wantsAdvisory,
                onChanged: (val) {
                  person.wantsAdvisory = !person.wantsAdvisory;
                  setState(() {});
                },
              )
            ],
          ),

          // Checkbox to include ASM periods
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Include ASM: "),
              Checkbox(
                value: person.wantsASM,
                onChanged: (val) {
                  person.wantsASM = !person.wantsASM;
                  setState(() {});
                },
              )
            ],
          ),

          // Checkbox to include break periods
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Include Breaks: "),
              Checkbox(
                value: person.wantsBreaks,
                onChanged: (val) {
                  person.wantsBreaks = !person.wantsBreaks;
                  setState(() {});
                },
              )
            ],
          ),

          // Checkbox to include Morning Meeting periods
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Include MM: "),
              Checkbox(
                value: person.wantsMM,
                onChanged: (val) {
                  person.wantsMM = !person.wantsMM;
                  setState(() {});
                },
              )
            ],
          ),
          // Button to initiate CSV generation
          ElevatedButton(
            child: const Text("Download File"),
            onPressed: () {
              person.fillYearPeriods(); // Fills in yearly schedule data
            },
          ),
        ],
      ),
    );
  }
}
