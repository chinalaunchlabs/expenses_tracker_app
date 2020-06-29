class Category {
  final id;
  final String icon;
  final String name;

  const Category({this.id, this.name, this.icon});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as int,
      name: json['name'] as String,
      icon: json['icon'] as String,
    );
  }

  Map<String, dynamic> toJson() =>
      {
        'id': id,
        'name': name,
        'icon': icon
      };

}