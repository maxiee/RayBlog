import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:ray_blog/article/function/func_dialog_add_article.dart';
import 'package:ray_blog/data/database.dart';
import 'package:ray_blog/page/article/page_article_management.dart';

import 'generator/generator.dart';
import 'net/api_wiki.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage() : super();

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController thoughtInputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    GetIt.I.registerSingleton(Database());
    GetIt.I.registerSingleton(ApiWiki());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('RayBlog')),
      body: Column(
        children: [
          TextField(
            decoration: const InputDecoration(hintText: '有什么新鲜事想分享？'),
            controller: thoughtInputController,
            minLines: 5,
            maxLines: 5,
          ),
          Row(
            children: [
              const TextButton(onPressed: null, child: Text('插入图片')),
              Expanded(child: Container()),
              const Checkbox(value: false, onChanged: null),
              const Text('同时更新站点'),
              const SizedBox(width: 20),
              const Text('发布平台'),
              DropdownButton(items: []),
              const SizedBox(width: 20),
              const OutlinedButton(onPressed: null, child: Text('发送'))
            ],
          ),
          const SizedBox(height: 40),
          Wrap(children: [
            MaterialButton(
                onPressed: () => addArticle(context),
                child: const Text('添加文章')),
            MaterialButton(
                onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => const PageArticleManagement())),
                child: const Text('文章管理')),
            const MaterialButton(onPressed: null, child: Text('感想管理')),
            MaterialButton(
                onPressed: () => Generator().generate(),
                child: const Text('生成站点')),
            const MaterialButton(onPressed: null, child: Text('提交站点')),
            const MaterialButton(onPressed: null, child: Text('本地预览')),
            const MaterialButton(onPressed: null, child: Text('设置')),
          ])
        ],
      ),
    );
  }
}
