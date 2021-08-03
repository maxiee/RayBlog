import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:ray_blog/data/database.dart';
import 'package:ray_blog/generator/model/article_revision.dart';
import 'package:ray_blog/net/api_wiki.dart';
import 'package:ray_blog/utils/util_file.dart';

const TEMPLATE_SIDE_BAR = '\$SIDE_BAR';
const TEMPLATE_FEEDS = '\$FEEDS';
const TEMPLATE_FEED_TITLE = '\$FEED_TITLE';
const TEMPLATE_FEED_COMMENT = '\$FEED_COMMENT';
const TEMPLATE_FEED_TIME = '\$FEED_TIME';

const CAPTURE_HOST = "http://omv.local:9080/index.php/";

class Generator {
  static String readFileContent(Directory dir, String fileName) {
    File file = FileUtils.join(dir.path, fileName);
    return file.readAsStringSync();
  }

  late final String templateIndex; // 首页模板
  late final String templateSidebar; // 侧边栏模板
  late final String templateFeedItem; // Feed 单元模板
  late final Directory siteOutputDir;

  // query 页面信息缓存
  Map<String, Map<String, dynamic>> pageInfoMap = {};
  // revision 缓存
  Map<String, List<Map<String, dynamic>>> pageRevisionMap = {};
  // 所有文章的修订历史
  List<ArticleRevision> articlerevisions = [];

  Generator() {
    // 加载站点目录
    Directory siteDir = FileUtils.raySiteTemplateDir();
    siteOutputDir = FileUtils.raySiteOutputDir();

    FileUtils.createDirIfNotExist(File(siteOutputDir.path));

    templateIndex = readFileContent(siteDir, 'index.html');
    templateSidebar = readFileContent(siteDir, 'sidebar.html');
    templateFeedItem = readFileContent(siteDir, 'feed_item.html');

    print('模板加载完毕');
  }

  generate() async {
    print('开始生成');
    print('调用 MediaWiki API 获取文章元信息');
    await collectArticles();
    print('调用 MediaWiki API 获取文章修订信息');
    await generateRevisions();
    print('调用 Single 获取文章网页');
    await captureWebPages();
    print('生成首页');
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
      print(revisions);
    }
  }

  /// 生成所有文章的 Revisions
  generateRevisions() async {
    for (final articleTitle in pageRevisionMap.keys) {
      // todo 对同一天里对 revision 进行合并
      for (final revisions in pageRevisionMap[articleTitle]!) {
        String timestampString = revisions['timestamp'] as String;
        DateTime dateTime = DateTime.parse(timestampString);
        String comment = revisions['comment'];
        if (comment.isNotEmpty) {
          articlerevisions.add(ArticleRevision(articleTitle, timestampString,
              dateTime.millisecondsSinceEpoch, comment));
        }
      }
    }
    articlerevisions.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    articlerevisions = articlerevisions.reversed.toList();
  }

  captureWebPages() async {
    Directory rayCaptureDir = FileUtils.raySiteCaptureDir();
    rayCaptureDir.createSync(recursive: true);
    for (final article in pageInfoMap.keys) {
      await Process.run('single-file', [
        CAPTURE_HOST + article,
        FileUtils.join(rayCaptureDir.path, article).path + '.html',
        '--browser-executable-path="/Applications/Google Chrome.app/Contents/MacOS/Google Chrome"'
      ]);
    }
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
    indexWithSidebar =
        indexWithSidebar.replaceAll(TEMPLATE_SIDE_BAR, templateSidebar);
    indexWithSidebar =
        indexWithSidebar.replaceAll(TEMPLATE_FEEDS, feeds.join('\n'));

    File indexOutput = FileUtils.join(siteOutputDir.path, 'index.html');
    indexOutput.writeAsStringSync(indexWithSidebar,
        mode: FileMode.write, flush: true);
  }
}
