import 'package:flutterdatabase/backend/authservice.dart';
import 'package:flutterdatabase/backend/constants.dart';
import 'package:flutterdatabase/screens/loading.dart';
import 'package:flutter/material.dart';

const List<String> headerText = [
  'Sign into Your Account',
  'Register an Account'
];
List<String> toggleText = ['Register', 'Sign In'];
List<String> buttonText = ['Sign In', 'Register'];

class RegisterLogin extends StatefulWidget {
  final int type;

  const RegisterLogin({super.key, required this.type});

  @override
  RegisterLoginState createState() => RegisterLoginState();
}

class RegisterLoginState extends State<RegisterLogin> {
  final AuthService _auth = AuthService();
  final _formKey = GlobalKey<FormState>();
  late int type;
  String error = '';
  bool loading = false;

  // text field state
  String email = '';
  String password = '';

  @override
  void initState() {
    type = widget.type;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? const Loading()
        : Scaffold(
            backgroundColor: backgroundColor,
            appBar: AppBar(
              backgroundColor: headerColor,
              elevation: 0.0,
              title: Text(headerText[type]),
              actions: <Widget>[
                // Sign In and Register buttons side by side
                TextButton(
                  onPressed: () {
                    if (type != 0) setState(() => type = 0);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        type == 0 ? Colors.white : Colors.transparent,
                    foregroundColor: type == 0 ? headerColor : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  child: const Text('Sign In'),
                ),
                TextButton(
                  onPressed: () {
                    if (type != 1) setState(() => type = 1);
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                        type == 1 ? Colors.white : Colors.transparent,
                    foregroundColor: type == 1 ? headerColor : Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  ),
                  child: const Text('Register'),
                ),
              ],
            ),
            body: Container(
              padding:
                  const EdgeInsets.symmetric(vertical: 20.0, horizontal: 50.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 20.0),
                    TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: 'email'),
                      validator: (val) =>
                          val!.isEmpty ? 'Enter an email' : null,
                      onChanged: (val) {
                        setState(() => email = val);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    TextFormField(
                      decoration:
                          textInputDecoration.copyWith(hintText: 'password'),
                      obscureText: true,
                      validator: (val) => val!.length < 6
                          ? 'Enter a password 6+ chars long'
                          : null,
                      onChanged: (val) {
                        setState(() => password = val);
                      },
                    ),
                    const SizedBox(height: 20.0),
                    ElevatedButton(
                        style: buttonStyle,
                        child: Text(
                          buttonText[type],
                          style: const TextStyle(color: Colors.black),
                        ),
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => loading = true);
                            dynamic result;
                            if (type == 0) {
                              result = await _auth.signInWithEmailAndPassword(
                                  email, password);
                            } else {
                              result = await _auth.registerWithEmailAndPassword(
                                  email, password);
                            }
                            if (result == null) {
                              setState(() {
                                loading = false;
                                error = 'Please supply a valid email';
                              });
                            }
                          }
                        }),
                    const SizedBox(height: 12.0),
                    Text(
                      error,
                      style: const TextStyle(color: Colors.red, fontSize: 14.0),
                    )
                  ],
                ),
              ),
            ),
          );
  }
}
