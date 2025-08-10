import 'package:flutter/material.dart';
import 'package:flutterdatabase/backend/authservice.dart';
import 'package:flutterdatabase/backend/constants.dart';
import 'package:flutterdatabase/screens/tabs/full_schedule.dart';
import 'package:flutterdatabase/screens/tabs/aday.dart';
import 'package:flutterdatabase/models/person.dart';
import 'package:flutterdatabase/screens/tabs/export_page.dart';

class Home extends StatefulWidget {
  final Person person;

  const Home({super.key, required this.person});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // Variables to deal with data from Google Server
  final AuthService _auth = AuthService();
  late Person person;

  @override
  void initState() {
    person = widget.person;
    person.loadScheduleData().then((result) => {setState(() {})});
    super.initState();
  }

  // Method to save data to Google Firestore
  void save() {
    person.sendScheduleData();
    setState(() {});
  }

  /// The build method is what creates the GUI for the program
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: headerColor,
          title: const Text('LFA Calendar'),
          actions: [
            TextButton.icon(
              onPressed: () async {
                save();
                await _auth.signOut();
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white, // ensure text/icon is visible
              ),
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
            ),
          ],
          bottom: const TabBar(
            tabs: [
              Tab(icon: Icon(Icons.list), text: 'Day'),
              Tab(icon: Icon(Icons.list_alt_outlined), text: 'Full'),
              Tab(icon: Icon(Icons.download), text: 'Export'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            ADayTable(person: person),
            FullScheduleTable(person: person),
            ExportPage(person: person),
          ],
        ),
      ),
    );
  }
}
