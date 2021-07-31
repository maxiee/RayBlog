import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:ray_blog/data/database.dart';
import 'package:ray_blog/utils/util_file.dart';

const TEMPLATE_SIDE_BAR = '\$SIDE_BAR';

class Generator {
  static String readFileContent(Directory dir, String fileName) {
    File file = FileUtils.join(dir.path, fileName);
    return file.readAsStringSync();
  }

  late final String templateIndex; // 首页模板
  late final String templateSidebar; // 侧边栏模板
  late final Directory siteOutputDir;

  Generator() {
    // 加载站点目录
    Directory siteDir = FileUtils.raySiteTemplateDir();
    siteOutputDir = FileUtils.raySiteOutputDir();

    FileUtils.createDirIfNotExist(File(siteOutputDir.path));
    templateIndex = readFileContent(siteDir, 'index.html');

    templateSidebar = readFileContent(siteDir, 'sidebar.html');

    print('模板加载完毕');
  }

  generate() async {
    await collectArticles();
    await generateIndex();
  }

  ///  收集文章信息
  collectArticles() async {
    for (final article in GetIt.I.get<Database>().boxArticle.values) {}
  }

  /// 生成首页
  generateIndex() async {
    String indexWithSidebar =
        templateIndex.replaceAll(TEMPLATE_SIDE_BAR, templateSidebar);

    File indexOutput = FileUtils.join(siteOutputDir.path, 'index.html');
    indexOutput.writeAsStringSync(indexWithSidebar,
        mode: FileMode.write, flush: true);
  }
}
