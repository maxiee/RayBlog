import 'dart:convert';

import 'package:dio/dio.dart';

class ApiWiki {
  static const API_HOST = 'http://omv.local:9080/api.php';

  final dio = Dio();

  // {pageid: 740, title: BinaryMessenger, pagelanguage: en, pagelanguagehtmlcode: en, touched: 2021-05-08T13:26:13Z, lastrevid: 4007, length: 1523, new: }
  Future<Map<String, dynamic>> getPageInfo(String title) async {
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
}
