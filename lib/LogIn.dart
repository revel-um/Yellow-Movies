import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:yellow_movies/AddOrEditPage.dart';
import 'package:yellow_movies/SignUp.dart';
import 'package:yellow_movies/authentication_service.dart';

import 'google_sign_in_provider.dart';

class LogIn extends StatefulWidget {
  const LogIn({Key? key}) : super(key: key);

  @override
  _LogInState createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  TextEditingController mailCon = TextEditingController();
  TextEditingController passCon = TextEditingController();

  bool showMailError = false;
  bool showPassError = false;
  bool touchWorks = true;
  var top;

  final fadingCircle = SpinKitFadingCircle(
    itemBuilder: (BuildContext context, int index) {
      return DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: index.isEven ? Colors.blue : Colors.blue,
        ),
      );
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              children: [
                Image.asset('assets/images/undraw_Sign_in_re_o58h.png'),
                TextView(
                  errorText: 'Mail is required',
                  enabled: touchWorks,
                  showError: showMailError,
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icon(Icons.mail),
                  hint: 'Email',
                  controller: mailCon,
                ),
                TextView(
                  enabled: touchWorks,
                  errorText: 'Password is required',
                  showError: showPassError,
                  prefixIcon: Icon(Icons.password_outlined),
                  hint: 'Password',
                  controller: passCon,
                ),
                TextButton(
                  onPressed: touchWorks
                      ? () async {
                          if (mailCon.text.isEmpty) {
                            setState(() {
                              showMailError = true;
                            });
                            return;
                          } else {
                            showMailError = false;
                          }
                          if (passCon.text.isEmpty) {
                            setState(() {
                              showPassError = true;
                            });
                            return;
                          } else {
                            showPassError = false;
                          }
                          AuthenticationService authService =
                              AuthenticationService(FirebaseAuth.instance);

                          setState(() {
                            touchWorks = false;
                            top = fadingCircle;
                          });
                          String result = await authService.signIn(
                              email: mailCon.text, password: passCon.text);
                          print(result);
                          if (result.toString() == 'Signed In') {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    AddOrEditPage(adding: true),
                              ),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(result),
                              action: SnackBarAction(
                                label: 'OKAY',
                                onPressed: () {
                                  Navigator.of(context, rootNavigator: true);
                                },
                              ),
                              duration: Duration(milliseconds: 5000),
                            ));
                            setState(() {
                              touchWorks = true;
                              top = null;
                            });
                          }
                        }
                      : null,
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    elevation: 10,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: touchWorks ? Colors.blue : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.login,
                            color: Colors.black,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('LOGIN')
                        ],
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: touchWorks
                      ? () async {
                    final provider = Provider.of<GoogleSignInProvider>(
                        context,
                        listen: false);
                    final userCredential = await provider.googleLogin();
                    if (userCredential != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              AddOrEditPage(adding: true),
                        ),
                      );
                    }
                  }
                      : null,
                  child: Material(
                    borderRadius: BorderRadius.circular(10),
                    shadowColor: Colors.red,
                    elevation: 10,
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: touchWorks ? Color(0xFFEEEEEE) : Colors.grey,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            FontAwesomeIcons.google,
                            color: Colors.red,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text('Login with Google')
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                TextButton(
                  onPressed: touchWorks
                      ? () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SignUp(),
                            ),
                          );
                        }
                      : null,
                  child: Text(
                    'New User? Sign Up.',
                    style: TextStyle(
                      color: touchWorks ? Colors.blue : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            Center(
              child: top,
            )
          ],
        ),
      ),
    );
  }
}

class TextView extends StatelessWidget {
  final controller;
  final onChanged;
  final errorText;
  final showError;
  final hint;
  final prefixIcon;
  final keyboardType;
  final enabled;

  TextView(
      {this.controller,
      this.onChanged,
      this.errorText,
      this.showError = false,
      this.hint,
      this.prefixIcon,
      this.keyboardType,
      this.enabled = true});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        keyboardType: keyboardType,
        enabled: enabled,
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          errorText: showError ? errorText : null,
          hintText: hint,
          prefixIcon: prefixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
