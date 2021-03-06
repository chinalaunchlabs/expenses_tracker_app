import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'package:fancy_dialog/FancyAnimation.dart';
import 'package:fancy_dialog/FancyGif.dart';
import 'package:fancy_dialog/FancyTheme.dart';
import 'package:fancy_dialog/fancy_dialog.dart';

import 'package:expenses_tracker_app/services/api_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expenses_tracker_app/pages/dashboard.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();

  String _email = "";
  String _password = "";

  @override
  Widget build(BuildContext context) {

    return Scaffold(
        resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          leading: BackButton(
              color: Colors.teal
          ),
          backgroundColor: Color(0xffE3F7F1),
          elevation: 0
        ),
        body: Form(
            key: _formKey,
            child: Container(
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                  color: Color(0xffE3F7F1)
              ),
              child: Column(
                  children: <Widget>[

                    SizedBox(height: 55),

                    Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                fit: BoxFit.fill,
                                image: AssetImage('images/app_icon.png')
                            )
                        )
                    ),

                    SizedBox(height: 10),

                    Text('WALLET',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24.0,
                            color: Colors.teal[500]
                        )
                    ),

                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50.0),
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                                labelText: 'Email'
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter your email.';
                              }

                              return null;
                            },
                            onChanged: (value) {
                              _email = value;
                            },
                          ),
                          TextFormField(
                            obscureText: true,
                            decoration: const InputDecoration(
                                labelText: 'Password'
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter a password.';
                              }

                              return null;
                            },
                            onChanged: (value) {
                              _password = value;
                            },
                          ),
                        ]
                      )
                    ),

                    SizedBox(height: 50),

                    ButtonTheme(
                        minWidth: 300.0,
                        height: 50.00,
                        child: RaisedButton(
                          color: Colors.white,
                          child: Text(
                              'LOGIN',
                              style: TextStyle (
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18.0
                              )
                          ),
                          onPressed: () {
                            ApiClient.login(_email, _password).then(
                                  (response) async {
                                // save auth token
                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.setString("auth_token", response);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => DashboardPage()),
                                );
                              }
                            ).catchError(
                                    (onError) {
                                  print("Error: ${onError}");
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        title: Text("Error"),
                                        content: Text(onError),
                                        actions: [
                                          FlatButton(
                                            child: Text("Okay"),
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                          )
                                        ]
                                      );
                                    }

                                  );
                                }
                            );
                          },
                        )
                    ),


                  ]
              )
            )
        )
    );

  }
}
