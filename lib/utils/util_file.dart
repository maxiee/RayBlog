import 'dart:io';

import 'package:path/path.dart' as path;

class FileUtils {
  /// 返回桌面平台的家目录
  static String desktopHomePath() {
    String? home = "";
    Map<String, String> envVars = Platform.environment;
    if (Platform.isMacOS) {
      home = envVars['HOME'];
    } else if (Platform.isLinux) {
      home = envVars['HOME'];
    } else if (Platform.isWindows) {
      home = envVars['UserProfile'];
    }
    print('home = $home');
    return home!;
  }

  // 合并两个目录
  static File join(String pathA, String pathB) {
    String fullPath = path.join(pathA, pathB);
    return File(fullPath);
  }

  static void createDirIfNotExist(File file) {
    final dir = Directory(file.path);
    dir.createSync(recursive: true);
  }

  /// 返回 RayBlog 主目录地址
  static File rayBlogDir() {
    String home = desktopHomePath();
    File full = join(home, 'RayBlog');
    return full;
  }
}
