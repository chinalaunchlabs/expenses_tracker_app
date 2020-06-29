import 'package:flutter/material.dart';
import 'package:expenses_tracker_app/widgets/records_list.dart';
import 'package:expenses_tracker_app/services/api_client.dart';
import 'package:expenses_tracker_app/models/record.dart';
import 'package:expenses_tracker_app/pages/create_record.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/line_scale_pulse_out_indicator.dart';

import 'package:incrementally_loading_listview/incrementally_loading_listview.dart';
import 'dart:async';

class RecordsPage extends StatefulWidget {
  @override
  _RecordsPageState createState() => _RecordsPageState();
}

class _RecordsPageState extends State<RecordsPage> {
  final _formKey = GlobalKey<_RecordsPageState>();
  Future<List<Record>> _records;
  List<Record> records = [];

  int _page = 1;
  int _totalPages = -1;
  String _query;
  bool _hasMore = false;
  bool _loading = false;
  bool _dirty = false;

  @override
  void initState() {
    super.initState();

    _records = _fetchRecords(1);
    _searchQuery.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchQuery.removeListener(_onSearchChanged);
    _searchQuery.dispose();
    _debounce.cancel();
    super.dispose();
  }

  Future<List<Record>> _fetchRecords(int page) async {
    _page = page;

    if (_totalPages > 0 && _page > _totalPages) {
      return [];
    }

    setState(() {
      _loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 1000));

    var result = await ApiClient.getRecords(_page, _query);
    _totalPages = result.item2;
    _hasMore = _page < _totalPages;

    setState(() {
      _loading = false;
    });

    return result.item1;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      appBar: buildBar(context),
      body: FutureBuilder(
        key: _formKey,
        future: _records,
        builder: (context, snapshot) {
          final records = snapshot.data;

          if (snapshot.connectionState == ConnectionState.done) {

            if (records.length == 0 && _query == null) {
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
                                    setState(() {
                                      _records = _fetchRecords(1);
                                    });
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

            return Stack(
              children: [
                _loading ? Center(
                  child: Loading(indicator: LineScalePulseOutIndicator(), size: 50, color: Colors.blueGrey)
                ) : SizedBox(),

              RecordsList(records: records,
              onLastItemReached: () async {
                _page += 1;
                var _newRecords = await _fetchRecords(_page);
                if (_newRecords.length > 0) {
                  setState(() {
                    records.addAll(_newRecords);
                  });
                }
              },
              onItemTapped: (r) async {
                bool reload = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateRecordPage(title: "Edit Record", record: r)),
                );

                if (reload) {
                  _dirty = true;
                  setState(() {
                    _records = _fetchRecords(1);
                  });
                }
              },
            )
            ]
            );
          }

          return Center(
            child: Loading(indicator: LineScalePulseOutIndicator(), size: 50, color: Colors.blueGrey)
          );
        }
      )
    );
  }


  bool _isSearchOpen = false;
  Widget appBarTitle = Text("Records");
  TextEditingController _searchQuery = new TextEditingController();
  Timer _debounce;

  //https://stackoverflow.com/questions/51791501/how-to-debounce-textfield-onchange-in-dart
  _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      // do something with _searchQuery.text
      if (_searchQuery.text == "") return;

      _query = _searchQuery.text;
      _page = 1;
      setState(() {
        _records = _fetchRecords(1);
      });
    });
  }

  // https://stackoverflow.com/questions/49966980/how-to-create-toolbar-searchview-in-flutter
  Widget buildBar(BuildContext context) {
    return new AppBar(
      centerTitle: true,
      title: appBarTitle,
      leading: BackButton(onPressed: () => Navigator.pop(context, _dirty),),
      actions: <Widget>[
        IconButton(
          icon: _isSearchOpen ? Icon(Icons.close) : Icon(Icons.search),
          onPressed: () {
            setState(() {
              if (_isSearchOpen) {
                _isSearchOpen = false;
                appBarTitle = Text("Records");

                // reset query
                _query = null;
                setState(() {
                  _records = _fetchRecords(1);
                });

              } else {
                _isSearchOpen = true;

                appBarTitle = new TextField(
                  controller: _searchQuery,
                  style: new TextStyle(
                    color: Colors.white,

                  ),
                  onChanged: (value) {
                    print("search query: ${value}");
                  },
                  decoration: new InputDecoration(
                      prefixIcon: new Icon(Icons.search, color: Colors.white),
                      hintText: "Search...",
                      hintStyle: new TextStyle(color: Colors.white)
                  ),
                );
              }
            });
          },
        )
      ]
    );
  }
}

