import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:expenses_tracker_app/services/api_client.dart';
import 'package:expenses_tracker_app/models/record.dart';

class RecordWidget extends StatelessWidget {
  final Record record;
  final _formKey = GlobalKey<FormState>();

  NumberFormat f = NumberFormat.currency(locale: "en_US", symbol: "₱",);

  RecordWidget({this.record});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Stack(
        children: <Widget>[
          Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(DateFormat("MMMM d, yyyy").format(record.date),
                    style: TextStyle(
                        fontSize: 11.0,
                        color: Colors.black45
                    )
                ),
              )
          ),
          ListTile(
            subtitle: Text.rich(
                TextSpan(
                    children: <TextSpan>[
                      TextSpan(text: record.category.name,
                          style: TextStyle(
                              fontSize: 12.0,
                              color: Colors.black38
                          )
                      ),
                      record.notes != "" ?
                      TextSpan(text: ' — ${record.notes}',
                          style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12.0

                          )
                      ) : TextSpan(),
                    ]
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis
            ),
            title: Text(f.format(record.amount),
                style: TextStyle(
                    color: record.recordType == 0 ? Colors.green : Colors.red,
                    fontWeight: FontWeight.bold
                )
            ),
            leading: Image.network('${Urls.BASE_URL}${record.category.icon}', height: 35),
          ),
        ]
      )
    );
  }
}