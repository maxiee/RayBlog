import 'dart:io';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:ray_blog/data/article.dart';
import 'package:ray_blog/data/common.dart';
import 'package:ray_blog/utils/util_file.dart';

class Database {
  late Box<Article> boxArticle;

  Database() {
    Future(() async {
      // 初始化配置目录
      File rayBlogDir = FileUtils.rayBlogDir();
      File databaseDir = FileUtils.join(rayBlogDir.path, "Database");

      print('databaseDir = ${databaseDir.path}');
      FileUtils.createDirIfNotExist(databaseDir);

      Hive.init(databaseDir.path);

      Hive.registerAdapter(ArticleAdapter());
      boxArticle = await Hive.openBox(BOX_ARTICLE);
    });
  }
}
