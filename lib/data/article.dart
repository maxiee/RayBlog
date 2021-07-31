import 'package:hive_flutter/hive_flutter.dart';
import 'package:ray_blog/data/common.dart';

part 'article.g.dart';

@HiveType(typeId: TYPE_ID_ARTICLE)
class Article {
  // 文章中文标题
  @HiveField(0)
  String? titleZh;

  // 文章英文标题
  @HiveField(1)
  String? titleEn;
}
