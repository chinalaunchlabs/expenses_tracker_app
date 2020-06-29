import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:expenses_tracker_app/pages/dashboard.dart';
import 'package:expenses_tracker_app/pages/onboarding.dart';

import 'package:expenses_tracker_app/services/api_client.dart';

import 'package:expenses_tracker_app/models/category.dart';

// for sqlite
import 'package:expenses_tracker_app/services/categories_db.dart';

class SplashPage extends StatefulWidget {
  @override
  _SplashPageState createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  // check if logged in or not
  Future<bool> loggedIn() async {
    // sync categories while we're at it
    syncCategories();

    SharedPreferences _prefs = await SharedPreferences.getInstance();
    return _prefs.containsKey("auth_token");
  }

  Future<void> syncCategories() {
    ApiClient
        .getCategories()
        .then(
          (categories) async
          {
            for (int i = 0; i < categories.length; i++) {
              await CategoriesDatabase.instance.insert(categories[i]);
            }

            CategoriesDatabase.categories = await CategoriesDatabase.instance.fetchAll();
          }
        )
        .catchError((error) {
          print("Error fetching categories: ${error}");
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
            future: loggedIn(),
            builder: (context, snapshot) {
              bool loggedIn = snapshot.data;

              if (snapshot.connectionState == ConnectionState.done) {
                if (loggedIn) {
                  return DashboardPage();
                } else {
                  return OnboardingPage();
                }
              }

              return Center(child: CircularProgressIndicator());
            }
        )
    );
  }
}
