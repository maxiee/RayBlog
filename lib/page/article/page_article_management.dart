import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ray_blog/data/article.dart';
import 'package:ray_blog/data/database.dart';

class PageArticleManagement extends StatefulWidget {
  const PageArticleManagement({Key? key}) : super(key: key);

  @override
  _PageArticleManagementState createState() => _PageArticleManagementState();
}

class _PageArticleManagementState extends State<PageArticleManagement> {
  List<Article> articles = [];

  @override
  void initState() {
    super.initState();
    setState(() {
      articles = GetIt.I.get<Database>().boxArticle.values.toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("文章管理"),
      ),
      body: ListView(
        children: articles
            .map((e) => ListTile(
                  title: Text(e.pageId!.toString()),
                ))
            .toList(),
      ),
    );
  }
}
