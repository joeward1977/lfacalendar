import 'package:flutter/material.dart';
import 'package:flutterdatabase/backend/authservice.dart';
import 'package:flutterdatabase/backend/constants.dart';
import 'package:flutterdatabase/screens/tabs/full_schedule.dart';
import 'package:flutterdatabase/screens/tabs/aday.dart';
import 'package:flutterdatabase/screens/settings.dart';
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
    /// This is the main GUI layout
    /// The first part is the appBar which is at the top of the screen and
    /// hold the title and the Logout action button
    return Scaffold(
        appBar: AppBar(
          backgroundColor: headerColor,
          title: const Text('LFA Calendar'),
          actions: <Widget>[
            ElevatedButton.icon(
              style: buttonStyle,
              icon: const Icon(Icons.person),
              label: const Text('logout'),
              onPressed: () async {
                save();
                await _auth.signOut();
              },
            ),
          ],
        ),
        body: DefaultTabController(
            length: 3,
            child: Scaffold(
              appBar: AppBar(
                title: const TabBar(
                  tabs: [
                    Tab(icon: Icon(Icons.list)),
                    Tab(icon: Icon(Icons.list_alt_outlined)),
                    Tab(icon: Icon(Icons.list)),
                  ],
                ),
                backgroundColor: headerColor,
              ),
              body: TabBarView(
                children: [
                  ADayTable(person: person),
                  FullScheduleTable(person: person),
                  ExportPage(person: person),
                ],
              ),
            )));
  }
}
