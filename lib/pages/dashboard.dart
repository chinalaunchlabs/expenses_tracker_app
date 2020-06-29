import 'package:flutter/material.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/line_scale_pulse_out_indicator.dart';
import 'package:expenses_tracker_app/pages/create_record.dart';
import 'package:expenses_tracker_app/pages/records.dart';
import 'package:expenses_tracker_app/pages/onboarding.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:expenses_tracker_app/services/api_client.dart';
import 'package:expenses_tracker_app/models/record.dart';
import 'package:expenses_tracker_app/widgets/record_widget.dart';
import 'package:expenses_tracker_app/widgets/records_list.dart';
import 'package:expenses_tracker_app/widgets/overview_chart.dart';

class DashboardPage extends StatefulWidget {
  DashboardPage();

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  Future<List<Record>> _records;
  Future<List<OverviewData>> _overview;
  bool _loading;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _records = _fetchRecords();
    _overview = _fetchOverview();
  }

  Future<List<Record>> _fetchRecords() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    return await ApiClient.getRecentRecords();
  }

  Future<List<OverviewData>> _fetchOverview() async {
    return await ApiClient.getOverview();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Home"),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            bool reload = await Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateRecordPage(title: "Add Record")),
            );

            if (reload) {
              setState(() {
                _records = _fetchRecords();
                _overview = _fetchOverview();
              });
            }
          },
          child: Icon(Icons.add)
        ),
        body: FutureBuilder(
            future: Future.wait([
              _records,
              _overview
            ]),
            builder: (context, snapshot) {

              if (snapshot.connectionState == ConnectionState.done) {
                final records = snapshot.data[0];
                final overview = snapshot.data[1];

                if (records.length == 0) {
                  return NoRecordsYetWidget(
                    onRecordAdded: () {
                      setState(() {
                        _records = _fetchRecords();
                        _overview = _fetchOverview();
                      });
                    },
                  );
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      
                      Padding(
                        padding: new EdgeInsets.symmetric(vertical: 10, horizontal: 12.0),
                        child: Card(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 5, 0, 0),
                                  child: Text("OVERVIEW",
                                      style: TextStyle(
                                          fontSize: 16.0,
                                          fontWeight: FontWeight.bold
                                      )
                                  ),
                                ),
                              ),
                              SizedBox(
                               height: 120.0,
                               child: Padding(
                                  padding: const EdgeInsets.fromLTRB(20,0,20,10),
                                  child: OverviewChart.withData(overview)
//                                 child: OverviewChart.withRandomData(),
                               )
                              ),
                            ],
                          ),
                        )
                      ),

                      Padding(
                        padding: new EdgeInsets.fromLTRB(12.0, 0, 12.0, 30),
                        child: Card(
                          child: Column(
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(10, 10, 0, 0),
                                  child: Text("RECENT",
                                    style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold
                                    )
                                  ),
                                ),
                              ),

                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child:  RecordsList(records: records,
                                    onItemTapped: (r) async {
                                      bool reload = await Navigator.push(
                                        context,
                                        MaterialPageRoute(builder: (context) => CreateRecordPage(title: "Edit Record", record: r)),
                                      );

                                      if (reload) {
                                        setState(() {
                                          _records = _fetchRecords();
                                          _overview = _fetchOverview();
                                        });
                                      }
                                    },
                                )
                              ),

                              Divider(
                                  height: 0,
                                  color: Colors.grey[300]
                              ),

                              FlatButton(
                                child: Text("View More"),
                                onPressed: () async {
                                  bool reload = await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => RecordsPage()),
                                  );

                                  if (reload) {
                                    setState(() {
                                      _records = _fetchRecords();
                                      _overview = _fetchOverview();
                                    });
                                  }
                                },
                              )
                            ]
                          )
                        )
                      ),
                      
                    ],
                  ),
                );
              }

              return Center(
                  child: Loading(indicator: LineScalePulseOutIndicator(), size: 50, color: Colors.blueGrey)
              );
            }
        ),
        drawer: Drawer(
            child: Container(
              constraints: BoxConstraints.expand(),
              decoration: BoxDecoration(
                  color: Colors.teal[500]
              ),
              child: ListView(
                  padding: EdgeInsets.fromLTRB(20, 200, 0, 0),
                  children: <Widget>[
                    ListTile(
                        leading: Icon(Icons.home, color: Colors.white),
                        title: Text('HOME',
                          style: TextStyle(
                            fontSize: 17.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          )
                        ),
                        onTap:() {
                          Navigator.pop(context);
                        }
                    ),

                    ListTile(
                        leading: Icon(Icons.category, color: Colors.white),
                        title: Text('RECORDS',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )
                        ),
                        onTap:() {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => RecordsPage()),
                          );
                        }
                    ),

                    ListTile(
                        leading: Icon(Icons.settings_power, color: Colors.white),
                        title: Text('LOGOUT',
                            style: TextStyle(
                              fontSize: 17.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            )
                        ),
                        onTap: () async {
                          SharedPreferences prefs = await SharedPreferences.getInstance();
                          prefs.clear();

                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (context) => OnboardingPage()),
                              ModalRoute.withName('/')
                          );
                        }
                    ),
//                    ListTile(
//                        title: Text('Records'),
//                        onTap:() {
//                          Navigator.push(
//                            context,
//                            MaterialPageRoute(builder: (context) => RecordsPage()),
//                          );
//                        }
//                    ),
//
//                    ListTile(
//                        title: Text('Log Out'),
//                        onTap: () async {
//                          SharedPreferences prefs = await SharedPreferences.getInstance();
//                          prefs.clear();
//
//                          Navigator.pushAndRemoveUntil(
//                            context,
//                            MaterialPageRoute(builder: (context) => OnboardingPage()),
//                            ModalRoute.withName('/')
//                          );
//                        }
//                    )
                  ]
              ),
            )
        )
    );
  }
}

class NoRecordsYetWidget extends StatelessWidget {
  final Function() onRecordAdded;

  NoRecordsYetWidget({this.onRecordAdded});

  @override
  Widget build(BuildContext context) {

    return Center(
      child: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            color: Color(0xffE3F7F1)
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  image: DecorationImage(
                      fit: BoxFit.fill,
                      image: AssetImage('images/empty_icon.png')
                  )
              )
            ),

            SizedBox(height: 20),
            Text(
              "There are no records here yet.",
              style: TextStyle(
                fontStyle: FontStyle.italic,
                fontSize: 16.0,
                color: Colors.black45,
              )
            ),

            SizedBox(height: 100),

            ButtonTheme(
                minWidth: 300.0,
                height: 50.00,
                child: RaisedButton(
                  color: Colors.white,
                  child: Text(
                      'START TRACKING',
                      style: TextStyle (
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0
                      )
                  ),
                  onPressed: () async {
                    bool reload = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CreateRecordPage(title: "Add Record")),
                    );

                    if (reload) {
                      onRecordAdded();
                    }
                  },
                )
            ),

            SizedBox(height: 100)
          ]
        ),
      )
    );

  }
}
