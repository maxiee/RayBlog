import 'dart:io';

import 'package:dio/dio.dart';
import 'package:html/parser.dart';
import 'package:ray_blog/utils/util_file.dart';

class CaptureDio {
  static Future capturePage(String pageUrl, String savePath) async {
    try {
      print('抓取url $pageUrl');

      // 獲取網頁數據
      var response = await Dio().get(pageUrl);
      var pageStr = response.data.toString();
      print('=========抓取成功page from $pageUrl============');
      //print(response.data.toString());

      // 解析 DOM
      var document = parse(pageStr, encoding: 'utf-8');

      // 獲取所有圖片 URL
      var imgURLList = <String>[];
      var imgNameList = <String>[];
      for (var img in document.getElementsByTagName('img')) {
        print('發現圖片');
        var src = img.attributes['src']!;
        var name = img.attributes['resource']!.split('/').last.replaceAll(':', '');
        print('圖片名稱 $name 原地址 $src');

        print('存入待抓取列表');
        imgURLList.add(src);
        imgNameList.add(name);

        print('原地替換節點');
        img.attributes['src'] = '/img/$name';
      }

      // 抓取圖片
      Directory raySiteOutputDir = FileUtils.raySiteOutputDir();
      File imgDir = FileUtils.join(raySiteOutputDir.path, 'img');
      FileUtils.createDirIfNotExist(imgDir);
      for (var i = 0; i < imgURLList.length; i++) {
        var src = imgURLList[i];
        var name = imgNameList[i];
        var response = await Dio().get('http:' + src, options: Options(
            responseType: ResponseType.bytes
        ));
        try {
          FileUtils.join(imgDir.path, name).writeAsBytesSync(response.data);
        } catch (e) {
          print('圖片下載失敗 $name $src');
          print(e);
        }
      }

      File pageToSave = File(savePath);
      // 輸出的是新 DOM
      pageToSave.writeAsStringSync(document.outerHtml);
    } catch (e) {
      print('出現異常: $pageUrl');
      print(e);
    }
  }
}
