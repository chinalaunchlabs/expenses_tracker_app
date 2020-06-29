import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker_app/widgets/overview_chart.dart';
import 'package:http/http.dart' as http;
import 'package:expenses_tracker_app/models/category.dart';
import 'package:expenses_tracker_app/models/record.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class Urls {
//  static const String BASE_URL = "http://10.0.2.2:3000";
  static const String BASE_URL = "http://expenses.koda.ws";
  static const String RECORDS = "/api/v1/records";
  static const String CATEGORIES = "/api/v1/categories";
  static const String REGISTRATION = "/api/v1/sign_up";
  static const String LOGIN = "/api/v1/sign_in";
}

class ApiClient {

  static Future<String> register(String name, String email, String password) async {
    final response = await http.post('${Urls.BASE_URL}${Urls.REGISTRATION}', body: { "email": email, "name": name, "password" : password });
    print(response.body);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      print(json);
      return json["token"];
    } else {
      var json = jsonDecode(response.body);
      return Future.error(json["error"], StackTrace.fromString(response.body));
    }
  }

  static Future<String> login(String email, String password) async {
    final response = await http.post('${Urls.BASE_URL}${Urls.LOGIN}', body: { "email": email, "password" : password });
    print(response.body);
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      print(json);
      return json["token"];
    } else {
      var json = jsonDecode(response.body);
      return Future.error(json["error"], StackTrace.fromString(response.body));
    }
  }

  static Future<List<Category>> getCategories() async {
    final response = await http.get('${Urls.BASE_URL}${Urls.CATEGORIES}');
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      var list = List<Category>.from((json['categories'] as List).map((c) => Category.fromJson(c)));
      return list;
    } else {
      return null;
    }
  }

  static Future<int> createRecord(Record record) async  {
    String token = "";
    await SharedPreferences.getInstance().then((p) {
      token = p.getString('auth_token');
    });

    Map<String,dynamic> body = {
      "record": record.toJson()
    };
    var recordJson = jsonEncode(body);

    Map<String,String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token}'
    };

    final response = await http.post('${Urls.BASE_URL}${Urls.RECORDS}',
      headers: headers,
      body: recordJson
    );

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return json["id"];
    } else {
      var json = jsonDecode(response.body);
      return Future.error(json["error"], StackTrace.fromString(response.body));
    }
  }

  static Future<int> editRecord(Record record) async  {
    String token = "";
    await SharedPreferences.getInstance().then((p) {
      token = p.getString('auth_token');
    });

    Map<String,dynamic> body = {
      "record": record.toJson()
    };
    var recordJson = jsonEncode(body);
    print(recordJson);

    Map<String,String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token}'
    };

    final response = await http.patch('${Urls.BASE_URL}${Urls.RECORDS}/${record.id}',
        headers: headers,
        body: recordJson
    );
    print(response.body);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return json["id"];
    } else {
      var json = jsonDecode(response.body);
      return Future.error(json["error"], StackTrace.fromString(response.body));
    }
  }

  static Future<bool> deleteRecord(Record record) async  {
    String token = "";
    await SharedPreferences.getInstance().then((p) {
      token = p.getString('auth_token');
    });

    Map<String,String> headers = {
      'Content-type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer ${token}'
    };

    final response = await http.delete('${Urls.BASE_URL}${Urls.RECORDS}/${record.id}',
        headers: headers
    );
    print(response.body);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      return true;
    } else {
      var json = jsonDecode(response.body);
      return Future.error(json["error"], StackTrace.fromString(response.body));
    }
  }

  static Future<Tuple2<List<Record>, int>> getRecords(int page, String q) async {
    // TODO: Pagination
    String token = "";
    await SharedPreferences.getInstance().then((p) {
      token = p.getString('auth_token');
    });

    String url = '${Urls.BASE_URL}${Urls.RECORDS}?page=${page}';

    if (q != null) {
      url += '&q=${q}';
    }

    final response = await http.get(url,
      headers: { HttpHeaders.authorizationHeader: "Bearer ${token}" },
      );
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      var list = List<Record>.from((json['records'] as List).map((c) => Record.fromJson(c)));
      return new Tuple2(list, json["pagination"]["pages"]);
    } else {
      return null;
    }
  }

  static Future<List<Record>> getRecentRecords() async {
    String token = "";
    await SharedPreferences.getInstance().then((p) {
      token = p.getString('auth_token');
    });

    print(token);

    final response = await http.get('${Urls.BASE_URL}${Urls.RECORDS}?limit=5',
      headers: { HttpHeaders.authorizationHeader: "Bearer ${token}" },
    );
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      var list = List<Record>.from((json['records'] as List).map((c) => Record.fromJson(c)));
      return list;
    } else {
      return null;
    }
  }

  static Future<List<OverviewData>> getOverview() async {
    String token = "";
    await SharedPreferences.getInstance().then((p) {
      token = p.getString('auth_token');
    });

    final response = await http.get('${Urls.BASE_URL}${Urls.RECORDS}/overview',
      headers: { HttpHeaders.authorizationHeader: "Bearer ${token}" },
    );
    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      OverviewData incomeData = OverviewData(title: "Income", amount: json['income'], color: Colors.green);
      OverviewData expenseData = OverviewData(title: "Expense", amount: json['expenses'], color: Colors.red);
      return [incomeData, expenseData];
    } else {
      return null;
    }
  }
}