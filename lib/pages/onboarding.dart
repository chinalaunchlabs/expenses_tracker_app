import 'package:expenses_tracker_app/pages/login.dart';
import 'package:expenses_tracker_app/pages/registration.dart';
import 'package:flutter/material.dart';

class OnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
//    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark.copyWith(
//        statusBarColor: Colors.white, // Color for Android
//        statusBarBrightness: Brightness.dark // Dark == white status bar -- for IOS.
//    ));
    return Scaffold(
        body: Center(
        child: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
            color: Color(0xffE3F7F1)
          ),

          child: Column(
            children: [
              SizedBox(height: 150),

              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.fill,
                    image: AssetImage('images/app_icon.png')
                  )
                )
              ),

              SizedBox(height: 20),

              Text('WALLET',
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28.0,
                      color: Colors.black45
                  )
              ),
              SizedBox(height: 7),

              Text('Track your spending.',
                style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.black45
                )
              ),

              SizedBox(height: 2),

              Text('Plan your budget.',
                  style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.black45
                  )
              ),

              SizedBox(height: 190),

              ButtonTheme(
                minWidth: 300.0,
                height: 50.00,
                child: RaisedButton(
                  color: Colors.white,
                  child: Text(
                      'SIGN UP',
                      style: TextStyle (
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0
                      )
                  ),
                  onPressed: () {
                    print("Sign up");
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegistrationPage()),
                    );
                  },
                )
              ),

              SizedBox(height: 10),

              FlatButton(
                child: Text(
                  'I already have an account',
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.black45
                  )
                ),
                onPressed: () {
                  print("Sign in");
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                  );
                },
              )
            ],
          )
        )
      )
    );
  }
}