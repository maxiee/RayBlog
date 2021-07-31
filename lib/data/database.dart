import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ray_blog/data/article.dart';
import 'package:ray_blog/data/common.dart';

class Database {
  late Box<Article> boxArticle;

  Database() {
    Future(() async {
      await Hive.initFlutter('RayBlog');

      final homePath = await getApplicationDocumentsDirectory();
      debugPrint("HomePath = $homePath");

      Hive.registerAdapter(ArticleAdapter());
      boxArticle = await Hive.openBox(BOX_ARTICLE);
    });
  }
}
