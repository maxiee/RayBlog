import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:ray_blog/data/database.dart';
import 'package:ray_blog/generator/model/article_revision.dart';
import 'package:ray_blog/net/api_wiki.dart';
import 'package:ray_blog/parser/html/parse_webpage.dart';
import 'package:ray_blog/utils/util_file.dart';

const TEMPLATE_SIDE_BAR = '\$SIDE_BAR';
const TEMPLATE_SIDE_BAR_CATEGORIES = '\$SIDEBAR_CATEGORIES';
const TEMPLATE_FEEDS = '\$FEEDS';
const TEMPLATE_FEED_TITLE = '\$FEED_TITLE';
const TEMPLATE_FEED_COMMENT = '\$FEED_COMMENT';
const TEMPLATE_FEED_TIME = '\$FEED_TIME';
const TEMPLATE_POST = '\$POST';
const TEMPLATE_POST_TITLE = '\$TITLE';
const TEMPLATE_NAV_BAR = '\$NAV_BAR';

const CAPTURE_HOST = "http://omv.local:8035/localhost/v3/page/html/";

class Generator {
  static String readFileContent(Directory dir, String fileName) {
    File file = FileUtils.join(dir.path, fileName);
    return file.readAsStringSync();
  }

  late final String templateIndex; // 首页模板
  late final String templateSidebar; // 侧边栏模板
  late final String templateFeedItem; // Feed 单元模板
  late final String templateNavBar; // 导航栏模板
  late final String templatePost;

  late final Directory siteOutputDir;

  // query 页面信息缓存
  Map<String, Map<String, dynamic>> pageInfoMap = {};
  // revision 缓存
  Map<String, List<Map<String, dynamic>>> pageRevisionMap = {};
  // 所有文章的修订历史
  List<ArticleRevision> articlerevisions = [];
  // 所有文章从 MediaWiki 捕获后，经过解析器解析后的缓存
  Map<String, String> articleContents = {};
  // 文章分类信息缓存
  Map<String, List<String>> articleCategoriesMap = {};
  // 以分类维度梳理文章
  Map<String, List<String>> categoriesMap = {};

  Generator() {
    // 加载站点目录
    Directory siteDir = FileUtils.raySiteTemplateDir();
    siteOutputDir = FileUtils.raySiteOutputDir();

    FileUtils.createDirIfNotExist(File(siteOutputDir.path));

    templateIndex = readFileContent(siteDir, 'index.html');
    templateSidebar = readFileContent(siteDir, 'sidebar.html');
    templateFeedItem = readFileContent(siteDir, 'feed_item.html');
    templatePost = readFileContent(siteDir, 'post.html');
    templateNavBar = readFileContent(siteDir, 'navbar.html');

    print('模板加载完毕');
  }

  generate() async {
    print('开始生成');
    print('调用 MediaWiki API 获取文章元信息');
    await collectArticles();
    print('收集文章分类信息');
    await collectArticleCategories();
    print('调用 MediaWiki API 获取文章修订信息');
    await generateRevisions();
    print('调用 Single 获取文章网页');
    await captureWebPages();
    print('解析网页');
    await parseWebPages();
    print('生成文章页');
    await generateArticlePages();
    print('生成分类页');
    await generateCategoriesPage();
    // print('生成首页');
    await generateIndex();
    print('生成完成');
  }

  ///  收集文章信息
  collectArticles() async {
    for (final article in GetIt.I.get<Database>().boxArticle.values) {
      print('文章:${article.titleZh}');
      // 获取文章 PageInfo
      Map<String, dynamic> pageInfo =
          await GetIt.I.get<ApiWiki>().getPageInfoByTitle(article.titleZh!);

      pageInfoMap.putIfAbsent(article.titleZh!, () => pageInfo);

      print('获取文章 Revisions');
      List<Map<String, dynamic>> revisions =
          await GetIt.I.get<ApiWiki>().getPageRevisions(article.titleZh!);
      pageRevisionMap.putIfAbsent(article.titleZh!, () => revisions);
      // print(revisions);
    }
  }

  /// 收集文章分类信息
  collectArticleCategories() async {
    for (final article in pageInfoMap.keys) {
      List<String> categories =
          await GetIt.I.get<ApiWiki>().getPageCategories(article);
      // print(categories.toString());
      articleCategoriesMap.putIfAbsent(article, () => categories);
    }
    for (final article in articleCategoriesMap.keys) {
      List<String> categories = articleCategoriesMap[article] ?? [];
      for (final cat in categories) {
        if (!categoriesMap.containsKey(cat)) {
          categoriesMap.putIfAbsent(cat, () => []);
        }
        categoriesMap[cat]!.add(article);
      }
    }
    categoriesMap = Map.fromEntries(categoriesMap.entries.toList()
      ..sort((e1, e2) => e1.value.length.compareTo(e2.value.length)));
    print(categoriesMap);
  }

