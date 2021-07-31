import 'dart:convert';

import 'package:dio/dio.dart';

class ApiWiki {
  static const API_HOST = 'http://omv.local:9080/api.php';

  final dio = Dio();

  Future<Map<String, dynamic>> getPageInfo(String title) async {
    final response = await dio.get(API_HOST, queryParameters: {
      'action': 'query',
      'prop': 'info',
      'titles': title,
      'format': 'json'
    });
    return jsonDecode(response.toString());
  }

  int getPageIdFromPageInfo(Map<String, dynamic> pageInfo) {
    Map<String, dynamic> pages =
        pageInfo['query']['pages'] as Map<String, dynamic>;
    Map<String, dynamic> realPageInfo = pages[pages.keys.first];
    return realPageInfo['pageid'];
  }
}
