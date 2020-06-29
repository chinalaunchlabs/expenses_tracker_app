import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expenses_tracker_app/models/record.dart';
import 'package:expenses_tracker_app/widgets/record_widget.dart';






class RecordsList extends StatefulWidget {
  final List<Record> records;
  final RecordsListCallback onItemTapped;
  final Function onLastItemReached;

  RecordsList({this.records, this.onItemTapped, this.onLastItemReached});

  @override
  _RecordsListState createState() => _RecordsListState();
}

class _RecordsListState extends State<RecordsList> {
  List<Record> _records;

  ScrollController _scrollController;

  _scrollListener() {
    if (_scrollController.offset >= _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      print("Last item reached!");
      widget.onLastItemReached();
    }
  }

  @override
  initState() {
    super.initState();
    print("Records List reloaded");
    _records = widget.records;
    _scrollController = ScrollController(
      keepScrollOffset: true
    );
    _scrollController.addListener(_scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
        controller: _scrollController,
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        itemBuilder: (context, index) {
          Record r = _records[index];
          return GestureDetector(
              onTap: () async {
                widget.onItemTapped(r);
              },
              child: RecordWidget(record: r)
          );
        },
        separatorBuilder: (context, index) {
          return Divider(
              height: 0,
              color: Colors.grey[300]
          );
        }, itemCount: _records.length
    );
  }
}

typedef RecordsListCallback = void Function(Record record);