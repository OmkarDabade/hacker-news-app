import 'package:hive/hive.dart';

part 'Item.g.dart';

// Custom data type to store data locally
@HiveType(typeId: 0)
class Item extends HiveObject {
  @HiveField(0)
  int id;

  @HiveField(1)
  int time;

  @HiveField(2)
  int score;

  @HiveField(3)
  String title;

  @HiveField(4)
  String url;

  @HiveField(5)
  String author;

  @HiveField(6)
  List kids;

  Item(
      {this.id,
      this.title,
      this.url,
      this.author,
      this.kids,
      this.time,
      this.score});
}
