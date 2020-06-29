import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading/indicator/line_scale_pulse_out_indicator.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';

import 'package:expenses_tracker_app/services/categories_db.dart';
import 'package:expenses_tracker_app/models/record.dart';
import 'package:expenses_tracker_app/models/category.dart';
import 'package:expenses_tracker_app/services/api_client.dart';
import 'package:expenses_tracker_app/pages/categories.dart';

class CreateRecordPage extends StatefulWidget {
  CreateRecordPage({this.title, this.record});

  final Record record;
  final String title;

  @override
  _CreateRecordPageState createState() => _CreateRecordPageState();
}

class _CreateRecordPageState extends State<CreateRecordPage> {
  final _formKey = GlobalKey<FormState>();
  bool _loading = false;

  double _amount = 0.0;
  int _recordType = 0;
  String _notes = "";
  DateTime _date = DateTime.now();
  Category _category;
  List<bool> isSelected = [true, false];

  TextEditingController _notesController = new TextEditingController();
  TextEditingController _amountController = new TextEditingController();
  TextEditingController _dateController = new TextEditingController();
  TextEditingController _timeController = new TextEditingController();
  TextEditingController _categoryController = new TextEditingController();

  @override
  void initState() {
    super.initState();

    fillInFields();
  }

  void fillInFields() async {
    if (widget.record != null) {
      Record r = widget.record;
      _amount = r.amount;
      _recordType = r.recordType;
      _notes = r.notes;
      _date = r.date;
      _category = r.category;

      isSelected = [false, false];
      isSelected[_recordType] = true;

      _notesController.text = _notes;
      _amountController.text = _amount.toString();
    } else {
      _category = await CategoriesDatabase.instance.getDefault();
    }

    _categoryController.text = _category.name;
    _dateController.text = DateFormat("MMM dd yyyy").format(_date);
    _timeController.text = DateFormat("hh:mm").format(_date);

  }

  void _createRecord() async {
    print("Creating record...");
    setState(() {
      _loading = true;
    });
    await Future.delayed(Duration(milliseconds: 1000));
    ApiClient.createRecord(_buildRecord()).then((value)
    {
      // show success dialog
      _loading = false;
      Navigator.pop(context, true);
    }).catchError( (error) {
      _loading = false;
      // show error dialog
    });
  }

  void _editRecord() async {
    print("Editing record...");
    setState(() {
      _loading = true;
    });
    await Future.delayed(Duration(milliseconds: 1000));
    ApiClient.editRecord(_buildRecord()).then((value)
    {
      // show success dialog
      setState(() {
        _loading = false;
      });
      Navigator.pop(context, true);
    }).catchError( (error) {
      _loading = false;
      // show error dialog
    });
  }

  void _deleteRecord() async {
    setState(() {
      _loading = true;
    });
    await Future.delayed(Duration(milliseconds: 1000));
    ApiClient.deleteRecord(widget.record).then((value)
    {
      // show success dialog
      setState(() {
        _loading = false;
      });
      Navigator.pop(context, true);
    }).catchError( (error) {
      _loading = false;
      // show error dialog
    });

  }

  Record _buildRecord() {
    if (widget.record != null) {
      return Record(id: widget.record.id,
          notes: _notes,
          amount: _amount,
          recordType: _recordType,
          date: _date,
          categoryId: _category.id);
    } else {
      return Record(notes: _notes,
          amount: _amount,
          recordType: _recordType,
          date: _date,
          categoryId: _category.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        centerTitle: true,
        title: Text(widget.title),
        actions: <Widget>[
          widget.record != null ? IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              _deleteRecord();
            },
          ) : SizedBox(),

          IconButton(
            icon: Icon(Icons.check),
            onPressed: () {
              if (widget.record != null) {
                _editRecord();
              } else {
                _createRecord();
              }
            },
          )
        ]
      ),
      body: Stack(
        children: [

          Padding(
            padding: EdgeInsets.symmetric(vertical: 10, horizontal: 50.0),
            child: Container(
              child: Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    Container(
                      width: MediaQuery.of(context).size.width - 100,
                      child: ToggleButtons(
                        children: <Widget>[
                          Container(child: Center(child: Text("Income")), width: (MediaQuery.of(context).size.width - 110)/2),
                          Container(child: Center(child: Text("Expense")), width: (MediaQuery.of(context).size.width - 100)/2),
                        ],
                        onPressed: (index) {
                          setState(() {
                            isSelected = [false, false];
                            isSelected[index] = !isSelected[index];
                          });

                          _recordType = index;
                        },
                        isSelected: isSelected,
                      ),
                    ),

                    TextFormField(
                      maxLines: null,
                      controller: _notesController,
                      decoration: const InputDecoration(
                          labelText: 'Notes'
                      ),
                      onChanged: (value) {
                        _notes = value;
                      },
                    ),

                    SizedBox(height: 5),

                    TextFormField(
                      controller: _amountController,
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                      ),
                      keyboardType: TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter an amount.';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        _amount = double.parse(value);
                      },
                    ),

                    SizedBox(height: 5),

                    Row(
                      children: <Widget>[
                        Expanded(
                          child: TextFormField(
                            controller: _dateController,
                            decoration: const InputDecoration(
                                labelText: 'Date'
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter an amount.';
                              }
                              return null;
                            },
                            onTap: () {
                              DatePicker.showDatePicker(context,
                                initialDateTime: _date,
                                dateFormat: "MMM dd yyyy",
                                onConfirm: (dateTime, List<int> index) {
                                  _dateController.text = DateFormat("MMM dd yyyy").format(dateTime);
                                  setState(() {
                                    _date = new DateTime(dateTime.year, dateTime.month, dateTime.day, _date.hour, _date.minute, 0);
                                  });
                                },
                              );
                            },
                          ),
                        ),

                        SizedBox(width: 20),

                        Expanded(
                          child: TextFormField(
                            controller: _timeController,
                            decoration: const InputDecoration(
                                labelText: 'Time'
                            ),
                            validator: (value) {
                              if (value.isEmpty) {
                                return 'Please enter an amount.';
                              }
                              return null;
                            },
                            onTap: () {
                              DatePicker.showDatePicker(context,
                                initialDateTime: _date,
                                pickerMode: DateTimePickerMode.time,
                                dateFormat: "HH:mm",
                                onConfirm: (dateTime, List<int> index) {
                                  _timeController.text = DateFormat('kk:mm').format(dateTime);
                                  setState(() {
                                    _date = new DateTime(_date.year, _date.month, _date.day, dateTime.hour, dateTime.minute, 0);
                                  });
                                },
                              );
                            },
                          ),
                        )

                      ],
                    ),

                    SizedBox(height: 5),

                    TextFormField(
                      controller: _categoryController,
                      enableInteractiveSelection: false,
                      decoration: const InputDecoration(
                          labelText: 'Category'
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter an amount.';
                        }
                        return null;
                      },
                      onTap: () async {
                        _category = await Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => CategoriesPage(title: 'Select Category', selectedCategory: _category,)),
                        ) as Category;

                        setState(() {
                          _categoryController.text = _category.name;
                        });
                      }
                    ),

                  ]
                )
              ),
            ),
          ),

          _loading ?
          Container(
              color: Colors.grey[350].withOpacity(0.5),
              child: Center(
                  child: Loading(indicator: LineScalePulseOutIndicator(), size: 50.0, color: Colors.teal)
              )
          ) : SizedBox(),
        ]
      )
    );
  }
}
