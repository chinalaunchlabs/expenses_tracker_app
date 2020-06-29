import 'package:expenses_tracker_app/models/category.dart';
import 'package:expenses_tracker_app/services/categories_db.dart';
import 'package:intl/intl.dart';

class Record {
  final id;
  final String notes;
  final double amount;
  final int recordType;
  final DateTime date;
  final int categoryId;

  Category _category;

  Category get category {
    return _category;
  }

  Record({this.id, this.notes, this.amount, this.recordType, this.date, this.categoryId});

  factory Record.fromJson(Map<String, dynamic> json) {
    Record r = Record(
      id: json['id'],
      notes: json['notes'],
      amount: json['amount'],
      recordType: json['record_type'],
      categoryId: json['category']['id'],
      date: new DateFormat("yyyy-MM-ddThh:mm:ss").parse(json["date"])
    );
    r.getCategory();
    return r;
  }

  Category getCategory() {
    _category = CategoriesDatabase.categories.where((c) => c.id == categoryId).toList()[0];
  }

//  Future<Category> getCategory() async {
////    print("Getting category...");
//    _category = await CategoriesDatabase.instance.fetch(categoryId);
////    print("Category: ${_category.name}");
//    return _category;
//  }

  Map<String, dynamic> toJson() =>
      {
        'amount': amount,
        'record_type': recordType,
        'date': date.toIso8601String(),
        'notes': notes,
        'category_id': categoryId
      };
}