  /// 生成所有文章的 Revisions
  generateRevisions() async {
    for (final articleTitle in pageRevisionMap.keys) {
      // todo 对同一天里对 revision 进行合并
      List<ArticleRevision> tempReivisions = [];

      DateTime? revisionDatetime;
      List<String> revisionMerged = [];
      for (final revisions in pageRevisionMap[articleTitle]!) {
        String timestampString = revisions['timestamp'] as String;
        DateTime dateTime = DateTime.parse(timestampString);
        String comment = revisions['comment'];

        if (comment.isEmpty) continue;

        // 如果合并缓存为空，则初始化并开始下一次遍历
        if (revisionDatetime == null) {
          revisionDatetime = dateTime;
          revisionMerged.add(comment);
          continue;
        }

        // 如果缓存不为空，当前修订与缓存同一天，那么添加修订缓存
        if (revisionDatetime.year == dateTime.year &&
            revisionDatetime.month == dateTime.month &&
            revisionDatetime.day == dateTime.day) {
          if (!revisionMerged.contains(comment)) revisionMerged.add(comment);
          continue;
        }

        // 如果当前修订是新的一天了，先清已有缓存，再把自己加进去
        if (revisionMerged.isNotEmpty) {
          tempReivisions.add(ArticleRevision(
              articleTitle,
              revisionDatetime.toString(),
              revisionDatetime.millisecondsSinceEpoch,
              revisionMerged.join('<br/>')));
          revisionMerged.clear();
        }
        revisionDatetime = dateTime;
        if (!revisionMerged.contains(comment)) revisionMerged.add(comment);
      }

      // 遍历完再把缓存里残存的提交上去
      if (revisionMerged.isNotEmpty) {
        tempReivisions.add(ArticleRevision(
            articleTitle,
            revisionDatetime.toString(),
            revisionDatetime!.millisecondsSinceEpoch,
            revisionMerged.join('<br/>')));
        revisionMerged.clear();
        revisionDatetime = null;
      }
      articlerevisions.addAll(tempReivisions);
    }
    articlerevisions.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    articlerevisions = articlerevisions.reversed.toList();
  }

  captureWebPages() async {
    Directory rayCaptureDir = FileUtils.raySiteCaptureDir();
    // 删除当前目录下的所有文件
    for (final file in rayCaptureDir.listSync()) {
      file.deleteSync();
    }
    rayCaptureDir.createSync(recursive: true);
    for (final article in pageInfoMap.keys) {
      await Process.run('single-file', [
        CAPTURE_HOST + article,
        FileUtils.join(rayCaptureDir.path, article).path + '.html',
        '--browser-executable-path="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"'
      ]);
    }
  }

  /// 解析网页
  parseWebPages() async {
    articleContents.clear();
    for (final article in pageInfoMap.keys) {
      print(article);
      Directory rayCaptureDir = FileUtils.raySiteCaptureDir();
      File articleFile =
          File(FileUtils.join(rayCaptureDir.path, article).path + '.html');
      String rawHtml = articleFile.readAsStringSync();
      articleContents.putIfAbsent(
          article, () => ParserWebPage.parseWebPage(rawHtml, article));
      // File testOutput = File(FileUtils.join(rayCaptureDir.path, article).path +
      //     '-test-output.html');
      // testOutput.writeAsStringSync(articleContents[article]!, encoding: utf8);
    }
  }

  generateArticlePages() async {
    for (final article in articleContents.keys) {
      String content = articleContents[article]!;
      String output = generateSideBar(templatePost);
      output = output.replaceAll(TEMPLATE_POST, content);
      output = output.replaceAll(TEMPLATE_NAV_BAR, templateNavBar);
      output = output.replaceAll(TEMPLATE_POST_TITLE, article);
      File articleFile = FileUtils.join(siteOutputDir.path, '$article.html');
      articleFile.writeAsStringSync(output, mode: FileMode.write, flush: true);
    }
  }

  generateCategoriesPage() async {
    for (final cat in categoriesMap.keys) {
      List<String> articles = categoriesMap[cat]!;
      String categoryOutput = articles
          .map((e) => '<p></p><a href="/$e.html">$e</a></p>')
          .join('<br/>');
      categoryOutput = '<h1>$cat</h1>' + categoryOutput;

      String output = generateSideBar(templatePost);
      output = output.replaceAll(TEMPLATE_POST_TITLE, cat);
      output = output.replaceAll(TEMPLATE_POST, categoryOutput);
      output = output.replaceAll(TEMPLATE_NAV_BAR, templateNavBar);
      File categoryFile = FileUtils.join(siteOutputDir.path, '$cat.html');
      categoryFile.writeAsStringSync(output, mode: FileMode.write, flush: true);
    }
  }

  /// 生成侧边栏
  String generateSideBar(String html) {
    return html.replaceAll(
        TEMPLATE_SIDE_BAR,
        templateSidebar.replaceAll(
            TEMPLATE_SIDE_BAR_CATEGORIES,
            categoriesMap.entries
                .map((e) =>
                    '<li><a href="/${e.key}.html">${e.key.replaceAll('Category:', '')}(${e.value.length})</a></li>')
                .toList()
                .join('\n')));
  }

  /// 生成首页
  generateIndex() async {
    // 首页 Feed 流生成
    List<String> feeds = [];
    for (final revision in articlerevisions) {
      String feedItem = templateFeedItem;
      feedItem = feedItem.replaceAll(TEMPLATE_FEED_TITLE, revision.title);
      feedItem = feedItem.replaceAll(TEMPLATE_FEED_COMMENT, revision.comment);
      feedItem = feedItem.replaceAll(TEMPLATE_FEED_TIME, revision.timeString);
      feeds.add(feedItem);
    }

    String indexWithSidebar = templateIndex;
    indexWithSidebar = generateSideBar(indexWithSidebar);
    indexWithSidebar =
        indexWithSidebar.replaceAll(TEMPLATE_FEEDS, feeds.join('\n'));
    indexWithSidebar =
        indexWithSidebar.replaceAll(TEMPLATE_NAV_BAR, templateNavBar);

    File indexOutput = FileUtils.join(siteOutputDir.path, 'index.html');
    indexOutput.writeAsStringSync(indexWithSidebar,
        mode: FileMode.write, flush: true);
  }
}
