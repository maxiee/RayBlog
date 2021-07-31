import 'dart:convert';

import 'package:dio/dio.dart';

class ApiWiki {
  static const API_HOST = 'http://omv.local:9080/api.php';

  final dio = Dio();

  // {pageid: 740, title: BinaryMessenger, pagelanguage: en, pagelanguagehtmlcode: en, touched: 2021-05-08T13:26:13Z, lastrevid: 4007, length: 1523, new: }
  Future<Map<String, dynamic>> getPageInfoByTitle(String title) async {
    final response = await dio.get(API_HOST, queryParameters: {
      'action': 'query',
      'prop': 'info',
      'titles': title,
      'format': 'json'
    });
    Map<String, dynamic> ret = jsonDecode(response.toString());
    Map<String, dynamic> pages = ret['query']['pages'] as Map<String, dynamic>;
    return pages[pages.keys.first];
  }

  int getPageIdFromPageInfo(Map<String, dynamic> pageInfo) {
    return pageInfo['pageid'];
  }

  /// [{revid: 4007, parentid: 0, user: Maxiee, timestamp: 2021-05-08T13:21:12Z, comment: Created page with "== Java 接口 == 声明在 engine/shell/platform/android/io/flutter/plugin/common/BinaryMessenger.java。  接口注释：  Facility for communicating with Flutter using asyn..."}]
  Future<List<Map<String, dynamic>>> getPageRevisions(String title) async {
    final response = await dio.get(API_HOST, queryParameters: {
      'action': 'query',
      'prop': 'revisions',
      'titles': title,
      'rvlimit': 500,
      'format': 'json'
    });
    Map<String, dynamic> ret = jsonDecode(response.toString());
    Map<String, dynamic> pages = ret['query']['pages'] as Map<String, dynamic>;
    List<dynamic> revisions = pages[pages.keys.first]['revisions'];
    return revisions.map((e) => e as Map<String, dynamic>).toList();
  }
}
