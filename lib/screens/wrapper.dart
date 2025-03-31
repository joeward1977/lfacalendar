import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flutterdatabase/models/person.dart';
import 'package:flutterdatabase/screens/home.dart';
import 'package:flutterdatabase/screens/register_login.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<Person?>(context);
    if (user == null) {
      return const RegisterLogin(type: 0);
    } else {
      return Home(person: user);
    }
  }
}
