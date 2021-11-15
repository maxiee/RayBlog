import 'package:get_it/get_it.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:ray_blog/config/environment_variables.dart';

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

    bool containsMath = false;
    for (final element in nonEmptySections) {
      if (element.outerHtml.contains('[math]')) {
        containsMath = true;
        break;
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

    if (containsMath) {
      Element mathJaxInit = Element.tag('script');
      mathJaxInit.text = '''
        MathJax = {
          tex: {
            inlineMath: [['[math]', '[/math]'], ]
          }
        };
      ''';
      div.append(mathJaxInit);

      Element mathJaxLink = Element.tag('script');
      mathJaxLink.attributes.putIfAbsent('src',
          () => "https://cdn.jsdelivr.net/npm/mathjax@3/es5/tex-mml-chtml.js");
      div.append(mathJaxLink);
    }

    String output = div.outerHtml;
    // hacks
    // 干掉透明度小于 0.5 的节点
    output = output.replaceAll('opacity:.5', '');
    output = output.replaceAll(
        GetIt.I.get<EnvironmentVariableStore>().rayBlogReplaceHost!, '');
    return output;
  }
}
