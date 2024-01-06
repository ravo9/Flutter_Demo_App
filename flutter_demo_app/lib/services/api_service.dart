import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/article.dart';

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