import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutterdatabase/models/person.dart';

class SettingsForm extends StatefulWidget {
  const SettingsForm({super.key});

  @override
  SettingsFormState createState() => SettingsFormState();
}

class SettingsFormState extends State<SettingsForm> {
  @override
  Widget build(BuildContext context) {
    Person person = Provider.of<Person>(context);
    return const Scaffold(
        body: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
    ));
  }
}
