import 'package:html/dom.dart';
import 'package:html/parser.dart';

class ParserWebPage {
  static String parseWebPage(String rawHtml, String titleString) {
    var document = parse(rawHtml, encoding: 'utf-8');
    // 定位正文
    final doctypeHtml = document.children[0];

    // 从 HTML 里面把 CSS 留下来
    final head = doctypeHtml.children[0];
    Node? style;
    for (final node in head.children) {
      if (node.localName == 'style') {
        style = node;
        break;
      }
    }

    final body = doctypeHtml.children[1];

    // 去掉非空段落
    List<Element> nonEmptySections = [];
    for (final section in body.children) {
      if (section.children.isNotEmpty) {
        nonEmptySections.add(section);
      }
    }

    // 生成新的树
    Element div = Element.tag('div');
    if (style != null) div.append(style);

    Element title = Element.tag('h1');
    title.text = titleString;
    div.append(title);

    for (final section in nonEmptySections) {
      div.append(section);
    }
    print(div.outerHtml);
    return div.outerHtml;
  }
}