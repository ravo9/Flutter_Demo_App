import 'package:flutter/material.dart';
import 'models/article.dart';
import 'services/api_service.dart';
import 'package:url_launcher/url_launcher.dart';

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
        appBarTheme: const AppBarTheme(
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
                    onTap: () async {
                      try {
                        if (await canLaunch(article.url)) {
                          await launch(article.url);
                        } else {
                          // This will run if the URL is invalid
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text('Invalid URL'),
                          ));
                        }
                      } catch (e) {
                        // This will run if there's an error in launching the URL
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error: $e'),
                        ));
                      }
                    },
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
