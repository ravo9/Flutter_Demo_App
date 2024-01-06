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
      title: 'Reddit #wallstreetbets App',
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.blueGrey[50] ?? Colors.blueGrey, // Lighter shade for app bar, with fallback
          onPrimary: Colors.black, // Black text/icon color on app bar
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white, // White app bar
          titleTextStyle: TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.black87),
        ),
        cardTheme: CardTheme(
          color: Colors.white, // White cards
          shadowColor: Colors.grey.withOpacity(0.2), // Soft shadow
          elevation: 2,
        ),
        textTheme: TextTheme(
          titleMedium: TextStyle(color: Colors.black, fontSize: 16), // Refined typography
        ),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Reddit #wallstreetbets App'),
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
  late Future<List<Article>> futureArticles;

  @override
  void initState() {
    super.initState();
    futureArticles = fetchArticles();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.title),
      ),
      body: FutureBuilder<List<Article>>(
        future: futureArticles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView.builder(
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                Article article = snapshot.data![index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 2,
                  child: ListTile(
                    title: Text(article.title, style: Theme.of(context).textTheme.titleMedium),
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(article.imageUrl),
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return Center(child: Text("${snapshot.error}"));
          }
          return Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
