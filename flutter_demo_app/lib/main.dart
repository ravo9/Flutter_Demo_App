import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo App'),
    );
  }
}

class Article {
  final String title;
  final String imageUrl;

  Article({required this.title, required this.imageUrl});

  factory Article.fromJson(Map<String, dynamic> json) {
    return Article(
      title: json['data']['title'] as String,
      imageUrl: json['data']['thumbnail'] as String,
    );
  }
}

Future<List<Article>> fetchArticles() async {
  final endpoint = 'https://www.reddit.com/r/Wallstreetbets/top.json?limit=10&t=year';
  final response = await http.get(Uri.parse(endpoint));

  if (response.statusCode == 200) {
    List<dynamic> children = json.decode(response.body)['data']['children'];
    return children.map((data) => Article.fromJson(data)).toList();
  } else {
    throw Exception('Failed to load articles');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final List<String> _listItems = ['Item 1', 'Item 2', 'Item 3'];
  late Future<List<Article>> futureArticles;

  void _incrementCounter() {
    setState(() {
      _listItems.add("Item ${(_listItems.length + 1)}");
    });
  }

  @override
  void initState() {
    super.initState();
    futureArticles = fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Click to add more news to the list:',
            ),
            Text(
              '${_listItems.length}',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            Expanded(
              child: FutureBuilder<List<Article>>(
                future: futureArticles,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data!.length,
                      itemBuilder: (context, index) {
                        Article article = snapshot.data![index];
                        return ListTile(
                          title: Text(article.title),
                          leading: Image.network(article.imageUrl),
                        );
                      },
                    );
                  } else if (snapshot.hasError) {
                    return Text("${snapshot.error}");
                  }
                  return CircularProgressIndicator();
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
