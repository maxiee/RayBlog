import 'dart:io';

import 'package:ray_blog/utils/util_file.dart';

class Generator {
  static String readFileContent(Directory dir, String fileName) {
    File file = FileUtils.join(dir.path, fileName);
    return file.readAsStringSync();
  }

  static generator() {
    // 加载站点目录
    Directory siteDir = FileUtils.raySiteTemplateDir();

    final templateIndex = readFileContent(siteDir, 'index.html');
    print(templateIndex);
  }
}
