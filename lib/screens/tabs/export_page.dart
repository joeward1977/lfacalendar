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
        title: Text(
          "Export CSV File(s)",
          style: Theme.of(context).appBarTheme.titleTextStyle,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: OutlinedButton.icon(
              onPressed: () {
                person.fillYearPeriods();
              },
              icon: const Icon(Icons.download),
              label: const Text("Download File(s)"),
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
      body: SingleChildScrollView(
        // Remove top padding to eliminate whitespace at top
        padding: const EdgeInsets.only(left: 12, right: 12, bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Removed initial SizedBox to tighten top spacing

            // Include Classes
            _buildCheckbox("Include Classes", person.wantsClasses, (val) {
              person.wantsClasses = !person.wantsClasses;
              setState(() {});
            }),

            // Sub-options for Classes
            if (person.wantsClasses) ...[
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: Column(
                  children: [
                    // Choose one or neither: Separate Files or Include Free Periods
                    CheckboxListTile(
                      title: const Text("Separate File for each Color Band"),
                      value: person.wantsColors,
                      onChanged: (val) {
                        setState(() {
                          person.wantsColors = val ?? false;
                          if (person.wantsColors) {
                            person.wantsFreePeriods = false;
                          }
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      visualDensity:
                          const VisualDensity(vertical: -4, horizontal: 0),
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                    CheckboxListTile(
                      title: const Text("Include Free Periods"),
                      value: person.wantsFreePeriods,
                      onChanged: (val) {
                        setState(() {
                          person.wantsFreePeriods = val ?? false;
                          if (person.wantsFreePeriods) {
                            person.wantsColors = false;
                          }
                        });
                      },
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      visualDensity:
                          const VisualDensity(vertical: -4, horizontal: 0),
                      controlAffinity: ListTileControlAffinity.trailing,
                    ),
                    _buildCheckbox("Include Period Headings (A1, A2, etc.)",
                        person.wantsPeriodHeadings, (val) {
                      person.wantsPeriodHeadings = !person.wantsPeriodHeadings;
                      setState(() {});
                    }),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 4),

            const Divider(), // Section separator before Include Advisory
            _buildCheckbox("Include Advisory", person.wantsAdvisory, (val) {
              person.wantsAdvisory = !person.wantsAdvisory;
              setState(() {});
            }),
            _buildCheckbox("Include Morning Meetings", person.wantsMM, (val) {
              person.wantsMM = !person.wantsMM;
              setState(() {});
            }),
            _buildCheckbox("Include Breaks", person.wantsBreaks, (val) {
              person.wantsBreaks = !person.wantsBreaks;
              setState(() {});
            }),
            _buildCheckbox("Include All School Meetings", person.wantsASM,
                (val) {
              person.wantsASM = !person.wantsASM;
              setState(() {});
            }),
            _buildCheckbox("Include Exams Schedule", person.wantsExams, (val) {
              person.wantsExams = !person.wantsExams;
              setState(() {});
            }),
            _buildCheckbox("Include Club Meeting Times", person.wantsClubs,
                (val) {
              person.wantsClubs = !person.wantsClubs;
              setState(() {});
            }),
            const Divider(), // Section separator before Include Letter Days
            _buildCheckbox("Include Letter Days", person.wantsLetterDays,
                (val) {
              person.wantsLetterDays = !person.wantsLetterDays;
              setState(() {});
            }),
            _buildCheckbox("Include Planner Events", person.wantsPlanner,
                (val) {
              person.wantsPlanner = !person.wantsPlanner;
              setState(() {});
            }),
            const Divider(), // Section separator before Include Faculty/Staff Meetings
            _buildCheckbox(
                "Include Faculty/Staff Meetings", person.wantsFacultyStaff,
                (val) {
              person.wantsFacultyStaff = !person.wantsFacultyStaff;
              setState(() {});
            }),
            _buildCheckbox("Include Deparment/Commitee Meetings",
                person.wantsMeetingPeriods, (val) {
              person.wantsMeetingPeriods = !person.wantsMeetingPeriods;
              setState(() {});
            }),
            const SizedBox(height: 8),
            // Download button moved to AppBar
          ],
        ),
      ),
    );
  }

  Widget _buildCheckbox(String label, bool value, Function(bool?) onChanged) {
    return CheckboxListTile(
      title: Text(label),
      value: value,
      onChanged: onChanged,
      dense: true,
      contentPadding: EdgeInsets.zero,
      visualDensity: const VisualDensity(vertical: -4, horizontal: 0),
      controlAffinity: ListTileControlAffinity.trailing,
    );
  }
}
