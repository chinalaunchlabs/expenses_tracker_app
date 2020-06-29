import 'package:flutter/material.dart';
import 'package:expenses_tracker_app/services/api_client.dart';
import 'package:expenses_tracker_app/models/category.dart';
import 'package:expenses_tracker_app/services/categories_db.dart';

class CategoriesPage extends StatefulWidget {
  CategoriesPage({Key key, this.title, this.selectedCategory}) : super(key: key);

  final String title;
  final Category selectedCategory;

  @override
  _CategoriesPageState createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  Category _selectedCategory = null;
  Future<List<Category>> _categories;
  bool _selectionAllowed = false;

  @override
  initState() {
    _selectedCategory = widget.selectedCategory;
    _selectionAllowed = _selectedCategory != null;
    _categories = CategoriesDatabase.instance.fetchAll();
  }

  Color _getColor(Category category) {
    if (_selectedCategory == null) return Colors.transparent;

    Category selected = _selectedCategory;
    if (selected.id == category.id) {
      return Colors.lightBlue[100];
    } else {
      return Colors.transparent;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title)
      ),
      body: FutureBuilder(
        future: _categories,
        builder: (context, snapshot) {
          final categories = snapshot.data;

          if (snapshot.connectionState == ConnectionState.done) {
            return ListView.separated(
                itemBuilder: (context, index) {

                  return Material(
                    color: _getColor(categories[index]),
                    child: ListTile(
                      leading: Image.network('${Urls.BASE_URL}${categories[index].icon}', height: 35),
                      title: Text(categories[index].name),
                      onTap: () {
                        print("Tapped '${categories[index].name}'");
                        setState(() {
                          if (_selectionAllowed) {
                            _selectedCategory = categories[index];
                            Navigator.pop(context, _selectedCategory);
                          }
                        });
                      },
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                      height: 0.5,
                      color: Colors.grey[300]
                  );
                }, itemCount: categories.length
            );
          }

          return Center(
            child: CircularProgressIndicator()
          );
        }
      ),
    );
  }
}