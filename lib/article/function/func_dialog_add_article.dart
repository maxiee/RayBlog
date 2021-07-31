import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ray_blog/data/article.dart';
import 'package:ray_blog/data/database.dart';
import 'package:ray_blog/net/api_wiki.dart';

Future<void> addArticle(BuildContext context) async {
  String articleTitle = (await showTextInputDialog(
              context: context,
              textFields: [
                const DialogTextField(hintText: '文章名称'),
              ],
              title: '添加文章'))
          ?.first ??
      '';

  if (articleTitle.isEmpty) return;

  Map<String, dynamic> pageInfo =
      await GetIt.I.get<ApiWiki>().getPageInfo(articleTitle);
  int pageId = GetIt.I.get<ApiWiki>().getPageIdFromPageInfo(pageInfo);
  print(pageId);

  await GetIt.I.get<Database>().boxArticle.add(Article()..pageId = pageId);
}
